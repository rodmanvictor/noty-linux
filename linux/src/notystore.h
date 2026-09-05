#pragma once

#include <QObject>
#include <QDateTime>
#include <QSqlDatabase>
#include <QVariantList>

/**
 * @brief Owns one sticky note and its persisted attributes.
 *
 * Bodies are encrypted before being handed to SQLite.  Titles, timestamps and
 * colours intentionally remain queryable so the edge deck can render quickly.
 */
struct NoteRecord {
    QString id;
    QString title;
    QString body;
    int color = 0;
    QDateTime created;
    QDateTime modified;
    bool archived = false;
    bool pinned = false;
    double order = 0;
};

/**
 * @brief SQLite-backed note model exposed to QML.
 *
 * @details The model is the only writer to the local database at
 * `~/.local/share/noty/notes.db`. Note bodies are AES-256-GCM encrypted using
 * a user-only 32-byte key stored beside the database. Every mutator emits
 * notesChanged so all visible views receive the same data.
 */
class NotyStore final : public QObject {
    Q_OBJECT
    Q_PROPERTY(QVariantList activeNotes READ activeNotes NOTIFY notesChanged)
    Q_PROPERTY(QVariantList archivedNotes READ archivedNotes NOTIFY notesChanged)
    Q_PROPERTY(QVariantList allNotes READ allNotes NOTIFY notesChanged)

public:
    /** @brief Opens or creates the local database and loads the note state. */
    explicit NotyStore(QObject *parent = nullptr);

    /** @brief Closes the database connection after all pending writes finish. */
    ~NotyStore() override;

    /** @brief Returns non-archived notes in deck order for QML. */
    [[nodiscard]] QVariantList activeNotes() const;

    /** @brief Returns archived notes, newest modified first, for QML. */
    [[nodiscard]] QVariantList archivedNotes() const;

    /** @brief Returns every note in its current order for library search. */
    [[nodiscard]] QVariantList allNotes() const;

    /**
     * @brief Creates a note at the top of the deck.
     * @param body Initial plain-text content.
     * @return New note identifier, or an empty string after a storage failure.
     */
    Q_INVOKABLE QString create(const QString &body = QString());

    /**
     * @brief Replaces a note body and derives its deck title.
     * @param id Note identifier.
     * @param body New plain-text body.
     * @return True when a matching note was saved.
     */
    Q_INVOKABLE bool updateBody(const QString &id, const QString &body);

    /** @brief Moves a note into or out of the archive without deleting it. */
    Q_INVOKABLE bool setArchived(const QString &id, bool archived);

    /** @brief Toggles the persisted pin used by the deck UI. */
    Q_INVOKABLE bool togglePinned(const QString &id);

    /** @brief Cycles through the shared eight-colour palette. */
    Q_INVOKABLE bool cycleColor(const QString &id);

    /** @brief Permanently removes a note from local storage. */
    Q_INVOKABLE bool remove(const QString &id);

signals:
    /** @brief Emitted after any mutation visible to a QML note list. */
    void notesChanged();

    /** @brief Emitted if local storage cannot be initialized or written. */
    void storageError(const QString &message);

private:
    /** @brief Creates the schema and applies additive migrations. */
    bool initialize();

    /** @brief Reads all records, decrypting bodies before exposing them. */
    bool load();

    /** @brief Encrypts and inserts or updates a complete record. */
    bool upsert(const NoteRecord &note);

    /** @brief Converts records into a QML-friendly map list. */
    [[nodiscard]] QVariantList asVariantList(bool archivedOnly, bool includeAll) const;

    /** @brief Encrypts plaintext as nonce + ciphertext + GCM tag. */
    [[nodiscard]] QByteArray seal(const QString &plain) const;

    /** @brief Decrypts nonce + ciphertext + GCM tag, returning empty on failure. */
    [[nodiscard]] QString open(const QByteArray &sealed) const;

    /** @brief Loads or securely creates the per-user AES key. */
    [[nodiscard]] bool loadOrCreateKey();

    /** @brief Finds a mutable note by primary key. */
    NoteRecord *find(const QString &id);

    /** @brief Derives the first meaningful line for a compact deck label. */
    [[nodiscard]] static QString derivedTitle(const QString &body);

    QSqlDatabase m_database;
    QVector<NoteRecord> m_notes;
    QByteArray m_key;
    QString m_connectionName;
};
