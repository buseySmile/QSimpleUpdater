#import <Cocoa/Cocoa.h>

NSString *bandleName = nil;
NSString *appDirFull = nil;

//#ifdef _DEBUG
BOOL g_debug = YES;
//#else
//BOOL g_debug = NO;
//#endif

NSFileHandle *_logFile = nil;
void openLog() {
    if (!g_debug || _logFile) return;
    NSString *logDir = [appDirFull stringByAppendingString:@"DebugLogs"];
    if (![[NSFileManager defaultManager] createDirectoryAtPath:logDir withIntermediateDirectories:YES attributes:nil error:nil]) {
        return;
    }

    NSDateFormatter *fmt = [[NSDateFormatter alloc] initWithDateFormat:@"DebugLogs/%Y%m%d_%H%M%S_upd.txt" allowNaturalLanguage:NO];
    NSString *logPath = [appDirFull stringByAppendingString:[fmt stringFromDate:[NSDate date]]];
    [[NSFileManager defaultManager] createFileAtPath:logPath contents:nil attributes:nil];
    _logFile = [NSFileHandle fileHandleForWritingAtPath:logPath];
}

void closeLog() {
    if (!_logFile) return;

    [_logFile closeFile];
}

void writeLog(NSString *msg) {
    if (!_logFile) return;

    [_logFile writeData:[[msg stringByAppendingString:@"\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [_logFile synchronizeFile];
}

void delFolder() {
    writeLog([@"Fully clearing updates: " stringByAppendingString:[appDirFull stringByAppendingString:@"updates"]]);
    if (![[NSFileManager defaultManager] removeItemAtPath:[appDirFull stringByAppendingString:@"updates"] error:nil]) {
        writeLog(@"Error: failed to clear new path! :(");
    }
    rmdir([[appDirFull stringByAppendingString:@"updates/"] fileSystemRepresentation]);
}

int main(int argc, char * argv[]) {
    // get the bandle path
    NSString *path = [[NSBundle mainBundle] bundlePath];
    if (!path) {
        return -1;
    }
    // search index till ".app/" inclusion backward
    NSRange range = [path rangeOfString:@".app/" options:NSBackwardsSearch];
    if (range.location == NSNotFound) {
        return -1;
    }
    // cut out path after ".app/"
    path = [path substringToIndex:range.location > 0 ? range.location : 0];
    // search index till "/" inclusion backward
    range = [path rangeOfString:@"/" options:NSBackwardsSearch];
    // separate app name from path
    NSString *appName = (range.location == NSNotFound) ? path : [path substringFromIndex:range.location + 1];
    // bandle name -- add ".app/" => @"[your_app].app"
    bandleName = [[NSArray arrayWithObjects:appName, @".app", nil] componentsJoinedByString:@""];
    // get root dir for bandle
    NSString *appDir = (range.location == NSNotFound) ? @"" : [path substringToIndex:range.location + 1];
    // get full path to exec
    appDirFull = [[NSArray arrayWithObjects:appDir, bandleName, @"/Contents/MacOS/", nil] componentsJoinedByString:@""];

    openLog();
    pid_t procId = 0;
    // args parsing
    BOOL update = YES;
    for (int i = 0; i < argc; ++i) {
        if ([@"-procid" isEqualToString:[NSString stringWithUTF8String:argv[i]]]) {
            if (++i < argc) {
                NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
                [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
                procId = [[formatter numberFromString:[NSString stringWithUTF8String:argv[i]]] intValue];
            }
        } else if ([@"-debug" isEqualToString:[NSString stringWithUTF8String:argv[i]]]) {
            g_debug = YES;
        }
    }

    openLog();
    NSMutableArray *argsArr = [[NSMutableArray alloc] initWithCapacity:argc];
    for (int i = 0; i < argc; ++i) {
        [argsArr addObject:[NSString stringWithUTF8String:argv[i]]];
    }
    writeLog([[NSArray arrayWithObjects:@"Arguments: '", [argsArr componentsJoinedByString:@"' '"], @"'..", nil] componentsJoinedByString:@""]);

    // finding main app procId...
    if (procId) {
        NSRunningApplication *app = [NSRunningApplication runningApplicationWithProcessIdentifier:procId];
        for (int i = 0; i < 5 && app != nil && ![app isTerminated]; ++i) {
            usleep(200000);
            app = [NSRunningApplication runningApplicationWithProcessIdentifier:procId];
        }
        // ...if found trying to terminate main process
        if (app) [app forceTerminate];
        app = [NSRunningApplication runningApplicationWithProcessIdentifier:procId];
        for (int i = 0; i < 5 && app != nil && ![app isTerminated]; ++i) {
            usleep(200000);
            app = [NSRunningApplication runningApplicationWithProcessIdentifier:procId];
        }
    }

    if (update) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        // get updates directory
        NSString *updDir = [appDirFull stringByAppendingString:@"updates/"];

        if ([fileManager fileExistsAtPath:[updDir stringByAppendingString:appName]]) {
            writeLog([@"Ready file found! Using updates from " stringByAppendingString: updDir]);
        } else {
            writeLog(@"Ready file not found! EXIT!");
            return -1;
        }

        writeLog([@"Starting update files from path: " stringByAppendingString: updDir]);

        NSArray *keys = [NSArray arrayWithObject:NSURLIsDirectoryKey];
        NSDirectoryEnumerator *enumerator = [fileManager
                                            enumeratorAtURL:[NSURL fileURLWithPath:updDir]
                                            includingPropertiesForKeys:keys
                                            options:0
                                            errorHandler:^(NSURL *url, NSError *error) {
                                            writeLog([[[@"Error in enumerating " stringByAppendingString:[url absoluteString]] stringByAppendingString: @" error is: "] stringByAppendingString: [error description]]);
                                    return NO;
                                }];
        for (NSURL *url in enumerator)
        {
            NSString *srcPath = [url path];
            writeLog([@"Handling file " stringByAppendingString:srcPath]);
            NSRange r = [srcPath rangeOfString:updDir];
            if (r.location != 0) {
                writeLog([@"Bad file found, no base path " stringByAppendingString:srcPath]);
                delFolder();
                break;
            }
            NSString *pathPart = [srcPath substringFromIndex:r.length];
            writeLog([@"    an app file:  " stringByAppendingString:pathPart]);
            r = [pathPart rangeOfString:appName];
            if (r.location != 0) {
                writeLog([@"Skipping not app file " stringByAppendingString:srcPath]);
                continue;
            }
            NSString *dstPath = [appDirFull stringByAppendingString:pathPart];
            NSError *error;
            NSNumber *isDirectory = nil;
            if (![url getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:&error]) {
                writeLog([@"Failed to get IsDirectory for file " stringByAppendingString:[url path]]);
                delFolder();
                break;
            }
            if ([isDirectory boolValue]) {
                writeLog([[NSArray arrayWithObjects: @"Copying dir ", srcPath, @" to ", dstPath, nil] componentsJoinedByString:@""]);
                if (![fileManager createDirectoryAtPath:dstPath withIntermediateDirectories:YES attributes:nil error:nil]) {
                    writeLog([@"Failed to force path for directory " stringByAppendingString:dstPath]);
                    delFolder();
                    break;
                }
            } else if ([fileManager fileExistsAtPath:dstPath]) {
                writeLog([@"Editing file " stringByAppendingString:dstPath]);
                if (![[NSData dataWithContentsOfFile:srcPath] writeToFile:dstPath atomically:YES]) {
                    writeLog([@"Failed to edit file " stringByAppendingString:dstPath]);
                    delFolder();
                    break;
                }
            } else {
                writeLog([[NSArray arrayWithObjects: @"Copying file ", srcPath, @" to ", dstPath, nil] componentsJoinedByString:@""]);
                if (![fileManager copyItemAtPath:srcPath toPath:dstPath error:nil]) {
                    writeLog([@"Failed to copy file to " stringByAppendingString:dstPath]);
                    delFolder();
                    break;
                }
            }
        }
        delFolder();
}

// restart main application
NSString *appPath = [[NSArray arrayWithObjects:appDirFull, appName, nil] componentsJoinedByString:@""];
NSMutableArray *args = [[NSMutableArray alloc] initWithObjects:@"-debug", nil];

writeLog([@"Running application '" stringByAppendingString:appPath]);
//writeLog([[NSArray arrayWithObjects:@"Running application '", appPath, @"'with args '", [args componentsJoinedByString:@"' '"], @"'..'",nil] componentsJoinedByString:@""]);

NSError *error = nil;
NSRunningApplication *result = [[NSWorkspace sharedWorkspace]
                launchApplicationAtURL:[NSURL fileURLWithPath:appPath]
                options:NSWorkspaceLaunchDefault
                configuration:[NSDictionary
                               dictionaryWithObject:args
                               forKey:NSWorkspaceLaunchConfigurationArguments]
                error:&error];
if (!result)
    writeLog([@"Could not run application, error: " stringByAppendingString:error ? [error localizedDescription] : @"(nil)"]);

    return result ? 0 : -1;
}
