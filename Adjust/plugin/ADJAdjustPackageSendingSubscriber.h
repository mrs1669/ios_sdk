//
//  ADJAdjustPackageSendingSubscriber.h
//  Adjust
//
//  Created by Pedro S. on 15.09.21.
//  Copyright © 2021 adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ADJAdjustPackageSendingSubscriber <NSObject>

- (void)willSendSdkPackageWithClientSdk:(nonnull NSString *)clientSdk
                                   path:(nonnull NSString *)path
                     readOnlyParameters:(nonnull NSDictionary<NSString *, NSString *> *)readOnlyParameters
                        parametersToAdd:(nonnull NSMutableDictionary<NSString *, NSString *> *)parametersToAdd
                           headersToAdd:(nonnull NSMutableDictionary<NSString *, NSString *> *)headersToAdd;

@end

@protocol ADJAdjustPackageSendingPublisher <NSObject>

- (void)addPackageSendingSubscriber:(nonnull id<ADJAdjustPackageSendingSubscriber>)packageSendingSubscriber;

@end
