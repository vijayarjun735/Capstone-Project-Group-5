//
//  MenuViewController.swift
//  ChillCheck
//
//  Created by JAISON ABRAHAM on 2025-06-22.
//

import UIKit
import UserNotifications

protocol MenuDelegate: AnyObject {
    func didSelectDarkModeToggle()
    func didSelectDeleteAllData()
    func didSelectHistory()
    func didSelectFilter()
    func didSelectSuggestions()
}

protocol TimePickerDelegate: AnyObject {
    func didSelectTime(_ time: Date)
}

class MenuViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var darkModeButton: UIButton!
    @IBOutlet weak var deleteAllButton: UIButton!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    // MARK: - UI Elements
    private var scrollView: UIScrollView!
    private var contentView: UIView!
    private var mainStackView: UIStackView!
    
    // Custom Buttons
    private var notificationButton: UIButton!
    private var timePickerButton: UIButton!
    private var testNotificationButton: UIButton!
    private var suggestionsButton: UIButton!
    private var historyButton: UIButton!
    private var filterButton: UIButton!
    private var debugButton: UIButton!
    
    // MARK: - Properties
    weak var delegate: MenuDelegate?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupScrollView()
        setupMainStackView()
        setupAllButtons()
        setupConstraints()
        applyTheme()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateDynamicContent()
        applyTheme()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        title = "Menu"
        navigationController?.navigationBar.prefersLargeTitles = false
        view.backgroundColor = UIColor.systemBackground
    }
    
    private func setupScrollView() {
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)
        
        contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
    }
    
    private func setupMainStackView() {
        mainStackView = UIStackView()
        mainStackView.axis = .vertical
        mainStackView.spacing = 16
        mainStackView.distribution = .fill
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(mainStackView)
    }
    
    private func setupAllButtons() {
        // Create all custom buttons
        createNotificationButton()
        createTimePickerButton()
        createSuggestionsButton()
        createHistoryButton()
        createFilterButton()
        
        // Add section headers and buttons to stack
        addSectionToStack(title: "Notifications", buttons: [notificationButton, timePickerButton])
        addSectionToStack(title: "Quick Actions", buttons: [suggestionsButton, historyButton, filterButton])
        addSectionToStack(title: "Settings", buttons: [darkModeButton, deleteAllButton])
        
        // Setup existing buttons from storyboard
        setupExistingButtons()
    }
    
    private func addSectionToStack(title: String, buttons: [UIButton]) {
        // Add section header
        let headerLabel = createSectionHeader(title: title)
        mainStackView.addArrangedSubview(headerLabel)
        
        // Add buttons
        for button in buttons {
            mainStackView.addArrangedSubview(button)
        }
        
        // Add spacing after section
        let spacer = UIView()
        spacer.heightAnchor.constraint(equalToConstant: 8).isActive = true
        mainStackView.addArrangedSubview(spacer)
    }
    
    private func createSectionHeader(title: String) -> UILabel {
        let label = UILabel()
        label.text = title
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = UIColor.systemBlue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Scroll view constraints
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Content view constraints
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Stack view constraints
            mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            mainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    // MARK: - Button Creation Methods
    private func createNotificationButton() {
        notificationButton = createStyledButton(
            title: "Enable Notifications",
            backgroundColor: UIColor.systemPurple.withAlphaComponent(0.1),
            textColor: UIColor.systemPurple,
            icon: "bell.fill",
            action: #selector(notificationButtonTapped)
        )
    }
    
    private func createTimePickerButton() {
        timePickerButton = createStyledButton(
            title: "Set Notification Time (\(NotificationManager.shared.notificationTimeString))",
            backgroundColor: UIColor.systemTeal.withAlphaComponent(0.1),
            textColor: UIColor.systemTeal,
            icon: "clock.fill",
            action: #selector(timePickerButtonTapped)
        )
    }
    

    private func createSuggestionsButton() {
        suggestionsButton = createStyledButton(
            title: "Use Today",
            backgroundColor: UIColor.systemOrange.withAlphaComponent(0.15),
            textColor: UIColor.systemOrange,
            icon: "clock.fill",
            action: #selector(suggestionsButtonTapped)
        )
        
        // Special styling for suggestions button
        suggestionsButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        suggestionsButton.layer.borderWidth = 1.5
        suggestionsButton.layer.borderColor = UIColor.systemOrange.withAlphaComponent(0.3).cgColor
    }
    
    private func createHistoryButton() {
        historyButton = createStyledButton(
            title: "View History",
            backgroundColor: UIColor.systemBlue.withAlphaComponent(0.1),
            textColor: UIColor.systemBlue,
            icon: "clock.arrow.circlepath",
            action: #selector(historyButtonTapped)
        )
    }
    
    private func createFilterButton() {
        filterButton = createStyledButton(
            title: "Filter by Expiry",
            backgroundColor: UIColor.systemGreen.withAlphaComponent(0.1),
            textColor: UIColor.systemGreen,
            icon: "line.3.horizontal.decrease.circle.fill",
            action: #selector(filterButtonTapped)
        )
    }
    

    private func createStyledButton(title: String,
                                  backgroundColor: UIColor,
                                  textColor: UIColor,
                                  icon: String? = nil,
                                  action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: action, for: .touchUpInside)
        setupButtonStyle(button, backgroundColor: backgroundColor, textColor: textColor, icon: icon)
        return button
    }
    
    private func setupButtonStyle(_ button: UIButton,
                                backgroundColor: UIColor,
                                textColor: UIColor,
                                icon: String? = nil) {
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.titleLabel?.numberOfLines = 0
        button.backgroundColor = backgroundColor
        button.setTitleColor(textColor, for: .normal)
        button.layer.cornerRadius = 12
        button.contentEdgeInsets = UIEdgeInsets(top: 16, left: 20, bottom: 16, right: 20)
        button.contentHorizontalAlignment = .left
        
        // Add icon if provided
        if let iconName = icon {
            let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
            let image = UIImage(systemName: iconName, withConfiguration: config)
            button.setImage(image, for: .normal)
            button.tintColor = textColor
            button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12)
            button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0)
        }
        
        // Add height constraint
        button.heightAnchor.constraint(greaterThanOrEqualToConstant: 56).isActive = true
        
        // Add shadow for better visual hierarchy
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 1)
        button.layer.shadowOpacity = 0.1
        button.layer.shadowRadius = 2
        button.layer.masksToBounds = false
    }
    
    private func setupExistingButtons() {
        setupButtonStyle(darkModeButton,
                        backgroundColor: UIColor.systemGray6,
                        textColor: UIColor.label,
                        icon: "moon.fill")
        
        setupButtonStyle(deleteAllButton,
                        backgroundColor: UIColor.systemRed.withAlphaComponent(0.1),
                        textColor: UIColor.systemRed,
                        icon: "trash.fill")
    }
    
    // MARK: - Dynamic Content Updates
    private func updateDynamicContent() {
        updateDarkModeButton()
        updateNotificationButton()
        updateTimePickerButton()
        updateSuggestionsButton()
    }
    
    private func updateDarkModeButton() {
        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        let title = isDarkMode ? "Switch to Light Mode" : "Switch to Dark Mode"
        let icon = isDarkMode ? "sun.max.fill" : "moon.fill"
        
        darkModeButton.setTitle(title, for: .normal)
        
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        let image = UIImage(systemName: icon, withConfiguration: config)
        darkModeButton.setImage(image, for: .normal)
    }
    
    private func updateNotificationButton() {
        let isEnabled = NotificationManager.shared.isNotificationEnabled
        
        if isEnabled {
            notificationButton.setTitle("Disable Notifications", for: .normal)
            notificationButton.backgroundColor = UIColor.systemPurple.withAlphaComponent(0.2)
            addNotificationIndicator()
        } else {
            notificationButton.setTitle("Enable Notifications", for: .normal)
            notificationButton.backgroundColor = UIColor.systemPurple.withAlphaComponent(0.1)
            removeNotificationIndicator()
        }
    }
    
    private func updateTimePickerButton() {
        timePickerButton.setTitle("Set Notification Time (\(NotificationManager.shared.notificationTimeString))", for: .normal)
        
        // Show/hide based on notification status
        let isEnabled = NotificationManager.shared.isNotificationEnabled
        timePickerButton.alpha = isEnabled ? 1.0 : 0.5
        timePickerButton.isEnabled = isEnabled
        
        if isEnabled {
            timePickerButton.backgroundColor = UIColor.systemTeal.withAlphaComponent(0.15)
        } else {
            timePickerButton.backgroundColor = UIColor.systemTeal.withAlphaComponent(0.05)
        }
    }
    
    private func updateSuggestionsButton() {
        let urgentCount = getUrgentItemsCount()
        
        if urgentCount > 0 {
            suggestionsButton.setTitle("Use Today (\(urgentCount) urgent)", for: .normal)
            addPulseAnimation()
            suggestionsButton.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.2)
            suggestionsButton.layer.borderColor = UIColor.systemOrange.cgColor
        } else {
            suggestionsButton.setTitle("Use Today", for: .normal)
            removePulseAnimation()
            suggestionsButton.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.15)
            suggestionsButton.layer.borderColor = UIColor.systemOrange.withAlphaComponent(0.3).cgColor
        }
    }
    
    // MARK: - Helper Methods
    private func getUrgentItemsCount() -> Int {
        let allItems = FridgeDataManager.shared.loadFridgeItems()
        let calendar = Calendar.current
        let today = Date()
        
        return allItems.filter { item in
            guard let expirationDate = item.expirationDate else { return false }
            let daysUntilExpiration = calendar.dateComponents([.day], from: today, to: expirationDate).day ?? 0
            return daysUntilExpiration <= 2
        }.count
    }
    
    private func addNotificationIndicator() {
        removeNotificationIndicator()
        
        let indicator = UIView()
        indicator.backgroundColor = .systemGreen
        indicator.layer.cornerRadius = 6
        indicator.tag = 1001
        indicator.translatesAutoresizingMaskIntoConstraints = false
        
        notificationButton.addSubview(indicator)
        
        NSLayoutConstraint.activate([
            indicator.trailingAnchor.constraint(equalTo: notificationButton.trailingAnchor, constant: -16),
            indicator.centerYAnchor.constraint(equalTo: notificationButton.centerYAnchor),
            indicator.widthAnchor.constraint(equalToConstant: 12),
            indicator.heightAnchor.constraint(equalToConstant: 12)
        ])
    }
    
    private func removeNotificationIndicator() {
        notificationButton.subviews.forEach { view in
            if view.tag == 1001 {
                view.removeFromSuperview()
            }
        }
    }
    
    private func addPulseAnimation() {
        removePulseAnimation()
        
        let pulseAnimation = CABasicAnimation(keyPath: "transform.scale")
        pulseAnimation.duration = 1.0
        pulseAnimation.fromValue = 1.0
        pulseAnimation.toValue = 1.02
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = Float.infinity
        
        suggestionsButton.layer.add(pulseAnimation, forKey: "pulse")
    }
    
    private func removePulseAnimation() {
        suggestionsButton.layer.removeAnimation(forKey: "pulse")
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
    
    // MARK: - Notification Handling
    private func handleNotificationPermission() {
        let isCurrentlyEnabled = NotificationManager.shared.isNotificationEnabled
        
        if isCurrentlyEnabled {
            disableNotifications()
        } else {
            enableNotifications()
        }
    }
    
    private func enableNotifications() {
        NotificationManager.shared.checkPermissionStatus { [weak self] hasPermission in
            if hasPermission {
                self?.activateNotifications()
            } else {
                self?.requestNotificationPermission()
            }
        }
    }
    
    private func disableNotifications() {
        NotificationManager.shared.isNotificationEnabled = false
        updateNotificationButton()
        updateTimePickerButton()
        
        showAlert(title: "Notifications Disabled",
                 message: "You will no longer receive daily expiration reminders.")
    }
    
    private func activateNotifications() {
        NotificationManager.shared.isNotificationEnabled = true
        updateNotificationButton()
        updateTimePickerButton()
        
        showAlert(title: "Notifications Enabled",
                 message: "You'll receive daily reminders at \(NotificationManager.shared.notificationTimeString) about items expiring that day.")
    }
    
    private func requestNotificationPermission() {
        NotificationManager.shared.requestPermission { [weak self] granted in
            if granted {
                self?.activateNotifications()
            } else {
                self?.showPermissionDeniedAlert()
            }
        }
    }
    
    private func showPermissionDeniedAlert() {
        let alert = UIAlertController(
            title: "Permission Required",
            message: "To receive expiration reminders, please enable notifications in Settings.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
            self.openSettings()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func openSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(settingsURL)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Button Actions
    @objc private func notificationButtonTapped() {
        handleNotificationPermission()
    }
    
    @objc private func timePickerButtonTapped() {
        guard NotificationManager.shared.isNotificationEnabled else {
            showAlert(title: "Enable Notifications First",
                     message: "Please enable notifications before setting a time.")
            return
        }
        
        // Create a proper view controller for the date picker
        let timePickerVC = TimePickerViewController()
        timePickerVC.delegate = self
        
        // Set current notification time
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.hour = NotificationManager.shared.notificationHour
        dateComponents.minute = NotificationManager.shared.notificationMinute
        
        if let currentTime = calendar.date(from: dateComponents) {
            timePickerVC.selectedTime = currentTime
        }
        
        let navController = UINavigationController(rootViewController: timePickerVC)
        navController.modalPresentationStyle = .formSheet
        
        present(navController, animated: true)
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
    
    // MARK: - IBActions
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

// MARK: - TimePickerDelegate
extension MenuViewController: TimePickerDelegate {
    func didSelectTime(_ time: Date) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: time)
        
        if let hour = components.hour, let minute = components.minute {
            NotificationManager.shared.setNotificationTime(hour: hour, minute: minute)
            
            // Update button title
            updateTimePickerButton()
            
            // Show confirmation
            showAlert(title: "Time Updated",
                      message: "Notifications will now be sent at \(NotificationManager.shared.notificationTimeString)")
        }
    }
}

// MARK: - TimePickerViewController
class TimePickerViewController: UIViewController {
    
    weak var delegate: TimePickerDelegate?
    var selectedTime: Date = Date()
    
    private var datePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupDatePicker()
        setupNavigationBar()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.systemBackground
        title = "Set Notification Time"
    }
    
    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelTapped)
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .save,
            target: self,
            action: #selector(saveTapped)
        )
    }
    
    private func setupDatePicker() {
        datePicker = UIDatePicker()
        datePicker.datePickerMode = .time
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.date = selectedTime
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(datePicker)
        
        NSLayoutConstraint.activate([
            datePicker.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            datePicker.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            datePicker.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            datePicker.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    @objc private func saveTapped() {
        delegate?.didSelectTime(datePicker.date)
        dismiss(animated: true)
    }
}
