//
//  AppDelegate.swift
//  Lensly
//
//  Created by Egor Bubiryov on 28.02.2024.
//

import Foundation
import SwiftUI

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        start()
        
        return true
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    private func start() {
        self.window = .init()
        let rootViewController = UIHostingController(rootView: ContentView())
        self.window?.rootViewController = rootViewController
        self.window?.makeKeyAndVisible()
    }
}
