#include "notystore.h"

#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QRandomGenerator>
#include <QSqlError>
#include <QSqlQuery>
#include <QStandardPaths>
#include <QTimeZone>
#include <QUuid>

#include <algorithm>
#include <utility>

#include <openssl/evp.h>
#include <openssl/rand.h>

namespace {
constexpr int kKeySize = 32;
constexpr int kNonceSize = 12;
constexpr int kTagSize = 16;
constexpr int kPaletteSize = 8;

/** @brief Returns the directory that holds this user's local Noty state. */
QString supportPath()
{
    return QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation);
}

/** @brief Builds a detailed local-storage diagnostic suitable for the UI. */
QString databaseError(const QSqlDatabase &database, const QString &operation)
{
    return QStringLiteral("%1: %2").arg(operation, database.lastError().text());
}
} // namespace

NotyStore::NotyStore(QObject *parent)
    : QObject(parent)
    , m_connectionName(QStringLiteral("noty-store-%1").arg(QUuid::createUuid().toString(QUuid::WithoutBraces)))
{
    if (!initialize() || !load()) {
        return;
    }

    if (m_notes.isEmpty()) {
        create(tr("Welcome to Noty\n\nMove the pointer to the right edge to open your notes.\n\nUse Meta+Alt+N for a new note and Meta+Shift+Space for quick capture."));
    }
}

NotyStore::~NotyStore()
{
    const QString connection = m_connectionName;
    m_database.close();
    m_database = {};
    QSqlDatabase::removeDatabase(connection);
}

QVariantList NotyStore::activeNotes() const
{
    return asVariantList(false, false);
}

QVariantList NotyStore::archivedNotes() const
{
    return asVariantList(true, false);
}

QVariantList NotyStore::allNotes() const
{
    return asVariantList(false, true);
}

QString NotyStore::create(const QString &body)
{
    NoteRecord note;
    note.id = QUuid::createUuid().toString(QUuid::WithoutBraces);
    note.body = body;
    note.title = derivedTitle(body);
    note.color = m_notes.size() % kPaletteSize;
    note.created = QDateTime::currentDateTimeUtc();
    note.modified = note.created;
    note.order = m_notes.isEmpty() ? 0.0 : m_notes.constFirst().order - 1.0;

    if (!upsert(note)) {
        return {};
    }
    m_notes.prepend(note);
    emit notesChanged();
    return note.id;
}

bool NotyStore::updateBody(const QString &id, const QString &body)
{
    NoteRecord *note = find(id);
    if (!note || note->body == body) {
        return note != nullptr;
    }
    note->body = body;
    note->title = derivedTitle(body);
    note->modified = QDateTime::currentDateTimeUtc();
    if (!upsert(*note)) {
        return false;
    }
    emit notesChanged();
    return true;
}

bool NotyStore::setArchived(const QString &id, const bool archived)
{
    NoteRecord *note = find(id);
    if (!note) {
        return false;
    }
    note->archived = archived;
    note->modified = QDateTime::currentDateTimeUtc();
    if (!archived) {
        double minimum = 0.0;
        for (const NoteRecord &candidate : std::as_const(m_notes)) {
            if (!candidate.archived) {
                minimum = qMin(minimum, candidate.order);
            }
        }
        note->order = minimum - 1.0;
    }
    if (!upsert(*note)) {
        return false;
    }
    emit notesChanged();
    return true;
}

bool NotyStore::togglePinned(const QString &id)
{
    NoteRecord *note = find(id);
    if (!note) {
        return false;
    }
    note->pinned = !note->pinned;
    note->modified = QDateTime::currentDateTimeUtc();
    if (!upsert(*note)) {
        return false;
    }
    emit notesChanged();
    return true;
}

bool NotyStore::cycleColor(const QString &id)
{
    NoteRecord *note = find(id);
    if (!note) {
        return false;
    }
    note->color = (note->color + 1) % kPaletteSize;
    note->modified = QDateTime::currentDateTimeUtc();
    if (!upsert(*note)) {
        return false;
    }
    emit notesChanged();
    return true;
}

bool NotyStore::remove(const QString &id)
{
    QSqlQuery query(m_database);
    query.prepare(QStringLiteral("DELETE FROM notes WHERE id = ?"));
    query.addBindValue(id);
    if (!query.exec()) {
        emit storageError(databaseError(m_database, tr("Could not delete note")));
        return false;
    }
    const auto iterator = std::find_if(m_notes.begin(), m_notes.end(), [&id](const NoteRecord &note) { return note.id == id; });
    if (iterator == m_notes.end()) {
        return false;
    }
    m_notes.erase(iterator);
    emit notesChanged();
    return true;
}

