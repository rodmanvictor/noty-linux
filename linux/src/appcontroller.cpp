#include "appcontroller.h"

#include <QAction>
#include <QApplication>
#include <QIcon>
#include <QKeySequence>
#include <QMenu>
#include <QSystemTrayIcon>

#include <KGlobalAccel>

namespace {
/** @brief Registers one user-visible action with KDE GlobalAccel. */
QAction *registerGlobal(QObject *owner, const QString &name, const QString &label, const QKeySequence &shortcut)
{
    auto *action = new QAction(label, owner);
    action->setObjectName(name);
    KGlobalAccel::self()->setDefaultShortcut(action, {shortcut});
    KGlobalAccel::self()->setShortcut(action, {shortcut}, KGlobalAccel::Autoloading);
    return action;
}
} // namespace

AppController::AppController(QObject *parent)
    : QObject(parent)
{
    auto *newNote = registerGlobal(this, QStringLiteral("new-note"), tr("New note"), QKeySequence(QStringLiteral("Meta+Alt+N")));
    auto *quickCapture = registerGlobal(this, QStringLiteral("quick-capture"), tr("Quick capture"), QKeySequence(QStringLiteral("Meta+Shift+Space")));
    auto *allNotes = registerGlobal(this, QStringLiteral("all-notes"), tr("All notes"), QKeySequence(QStringLiteral("Meta+Alt+A")));
    auto *archive = registerGlobal(this, QStringLiteral("archive"), tr("Archive"), QKeySequence(QStringLiteral("Meta+Alt+L")));
    connect(newNote, &QAction::triggered, this, &AppController::newNoteRequested);
    connect(quickCapture, &QAction::triggered, this, &AppController::quickCaptureRequested);
    connect(allNotes, &QAction::triggered, this, &AppController::allNotesRequested);
    connect(archive, &QAction::triggered, this, &AppController::archiveRequested);

    auto *tray = new QSystemTrayIcon(QIcon(QStringLiteral(":/linux/resources/noty.svg")), this);
    auto *menu = new QMenu;
    menu->QObject::setParent(this);
    menu->addAction(newNote);
    menu->addAction(quickCapture);
    menu->addSeparator();
    menu->addAction(allNotes);
    menu->addAction(archive);
    menu->addSeparator();
    auto *quit = menu->addAction(tr("Quit Noty"));
    connect(quit, &QAction::triggered, this, &AppController::quitRequested);
    tray->setContextMenu(menu);
    tray->setToolTip(tr("Noty — sticky notes at the screen edge"));
    tray->show();
}
