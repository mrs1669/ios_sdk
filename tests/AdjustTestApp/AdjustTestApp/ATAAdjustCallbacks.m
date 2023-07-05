//
//  ATAAdjustCallbacks.m
//  AdjustTestApp
//
//  Created by Pedro Silva on 21.06.23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import "ATAAdjustCallbacks.h"

#import "ADJAdjustLaunchedDeeplinkCallback.h"
#import "ADJAdjustAttributionSubscriber.h"
#import "ADJAdjustCallback.h"
#import "ADJAdjustInternal.h"
#import "ADJAdjustAttribution.h"

@interface ATAAdjustCallbackBase : NSObject
@property (nullable, readonly, weak, nonatomic) ATLTestLibrary *testLibraryWeak;
@property (nonnull, readonly, strong, nonatomic) NSString *extraPath;

- (nonnull instancetype)initWithTestLibrary:(nonnull ATLTestLibrary *)testLibrary
                                  extraPath:(nonnull NSString *)extraPath;
@end

@interface ATAAdjustLaunchedDeeplinkGetter :
    ATAAdjustCallbackBase<ADJAdjustLaunchedDeeplinkCallback> @end
@interface ATAAdjustAttributionSendAllSubscriber :
    ATAAdjustCallbackBase<ADJAdjustAttributionSubscriber> @end
@interface ATAAdjustAttributionDeferredDeeplinkSubscriber :
    ATAAdjustCallbackBase<ADJAdjustAttributionSubscriber> @end
@interface ATAAdjustIdentifierGetter :
    ATAAdjustCallbackBase<ADJAdjustIdentifierCallback> @end
@interface ATAAdjustIdentifierSubscriber :
    ATAAdjustCallbackBase<ADJAdjustIdentifierSubscriber> @end

@implementation ATAAdjustCallbacks

+ (nonnull id<ADJAdjustLaunchedDeeplinkCallback>)
    adjustLaunchedDeeplinkGetterWithTestLibrary:(nonnull ATLTestLibrary *)testLibrary
    extraPath:(nonnull NSString *)extraPath
{
    return [[ATAAdjustLaunchedDeeplinkGetter alloc] initWithTestLibrary:testLibrary
                                                              extraPath:extraPath];
}

+ (nonnull id<ADJAdjustAttributionSubscriber>)
    adjustAttributionSubscriberWithTestLibrary:(nonnull ATLTestLibrary *)testLibrary
    extraPath:(nonnull NSString *)extraPath
{
    return [[ATAAdjustAttributionSendAllSubscriber alloc] initWithTestLibrary:testLibrary
                                                                    extraPath:extraPath];
}

+ (nonnull id<ADJAdjustAttributionSubscriber>)
    adjustAttributionDeferredDeeplinkSubscriberWithTestLibrary:(nonnull ATLTestLibrary *)testLibrary
    extraPath:(nonnull NSString *)extraPath
{
    return [[ATAAdjustAttributionDeferredDeeplinkSubscriber alloc] initWithTestLibrary:testLibrary
                                                                             extraPath:extraPath];
}

+ (nonnull id<ADJAdjustIdentifierCallback>)
    adjustIdentifierGetterWithTestLibrary:(nonnull ATLTestLibrary *)testLibrary
    extraPath:(nonnull NSString *)extraPath
{
    return [[ATAAdjustIdentifierGetter alloc] initWithTestLibrary:testLibrary
                                                        extraPath:extraPath];
}

+ (nonnull id<ADJAdjustIdentifierSubscriber>)
    adjustIdentifierSubscriberWithTestLibrary:(nonnull ATLTestLibrary *)testLibrary
    extraPath:(nonnull NSString *)extraPath
{
    return [[ATAAdjustIdentifierSubscriber alloc] initWithTestLibrary:testLibrary
                                                            extraPath:extraPath];
}

@end


@implementation ATAAdjustCallbackBase

- (nonnull instancetype)initWithTestLibrary:(nonnull ATLTestLibrary *)testLibrary
                                  extraPath:(nonnull NSString *)extraPath
{
    self = [super init];

    _testLibraryWeak = testLibrary;
    _extraPath = extraPath;

    return self;
}

- (void)addNullableStringWithKey:(nonnull NSString *)key
                           value:(nullable NSString *)value
{
    if (value == nil) {
        return;
    }
    [self.testLibraryWeak addInfoToSend:key value:value];
}

- (void)addNullableNumberWithKey:(nonnull NSString *)key
                           value:(nullable NSNumber *)value
{
    if (value == nil) {
        return;
    }
    [self.testLibraryWeak addInfoToSend:key value:value.description];
}

@end


@implementation ATAAdjustLaunchedDeeplinkGetter

#pragma mark - ADJAdjustLaunchedDeeplinkCallback
- (void)didReadWithAdjustLaunchedDeeplink:(nonnull NSString *)adjustLaunchedDeeplink {
    [self.testLibraryWeak addInfoHeaderToSend:@"method_name"
                                        value:ADJLaunchedDeeplinkGetterReadMethodName];
    // TODO change key to "value" in tests to be consistent
    [self.testLibraryWeak addInfoToSend:@"last_deeplink"
                                  value:adjustLaunchedDeeplink.description];
    [self.testLibraryWeak sendInfoToServer:self.extraPath];
}

