#include "appcontroller.h"
#include "notystore.h"

#include <QApplication>
#include <QFileInfo>
#include <QLibraryInfo>
#include <QQuickWindow>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QScreen>
#include <QTimer>

/**
 * @brief Chooses XWayland when Plasma Wayland would reject requested geometry.
 *
 * @details KWin centers ordinary Wayland toplevels because the protocol does
 * not let a client fix their coordinates. The edge deck requires exact window
 * placement, so the Qt XCB platform is selected only when it is installed and
 * the caller has not explicitly chosen another Qt platform.
 * @sideeffect Sets QT_QPA_PLATFORM before QApplication initializes QPA.
 */
static void configurePlatformForEdgeDeck()
{
    const QString xcbPlugin = QLibraryInfo::path(QLibraryInfo::PluginsPath) + QStringLiteral("/platforms/libqxcb.so");
    if (qEnvironmentVariable("XDG_SESSION_TYPE") == QStringLiteral("wayland")
        && qEnvironmentVariableIsEmpty("QT_QPA_PLATFORM")
        && QFileInfo::exists(xcbPlugin)) {
        qputenv("QT_QPA_PLATFORM", "xcb");
    }
}

/**
 * @brief Pins an already-created deck window to the right edge of its screen.
 * @param window The root Qt Quick window, which must have a valid QScreen.
 * @sideeffect Updates the native XWayland window position.
 *
 * QML's screen attached property can be unavailable during its first binding
 * evaluation. Positioning after the native QWindow exists avoids an accidental
 * `(0, 0)` placement and uses the screen's real available geometry.
 */
static void pinToScreenEdge(QQuickWindow *window)
{
    QScreen *screen = window->screen();
    if (!screen) {
        return;
    }
    const QRect available = screen->availableGeometry();
    const int x = available.x() + available.width() - window->width();
    const int y = available.y() + qMax(56, qRound((available.height() - window->height()) * 0.34));
    window->setPosition(x, y);

}

/**
 * @brief Defers edge positioning until KWin has applied the latest resize.
 * @param window Root window to re-pin after a geometry or screen transition.
 * @sideeffect Schedules a short-lived event-loop callback tied to @p window.
 */
static void scheduleEdgePin(QQuickWindow *window)
{
    QTimer::singleShot(40, window, [window] { pinToScreenEdge(window); });
    QTimer::singleShot(140, window, [window] { pinToScreenEdge(window); });
    // KWin creates the visible XWayland toplevel after Qt's initial helper
    // window, so run once more after the WM_CLASS-bearing window exists.
    QTimer::singleShot(800, window, [window] { pinToScreenEdge(window); });
}

/**
 * @brief Starts the KDE/Qt port of Noty.
 * @param argc Command-line argument count supplied by the operating system.
 * @param argv Command-line argument vector supplied by the operating system.
 * @return Qt event-loop exit status.
 * @sideeffect Creates the encrypted local note store and registers global KDE shortcuts.
 */
int main(int argc, char *argv[])
{
    configurePlatformForEdgeDeck();
    QApplication application(argc, argv);
    application.setApplicationName(QStringLiteral("Noty"));
    application.setOrganizationName(QStringLiteral("Noty"));
    application.setQuitOnLastWindowClosed(false);

    NotyStore store;
    AppController controller;
    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty(QStringLiteral("store"), &store);
    engine.rootContext()->setContextProperty(QStringLiteral("appController"), &controller);
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed, &application, [] { QCoreApplication::exit(1); }, Qt::QueuedConnection);
    engine.loadFromModule(QStringLiteral("Noty"), QStringLiteral("Main"));
    if (engine.rootObjects().isEmpty()) {
        return 1;
    }
    auto *window = qobject_cast<QQuickWindow *>(engine.rootObjects().constFirst());
    if (window) {
        QObject::connect(window, &QWindow::widthChanged, window, [window] { scheduleEdgePin(window); });
        QObject::connect(window, &QWindow::heightChanged, window, [window] { scheduleEdgePin(window); });
        QObject::connect(window, &QWindow::screenChanged, window, [window] { scheduleEdgePin(window); });
        scheduleEdgePin(window);
    }
    return application.exec();
}
