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
    func didSelectHistory()
    func didSelectFilter()
    func didSelectSuggestions()
}

class MenuViewController: UIViewController {
    
    @IBOutlet weak var darkModeButton: UIButton!
    @IBOutlet weak var deleteAllButton: UIButton!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    private var historyButton: UIButton!
    private var filterButton: UIButton!
    private var suggestionsButton: UIButton!
    private var stackView: UIStackView!
    
    weak var delegate: MenuDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNewButtons()
        applyTheme()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applyTheme()
        updateSuggestionsButton()
    }
    
    private func setupUI() {
        title = "Menu"

        updateDarkModeButton()
  
        setupButtonStyle(darkModeButton, backgroundColor: UIColor.systemGray6, textColor: UIColor.label)
        setupButtonStyle(deleteAllButton, backgroundColor: UIColor.systemRed.withAlphaComponent(0.1), textColor: UIColor.systemRed)
    }
    
    private func setupNewButtons() {
  
        suggestionsButton = UIButton(type: .system)
        suggestionsButton.setTitle("Use Today", for: .normal)
        suggestionsButton.addTarget(self, action: #selector(suggestionsButtonTapped), for: .touchUpInside)
        setupButtonStyle(suggestionsButton, backgroundColor: UIColor.systemOrange.withAlphaComponent(0.15), textColor: UIColor.systemOrange)
    
        suggestionsButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        suggestionsButton.layer.borderWidth = 1.5
        suggestionsButton.layer.borderColor = UIColor.systemOrange.withAlphaComponent(0.3).cgColor

        historyButton = UIButton(type: .system)
        historyButton.setTitle("View History", for: .normal)
        historyButton.addTarget(self, action: #selector(historyButtonTapped), for: .touchUpInside)
        setupButtonStyle(historyButton, backgroundColor: UIColor.systemBlue.withAlphaComponent(0.1), textColor: UIColor.systemBlue)
   
        filterButton = UIButton(type: .system)
        filterButton.setTitle("Filter by Expiry", for: .normal)
        filterButton.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
        setupButtonStyle(filterButton, backgroundColor: UIColor.systemGreen.withAlphaComponent(0.1), textColor: UIColor.systemGreen)
    
        if let existingStackView = view.subviews.first(where: { $0 is UIStackView }) as? UIStackView {
      
            existingStackView.insertArrangedSubview(suggestionsButton, at: 0)
      
            existingStackView.insertArrangedSubview(historyButton, at: existingStackView.arrangedSubviews.count - 1)
            existingStackView.insertArrangedSubview(filterButton, at: existingStackView.arrangedSubviews.count - 1)
       
            suggestionsButton.heightAnchor.constraint(equalToConstant: 56).isActive = true
            historyButton.heightAnchor.constraint(equalToConstant: 56).isActive = true
            filterButton.heightAnchor.constraint(equalToConstant: 56).isActive = true
        }
    }
    
    private func setupButtonStyle(_ button: UIButton, backgroundColor: UIColor, textColor: UIColor) {
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.contentHorizontalAlignment = .left
        button.backgroundColor = backgroundColor
        button.setTitleColor(textColor, for: .normal)
        button.layer.cornerRadius = 12
        button.contentEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }
    
    private func updateDarkModeButton() {
        let currentMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        let title = currentMode ? "Switch to Light Mode" : "Switch to Dark Mode"
        darkModeButton.setTitle(title, for: .normal)
    }
    
    private func updateSuggestionsButton() {
        guard suggestionsButton != nil else { return }
        
        let allItems = FridgeDataManager.shared.loadFridgeItems()
        let calendar = Calendar.current
        let today = Date()
        
        var urgentCount = 0
        
        for item in allItems {
            guard let expirationDate = item.expirationDate else { continue }
            let daysUntilExpiration = calendar.dateComponents([.day], from: today, to: expirationDate).day ?? 0
   
            if daysUntilExpiration <= 2 {
                urgentCount += 1
            }
        }
        
        if urgentCount > 0 {
            suggestionsButton.setTitle("Use Today (\(urgentCount))", for: .normal)
   
            let pulseAnimation = CABasicAnimation(keyPath: "transform.scale")
            pulseAnimation.duration = 1.0
            pulseAnimation.fromValue = 1.0
            pulseAnimation.toValue = 1.05
            pulseAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            pulseAnimation.autoreverses = true
            pulseAnimation.repeatCount = Float.infinity
            suggestionsButton.layer.add(pulseAnimation, forKey: "pulse")
 
            suggestionsButton.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.2)
            suggestionsButton.layer.borderColor = UIColor.systemOrange.cgColor
        } else {
            suggestionsButton.setTitle("Use Today", for: .normal)
            suggestionsButton.layer.removeAnimation(forKey: "pulse")
            suggestionsButton.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.1)
            suggestionsButton.layer.borderColor = UIColor.systemOrange.withAlphaComponent(0.3).cgColor
        }
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
    
    @objc private func suggestionsButtonTapped() {
        dismiss(animated: true) {
            self.delegate?.didSelectSuggestions()
        }
    }
    
    @objc private func historyButtonTapped() {
        dismiss(animated: true) {
            self.delegate?.didSelectHistory()
        }
    }
    
    @objc private func filterButtonTapped() {
        dismiss(animated: true) {
            self.delegate?.didSelectFilter()
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
}
