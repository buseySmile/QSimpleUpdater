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
# command for build native
# xcodebuild \
# -sdk macosx10.10 \
# -project updater.xcodeproj/ -configuration Release -target updater \
# ARCHS=x86_64 ONLY_ACTIVE_ARCH=YES MACOSX_DEPLOYMENT_TARGET=10.10 GCC_VERSION=com.apple.compilers.llvm.clang.1_0
# Output path
# ../Updater/mac/Release/example.app/Contents/Frameworks/updater
}

unix:!macx {
    SOURCES += updater_linux.cpp
}

