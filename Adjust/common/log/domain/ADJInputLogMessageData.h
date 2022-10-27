//
//  ADJInputLogMessageData.h
//  Adjust
//
//  Created by Pedro Silva on 27.10.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const ADJLogLevelDevTrace;
FOUNDATION_EXPORT NSString *const ADJLogLevelDevDebug;
FOUNDATION_EXPORT NSString *const ADJLogLevelClientInfo;
FOUNDATION_EXPORT NSString *const ADJLogLevelClientNotice;
FOUNDATION_EXPORT NSString *const ADJLogLevelClientError;

NS_ASSUME_NONNULL_END

NS_ASSUME_NONNULL_BEGIN

@interface ADJInputLogMessageData : NSObject

@end

NS_ASSUME_NONNULL_END
