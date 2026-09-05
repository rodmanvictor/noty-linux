cmake_minimum_required(VERSION 3.21)

project(NotyLinux VERSION 0.1.0 LANGUAGES CXX)

include(GNUInstallDirs)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

find_package(Qt6 6.8 REQUIRED COMPONENTS Core Gui Qml Quick QuickControls2 Sql Widgets)
find_package(KF6GlobalAccel REQUIRED)
find_package(OpenSSL REQUIRED)

qt_standard_project_setup(REQUIRES 6.8)

qt_add_executable(noty
    linux/src/main.cpp
    linux/src/notystore.cpp
    linux/src/notystore.h
    linux/src/appcontroller.cpp
    linux/src/appcontroller.h
)

qt_add_qml_module(noty
    URI Noty
    VERSION 1.0
    QML_FILES
        linux/qml/Main.qml
)

qt_add_resources(noty "noty_assets"
    PREFIX "/"
    FILES linux/resources/noty.svg
)

target_link_libraries(noty PRIVATE
    Qt6::Core Qt6::Gui Qt6::Qml Qt6::Quick Qt6::QuickControls2 Qt6::Sql Qt6::Widgets
    KF6::GlobalAccel
    OpenSSL::Crypto
)

install(TARGETS noty RUNTIME DESTINATION bin)
configure_file(linux/noty.desktop.in noty.desktop @ONLY)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/noty.desktop DESTINATION ${CMAKE_INSTALL_DATADIR}/applications)
install(FILES linux/resources/noty.svg DESTINATION ${CMAKE_INSTALL_DATADIR}/icons/hicolor/scalable/apps RENAME noty.svg)
