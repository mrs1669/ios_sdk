//
//  ADJAdjustAttribution.m
//  Adjust
//
//  Created by Aditi Agrawal on 19/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJAdjustAttribution.h"

#import "ADJUtilObj.h"

@implementation ADJAdjustAttribution

#pragma mark - NSObject
- (nonnull NSString *)description {
    return [ADJUtilObj formatInlineKeyValuesWithName:
                @"AdjustAttribution",
                    @"trackerToken", self.trackerToken,
                    @"trackerName", self.trackerName,
                    @"network", self.network,
                    @"campaign", self.campaign,
                    @"adgroup", self.adgroup,
                    @"creative", self.creative,
                    @"clickLabel", self.clickLabel,
                    @"adid", self.adid,
                    @"deeplink", self.deeplink,
                    @"state", self.state,
                    @"costType", self.costType,
                    @"costAmount", @(self.costAmount),
                    @"costCurrency", self.costCurrency,
                nil];
}

@end

