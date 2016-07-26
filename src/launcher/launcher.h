#pragma once

#include <QtGlobal>
#include <QString>

#if defined(Q_OS_MAC)
bool objc_execUpdater(const QString& working_dir);
#elif defined(Q_OS_LINUX)
bool linux_execUpdater();
#elif defined(Q_OS_WIN32)
bool win_execUpdater();
#endif
