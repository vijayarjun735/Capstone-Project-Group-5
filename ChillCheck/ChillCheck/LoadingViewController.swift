//
//  LoadingViewController.swift
//  Sample
//
//  Created by JAISON ABRAHAM on 2025-07-06.
//


import UIKit

class LoadingViewController: UIViewController {
    
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var appNameLabel: UILabel!
    @IBOutlet weak var taglineLabel: UILabel!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var versionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        applyTheme()
        startLoading()
    }
    
    private func setupUI() {
        // Configure the loading indicator
        loadingIndicator.style = .medium
        loadingIndicator.hidesWhenStopped = true
        
        // Set up the logo with a nice animation
        logoImageView.alpha = 0
        appNameLabel.alpha = 0
        taglineLabel.alpha = 0
        versionLabel.alpha = 0
    }
    
    private func applyTheme() {
        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        
        if #available(iOS 13.0, *) {
            view.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
        } else {
            view.backgroundColor = isDarkMode ? .black : .white
        }
    }
    
    private func startLoading() {
        // Start the loading indicator
        loadingIndicator.startAnimating()
        
        // Animate the UI elements appearing
        animateUIElements()
        
        // Simulate loading time (you can replace this with actual loading logic)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            self.finishLoading()
        }
    }
    
    private func animateUIElements() {
        // Animate logo appearance
        UIView.animate(withDuration: 0.8, delay: 0.2, options: [.curveEaseOut], animations: {
            self.logoImageView.alpha = 1.0
            self.logoImageView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }) { _ in
            UIView.animate(withDuration: 0.3) {
                self.logoImageView.transform = CGAffineTransform.identity
            }
        }
        
        // Animate app name
        UIView.animate(withDuration: 0.6, delay: 0.8, options: [.curveEaseOut], animations: {
            self.appNameLabel.alpha = 1.0
        })
        
        // Animate tagline
        UIView.animate(withDuration: 0.6, delay: 1.2, options: [.curveEaseOut], animations: {
            self.taglineLabel.alpha = 1.0
        })
        
        // Animate version label
        UIView.animate(withDuration: 0.4, delay: 1.8, options: [.curveEaseOut], animations: {
            self.versionLabel.alpha = 1.0
        })
    }
    
    private func finishLoading() {
        // Stop the loading indicator
        loadingIndicator.stopAnimating()
        
        // Transition to main app
        transitionToMainApp()
    }
    
    private func transitionToMainApp() {
        // Create the main storyboard and initial view controller
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let mainViewController = storyboard.instantiateViewController(withIdentifier: "Nav-Root") as? UINavigationController else {
            return
        }
        
        // Get the current window
        guard let window = view.window else { return }
        
        // Set the new root view controller with animation
        UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: {
            window.rootViewController = mainViewController
        }, completion: nil)
    }
    
    // MARK: - Simulate actual loading tasks
    private func performActualLoadingTasks() {
        // You can replace the simulated delay with actual loading logic here
        // For example:
        // - Load data from UserDefaults
        // - Initialize app settings
        // - Preload images or resources
        // - Check for app updates
        
        DispatchQueue.global(qos: .background).async {
            // Simulate some background work
            Thread.sleep(forTimeInterval: 1.0)
            
            // Switch back to main thread for UI updates
            DispatchQueue.main.async {
                self.finishLoading()
            }
        }
    }
}