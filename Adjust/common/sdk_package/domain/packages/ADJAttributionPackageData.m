//
//  ADJAttributionPackageData.m
//  Adjust
//
//  Created by Aditi Agrawal on 16/09/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJAttributionPackageData.h"

#import "ADJConstantsParam.h"

#pragma mark Fields
#pragma mark - Public constants
NSString *const ADJAttributionPackageDataPath = @"attribution";

@implementation ADJAttributionPackageData
#pragma mark Instantiation
- (nonnull instancetype)initWithClientSdk:(nonnull NSString *)clientSdk
                               parameters:(nonnull ADJStringMap *)parameters {
    self = [super initWithPath:ADJAttributionPackageDataPath
                     clientSdk:clientSdk
  isPostOrElseGetNetworkMethod:NO
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
    return [[ADJNonEmptyString alloc] initWithConstStringValue:@"Attribution"];
}

@end
