//
//  ADJClientBillingSubscriptionData.h
//  Adjust
//
//  Created by Aditi Agrawal on 17/09/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJClientActionIoDataInjectable.h"
#import "ADJAdjustBillingSubscription.h"
#import "ADJLogger.h"
#import "ADJIoData.h"
#import "ADJMoney.h"
#import "ADJNonEmptyString.h"
#import "ADJTimestampMilli.h"

// public constants
NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const ADJClientBillingSubcriptionDataMetadataTypeValue;

NS_ASSUME_NONNULL_END

@interface ADJClientBillingSubscriptionData : NSObject<ADJClientActionIoDataInjectable>
// instantiation
+ (nullable instancetype)instanceFromClientWithAdjustBillingSubscription:(nullable ADJAdjustBillingSubscription *)adjustBillingSubscription
                                                                  logger:(nonnull ADJLogger *)logger;

+ (nullable instancetype)instanceFromClientActionInjectedIoDataWithData:(nonnull ADJIoData *)clientActionInjectedIoData
                                                                 logger:(nonnull ADJLogger *)logger;

- (nullable instancetype)init NS_UNAVAILABLE;

// public properties
@property (nonnull, readonly, strong, nonatomic) ADJMoney *price;
@property (nonnull, readonly, strong, nonatomic) ADJNonEmptyString *transactionId;
@property (nonnull, readonly, strong, nonatomic) ADJNonEmptyString *receiptDataString;
@property (nonnull, readonly, strong, nonatomic) ADJNonEmptyString *billingStore;
@property (nullable, readonly, strong, nonatomic) ADJTimestampMilli *transactionTimestamp;
@property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *salesRegion;
@property (nullable, readonly, strong, nonatomic) ADJStringMap *callbackParameters;
@property (nullable, readonly, strong, nonatomic) ADJStringMap *partnerParameters;

@end

