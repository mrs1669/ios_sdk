//
//  ADJLogPackageData.m
//  Adjust
//
//  Created by Aditi Agrawal on 20/09/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJLogPackageData.h"

#import "ADJConstantsParam.h"

#pragma mark Fields
#pragma mark - Public constants
NSString *const ADJLogPackageDataMetadataTypeValue = @"LogPackageData";
NSString *const ADJLogPackageDataPath = @"error";

@implementation ADJLogPackageData
#pragma mark Instantiation

- (nonnull instancetype)initWithClientSdk:(nonnull NSString *)clientSdk
                               parameters:(nonnull ADJStringMap *)parameters {
    self = [super initWithPath:ADJLogPackageDataPath
                     clientSdk:clientSdk
  isPostOrElseGetNetworkMethod:YES
                    parameters:parameters];

    return self;
}

- (nonnull instancetype)initWithClientSdk:(nonnull NSString *)clientSdk
                               parameters:(nonnull ADJStringMap *)parameters
                                   ioData:(nonnull ADJIoData *)ioData
                                   logger:(nonnull ADJLogger *)logger {
    // does not read ioData for further information
    return [self initWithClientSdk:clientSdk parameters:parameters];
}

#pragma mark Protected Methods
#pragma mark - Concrete ADJSdkPackageBaseData
- (nonnull ADJNonEmptyString *)concreteGenerateShortDescription {
    ADJNonEmptyString *_Nullable logMessageString =
    [self.parameters pairValueWithKey:ADJParamLogMessageKey];
    ADJNonEmptyString *_Nullable logLevelString =
    [self.parameters pairValueWithKey:ADJParamLogLevelKey];
    ADJNonEmptyString *_Nullable logSourceString =
    [self.parameters pairValueWithKey:ADJParamLogSourceKey];

    return [[ADJNonEmptyString alloc]
            initWithConstStringValue:
                [NSString stringWithFormat:@"Log with message:%@, level:%@, source:%@",
                 logMessageString, logLevelString, logSourceString]];
}

@end
