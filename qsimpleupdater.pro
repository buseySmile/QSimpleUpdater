TEMPLATE = lib
TARGET = qsimpleupdater
VERSION = 0.7.1

### qsimpleupdater
include($$PWD/qsimpleupdater.pri)

OBJECTS_DIR = $$OUT_PWD/_build/obj
MOC_DIR     = $$OUT_PWD/_build/moc
RCC_DIR     = $$OUT_PWD/_build/rcc
UI_DIR      = $$OUT_PWD/_build/ui

win32 {
    DESTDIR = $$OUT_PWD/_build
}
