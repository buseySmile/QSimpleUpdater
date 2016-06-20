#include <unistd.h>
#include <QCoreApplication>
#include <QFile>
#include <QByteArray>

#include "launcher.h"

bool execUpdater()
{
    if(!QFile::exists(QCoreApplication::applicationDirPath() + "/updater"))
        return false;

    static const int max_len= 65536, max_args_count = 128;

    char path[max_len] = {0};
    QByteArray data(QFile::encodeName(QCoreApplication::applicationDirPath() + "/updater"));
    memcpy(path, data.constData(), data.size());

    char *args[max_args_count] = {0};
    char p_path[] = "-workpath";
    char p_pathbuf[max_len] = {0};

    int argIndex = 0;
    args[argIndex++] = path;

    QByteArray pathf = QCoreApplication::applicationDirPath().toUtf8();
    if (pathf.size() < max_len) {
        memcpy(p_pathbuf, pathf.constData(), pathf.size());
        args[argIndex++] = p_path;
        args[argIndex++] = p_pathbuf;
    }

    pid_t pid = fork();
    switch (pid) {
        case -1:
            return false;
        case  0:
            execv(path, args);
            return true;
    }
    return true;
}
