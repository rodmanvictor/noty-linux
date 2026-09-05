import QtQuick

import org.kde.plasma.configuration

/**
 * @brief Declares the pages shown by Plasma's Configure Noty dialog.
 *
 * The configuration framework persists properties named `cfg_<entry>` in each
 * page to the matching KConfig entry from `contents/config/main.xml`.
 */
ConfigModel {
    ConfigCategory {
        name: "Appearance"
        icon: "preferences-desktop-color"
        source: "configGeneral.qml"
    }
}
