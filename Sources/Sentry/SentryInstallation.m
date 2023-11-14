#import "SentryInstallation.h"
#import "SentryDefines.h"
#import "SentryLog.h"

NS_ASSUME_NONNULL_BEGIN

@interface SentryInstallation (Private)
@property(class, nonatomic, readonly) NSMutableDictionary<NSString*, NSString*>* installationStringsByCacheDirectoryPaths;
@end

@implementation SentryInstallation (Private)
@dynamic installationStringsByCacheDirectoryPaths;

+ (NSMutableDictionary<NSString*, NSString*>*)installationStringsByCacheDirectoryPaths
{
    static dispatch_once_t once;
    static NSMutableDictionary* dictionary;
    
    dispatch_once(&once, ^{
        dictionary = [NSMutableDictionary dictionary];
    });
    return dictionary;
}
@end

@implementation SentryInstallation

+ (NSString *)idWithCacheDirectoryPath:(NSString *)cacheDirectoryPath
{
    @synchronized(self) {
        NSString* installationString = self.installationStringsByCacheDirectoryPaths[cacheDirectoryPath];
        
        if (nil != installationString) {
            return installationString;
        }
        
        NSString *cachePath = cacheDirectoryPath;
        NSString *installationFilePath = [cachePath stringByAppendingPathComponent:@"INSTALLATION"];
        NSData *installationData = [NSData dataWithContentsOfFile:installationFilePath];

        if (nil == installationData) {
            installationString = [NSUUID UUID].UUIDString;
            NSData *installationStringData = [installationString dataUsingEncoding:NSUTF8StringEncoding];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            
            if (![fileManager createFileAtPath:installationFilePath contents:installationStringData attributes:nil]) {
                SENTRY_LOG_ERROR(@"Error creating file at path %@", installationFilePath);
            }
        } else {
            installationString = [[NSString alloc] initWithData:installationData encoding:NSUTF8StringEncoding];
        }
        
        self.installationStringsByCacheDirectoryPaths[cacheDirectoryPath] = installationString;
        return installationString;
    }
}

@end

NS_ASSUME_NONNULL_END
