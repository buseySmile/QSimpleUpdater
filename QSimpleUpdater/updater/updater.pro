TEMPLATE = app
TARGET = updater

QT += core gui widgets
CONFIG -= app_bundle

#DEFINES += _DEBUG

win32 {
    HEADERS += updater.h
    SOURCES += updater.cpp
}

macx {
    OBJECTIVE_SOURCES += updater_osx.mm
    LIBS += -framework Cocoa
}

unix:!macx {
    SOURCES += updater_linux.cpp
}