bool NotyStore::initialize()
{
    const QString path = supportPath();
    if (!QDir().mkpath(path) || !loadOrCreateKey()) {
        return false;
    }
    m_database = QSqlDatabase::addDatabase(QStringLiteral("QSQLITE"), m_connectionName);
    m_database.setDatabaseName(path + QStringLiteral("/notes.db"));
    if (!m_database.open()) {
        emit storageError(databaseError(m_database, tr("Could not open notes database")));
        return false;
    }
    QSqlQuery query(m_database);
    if (!query.exec(QStringLiteral("PRAGMA journal_mode=WAL"))
        || !query.exec(QStringLiteral("PRAGMA synchronous=NORMAL"))
        || !query.exec(QStringLiteral("CREATE TABLE IF NOT EXISTS notes ("
                                      "id TEXT PRIMARY KEY, title TEXT NOT NULL DEFAULT '', body BLOB NOT NULL, "
                                      "color INTEGER NOT NULL DEFAULT 0, created INTEGER NOT NULL, modified INTEGER NOT NULL, "
                                      "archived INTEGER NOT NULL DEFAULT 0, sort_order REAL NOT NULL DEFAULT 0, "
                                      "pinned INTEGER NOT NULL DEFAULT 0)"))
        || !query.exec(QStringLiteral("CREATE INDEX IF NOT EXISTS idx_notes_archived ON notes(archived, sort_order)"))) {
        emit storageError(databaseError(m_database, tr("Could not initialize notes database")));
        return false;
    }
    return true;
}

bool NotyStore::load()
{
    QSqlQuery query(m_database);
    if (!query.exec(QStringLiteral("SELECT id, title, body, color, created, modified, archived, sort_order, pinned "
                                   "FROM notes ORDER BY sort_order ASC"))) {
        emit storageError(databaseError(m_database, tr("Could not load notes")));
        return false;
    }
    while (query.next()) {
        NoteRecord note;
        note.id = query.value(0).toString();
        note.title = query.value(1).toString();
        note.body = open(query.value(2).toByteArray());
        note.color = query.value(3).toInt();
        note.created = QDateTime::fromMSecsSinceEpoch(query.value(4).toLongLong(), QTimeZone::UTC);
        note.modified = QDateTime::fromMSecsSinceEpoch(query.value(5).toLongLong(), QTimeZone::UTC);
        note.archived = query.value(6).toBool();
        note.order = query.value(7).toDouble();
        note.pinned = query.value(8).toBool();
        m_notes.append(note);
    }
    return true;
}

bool NotyStore::upsert(const NoteRecord &note)
{
    const QByteArray body = seal(note.body);
    if (body.isEmpty() && !note.body.isEmpty()) {
        emit storageError(tr("Could not encrypt note body"));
        return false;
    }
    QSqlQuery query(m_database);
    query.prepare(QStringLiteral("INSERT INTO notes (id,title,body,color,created,modified,archived,sort_order,pinned) "
                                 "VALUES (?,?,?,?,?,?,?,?,?) ON CONFLICT(id) DO UPDATE SET "
                                 "title=excluded.title,body=excluded.body,color=excluded.color,modified=excluded.modified,"
                                 "archived=excluded.archived,sort_order=excluded.sort_order,pinned=excluded.pinned"));
    query.addBindValue(note.id);
    query.addBindValue(note.title);
    query.addBindValue(body);
    query.addBindValue(note.color);
    query.addBindValue(note.created.toMSecsSinceEpoch());
    query.addBindValue(note.modified.toMSecsSinceEpoch());
    query.addBindValue(note.archived);
    query.addBindValue(note.order);
    query.addBindValue(note.pinned);
    if (!query.exec()) {
        emit storageError(databaseError(m_database, tr("Could not save note")));
        return false;
    }
    return true;
}

QVariantList NotyStore::asVariantList(const bool archivedOnly, const bool includeAll) const
{
    QVector<NoteRecord> filtered;
    for (const NoteRecord &note : m_notes) {
        if (includeAll || note.archived == archivedOnly) {
            filtered.append(note);
        }
    }
    std::sort(filtered.begin(), filtered.end(), [archivedOnly](const NoteRecord &left, const NoteRecord &right) {
        return archivedOnly ? left.modified > right.modified : left.order < right.order;
    });
    QVariantList result;
    for (const NoteRecord &note : std::as_const(filtered)) {
        result.append(QVariantMap{{QStringLiteral("id"), note.id}, {QStringLiteral("title"), note.title},
                                  {QStringLiteral("body"), note.body}, {QStringLiteral("color"), note.color},
                                  {QStringLiteral("archived"), note.archived}, {QStringLiteral("pinned"), note.pinned}});
    }
    return result;
}

