//
//  ADJLogBuilder.h
//  Adjust
//
//  Created by Pedro Silva on 28.10.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJLogBuildCallback.h"

@protocol ADJClientLogBuilder <NSObject>

@property(nonnull, nonatomic, copy, readonly)
    id<ADJClientLogBuilder> _Nonnull (^wKv)
        (NSString *_Nonnull key, NSString * _Nullable value);

@property(nonnull, nonatomic, copy, readonly)
    id<ADJClientLogBuilder> _Nonnull (^log)(void);

@end

@interface ADJLogBuilder : NSObject<ADJClientLogBuilder>
// instantiation
- (nonnull instancetype)initWithLevel:(nonnull NSString *)logLevel
                              message:(nonnull NSString *)message
                     logBuildCallback:(nonnull id<ADJLogBuildCallback>)logBuildCallback
    NS_DESIGNATED_INITIALIZER;

- (nullable instancetype)init NS_UNAVAILABLE;

// public properties and API
@property(nonnull, nonatomic, copy, readonly)
    ADJLogBuilder *_Nonnull (^wIssue)(NSString * _Nonnull issueType);
@property(nonnull, nonatomic, copy, readonly)
    ADJLogBuilder *_Nonnull (^wKv)
        (NSString *_Nonnull key, NSString * _Nullable value);
@property(nonnull, nonatomic, copy, readonly)
    ADJLogBuilder *_Nonnull (^wError)(NSError * _Nonnull nsError);

@property(nonnull, nonatomic, copy, readonly)
    ADJLogBuilder *_Nonnull (^end)(void);

@end
