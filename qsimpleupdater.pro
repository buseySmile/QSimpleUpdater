TEMPLATE = lib
TARGET = qsimpleupdater
VERSION = 0.7.0

### qsimpleupdater
include($$PWD/qsimpleupdater.pri)

OBJECTS_DIR = _build/obj
MOC_DIR = _build/moc
RCC_DIR = _build/res
UI_DIR = _build/ui
win32 {
    DESTDIR = $$OUT_PWD
}
