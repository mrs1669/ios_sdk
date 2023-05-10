//
//  ADJAdjustInternal.m
//  Adjust
//
//  Created by Pedro Silva on 22.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJAdjustInternal.h"

#import "ADJEntryRoot.h"
#import "ADJUtilSys.h"
#import "ADJConstants.h"
#import "ADJConstantsSys.h"
#import "ADJUtilF.h"
#import "ADJAdjustInstance.h"
#import "ADJUtilFiles.h"

static ADJEntryRoot *entryRootInstance = nil;
static dispatch_once_t entryRootOnceToken = 0;

NSString *const ADJInternalAttributionSubscriberV5000Key = @"internalAttributionSubscriberV5000";
NSString *const ADJInternalLogSubscriberV5000Key = @"internalLogSubscriberV5000";

NSString *const ADJReadAttributionMethodName = @"readAttribution";
NSString *const ADJChangedAttributionMethodName = @"changedAttribution";

NSString *const ADJLoggedMessageMethodName = @"loggedMessage";
NSString *const ADJLoggedMessagesPreInitMethodName = @"loggedMessagesPreInit";

NSString *const ADJFailedMethodName = @"failed";

NSString *const ADJAttributionGetterReadMethodName = @"getAttributionRead";
NSString *const ADJAttributionGetterFailedMethodName = @"getAttributionFailed";

NSString *const ADJDeviceIdsGetterReadMethodName = @"getDeviceIdsRead";
NSString *const ADJDeviceIdsGetterFailedMethodName = @"getDeviceIdsFailed";

NSString *const ADJInternalCallbackStringSuffix = @"_string";
NSString *const ADJInternalCallbackAdjustDataSuffix = @"_adjustData";
NSString *const ADJInternalCallbackNsDictionarySuffix = @"_nsDictionary";
NSString *const ADJInternalCallbackJsonStringSuffix = @"_jsonString";

@implementation ADJAdjustInternal

+ (nonnull id<ADJAdjustInstance>)sdkInstanceForClientId:(nullable NSString *)clientId {
    return [[ADJAdjustInternal entryRootForClientId:clientId] instanceForClientId:clientId];
}

+ (nonnull ADJEntryRoot *)entryRootForClientId:(nullable NSString *)clientId {
    // add syncronization for testing teardown
#ifdef DEBUG
    @synchronized ([ADJEntryRoot class]) {
#endif
        dispatch_once(&entryRootOnceToken, ^{
            entryRootInstance = [ADJEntryRoot instanceWithClientId:clientId
                                                     sdkConfigData:nil];
        });
        return entryRootInstance;
#ifdef DEBUG
    }
#endif
}

+ (void)
    initSdkForClientId:(nullable NSString *)clientId
    adjustConfig:(nonnull ADJAdjustConfig *)adjustConfig
    internalConfigSubscriptions:
        (nullable NSDictionary<NSString *, id<ADJInternalCallback>> *)internalConfigSubscriptions
{
    ADJInstanceRoot *_Nonnull instanceRoot =
        [[ADJAdjustInternal entryRootForClientId:clientId] instanceForClientId:clientId];

    [instanceRoot initSdkWithConfig:adjustConfig
        internalConfigSubscriptions:internalConfigSubscriptions];
}

+ (void)adjustAttributionWithClientId:(nullable NSString *)clientId
                     internalCallback:(nonnull id<ADJInternalCallback>)internalCallback
{
    ADJInstanceRoot *_Nonnull instanceRoot =
        [[ADJAdjustInternal entryRootForClientId:clientId] instanceForClientId:clientId];

    [instanceRoot adjustAttributionWithInternalCallback:internalCallback];
}
+ (void)adjustDeviceIdsWithClientId:(nullable NSString *)clientId
                   internalCallback:(nonnull id<ADJInternalCallback>)internalCallback
{
    ADJInstanceRoot *_Nonnull instanceRoot =
        [[ADJAdjustInternal entryRootForClientId:clientId] instanceForClientId:clientId];

    [instanceRoot adjustDeviceIdsWithInternalCallback:internalCallback];
}

+ (void)
    trackThirdPartySharingForClientId:(nullable NSString *)clientId
    adjustThirdPartySharing:(nonnull ADJAdjustThirdPartySharing *)adjustThirdPartySharing
    granularOptionsByNameArray:(nullable NSArray *)granularOptionsByNameArray
    partnerSharingSettingsByNameArray:(nullable NSArray *)partnerSharingSettingsByNameArray
{
    ADJInstanceRoot *_Nonnull instanceRoot =
        [[ADJAdjustInternal entryRootForClientId:clientId] instanceForClientId:clientId];

    [instanceRoot trackThirdPartySharing:adjustThirdPartySharing
              granularOptionsByNameArray:granularOptionsByNameArray
       partnerSharingSettingsByNameArray:partnerSharingSettingsByNameArray];
}

+ (nonnull NSString *)sdkVersion {
    return ADJClientSdk;
}

+ (nonnull NSString *)sdkVersionWithSdkPrefix:(nullable NSString *)sdkPrefix {
    return [ADJUtilSys clientSdkWithPrefix:sdkPrefix];
}

+ (void)
    setSdkPrefix:(nullable NSString *)sdkPrefix
    fromInstanceWithClientId:(nullable NSString *)clientId
{
    [[ADJAdjustInternal entryRootForClientId:clientId] setSdkPrefix:sdkPrefix];
}

