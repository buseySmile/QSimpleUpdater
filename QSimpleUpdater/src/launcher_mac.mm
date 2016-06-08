#include <Cocoa/Cocoa.h>
#include <IOKit/IOKitLib.h>
#include <QDebug>

#include "launcher.h"

BOOL _execUpdater() {
    NSString *path = @"", *args = @"";
    @try {
        path = [[NSBundle mainBundle] bundlePath];
        if (!path) {
            qDebug() << "Could not get bundle path!!";
            return NO;
        }
        path = [path stringByAppendingString:@"/Contents/Frameworks/updater"];

        NSMutableArray *args = [[NSMutableArray alloc] initWithObjects:/*@"-workpath", workingDir,*/ @"-procid", nil];
        [args addObject:[NSString stringWithFormat:@"%d", [[NSProcessInfo processInfo] processIdentifier]]];

        qDebug() << QString("Application Info: executing %1 %2")
                        .arg(QString::fromNSString(path))
                        .arg(QString::fromNSString([args componentsJoinedByString:@" "]));
        if (![NSTask launchedTaskWithLaunchPath:path arguments:args]) {
            qDebug() << QString("Task not launched while executing %1 %2")
                                .arg(QString::fromNSString(path))
                                .arg(QString::fromNSString([args componentsJoinedByString:@" "]));
            return NO;
        }
    }
    @catch (NSException *exception) {
        qDebug() << QString("Exception caught while executing %1 %2")
                            .arg(QString::fromNSString(path))
                            .arg(QString::fromNSString(args));
        return NO;
    }
    @finally {
    }
    return YES;
}

bool objc_execUpdater(const QString& working_dir) {
    // Q_UNUSED(working_dir)
    qDebug() << "Workin dir" << working_dir;
    return _execUpdater(/*working_dir.toNSString()*/);
}
