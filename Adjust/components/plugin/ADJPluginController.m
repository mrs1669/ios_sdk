//
//  ADJPluginController.m
//  Adjust
//
//  Created by Pedro S. on 16.09.21.
//  Copyright © 2021 adjust GmbH. All rights reserved.
//

#import "ADJPluginController.h"

#import "ADJPluginPackageSendingPublisher.h"
#import "ADJPluginForegroundPublisher.h"
#import "ADJAdjustPlugin.h"
#import "ADJUtilSys.h"
#import "ADJUtilR.h"
#import "ADJPluginLogger.h"
#import "ADJAdjustPublishers.h"
#import "ADJUtilF.h"

#pragma mark Fields
@interface ADJPluginController ()
#pragma mark - Injected dependencies
#pragma mark - Internal variables
@property (nonnull, readonly, strong, nonatomic) ADJPluginPackageSendingPublisher *pluginPackageSendingPublisher;
@property (nonnull, readonly, strong, nonatomic) ADJPluginForegroundPublisher *pluginForegroundPublisher;
@property (nonnull, readonly, strong, nonatomic) NSMutableArray<id<ADJAdjustPlugin>> *loadedPluginList;
@end

@implementation ADJPluginController
#pragma mark Instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory {
    self = [super initWithLoggerFactory:loggerFactory source:@"PluginController"];

    _pluginPackageSendingPublisher = [[ADJPluginPackageSendingPublisher alloc] init];
    _pluginForegroundPublisher = [[ADJPluginForegroundPublisher alloc] init];
    _loadedPluginList = [[NSMutableArray alloc] init];

    [self ccLoadPluginsWithLoggerFactory:loggerFactory];

    return self;
}

- (void)ccLoadPluginsWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory {
    NSArray<NSString *> *_Nonnull pluginClassNameList = [ADJUtilSys pluginsClassNameList];

    for (NSString *_Nonnull pluginClassName in pluginClassNameList) {
        id _Nullable objectInstance = [ADJUtilR createDefaultInstanceWithClassName:pluginClassName];

        if (objectInstance == nil) {
            [self.logger debug:@"Could not find plugin for %@ class name", pluginClassName];
            continue;
        }

        if (! [objectInstance conformsToProtocol:@protocol(ADJAdjustPlugin)]) {
            [self.logger error:@"Could not cast class name %@ to plugin", pluginClassName];
            continue;
        }

        id<ADJAdjustPlugin> _Nonnull pluginInstance = (id<ADJAdjustPlugin>)objectInstance;

        ADJLogger *_Nonnull loggerForPlugin = [loggerFactory createLoggerWithSource:[pluginInstance source]];

        ADJPluginLogger *_Nonnull pluginLogger = [[ADJPluginLogger alloc] initWithLogger:loggerForPlugin];

        [pluginInstance setPluginDependenciesWithLoggerFactory:pluginLogger];

        [self.loadedPluginList addObject:pluginInstance];

        [self.logger debug:@"Found plugin for %@ class name, %@ source", pluginClassName, [pluginInstance source]];
    }
}

#pragma mark Public API
#pragma mark - ADJSdkPackageSendingSubscriber
- (void)willSendSdkPackageWithData:(nonnull id<ADJSdkPackageData>)sdkPackageData
                   parametersToAdd:(nonnull ADJStringMapBuilder *)parametersToAdd
                      headersToAdd:(nonnull ADJStringMapBuilder *)headersToAdd {
    // no need to check if has subscribers to avoid conversion,
    //  since it has checked when subscribing to publishers
    NSDictionary<NSString *, NSString *> *_Nonnull parametersFoundationMap = [sdkPackageData.parameters foundationStringMap];

    ADJStringMap *_Nonnull parametersToAddStringMap = [[ADJStringMap alloc] initWithStringMapBuilder:parametersToAdd];
    NSMutableDictionary<NSString *, NSString *> *_Nonnull parametersToAddFoundationMutableMap = [NSMutableDictionary dictionaryWithDictionary:[parametersToAddStringMap foundationStringMap]];

    [self.pluginPackageSendingPublisher.publisher notifySubscribersWithSubscriberBlock:
        ^(id<ADJAdjustPackageSendingSubscriber>  _Nonnull subscriber)
     {
        NSMutableDictionary<NSString *, NSString *> *_Nonnull headersToAddFoundationMutableMap = [[NSMutableDictionary alloc] init];

        [subscriber willSendSdkPackageWithClientSdk:sdkPackageData.clientSdk
                                               path:sdkPackageData.path
                                 readOnlyParameters:parametersFoundationMap
                                    parametersToAdd:parametersToAddFoundationMutableMap
                                       headersToAdd:headersToAddFoundationMutableMap];

        [ADJUtilF transferExternalParametersWithFoundationMapToRead:parametersToAddFoundationMutableMap
                                                  parametersToWrite:parametersToAdd
                                                             source:@"Plugin sending Sdk Package parameters"
                                                             logger:self.logger];

        [ADJUtilF transferExternalParametersWithFoundationMapToRead:headersToAddFoundationMutableMap
                                                  parametersToWrite:headersToAdd
                                                             source:@"Plugin sending Sdk Package headers"
                                                             logger:self.logger];
    }];
}

#pragma mark - ADJLifecycleSubscriber
- (void)onForegroundWithIsFromClientContext:(BOOL)isFromClientContext {
    [self.pluginForegroundPublisher.publisher notifySubscribersWithSubscriberBlock:
        ^(id<ADJAdjustForegroundSubscriber>  _Nonnull subscriber)
     {
        [subscriber onForeground];
    }];
}

- (void)onBackgroundWithIsFromClientContext:(BOOL)isFromClientContext {
    // nothing to do
}

#pragma mark - Subscriptions
- (void)ccSubscribeToPublishersWithSdkPackageSendingPublisher:(nonnull ADJSdkPackageSendingPublisher *)sdkPackageSendingPublisher
                                           lifecyclePublisher:(nonnull ADJLifecyclePublisher *)lifecyclePublisher
{
    ADJAdjustPublishers *_Nonnull adjustPublishers = [[ADJAdjustPublishers alloc] initWithPackageSendingPublisher:self.pluginPackageSendingPublisher
                                                                                              foregroundPublisher:self.pluginForegroundPublisher];

    for (id<ADJAdjustPlugin> _Nonnull plugin in self.loadedPluginList) {
        [plugin subscribeWithPublishers:adjustPublishers];
    }

    if ([self.pluginPackageSendingPublisher.publisher hasSubscribers]) {
        [sdkPackageSendingPublisher addSubscriber:self];
    }

    if ([self.pluginForegroundPublisher.publisher hasSubscribers]) {
        [lifecyclePublisher addSubscriber:self];
    }
}

@end