QByteArray NotyStore::seal(const QString &plain) const
{
    QByteArray nonce(kNonceSize, Qt::Uninitialized);
    if (RAND_bytes(reinterpret_cast<unsigned char *>(nonce.data()), nonce.size()) != 1) {
        return {};
    }
    const QByteArray input = plain.toUtf8();
    QByteArray ciphertext(input.size() + EVP_MAX_BLOCK_LENGTH, Qt::Uninitialized);
    QByteArray tag(kTagSize, Qt::Uninitialized);
    EVP_CIPHER_CTX *context = EVP_CIPHER_CTX_new();
    int size = 0;
    int total = 0;
    const bool ok = context && EVP_EncryptInit_ex(context, EVP_aes_256_gcm(), nullptr, nullptr, nullptr) == 1
        && EVP_CIPHER_CTX_ctrl(context, EVP_CTRL_GCM_SET_IVLEN, nonce.size(), nullptr) == 1
        && EVP_EncryptInit_ex(context, nullptr, nullptr, reinterpret_cast<const unsigned char *>(m_key.constData()), reinterpret_cast<const unsigned char *>(nonce.constData())) == 1
        && EVP_EncryptUpdate(context, reinterpret_cast<unsigned char *>(ciphertext.data()), &size, reinterpret_cast<const unsigned char *>(input.constData()), input.size()) == 1
        && ((total = size), EVP_EncryptFinal_ex(context, reinterpret_cast<unsigned char *>(ciphertext.data()) + total, &size) == 1)
        && ((total += size), EVP_CIPHER_CTX_ctrl(context, EVP_CTRL_GCM_GET_TAG, tag.size(), tag.data()) == 1);
    EVP_CIPHER_CTX_free(context);
    if (!ok) {
        return {};
    }
    ciphertext.truncate(total);
    return nonce + ciphertext + tag;
}

QString NotyStore::open(const QByteArray &sealed) const
{
    if (sealed.size() < kNonceSize + kTagSize) {
        return {};
    }
    const QByteArray nonce = sealed.left(kNonceSize);
    const QByteArray tag = sealed.right(kTagSize);
    const QByteArray input = sealed.mid(kNonceSize, sealed.size() - kNonceSize - kTagSize);
    QByteArray plain(input.size(), Qt::Uninitialized);
    EVP_CIPHER_CTX *context = EVP_CIPHER_CTX_new();
    int size = 0;
    int total = 0;
    const bool ok = context && EVP_DecryptInit_ex(context, EVP_aes_256_gcm(), nullptr, nullptr, nullptr) == 1
        && EVP_CIPHER_CTX_ctrl(context, EVP_CTRL_GCM_SET_IVLEN, nonce.size(), nullptr) == 1
        && EVP_DecryptInit_ex(context, nullptr, nullptr, reinterpret_cast<const unsigned char *>(m_key.constData()), reinterpret_cast<const unsigned char *>(nonce.constData())) == 1
        && EVP_DecryptUpdate(context, reinterpret_cast<unsigned char *>(plain.data()), &size, reinterpret_cast<const unsigned char *>(input.constData()), input.size()) == 1
        && ((total = size), EVP_CIPHER_CTX_ctrl(context, EVP_CTRL_GCM_SET_TAG, tag.size(), const_cast<char *>(tag.constData())) == 1)
        && EVP_DecryptFinal_ex(context, reinterpret_cast<unsigned char *>(plain.data()) + total, &size) == 1;
    EVP_CIPHER_CTX_free(context);
    if (!ok) {
        return {};
    }
    plain.truncate(total + size);
    return QString::fromUtf8(plain);
}

bool NotyStore::loadOrCreateKey()
{
    const QString filename = supportPath() + QStringLiteral("/note.key");
    QFile keyFile(filename);
    if (keyFile.exists()) {
        if (!keyFile.open(QIODevice::ReadOnly) || (m_key = keyFile.readAll()).size() != kKeySize) {
            emit storageError(tr("Could not read a valid note encryption key"));
            return false;
        }
        return true;
    }
    m_key.resize(kKeySize);
    if (RAND_bytes(reinterpret_cast<unsigned char *>(m_key.data()), m_key.size()) != 1 || !keyFile.open(QIODevice::WriteOnly | QIODevice::NewOnly)) {
        emit storageError(tr("Could not create note encryption key"));
        return false;
    }
    keyFile.setPermissions(QFileDevice::ReadOwner | QFileDevice::WriteOwner);
    if (keyFile.write(m_key) != m_key.size()) {
        emit storageError(tr("Could not write note encryption key"));
        return false;
    }
    return true;
}

NoteRecord *NotyStore::find(const QString &id)
{
    const auto iterator = std::find_if(m_notes.begin(), m_notes.end(), [&id](const NoteRecord &note) { return note.id == id; });
    return iterator == m_notes.end() ? nullptr : &*iterator;
}

QString NotyStore::derivedTitle(const QString &body)
{
    for (const QString &line : body.split(u'\n')) {
        const QString title = line.trimmed();
        if (!title.isEmpty()) {
            return title.left(72);
        }
    }
    return QObject::tr("Untitled note");
}
