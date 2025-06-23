//
//  MenuViewController.swift
//  ChillCheck
//
//  Created by JAISON ABRAHAM on 2025-06-22.
//

import UIKit

protocol MenuDelegate: AnyObject {
    func didSelectDarkModeToggle()
    func didSelectDeleteAllData()
}

class MenuViewController: UIViewController {
    
    @IBOutlet weak var darkModeButton: UIButton!
    @IBOutlet weak var deleteAllButton: UIButton!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    weak var delegate: MenuDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        applyTheme()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applyTheme()
    }
    
    private func setupUI() {
        title = "Menu"
        
        updateDarkModeButton()
        
        darkModeButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        darkModeButton.contentHorizontalAlignment = .left
        darkModeButton.backgroundColor = UIColor.systemGray6
        darkModeButton.layer.cornerRadius = 12
        darkModeButton.contentEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
        deleteAllButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        deleteAllButton.contentHorizontalAlignment = .left
        deleteAllButton.backgroundColor = UIColor.systemRed.withAlphaComponent(0.1)
        deleteAllButton.setTitleColor(UIColor.systemRed, for: .normal)
        deleteAllButton.layer.cornerRadius = 12
        deleteAllButton.contentEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }
    
    private func updateDarkModeButton() {
        let currentMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        let title = currentMode ? "Switch to Light Mode" : "Switch to Dark Mode"
        darkModeButton.setTitle(title, for: .normal)
    }
    
    private func applyTheme() {
        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        
        if #available(iOS 13.0, *) {
            view.window?.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
        } else {
            navigationController?.navigationBar.barStyle = isDarkMode ? .black : .default
            view.backgroundColor = isDarkMode ? .black : .white
        }
    }
    
    @IBAction func darkModeButtonTapped(_ sender: UIButton) {
        dismiss(animated: true) {
            self.delegate?.didSelectDarkModeToggle()
        }
    }
    
    @IBAction func deleteAllButtonTapped(_ sender: UIButton) {
        dismiss(animated: true) {
            self.delegate?.didSelectDeleteAllData()
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
}
