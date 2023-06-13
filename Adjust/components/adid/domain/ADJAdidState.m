//
//  ADJAdidState.m
//  Adjust
//
//  Created by Pedro Silva on 13.06.23.
//  Copyright © 2023 Adjust GmbH. All rights reserved.
//

#import "ADJAdidState.h"

@interface ADJAdidState ()
#pragma mark - Injected dependencies
@property (nonnull, readwrite, strong, nonatomic) ADJAdidStateData *stateData;

@end

@implementation ADJAdidState

#pragma mark Instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                             initialStateData:(nonnull ADJAdidStateData *)initialStateData
{
    self = [super initWithLoggerFactory:loggerFactory loggerName:@"ADJAdidState"];
    _stateData = initialStateData;

    return self;
}

#pragma mark Public API
- (nullable ADJAdidStateData *)updateStateWithReceivedAdid:
    (nullable ADJNonEmptyString *)receivedAdid
{
    if (receivedAdid == nil) {
        return nil;
    }

    if ([receivedAdid isEqual:self.stateData.adid]) {
        return nil;
    }

    self.stateData = [[ADJAdidStateData alloc] initWithAdid:receivedAdid];

    return self.stateData;
}

@end
