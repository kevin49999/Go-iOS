//
//  AppDelegate.swift
//  Go
//
//  Created by Kevin Johnson on 4/7/19.
//  Copyright © 2019 Kevin Johnson. All rights reserved.
//

import AdSupport
import UIKit

import FirebaseCore
import FirebaseAnalytics
import FirebaseCrashlytics
import GoogleMobileAds


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        
        MobileAds.shared.start(completionHandler: nil)

        return true
    }
}

// MARK: - SceneDelegate

// window created from Main storyboard, set in Info.plist scene manifest
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
}