- (void)didFailWithAdjustCallbackMessage:(nonnull NSString *)message {
    [self.testLibraryWeak addInfoHeaderToSend:@"method_name"
                                        value:ADJLaunchedDeeplinkGetterFailedMethodName];
    [self.testLibraryWeak addInfoToSend:@"fail_message" value:message];
    [self.testLibraryWeak sendInfoToServer:self.extraPath];
}

@end


@implementation ATAAdjustAttributionSendAllSubscriber

#pragma mark - ADJAdjustAttributionSubscriber
- (void)didChangeWithAdjustAttribution:(nonnull ADJAdjustAttribution *)adjustAttribution {
    [self.testLibraryWeak addInfoHeaderToSend:@"method_name"
                                        value:ADJChangedAttributionMethodName];
    [self addInfoWithAttribution:adjustAttribution];
    [self.testLibraryWeak sendInfoToServer:self.extraPath];
}

- (void)didReadWithAdjustAttribution:(nonnull ADJAdjustAttribution *)adjustAttribution {
    [self.testLibraryWeak addInfoHeaderToSend:@"method_name"
                                        value:ADJReadAttributionMethodName];
    [self addInfoWithAttribution:adjustAttribution];
    [self.testLibraryWeak sendInfoToServer:self.extraPath];
}

#pragma mark Internal Methods

- (void)addInfoWithAttribution:(nonnull ADJAdjustAttribution *)adjustAttribution {
    [self addNullableStringWithKey:@"tracker_token" value:adjustAttribution.trackerToken];
    [self addNullableStringWithKey:@"tracker_name" value:adjustAttribution.trackerName];
    [self addNullableStringWithKey:@"network" value:adjustAttribution.network];
    [self addNullableStringWithKey:@"campaign" value:adjustAttribution.campaign];
    [self addNullableStringWithKey:@"adgroup" value:adjustAttribution.adgroup];
    [self addNullableStringWithKey:@"creative" value:adjustAttribution.creative];
    [self addNullableStringWithKey:@"click_label" value:adjustAttribution.clickLabel];
    [self addNullableStringWithKey:@"deeplink" value:adjustAttribution.deeplink];
    [self addNullableStringWithKey:@"state" value:adjustAttribution.state];
    [self addNullableStringWithKey:@"cost_type" value:adjustAttribution.costType];
    [self addNullableNumberWithKey:@"cost_amount" value:adjustAttribution.costAmount];
    [self addNullableStringWithKey:@"cost_currency" value:adjustAttribution.costCurrency];
}

@end


@implementation ATAAdjustAttributionDeferredDeeplinkSubscriber

#pragma mark - ADJAdjustAttributionSubscriber
- (void)didChangeWithAdjustAttribution:(nonnull ADJAdjustAttribution *)adjustAttribution {
    [self.testLibraryWeak addInfoHeaderToSend:@"method_name"
                                        value:ADJChangedAttributionMethodName];
    [self addNullableStringWithKey:@"deeplink" value:adjustAttribution.deeplink];
    [self.testLibraryWeak sendInfoToServer:self.extraPath];
}

- (void)didReadWithAdjustAttribution:(nonnull ADJAdjustAttribution *)adjustAttribution {
    [self.testLibraryWeak addInfoHeaderToSend:@"method_name"
                                        value:ADJReadAttributionMethodName];
    [self addNullableStringWithKey:@"deeplink" value:adjustAttribution.deeplink];
    [self.testLibraryWeak sendInfoToServer:self.extraPath];
}

@end


@implementation ATAAdjustIdentifierGetter

#pragma mark - ADJAdjustIdentifierCallback
- (void)didReadWithAdjustIdentifier:(nonnull NSString *)adid {
    [self.testLibraryWeak addInfoHeaderToSend:@"method_name"
                                        value:ADJAdjustIdentifierGetterReadMethodName];
    [self.testLibraryWeak addInfoToSend:@"value" value:adid];
    [self.testLibraryWeak sendInfoToServer:self.extraPath];
}

- (void)didFailWithAdjustCallbackMessage:(nonnull NSString *)message {
    [self.testLibraryWeak addInfoHeaderToSend:@"method_name"
                                        value:ADJAdjustIdentifierGetterFailedMethodName];
    [self.testLibraryWeak addInfoToSend:@"fail_message" value:message];
    [self.testLibraryWeak sendInfoToServer:self.extraPath];
}

@end


@implementation ATAAdjustIdentifierSubscriber

#pragma mark - ADJAdjustIdentifierSubscriber
- (void)didReadWithAdjustIdentifier:(nonnull NSString *)adid {
    [self.testLibraryWeak addInfoHeaderToSend:@"method_name"
                                        value:ADJReadAdjustIdentifierdMethodName];
    [self.testLibraryWeak addInfoToSend:@"adid" value:adid];
    [self.testLibraryWeak sendInfoToServer:self.extraPath];
}

- (void)didChangeWithAdjustIdentifier:(nonnull NSString *)adid {

    [self.testLibraryWeak addInfoHeaderToSend:@"method_name"
                                        value:ADJChangedAdjustIdentifierMethodName];
    [self.testLibraryWeak addInfoToSend:@"adid" value:adid];
    [self.testLibraryWeak sendInfoToServer:self.extraPath];
}

@end
