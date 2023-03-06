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
#import "ADJResultNL.h"

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (nullable, readonly, strong, nonatomic) ADJV4ActivityState *v4ActivityState;
 @property (nullable, readonly, strong, nonatomic) ADJV4Attribution *v4Attribution;
 @property (nullable, readonly, strong, nonatomic) NSArray<ADJV4ActivityPackage *> *v4ActivityPackageArray;
 @property (nullable, readonly, strong, nonatomic) NSDictionary<NSString *, NSString *> *v4SessionCallbackParameters;
 @property (nullable, readonly, strong, nonatomic) NSDictionary<NSString *, NSString *> *v4SessionPartnerParameters;
 */

@implementation ADJV4FilesData
#pragma mark Instantiation
- (nonnull instancetype)initWithLogger:(nonnull ADJLogger *)logger {
    self = [super init];
    
    [NSKeyedUnarchiver setClass:[ADJV4ActivityState class] forClassName:@"AIActivityState"];
    [NSKeyedUnarchiver setClass:[ADJV4ActivityState class] forClassName:@"ADJActivityState"];
    _v4ActivityState = [ADJV4FilesData readObjectWithFileName:@"AdjustIoActivityState"
                                                        class:[ADJV4ActivityState class]
                                                       logger:logger];
    
    [NSKeyedUnarchiver setClass:[ADJV4Attribution class] forClassName:@"ADJAttribution"];
    _v4Attribution = [ADJV4FilesData readObjectWithFileName:@"AdjustIoAttribution"
                                                      class:[ADJV4Attribution class]
                                                     logger:logger];
    
    [NSKeyedUnarchiver setClass:[ADJV4ActivityPackage class] forClassName:@"ADJActivityPackage"];
    _v4ActivityPackageArray = [ADJV4FilesData readObjectWithFileName:@"AdjustIoPackageQueue"
                                                               class:[NSArray class]
                                                              logger:logger];
    
    _v4SessionCallbackParameters =
    [ADJV4FilesData readObjectWithFileName:@"AdjustSessionCallbackParameters"
                                     class:[NSDictionary class]
                                    logger:logger];
    
    _v4SessionPartnerParameters =
    [ADJV4FilesData readObjectWithFileName:@"AdjustSessionPartnerParameters"
                                     class:[NSDictionary class]
                                    logger:logger];
    
    return self;
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark Internal Methods
+ (nullable id)readObjectWithFileName:(nonnull NSString *)fileName
                                class:(nonnull Class)classToRead
                               logger:(nonnull ADJLogger *)logger
{
    // Try to read from Application Support directory first.
    NSString *_Nullable appSupportFilePath =
        [ADJUtilFiles filePathInAdjustAppSupportDir:fileName];
    if (appSupportFilePath == nil) {
        [logger debugDev:@"Could not obtain the file path in the adjust app support dir"
                    key:@"file name"
                  value:fileName
               issueType:ADJIssueStorageIo];
    } else {
        ADJResultNL<id> *_Nonnull appSupportReadObjectResult =
            [self readObjectWithFilePath:appSupportFilePath class:classToRead];
        if (appSupportReadObjectResult.fail != nil) {
            [logger debugDev:@"Failed to read object in the adjust app support dir"
                         key:@"file name"
                       value:fileName
                  resultFail:appSupportReadObjectResult.fail
                   issueType:ADJIssueStorageIo];
        } else {
            return appSupportReadObjectResult.value;
        }
    }
    

    // If in here, for some reason, reading of file from Application Support folder failed.
    // Let's check the Documents folder.
    NSString *_Nullable documentsFilePath = [ADJUtilFiles filePathInDocumentsDir:fileName];
    if (documentsFilePath == nil) {

        return nil;
    }

    ADJResultNL<id> *_Nonnull documentsReadObjectResult =
        [self readObjectWithFilePath:documentsFilePath class:classToRead];
    if (documentsReadObjectResult.fail != nil) {
        [logger debugWithMessage:@"Failed to read object in the documents dir"
                    builderBlock:^(ADJLogBuilder * _Nonnull logBuilder) {
            [logBuilder withFail:documentsReadObjectResult.fail
                           issue:ADJIssueStorageIo];
            [logBuilder withKey:@"file name" value:fileName];
        }];
        return nil;
    }

    return documentsReadObjectResult.value;
}

+ (nonnull ADJResultNL<id> *)
    readObjectWithFilePath:(nonnull NSString *)filePath
    class:(nonnull Class)classToRead
{
    if (@available(iOS 11.0, macOS 10.13, tvOS 11.0, watchOS 4.0, *)) {
        NSError *_Nullable error = nil;
        NSData *_Nullable readData = [NSData dataWithContentsOfFile:filePath
                                                            options:0
                                                              error:&error];

        if (readData == nil) {
            if ([ADJUtilFiles fileExistsWithPath:filePath]) {
                return [ADJResultNL failWithMessage:
                            @"nil return on dataWithContentsOfFile when fileExistsWithPath"
                        error:error];
            } else {
                return [ADJResultNL okWithoutValue];
            }
        }

        // TODO: check if it works with v4 written data.
        //  If not, we still need to use the deprecated version
        id _Nullable objectRead =
            [NSKeyedUnarchiver unarchivedObjectOfClass:classToRead fromData:readData error:&error];

        if (objectRead != nil) {
            return [ADJResultNL okWithValue:objectRead];
        }

        return [ADJResultNL failWithMessage:@"Cannot unarchive object"
                                      error:error];
    } else {
        @try {
            id _Nullable objectRead = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
            if (objectRead == nil) {
                return [ADJResultNL okWithoutValue];
            }

            if (! [objectRead isKindOfClass:classToRead]) {
                return [ADJResultNL failWithMessage:@"Cannot cast read object to class"];
            }

            return [ADJResultNL okWithValue:objectRead];

        } @catch (NSException *exception) {
            return [ADJResultNL failWithMessage:
                    @"NSKeyedUnarchiver unarchiveObjectWithFile exception"
                                      exception:exception];
        }
    }
}

@end
