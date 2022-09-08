//
//  ADJClickPackageData.m
//  Adjust
//
//  Created by Aditi Agrawal on 08/09/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJClickPackageData.h"

#import "ADJConstantsParam.h"

#pragma mark Fields
#pragma mark - Public constants
NSString *const ADJClickPackageDataPath = @"sdk_click";

@implementation ADJClickPackageData
#pragma mark Instantiation
- (nonnull instancetype)initWithClientSdk:(nonnull NSString *)clientSdk
                               parameters:(nonnull ADJStringMap *)parameters {
    self = [super initWithPath:ADJClickPackageDataPath
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
    ADJNonEmptyString *_Nullable clickSource = [self.parameters pairValueWithKey:ADJParamClickSourceKey];

    if (clickSource == nil) {
        return [[ADJNonEmptyString alloc] initWithConstStringValue:@"Click without source"];
    }

    return [[ADJNonEmptyString alloc]
            initWithConstStringValue:[NSString stringWithFormat:@"Click with source: %@", clickSource]];
}

@end
