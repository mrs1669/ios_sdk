//
//  ADJAdjust.h
//  Adjust
//
//  Created by Aditi Agrawal on 04/07/22.
//

#import <Foundation/Foundation.h>

@protocol ADJAdjustInstance;
@interface ADJAdjust : NSObject

+ (nonnull id<ADJAdjustInstance>)instance;
+ (nonnull id<ADJAdjustInstance>)instanceForId:(nonnull NSString *)instanceId;

// instantiation
- (nullable instancetype)init NS_UNAVAILABLE;
@end
