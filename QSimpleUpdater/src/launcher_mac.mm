#include "stdafx.h"

#include "launcher.h"

BOOL _execUpdater() {
    NSString *path = @"", *args = @"";
    @try {
        path = [[NSBundle mainBundle] bundlePath];
        if (!path) {
            LOG(("Could not get bundle path!!"));
            return NO;
        }
        path = [path stringByAppendingString:@"/Contents/Frameworks/updater"];

        NSMutableArray *args = [[NSMutableArray alloc] initWithObjects:@"-workpath", QNSString(cWorkingDir()).s(), @"-procid", nil];
        [args addObject:[NSString stringWithFormat:@"%d", [[NSProcessInfo processInfo] processIdentifier]]];

        if (cDebug())
            [args addObject:@"-debug"];


        DEBUG_LOG(("Application Info: executing %1 %2").arg(objcString(path)).arg(objcString([args componentsJoinedByString:@" "])));
        if (![NSTask launchedTaskWithLaunchPath:path arguments:args]) {
            LOG(("Task not launched while executing %1 %2").arg(objcString(path)).arg(objcString([args componentsJoinedByString:@" "])));
            return NO;
        }
    }
    @catch (NSException *exception) {
        LOG(("Exception caught while executing %1 %2").arg(objcString(path)).arg(objcString(args)));
        return NO;
    }
    @finally {
    }
    return YES;
}

bool objc_execUpdater() {
    return !!_execUpdater();
}
