#pragma once

#include <QObject>

/**
 * @brief Routes KDE global shortcuts and tray actions into the QML shell.
 *
 * The controller owns no note data.  It emits intent-only signals so QML can
 * decide whether to display the edge deck, capture box, or library window.
 */
class AppController final : public QObject {
    Q_OBJECT

public:
    /** @brief Registers tray menu actions and KDE GlobalAccel shortcuts. */
    explicit AppController(QObject *parent = nullptr);

signals:
    /** @brief Requests a new full-size note. */
    void newNoteRequested();

    /** @brief Requests the quick-capture input. */
    void quickCaptureRequested();

    /** @brief Requests the searchable All Notes dialog. */
    void allNotesRequested();

    /** @brief Requests the archive dialog. */
    void archiveRequested();

    /** @brief Requests application shutdown from the tray menu. */
    void quitRequested();
};
