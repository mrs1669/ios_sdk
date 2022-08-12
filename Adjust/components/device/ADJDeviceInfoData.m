//
//  ADJDeviceInfoData.m
//  Adjust
//
//  Created by Pedro S. on 23.02.21.
//  Copyright © 2021 adjust GmbH. All rights reserved.
//

#import "ADJDeviceInfoData.h"

#import <UIKit/UIKit.h>
#import <sys/sysctl.h>
#import "ADJUtilF.h"

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *fbAnonymousId;
 @property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *bundeIdentifier;
 @property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *bundleVersion;
 @property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *bundleShortVersion;
 @property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *deviceType;
 @property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *deviceName;
 @property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *osName;
 @property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *systemVersion;
 @property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *languageCode;
 @property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *countryCode;
 @property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *machineModel;
 @property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *cpuTypeSubtype;
 @property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *osBuild;
 */

@implementation ADJDeviceInfoData
#pragma mark Instantiation
- (nonnull instancetype)initWithLogger:(nonnull ADJLogger *)logger {
    self = [super init];
    
    UIDevice *_Nonnull currentDevice = UIDevice.currentDevice;
    
    NSBundle *_Nonnull mainBundle = NSBundle.mainBundle;
    
    NSLocale *_Nonnull currentLocale = NSLocale.currentLocale;
    
    NSDictionary<NSString *, id> *_Nullable infoDictionary = mainBundle.infoDictionary;
    
    _fbAnonymousId = [ADJDeviceInfoData readFbAnonymousIdWithLogger:logger];
    _bundeIdentifier = [ADJDeviceInfoData readBundleIdentifierWithLogger:logger
                                                          infoDictionary:infoDictionary];
    _bundleVersion = [ADJDeviceInfoData readBundleVersionWithLogger:logger
                                                     infoDictionary:infoDictionary];
    _bundleShortVersion = [ADJDeviceInfoData readBundleShortVersionWithLogger:logger
                                                                   mainBundle:mainBundle];
    _deviceType = [ADJDeviceInfoData readDeviceTypeWithLogger:logger
                                                currentDevice:currentDevice];
    _deviceName = [ADJDeviceInfoData readDeviceNameWithLogger:logger];
    _osName = [ADJDeviceInfoData readOsNameWithLogger:logger];
    _systemVersion = [ADJDeviceInfoData readSystemVersionWithLogger:logger
                                                      currentDevice:currentDevice];
    _languageCode = [ADJDeviceInfoData readLanguageCodeWithLogger:logger
                                                    currentLocale:currentLocale];
    _countryCode = [ADJDeviceInfoData readCountryCodeWithLogger:logger
                                                  currentLocale:currentLocale];
    _machineModel = [ADJDeviceInfoData readMachineModelWithLogger:logger];
    _cpuTypeSubtype = [ADJDeviceInfoData readCpuTypeSubtype];
    _osBuild = [ADJDeviceInfoData readOsBuildWithLogger:logger];
    
    return self;
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark Internal Methods
// pre FB SDK v6.0.0
// return [FBSDKAppEventsUtility retrievePersistedAnonymousID];
// post FB SDK v6.0.0
// return [FBSDKBasicUtility retrievePersistedAnonymousID];
+ (nullable ADJNonEmptyString *)readFbAnonymousIdWithLogger:(nonnull ADJLogger *)logger {
#if TARGET_OS_TV
    return nil;
#else
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    SEL selGetId = NSSelectorFromString(@"retrievePersistedAnonymousID");
    
    Class _Nullable class = NSClassFromString(@"FBSDKBasicUtility");
    if (class != nil && [class respondsToSelector:selGetId]) {
        id _Nullable fbAnonymousId = (NSString *)[class performSelector:selGetId];
        if (fbAnonymousId == nil
            || ! [fbAnonymousId isKindOfClass:[NSString class]])
        {
            return nil;
        }
        
        return [ADJNonEmptyString instanceFromOptionalString:(NSString *)fbAnonymousId
                                           sourceDescription:@"FBSDKBasicUtility id"
                                                      logger:logger];
    }
    
    class = NSClassFromString(@"FBSDKAppEventsUtility");
    if (class != nil && [class respondsToSelector:selGetId]) {
        id _Nullable fbAnonymousId = (NSString *)[class performSelector:selGetId];
        if (fbAnonymousId == nil
            || ! [fbAnonymousId isKindOfClass:[NSString class]])
        {
            return nil;
        }
        
        return [ADJNonEmptyString instanceFromOptionalString:(NSString *)fbAnonymousId
                                           sourceDescription:@"FBSDKAppEventsUtility id"
                                                      logger:logger];
    }
    
    return nil;
#pragma clang diagnostic pop
#endif
}

+ (nullable ADJNonEmptyString *)readBundleIdentifierWithLogger:(nonnull ADJLogger *)logger
                                                infoDictionary:(nullable NSDictionary<NSString *, id> *)infoDictionary {
    if (infoDictionary == nil) {
        return nil;
    }
    
    NSString *_Nullable bundleIdentifierKey = (__bridge NSString *)kCFBundleIdentifierKey;
    if (bundleIdentifierKey == nil) {
        return nil;
    }
    
    id _Nullable bundleIdentifierValueObject = [infoDictionary objectForKey:bundleIdentifierKey];
    
    if (bundleIdentifierValueObject == nil ||
        ! [bundleIdentifierValueObject isKindOfClass:[NSString class]])
    {
        return nil;
    }
    
    return [ADJNonEmptyString instanceFromOptionalString:(NSString *)bundleIdentifierValueObject
                                       sourceDescription:@"Bundle Identifier"
                                                  logger:logger];
}

+ (nullable ADJNonEmptyString *)readBundleVersionWithLogger:(nonnull ADJLogger *)logger
                                             infoDictionary:(nullable NSDictionary<NSString *, id> *)infoDictionary {
    if (infoDictionary == nil) {
        return nil;
    }
    
    NSString *_Nullable bundleVersionKey = (__bridge NSString *)kCFBundleVersionKey;
    if (bundleVersionKey == nil) {
        return nil;
    }
    
    id _Nullable bundleVersionValueObject = [infoDictionary objectForKey:bundleVersionKey];
    
    if (bundleVersionValueObject == nil ||
        ! [bundleVersionValueObject isKindOfClass:[NSString class]])
    {
        return nil;
    }
    
    return [ADJNonEmptyString instanceFromOptionalString:(NSString *)bundleVersionValueObject
                                       sourceDescription:@"Bundle Version"
                                                  logger:logger];
}

+ (nullable ADJNonEmptyString *)readBundleShortVersionWithLogger:(nonnull ADJLogger *)logger
                                                      mainBundle:(nonnull NSBundle *)mainBundle {
    id _Nullable bundleShortVersionValueObject =
    [mainBundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    
    if (bundleShortVersionValueObject == nil ||
        ! [bundleShortVersionValueObject isKindOfClass:[NSString class]])
    {
        return nil;
    }
    
    return [ADJNonEmptyString instanceFromOptionalString:(NSString *)bundleShortVersionValueObject
                                       sourceDescription:@"Bundle Short Version"
                                                  logger:logger];
}

+ (nullable ADJNonEmptyString *)readDeviceTypeWithLogger:(nonnull ADJLogger *)logger
                                           currentDevice:(nonnull UIDevice *)currentDevice {
    NSString *_Nonnull deviceType =
    [currentDevice.model stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    return [ADJNonEmptyString instanceFromOptionalString:(NSString *)deviceType
                                       sourceDescription:@"Device Type"
                                                  logger:logger];
}

+ (nullable ADJNonEmptyString *)readDeviceNameWithLogger:(nonnull ADJLogger *)logger {
    NSString *_Nullable machine = [self readSysctlbByNameString:"hw.machine"];
    
    return [ADJNonEmptyString instanceFromOptionalString:machine
                                       sourceDescription:@"Device Name"
                                                  logger:logger];
}

+ (nullable ADJNonEmptyString *)readOsNameWithLogger:(nonnull ADJLogger *)logger {
    NSString *_Nullable osName =
#if TARGET_OS_MACCATALYST
    @"macCatalyst"
#elif TARGET_OS_TV
    @"tvOs"
#elif TARGET_OS_WATCH
    @"watchOS"
#elif TARGET_OS_BRIDGE
    @"bridgeOS"
#elif TARGET_OS_OSX
    @"macOS"
#elif TARGET_OS_DRIVERKIT
    @"driverKit"
#elif TARGET_OS_IOS
    @"iOS"
#else
    nil
#endif
    ;
    
    return [ADJNonEmptyString instanceFromOptionalString:osName
                                       sourceDescription:@"os name"
                                                  logger:logger];
}

+ (nullable ADJNonEmptyString *)readSystemVersionWithLogger:(nonnull ADJLogger *)logger
                                              currentDevice:(nonnull UIDevice *)currentDevice {
    return [ADJNonEmptyString instanceFromOptionalString:currentDevice.systemName
                                       sourceDescription:@"System name"
                                                  logger:logger];
}

+ (nullable ADJNonEmptyString *)readLanguageCodeWithLogger:(nonnull ADJLogger *)logger
                                             currentLocale:(nonnull NSLocale *)currentLocale {
    id _Nullable languageCodeObject = [currentLocale objectForKey:NSLocaleLanguageCode];
    
    if (languageCodeObject == nil
        || [languageCodeObject isKindOfClass:[NSString class]])
    {
        return nil;
    }
    
    return [ADJNonEmptyString instanceFromOptionalString:(NSString *)languageCodeObject
                                       sourceDescription:@"Language code"
                                                  logger:logger];
}

+ (nullable ADJNonEmptyString *)readCountryCodeWithLogger:(nonnull ADJLogger *)logger
                                            currentLocale:(nonnull NSLocale *)currentLocale {
    id _Nullable countryCodeObject = [currentLocale objectForKey:NSLocaleCountryCode];
    
    if (countryCodeObject == nil
        || [countryCodeObject isKindOfClass:[NSString class]])
    {
        return nil;
    }
    
    return [ADJNonEmptyString instanceFromOptionalString:(NSString *)countryCodeObject
                                       sourceDescription:@"Country code"
                                                  logger:logger];
}

+ (nullable ADJNonEmptyString *)readMachineModelWithLogger:(nonnull ADJLogger *)logger {
    NSString *_Nullable model = [self readSysctlbByNameString:"hw.model"];
    
    return [ADJNonEmptyString instanceFromOptionalString:model
                                       sourceDescription:@"Machine model"
                                                  logger:logger];
}

+ (nullable ADJNonEmptyString *)readCpuTypeSubtype {
    NSNumber *_Nullable cpuTypeInt = [self readSysctlbByNameInt:"hw.cputype"];
    
    NSNumber *_Nullable cpuSubtypeInt = [self readSysctlbByNameInt:"hw.cpusubtype"];
    
    if (cpuTypeInt == nil && cpuSubtypeInt == nil) {
        return nil;
    }
    
    if (cpuTypeInt == nil) {
        return [[ADJNonEmptyString alloc] initWithConstStringValue:
                [NSString stringWithFormat:@"_%@", cpuSubtypeInt]];
    }
    
    if (cpuSubtypeInt == nil) {
        return [[ADJNonEmptyString alloc] initWithConstStringValue:
                [NSString stringWithFormat:@"%@_", cpuTypeInt]];
    }
    
    return [[ADJNonEmptyString alloc] initWithConstStringValue:
            [NSString stringWithFormat:@"%@_%@", cpuTypeInt, cpuSubtypeInt]];
}

+ (nullable ADJNonEmptyString *)readOsBuildWithLogger:(nonnull ADJLogger *)logger {
    NSString *_Nullable osversion = [self readSysctlbByNameString:"kern.osversion"];
    
    return [ADJNonEmptyString instanceFromOptionalString:osversion
                                       sourceDescription:@"Os build"
                                                  logger:logger];
}

+ (nullable NSString *)readSysctlbByNameString:(const char*)name {
    int error = 0;
    size_t length = 0;
    error = sysctlbyname(name, NULL, &length, NULL, 0);
    
    if (error != 0) {
        return nil;
    }
    
    char *p = malloc(sizeof(char) * length);
    if (!p) {
        return nil;
    }
    
    error = sysctlbyname(name, p, &length, NULL, 0);
    
    if (error != 0) {
        free(p);
        return nil;
    }
    
    NSString *value = [NSString stringWithUTF8String:p];
    
    free(p);
    
    return value;
}

+ (nullable NSNumber *)readSysctlbByNameInt:(const char*)name {
    int error = 0;
    
    int intValue = -1;
    size_t length = sizeof(intValue);
    error = sysctlbyname(name, &intValue, &length, NULL, 0);
    
    if (error != 0) {
        return nil;
    }
    
    return @(intValue);
}

@end
