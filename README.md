## QSimpleUpdater

[![Build status](https://travis-ci.org/buzzySmile/QSimpleUpdater.svg?branch=master)](https://travis-ci.org/buzzySmile/QSimpleUpdater)

QSimpleUpdater is an implementation of an auto-updating system to be used with Qt projects. It can check updates silent or not, get changelog, download updates to ```[app_dir_path]/updates``` and start external file update tool.

File update tool you can find [here](https://github.com/buzzySmile/QSimpleUpdater/tree/master/QSimpleUpdater/updater) or realise by yourself.

Current state

```
__update loader______|______file updater__
      + mac          |        + mac
      + nix          |        - nix
      + win          |        - win
```

QSimpleUpdater is free and open source [LGPL software](https://www.gnu.org/licenses/lgpl.html), which means that you can use it for both open source and proprietary applications.

## Quick start

* Copy/create submodule of `QSimpleUpdater` in your "3rd-party" project folder.
```bash
$ git clone https://github.com/buzzySmile/QSimpleUpdater.git
```
or
```bash
$ git submodule add https://github.com/buzzySmile/QSimpleUpdater.git
$ git submodule init
$ git submodule update
```
* Include ```qsimpleupdater.pri``` to your target Qt project
```
include($$PWD/third-party/QSimpleUpdater/qsimpleupdater.pri)
```
* Check the example project and taste how it works.

Detail description about integration `QSimpleUpdater` module and file updater tool into your system and platform you could find in **[Wiki](https://github.com/buzzySmile/QSimpleUpdater/wiki)**.

## Organize remote hosting with updates

The typical file structure on server side is
```
├── CHANGELOG
├── CURRENT_VERSION
├── mac
│   └── example
├── nix
│   └── example
├── win
    └── example.exe
```

CURRENT_VERSION contains current version of application as a first line and platform & download link devided "||" symbols.
```
0.0.2
win || http://[your.host.com]/win/example.exe
mac || http://[your.host.com]/mac/example
nix || http://[your.host.com]/nix/example
```

CHANGELOG is a additional simple text file, you could use it your own way.

Be sure all this files available from client machines.
