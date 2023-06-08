//
//  ADJV4FilesData.m
//  Adjust
//
//  Created by Aditi Agrawal on 19/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJV4FilesData.h"

#import "ADJUtilFiles.h"
#import "ADJAdjustLogMessageData.h"
#import "ADJResult.h"
#import "ADJConstants.h"

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (nullable, readonly, strong, nonatomic) ADJV4ActivityState *v4ActivityState;
 @property (nullable, readonly, strong, nonatomic) ADJV4Attribution *v4Attribution;
 @property (nullable, readonly, strong, nonatomic)
     NSArray *v4ActivityPackageArray;
 @property (nullable, readonly, strong, nonatomic)
     NSDictionary<NSString *, NSString *> *v4SessionCallbackParameters;
 @property (nullable, readonly, strong, nonatomic)
     NSDictionary<NSString *, NSString *> *v4SessionPartnerParameters;
*/

@implementation ADJV4FilesData
#pragma mark Instantiation

+ (nonnull ADJOptionalFailsNN<ADJV4FilesData *> *)readV4Files {
    NSMutableArray<ADJResultFail *> *_Nonnull optionalFails =  [[NSMutableArray alloc] init];

    [NSKeyedUnarchiver setClass:[ADJV4ActivityState class] forClassName:@"AIActivityState"];
    [NSKeyedUnarchiver setClass:[ADJV4ActivityState class] forClassName:@"ADJActivityState"];
    id _Nullable v4ActivityState =
        [ADJV4FilesData readObjectWithFileName:@"AdjustIoActivityState"
                                         class:[ADJV4ActivityState class]
                                 optionalFails:optionalFails];
    
    [NSKeyedUnarchiver setClass:[ADJV4Attribution class] forClassName:@"ADJAttribution"];
    id _Nullable v4Attribution = [ADJV4FilesData readObjectWithFileName:@"AdjustIoAttribution"
                                                                  class:[ADJV4Attribution class]
                                                          optionalFails:optionalFails];

    [NSKeyedUnarchiver setClass:[ADJV4ActivityPackage class] forClassName:@"ADJActivityPackage"];
    id _Nullable v4ActivityPackageArray =
        [ADJV4FilesData readObjectWithFileName:@"AdjustIoPackageQueue"
                                         class:[NSArray class]
                                 optionalFails:optionalFails];

    id _Nullable v4SessionCallbackParameters =
        [ADJV4FilesData readObjectWithFileName:@"AdjustSessionCallbackParameters"
                                         class:[NSDictionary class]
                                 optionalFails:optionalFails];
    
    id _Nullable v4SessionPartnerParameters =
        [ADJV4FilesData readObjectWithFileName:@"AdjustSessionPartnerParameters"
                                         class:[NSDictionary class]
                                 optionalFails:optionalFails];
    
    return [[ADJOptionalFailsNN alloc]
            initWithOptionalFails:optionalFails
            value:[[ADJV4FilesData alloc] initWithV4ActivityState:v4ActivityState
                                                    v4Attribution:v4Attribution
                                           v4ActivityPackageArray:v4ActivityPackageArray
                                      v4SessionCallbackParameters:v4SessionCallbackParameters
                                       v4SessionPartnerParameters:v4SessionPartnerParameters]];
}

