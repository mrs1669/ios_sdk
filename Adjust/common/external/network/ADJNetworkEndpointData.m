//
//  ADJNetworkEndpointData.m
//  Adjust
//
//  Created by Pedro Silva on 22.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJNetworkEndpointData.h"

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (nullable, readonly, strong, nonatomic) NSString *extraPath;
 @property (nullable, readonly, strong, nonatomic) NSString *urlOverwrite;
 //public @NonNull final ConnectionOptions connectionOptions;
 //public @NonNull final HttpsURLConnectionProvider httpsURLConnectionProvider;
 @property (nonnull, readonly, strong, nonatomic) ADJTimeLengthMilli *timeoutMilli;
*/

@implementation ADJNetworkEndpointData
#pragma mark Instantiation
- (nonnull instancetype)initWithExtraPath:(nullable NSString *)extraPath
                             urlOverwrite:(nullable NSString *)urlOverwrite
                             timeoutMilli:(nonnull ADJTimeLengthMilli *)timeoutMilli
{
    self = [super init];

    _extraPath = extraPath;
    _urlOverwrite = urlOverwrite;
    _timeoutMilli = timeoutMilli;

    return self;
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end
