//
//  SceneDelegate.swift
//  flipflap
//
//  Created by Zachary Gorak on 2/7/20.
//  Copyright © 2020 twodayslate. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else {
            print("returning")
            return
        }
        
        if let windowScene = scene as? UIWindowScene {
            print("setting controller")
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = ViewController()
            self.window = window
            
            self.window?.backgroundColor = UIColor.black
            
            if let data = UserDefaults.standard.object(forKey: "tint") as? Data, let color = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data) {
                
                self.window?.tintColor = color
            }
            
            UserDefaults.standard.addObserver(self, forKeyPath: "theme", options: .new, context: nil)
            self.setTheme()
            
            window.makeKeyAndVisible()
        }
        
        
        
        // don't fall asleep
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    deinit {
        UserDefaults.standard.removeObserver(self, forKeyPath: "theme")
    }
    
    func setTheme() {
        DispatchQueue.main.async {
            switch UserDefaults.standard.integer(forKey: "theme") {
            case 1:
                self.window?.overrideUserInterfaceStyle = .light
            case 2:
                self.window?.overrideUserInterfaceStyle = .dark
            default:
                self.window?.overrideUserInterfaceStyle = .unspecified
            }
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "theme" {
            self.setTheme()
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }


}

