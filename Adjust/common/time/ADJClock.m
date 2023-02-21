//
//  ADJClock.m
//  Adjust
//
//  Created by Aditi Agrawal on 20/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJClock.h"

#include <sys/sysctl.h>
#include <time.h>

@implementation ADJClock
#pragma mark Instantiation
- (nonnull instancetype)init {
    self = [super init];
    
    return self;
}

#pragma mark Public API
- (nonnull ADJResultNN<ADJTimestampMilli *> *)nonMonotonicNowTimestamp {
    return [ADJTimestampMilli
            instanceWithTimeIntervalSecondsSince1970:[NSDate.date timeIntervalSince1970]];
}

- (nullable ADJRelativeTimestamp *)monotonicRelativeTimestamp {
    if (@available(iOS 10.0, macOS 10.12, tvOS 10.0, watchOS 3.0, *)) {
        struct timespec timespecValue;
        
        int gettimmeReturnValue = clock_gettime(CLOCK_MONOTONIC_RAW, &timespecValue);
        
        if (gettimmeReturnValue == 0) {
            return [[ADJRelativeTimestamp alloc] initWithTimespec:timespecValue];
        }
        
        return nil;
    }
    
    struct timeval * uptimePtr = NULL;
    
    [self injectUptime:uptimePtr];
    
    if (uptimePtr == NULL) {
        return nil;
    }
    
    return [[ADJRelativeTimestamp alloc] initWithTimeval:*uptimePtr];
}

#pragma mark Internal Methods
// Adapted from https://stackoverflow.com/a/40497811
- (void)injectUptime:(struct timeval *)timevalPtr {
    struct timeval * beforeNowPtr = NULL;
    struct timeval * afterNowPtr = NULL;
    struct timeval * nowPtr = NULL;
    
    [self injectKernelBootime:afterNowPtr];
    
    if (afterNowPtr == NULL) {
        return;
    }
    
    do {
        *beforeNowPtr = *afterNowPtr;
        gettimeofday(nowPtr, NULL);
        if (nowPtr == NULL) {
            return;
        }
        
        [self injectKernelBootime:afterNowPtr];
        if (afterNowPtr == NULL) {
            return;
        }
        
    } while ((*afterNowPtr).tv_sec != (*beforeNowPtr).tv_sec
             && (*afterNowPtr).tv_usec != (*beforeNowPtr).tv_usec);
    
    struct timeval uptime = {
        (*nowPtr).tv_sec - (*beforeNowPtr).tv_sec,
        (*nowPtr).tv_usec - (*beforeNowPtr).tv_usec
    };
    
    *timevalPtr = uptime;
}

- (void)injectKernelBootime:(struct timeval *)timevalPtr {
    struct timeval boottime;
    
    int mib[2] = {CTL_KERN, KERN_BOOTTIME};
    
    size_t size = sizeof(boottime);
    
    int rc = sysctl(mib, 2, &boottime, &size, NULL, 0);
    
    if (rc != 0) {
        return;
    }
    
    *timevalPtr = boottime;
}

@end
