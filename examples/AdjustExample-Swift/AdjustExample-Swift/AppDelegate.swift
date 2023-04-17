//
//  AppDelegate.swift
//  AdjustExample-Swift
//
//  Created by Aditi Agrawal on 22/08/22.
//

import UIKit
import Adjust

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let appToken = "36wbd8gmlvsw"
        let environment = ADJEnvironmentSandbox
        let adjustConfig = ADJAdjustConfig(appToken: appToken, environment: environment)
        
        ADJAdjust.instance().initSdk(with: adjustConfig)
        
        let event = ADJAdjustEvent.init(eventId: "d8bf3k")
        ADJAdjust.instance().trackEvent(event)
        
        let launchedDeeplink = ADJAdjustLaunchedDeeplink(string: "https://github.com/")
        ADJAdjust.instance().trackLaunchedDeeplink(launchedDeeplink)
        
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

extension AppDelegate: ADJAdjustLaunchedDeeplinkCallback {
    
    func didRead(withAdjustLaunchedDeeplink adjustLaunchedDeeplink: URL) {
        print("Adjust Launched Deeplink:\(adjustLaunchedDeeplink)")
    }
    
    func didFail(withMessage message: String) {
        print("Adjust Fail Message:\(message)")
    }
}
