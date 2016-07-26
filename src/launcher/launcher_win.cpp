//#include <shellapi.h>
#include "launcher.h"

bool win_execUpdater() {
//	QString updaterPath = cWriteProtected() ? (cWorkingDir() + "updater.exe") : (cExeDir() + "Updater.exe");

//	QString updater(QDir::toNativeSeparators(updaterPath)), wdir(QDir::toNativeSeparators(cWorkingDir()));

    // (("Executing %1 %2").arg(cExeDir() + "updater.exe").arg(targs));
//    HINSTANCE r = ShellExecute(0, cWriteProtected()
//                                    ? L"runas"
//                                    : 0, updater.toStdWString().c_str(), targs.toStdWString().c_str(), wdir.isEmpty() ? 0 : wdir.toStdWString().c_str(), SW_SHOWNORMAL);
//	if (long(r) < 32) {
        //(("Error: failed to execute %1, working directory: '%2', result: %3").arg(updater).arg(wdir).arg(long(r)));
//		psDeleteDir(cWorkingDir() + qsl("tupdates/temp"));
//	}
    return true;
}

