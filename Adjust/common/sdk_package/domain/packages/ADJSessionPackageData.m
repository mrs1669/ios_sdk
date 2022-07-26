//
//  ADJSessionPackageData.m
//  Adjust
//
//  Created by Pedro Silva on 26.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJSessionPackageData.h"

#import "ADJConstantsParam.h"
#import "ADJNonNegativeInt.h"

#pragma mark Fields
#pragma mark - Public constants
NSString *const ADJSessionPackageDataPath = @"session";

@implementation ADJSessionPackageData
#pragma mark Instantiation
- (nonnull instancetype)initWithClientSdk:(nonnull NSString *)clientSdk
                               parameters:(nonnull ADJStringMap *)parameters
{
    self = [super initWithPath:ADJSessionPackageDataPath
                     clientSdk:clientSdk
  isPostOrElseGetNetworkMethod:YES
                    parameters:parameters];

    return self;
}

- (nonnull instancetype)initWithClientSdk:(nonnull NSString *)clientSdk
                               parameters:(nonnull ADJStringMap *)parameters
                                   ioData:(nonnull ADJIoData *)ioData
                                   logger:(nonnull ADJLogger *)logger
{
    // does not read ioData for further information
    return [self initWithClientSdk:clientSdk parameters:parameters];
}

#pragma mark Public API
- (BOOL)isFirstSession {
    ADJNonEmptyString *_Nullable sessionCountString =
        [self.parameters pairValueWithKey:ADJParamSessionCountKey];

    if (sessionCountString == nil) {
        return NO;
    }

    return [self isOneWithNonEmtpyString:sessionCountString];
}

#pragma mark Protected Methods
#pragma mark - Concrete ADJSdkPackageBaseData
- (nonnull ADJNonEmptyString *)concreteGenerateShortDescription {
    ADJNonEmptyString *_Nullable sessionCountString =
        [self.parameters pairValueWithKey:ADJParamSessionCountKey];

    if (sessionCountString == nil) {
        return [[ADJNonEmptyString alloc] initWithConstStringValue:@"Session"];
    }
    if ([self isOneWithNonEmtpyString:sessionCountString]) {
        return [[ADJNonEmptyString alloc]
                initWithConstStringValue:@"Install / First Session"];
    }
    return [[ADJNonEmptyString alloc]
                initWithConstStringValue:
                    [NSString stringWithFormat:@"Session number %@", sessionCountString]];
}

#pragma mark Internal Methods
- (BOOL)isOneWithNonEmtpyString:(nonnull ADJNonEmptyString *)nonEmptyString {
    ADJNonNegativeInt *_Nonnull oneInstance = [ADJNonNegativeInt instanceAtOne];

    ADJNonEmptyString *_Nonnull oneNonEmptyString = [oneInstance toNonEmptyString];

    return [oneNonEmptyString isEqual:nonEmptyString];
}

@end
