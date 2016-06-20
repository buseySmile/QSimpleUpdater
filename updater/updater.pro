TEMPLATE = app
TARGET = updater

CONFIG -= qt
CONFIG -= app_bundle

DEFINES += _DEBUG

win32 {
    HEADERS += updater.h
    SOURCES += updater.cpp
}

macx {
    OBJECTIVE_SOURCES += updater_osx.m
    LIBS += -framework Cocoa
#    LIBS += -framework CoreFoundation
#    LIBS += -framework IOKit
#    LIBS += -framework AppKit
}

unix:!macx {
    SOURCES += updater_linux.cpp
}

