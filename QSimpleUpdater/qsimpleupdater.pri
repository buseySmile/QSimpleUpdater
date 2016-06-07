greaterThan(QT_MAJOR_VERSION, 4) {
    QT += widgets
}
QT += network

#unix:!android {
#    LIBS += -lcrypto -lssl
#}

HEADERS += \
    $$PWD/src/launcher.h

#win32 {
#    SOURCES +=  \
#        $$PWD/src/launcher_win.cpp
#}
macx {
    LIBS += -framework CoreFoundation -framework IOKit -framework AppKit
    OBJECTIVE_SOURCES +=  \
        $$PWD/src/launcher_mac.mm
}
unix:!macx {    # other *nix
    SOURCES +=  \
        $$PWD/src/launcher_nix.cpp
}

INCLUDEPATH += $$PWD/src

HEADERS += \
    $$PWD/src/qsimpleupdater.h \
    $$PWD/src/dialogs/download_dialog.h \
    $$PWD/src/dialogs/progress_dialog.h

SOURCES +=  \
    $$PWD/src/qsimpleupdater.cpp \
    $$PWD/src/dialogs/download_dialog.cpp \
    $$PWD/src/dialogs/progress_dialog.cpp

FORMS += \
    $$PWD/src/dialogs/download_dialog.ui \
    $$PWD/src/dialogs/progress_dialog.ui

RESOURCES += \
    $$PWD/res/qsu_resources.qrc

OTHER_FILES += \
    $$PWD/src/QSimpleUpdater
