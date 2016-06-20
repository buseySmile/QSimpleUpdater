#pragma once

#include <QtGlobal>
#include <QString>

#if defined(Q_OS_MAC)
bool objc_execUpdater(const QString& working_dir);
#elif defined(Q_OS_LINUX)
bool execUpdater();
//#elif defined(Q_OS_WIN32)
#endif
