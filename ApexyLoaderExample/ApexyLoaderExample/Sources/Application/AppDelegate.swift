//
//  AppDelegate.swift
//  ApexyLoaderExample
//
//  Created by Daniil Subbotin on 04.03.2021.
//

import UIKit

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let window = UIWindow()
        self.window = window
      
        let fetchVC = FetchViewController()
        fetchVC.tabBarItem = UITabBarItem(
            title: "Fetch",
            image: UIImage(systemName: "arrow.down.square.fill"),
            tag: 0)

        let resultVC = ResultViewController()
        resultVC.tabBarItem = UITabBarItem(
            title: "Result",
            image: UIImage(systemName: "list.bullet"),
            tag: 1)

        let tbc = UITabBarController()
        tbc.viewControllers = [fetchVC, resultVC]
        
        window.frame = UIScreen.main.bounds
        window.rootViewController = tbc
        window.makeKeyAndVisible()
        
        return true
    }

}

