#pragma once

#include <QtGlobal>

#if defined(Q_OS_MAC)
bool objc_execUpdater();
#elif defined(Q_OS_LINUX)
bool execUpdater();
//#elif defined(Q_OS_WIN32)
#endif
