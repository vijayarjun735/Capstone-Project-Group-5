//
//  SceneDelegate.swift
//  ChillCheck
//
//  Created by Arjun V on 2025-05-18.
//

import UIKit
import UserNotifications

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // Create the window
        window = UIWindow(windowScene: windowScene)
        
        // Apply theme first
        applyTheme()
        
        // Show loading screen first
        showLoadingScreen()
        
        // Make window visible
        window?.makeKeyAndVisible()
        
        // Set up notifications
        setupNotifications()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        applyTheme()
        
        // Update notification content when app becomes active
        if NotificationManager.shared.isNotificationEnabled {
            NotificationManager.shared.updateNotificationContent()
        }
        
        // Clear badge count when app becomes active
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        applyTheme()
        
        // Update notifications when coming back to foreground
        if NotificationManager.shared.isNotificationEnabled {
            NotificationManager.shared.updateNotificationContent()
        }
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    // MARK: - Notification Setup
    private func setupNotifications() {
        UNUserNotificationCenter.current().delegate = NotificationManager.shared
        
        // Update notifications if enabled
        if NotificationManager.shared.isNotificationEnabled {
            NotificationManager.shared.updateNotificationContent()
        }
    }
    
    // MARK: - Loading Screen
    private func showLoadingScreen() {
        let loadingStoryboard = UIStoryboard(name: "Loading", bundle: nil)
        guard let loadingViewController = loadingStoryboard.instantiateViewController(withIdentifier: "LoadingViewController") as? LoadingViewController else {
            // Fallback to main storyboard if loading screen fails
            showMainApp()
            return
        }
        
        window?.rootViewController = loadingViewController
    }
    
    private func showMainApp() {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        guard let mainViewController = mainStoryboard.instantiateViewController(withIdentifier: "Nav-Root") as? UINavigationController else {
            return
        }
        window?.rootViewController = mainViewController
    }
    
    // MARK: - Theme Management
    private func applyTheme() {
        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        
        if #available(iOS 13.0, *) {
            window?.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
        }
    }
}
