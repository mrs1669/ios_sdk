//
//  AppDelegate.m
//  AdjustTestApp
//
//  Created by Genady Buchatsky on 27.07.22.
//

#import "AppDelegate.h"
//#import 

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
//    [Adjust appWillOpenUrl:url];
    return YES;
}




@end
