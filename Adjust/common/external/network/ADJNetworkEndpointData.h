//
//  ADJNetworkEndpointData.h
//  Adjust
//
//  Created by Pedro Silva on 22.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJTimeLengthMilli.h"

@interface ADJNetworkEndpointData : NSObject
// instantiation
- (nonnull instancetype)initWithExtraPath:(nullable NSString *)extraPath
                             urlOverwrite:(nullable NSString *)urlOverwrite
                             timeoutMilli:(nonnull ADJTimeLengthMilli *)timeoutMilli
    NS_DESIGNATED_INITIALIZER;

- (nullable instancetype)init NS_UNAVAILABLE;

// public properties
@property (nullable, readonly, strong, nonatomic) NSString *extraPath;
@property (nullable, readonly, strong, nonatomic) NSString *urlOverwrite;
//public @NonNull final ConnectionOptions connectionOptions;
//public @NonNull final HttpsURLConnectionProvider httpsURLConnectionProvider;
@property (nonnull, readonly, strong, nonatomic) ADJTimeLengthMilli *timeoutMilli;

@end
