//
//  ADJThirdPartySharingPackageData.m
//  Adjust
//
//  Created by Aditi Agrawal on 17/09/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJThirdPartySharingPackageData.h"

#import "ADJConstantsParam.h"
#import "ADJStringMapBuilder.h"

#pragma mark Fields
#pragma mark - Public constants
NSString *const ADJThirdPartySharingPackageDataPath = @"third_party_sharing";

@implementation ADJThirdPartySharingPackageData
#pragma mark Instantiation
- (nonnull instancetype)initWithClientSdk:(nonnull NSString *)clientSdk
                               parameters:(nonnull ADJStringMap *)parameters {
    self = [super initWithPath:ADJThirdPartySharingPackageDataPath
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

- (nonnull instancetype)initV4DisableThirdPartySharingMigratedWithClientSdk:(nonnull NSString *)clientSdk
                                                                 parameters:(nonnull ADJStringMap *)parameters {
    ADJStringMapBuilder *_Nonnull parametersBuilder =
    [[ADJStringMapBuilder alloc] initWithStringMap:parameters];

    [parametersBuilder addPairWithConstValue:@"disable" key:@"sharing"];

    return [self initWithClientSdk:clientSdk parameters:
            [[ADJStringMap alloc] initWithStringMapBuilder:parametersBuilder]];
}


#pragma mark Protected Methods
#pragma mark - Concrete ADJSdkPackageBaseData
- (nonnull ADJNonEmptyString *)concreteGenerateShortDescription {
    ADJNonEmptyString *_Nullable isThirdPartySharingEnabledOrElseDisabled =
    [self.parameters pairValueWithKey:ADJParamThirdPartySharingKey];

    NSString *_Nullable isThirdPartySharingEnabledOrElseDisabledString =
    isThirdPartySharingEnabledOrElseDisabled != nil ?
    isThirdPartySharingEnabledOrElseDisabled.stringValue : nil;

    if ([ADJParamThirdPartySharingEnabledValue isEqual:
         isThirdPartySharingEnabledOrElseDisabledString])
    {
        return [[ADJNonEmptyString alloc]
                initWithConstStringValue:@"Enable Third Party Sharing"];
    }
    if ([ADJParamThirdPartySharingDisabledValue isEqual:
         isThirdPartySharingEnabledOrElseDisabledString])
    {
        return [[ADJNonEmptyString alloc]
                initWithConstStringValue:@"Disable Third Party Sharing"];
    }

    return [[ADJNonEmptyString alloc] initWithConstStringValue:@"Third Party Sharing"];
}

@end