- (nonnull instancetype)
    initWithV4ActivityState:(nullable ADJV4ActivityState *)v4ActivityState
    v4Attribution:(nullable ADJV4Attribution *)v4Attribution
    v4ActivityPackageArray:(nullable NSArray<ADJV4ActivityPackage *> *)v4ActivityPackageArray
    v4SessionCallbackParameters:
        (nullable NSDictionary<NSString *, NSString *> *)v4SessionCallbackParameters
    v4SessionPartnerParameters:
        (nullable NSDictionary<NSString *, NSString *> *)v4SessionPartnerParameters
{
    self = [super init];
    _v4ActivityState = v4ActivityState;
    _v4Attribution = v4Attribution;
    _v4ActivityPackageArray = v4ActivityPackageArray;
    _v4SessionCallbackParameters = v4SessionCallbackParameters;
    _v4SessionPartnerParameters = v4SessionPartnerParameters;

    return self;
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark Internal Methods
+ (nullable id)readObjectWithFileName:(nonnull NSString *)fileName
                                class:(nonnull Class)classToRead
                        optionalFails:(nonnull NSMutableArray<ADJResultFail *> *)optionalFails
{
    // Try to read from Application Support directory first.
    NSString *_Nullable appSupportFilePath =
        [ADJUtilFiles filePathInAdjustAppSupportDir:fileName];
    if (appSupportFilePath == nil) {
        [optionalFails addObject:
         [[ADJResultFail alloc]
          initWithMessage:@"Could not obtain the file path in the adjust app support dir"
          key:@"file name"
          stringValue:fileName]];
    } else {
        ADJResult<id> *_Nonnull appSupportReadObjectResult =
            [self readObjectWithFilePath:appSupportFilePath
                                   class:classToRead
                           optionalFails:optionalFails];

        // result value is NSNull if the file does not exist
        if (appSupportReadObjectResult.value != nil &&
            ! [appSupportReadObjectResult.value isKindOfClass:[NSNull class]])
        {
            return appSupportReadObjectResult.value;
        }
        if (appSupportReadObjectResult.fail != nil) {
            ADJResultFailBuilder *_Nonnull resultFailBuilder =
                [[ADJResultFailBuilder alloc] initWithMessage:
                 @"Failed to read object in the adjust app support dir"];
            [resultFailBuilder withKey:@"class to read"
                             stringValue:NSStringFromClass(classToRead)];
            [resultFailBuilder withKey:@"file path"
                           stringValue:appSupportFilePath];
            [resultFailBuilder withKey:@"read object fail"
                             otherFail:appSupportReadObjectResult.fail];
            [optionalFails addObject:[resultFailBuilder build]];
        }
    }
    

    // If in here, for some reason, reading of file from Application Support folder failed.
    // Let's check the Documents folder.
    NSString *_Nullable documentsFilePath = [ADJUtilFiles filePathInDocumentsDir:fileName];
    if (documentsFilePath == nil) {
        return nil;
    }

    ADJResult<id> *_Nonnull documentsReadObjectResult =
        [self readObjectWithFilePath:documentsFilePath
                               class:classToRead
                       optionalFails:optionalFails];

    // result value is NSNull if the file does not exist
    if (documentsReadObjectResult.value != nil &&
        ! [documentsReadObjectResult.value isKindOfClass:[NSNull class]])
    {
        return documentsReadObjectResult.value;
    }

    if (documentsReadObjectResult.fail != nil) {
        ADJResultFailBuilder *_Nonnull resultFailBuilder =
            [[ADJResultFailBuilder alloc] initWithMessage:
             @"Failed to read object in the documents dir"];
        [resultFailBuilder withKey:@"class to read"
                         stringValue:NSStringFromClass(classToRead)];
        [resultFailBuilder withKey:@"file path"
                       stringValue:documentsFilePath];
        [resultFailBuilder withKey:@"read object fail"
                         otherFail:documentsReadObjectResult.fail];
        [optionalFails addObject:[resultFailBuilder build]];
    }

    return nil;
}

// result value is NSNull if the file does not exist
+ (nonnull ADJResult<id> *)
    readObjectWithFilePath:(nonnull NSString *)filePath
    class:(nonnull Class)classToRead
    optionalFails:(nonnull NSMutableArray<ADJResultFail *> *)optionalFails
{
    if (@available(iOS 11.0, macOS 10.13, tvOS 11.0, watchOS 4.0, *)) {
        NSError *_Nullable readDataError = nil;
        NSData *_Nullable readData = [NSData dataWithContentsOfFile:filePath
                                                            options:0
                                                              error:&readDataError];

        if (readData == nil) {
            if ([ADJUtilFiles fileExistsWithPath:filePath]) {
                [optionalFails addObject:
                    [[ADJResultFail alloc] initWithMessage:
                     @"Cannot read existing file using 'NSData dataWithContentsOfFile'"
                                                     error:readDataError]];

                return [ADJV4FilesData readObjectUsingDeprecatedUnarchiveWithFilePath:filePath
                                                                                class:classToRead];
            } else {
                return [ADJResult okWithValue:[NSNull null]];
            }
        }

        NSError *_Nullable convertDataError = nil;
        // TODO: check if it works with v4 written data.
        //  If not, we still need to use the deprecated version
        id _Nullable objectRead =
            [NSKeyedUnarchiver unarchivedObjectOfClass:classToRead
                                              fromData:readData
                                                 error:&convertDataError];

        if (objectRead != nil) {
            return [ADJResult okWithValue:objectRead];
        }

        [optionalFails addObject:
         [[ADJResultFail alloc] initWithMessage:
          @"Cannot parse read NSData using 'unarchivedObjectOfClass'"
                                          error:convertDataError]];

        // don't return, fallback to deprecated unarchive
    }

    return [ADJV4FilesData readObjectUsingDeprecatedUnarchiveWithFilePath:filePath
                                                                    class:classToRead];
}

+ (nonnull ADJResult<id> *)
    readObjectUsingDeprecatedUnarchiveWithFilePath:(nonnull NSString *)filePath
    class:(nonnull Class)classToRead
{
    @try {
        id _Nullable objectRead = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
        if (objectRead == nil) {
            return [ADJResult okWithValue:[NSNull null]];
        }

        if (! [objectRead isKindOfClass:classToRead]) {
            return [ADJResult failWithMessage:
                    @"Cannot cast read object using 'unarchiveObjectWithFile' to expected class"
                                          key:ADJLogActualKey
                                  stringValue:NSStringFromClass([objectRead class])];
        }

        return [ADJResult okWithValue:objectRead];
    } @catch (NSException *exception) {
        return [ADJResult failWithMessage:
                @"NSKeyedUnarchiver unarchiveObjectWithFile exception"
                                exception:exception];
    }
}

@end
