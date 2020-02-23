//
//  AppDelegate.swift
//  MovaTest
//
//  Created by Danil Shchegol on 21.02.2020.
//  Copyright © 2020 Danil Shchegol. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        self.window?.rootViewController = PhotoSearchVC()
        self.window?.makeKeyAndVisible()
        
        return true
    }
}