// Resets the sdk state, as if it was not initialized or used before.
+ (nonnull NSString *)teardownWithSdkConfigData:(nullable ADJSdkConfigData *)sdkConfigData
                             shouldClearStorage:(BOOL)shouldClearStorage
{
    // restrict teardown to debug builds
#ifndef DEBUG
    return @"Teardown cannot be done in non-debug mode";
#else
    NSMutableString *_Nonnull returnMessage = [[NSMutableString alloc] initWithString:@"Entry root teardown"];

    @synchronized ([ADJEntryRoot class]) {
        if (shouldClearStorage) {
            [self teardownWhileClearingStorageWithReturnMessage:returnMessage];
        } else {
            [self teardownWithoutClearingStorageWithReturnMessage:returnMessage];
        }

        entryRootInstance = nil;

        if (sdkConfigData != nil) {
            [returnMessage appendString:@". Creating new entry root instance with injected sdk config"];
            entryRootOnceToken = 0;
            dispatch_once(&entryRootOnceToken, ^{
                entryRootInstance = [ADJEntryRoot instanceWithClientId:nil // TODO: add when testing for it
                                                         sdkConfigData:sdkConfigData];
            });
        } else {
            [returnMessage appendString:@". Not creating new entry root instance without injected sdk config"];
        }
    }

    return returnMessage;
#endif
}

+ (void)teardownWithoutClearingStorageWithReturnMessage:(nonnull NSMutableString *)returnMessage {
    if (entryRootInstance == nil) {
        [returnMessage appendString:@". No singleton root instance to null without clearing storage"];
        return;
    }
    [returnMessage appendString:@". Nulling singleton root instance without clearing storage"];

    __block dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    void (^ closeStorageBlockSync)(void) = ^{
        dispatch_semaphore_signal(sem);
    };

    [entryRootInstance finalizeAtTeardownWithCloseStorageBlock:closeStorageBlockSync];

    if (dispatch_semaphore_wait(sem, [ADJUtilSys dispatchTimeWithMilli:(ADJOneSecondMilli * 5)]) == 0) {
        [returnMessage appendString:@". Teardown finalized within close storage timeout"];
    } else {
        [returnMessage appendString:@". Teardown not finalized within close storage timeout"];
    }
}

+ (void)teardownWhileClearingStorageWithReturnMessage:(nonnull NSMutableString *)returnMessage {
    __block NSMutableString *returnMessageInBlock = returnMessage;
    __weak NSMutableString *returnMessageWeak = returnMessageInBlock;

    __block void (^ clearStorageBlock)(void) = ^{
        NSString *_Nonnull clearMessage = [ADJAdjustInternal clearStorage];
        __strong NSMutableString *returnMessageStrong = returnMessageWeak;
        if (returnMessageStrong == nil) {
            return;
        }

        [returnMessageStrong appendFormat:@". %@", clearMessage];
    };

    if (entryRootInstance == nil) {
        [returnMessage appendString:@". No singleton root instance to null while clearing storage"];
        clearStorageBlock();
        return;
    }

    [returnMessage appendString:@". Nulling singleton root instance while clearing storage"];
    __block dispatch_semaphore_t sem = dispatch_semaphore_create(0);

    void (^ closeAndClearStorageBlock)(void) = ^{
        clearStorageBlock();
        dispatch_semaphore_signal(sem);
    };

    [entryRootInstance finalizeAtTeardownWithCloseStorageBlock:closeAndClearStorageBlock];

    if (dispatch_semaphore_wait(sem, [ADJUtilSys dispatchTimeWithMilli:(ADJOneSecondMilli * 5)]) == 0) {
        [returnMessage appendString:@". Teardown finalized within close and clear storage timeout"];
    } else {
        // nil to avoid being accessed inside the unfinished block
        returnMessageInBlock = nil;
        [returnMessage appendString:@". Teardown not finalized within close and clear storage timeout"];
    }
}


+ (nonnull NSString *)clearStorage {
    // TODO: add delete of all instances
    NSMutableString *_Nonnull returnString = [[NSMutableString alloc]
                                              initWithString:@"Clearing storage"];

    [returnString appendFormat:@". %@",
     [ADJAdjustInternal clearDbInAdjustAppSupportWithIdString:@""]];

    [returnString appendFormat:@". %@",
     [ADJAdjustInternal clearDbInDocumentsDirWithIdString:@""]];

    //TODO: delete custom user defaults

    return returnString;
}

+ (nonnull NSString *)clearDbInAdjustAppSupportWithIdString:(nonnull NSString *)idString {

    NSString *_Nonnull dbFilename = [ADJInstanceIdData toDbNameWithIdString:idString];
    NSString *_Nullable appSupportDbFilename = [ADJUtilFiles filePathInAdjustAppSupportDir:dbFilename];

    if (appSupportDbFilename == nil) {
        return @"Could not obtain db filename in Application Support dir";
    }
    return [self clearDbAtPath:appSupportDbFilename];
}

+ (nonnull NSString *)clearDbInDocumentsDirWithIdString:(nonnull NSString *)idString {

    NSString *_Nonnull dbFilename = [ADJInstanceIdData toDbNameWithIdString:idString];
    NSString *_Nullable documentsDbFilename = [ADJUtilFiles filePathInDocumentsDir:dbFilename];
    if (documentsDbFilename == nil) {
        return @"Could not obtain db filename in documents dir";
    }
    return [self clearDbAtPath:documentsDbFilename];
}

+ (nonnull NSString *)clearDbAtPath:(nonnull NSString *)dbPath {

    NSError *error = nil;
    BOOL success = [[NSFileManager defaultManager] removeItemAtPath:dbPath
                                                              error:&error];
    if (error) {
        return [ADJUtilF errorFormat:error];
    }
    return [NSString stringWithFormat:@"%@ to remove [%@]",
            success ? @"Succeeded" : @"Failed",
            dbPath];
}
@end
