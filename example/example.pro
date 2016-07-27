include($$PWD/../qsimpleupdater.pri)

TEMPLATE = app
TARGET = example
# version
DEFINES += EXAMPLE_VERSION=\\\"0.0.1\\\"
message("Version: 0.0.1")

HEADERS += example.h
SOURCES += example.cpp
FORMS   += example.ui

OBJECTS_DIR = $$OUT_PWD/_build/obj
MOC_DIR     = $$OUT_PWD/_build/moc
RCC_DIR     = $$OUT_PWD/_build/rcc
UI_DIR      = $$OUT_PWD/_build/ui
