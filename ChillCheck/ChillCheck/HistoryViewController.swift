//
//  HistoryViewController.swift
//  ChillCheck
//
//  Created by Arjun V on 2025-07-16.
//

import UIKit

class HistoryViewController: UIViewController {
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var clearHistoryButton: UIBarButtonItem!
    
    private var allHistoryItems: [HistoryItem] = []
    private var displayedHistoryItems: [HistoryItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadHistoryItems()
        applyTheme()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadHistoryItems()
        applyTheme()
    }
    
    private func setupUI() {
        title = "History"
        
        segmentedControl.selectedSegmentIndex = 0
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "HistoryCell")
        
        clearHistoryButton.target = self
        clearHistoryButton.action = #selector(clearHistoryButtonTapped)
    }
    
    private func loadHistoryItems() {
        allHistoryItems = FridgeDataManager.shared.loadHistoryItems()
        filterHistoryItems()
    }
    
    private func filterHistoryItems() {
        switch segmentedControl.selectedSegmentIndex {
        case 0: // Recently Added
            displayedHistoryItems = allHistoryItems.filter { $0.action == .added }
        case 1: // Recently Deleted
            displayedHistoryItems = allHistoryItems.filter { $0.action == .removed }
        default:
            displayedHistoryItems = allHistoryItems
        }
        tableView.reloadData()
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
    
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        filterHistoryItems()
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    @objc private func clearHistoryButtonTapped() {
        let alertController = UIAlertController(
            title: "Clear History",
            message: "Are you sure you want to clear all history? This action cannot be undone.",
            preferredStyle: .alert
        )
        
        let clearAction = UIAlertAction(title: "Clear", style: .destructive) { _ in
            FridgeDataManager.shared.saveHistoryItems([])
            self.loadHistoryItems()
            
            let successAlert = UIAlertController(
                title: "Success",
                message: "History has been cleared.",
                preferredStyle: .alert
            )
            successAlert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(successAlert, animated: true)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(clearAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
    
    private func getActionColor(for action: HistoryAction) -> UIColor {
        switch action {
        case .added:
            return .systemGreen
        case .removed:
            return .systemRed
        case .updated:
            return .systemBlue
        }
    }
    
    private func getActionIcon(for action: HistoryAction) -> String {
        switch action {
        case .added:
            return "plus.circle.fill"
        case .removed:
            return "minus.circle.fill"
        case .updated:
            return "pencil.circle.fill"
        }
    }
}

// MARK: - TableView DataSource and Delegate
extension HistoryViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayedHistoryItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath)
        let historyItem = displayedHistoryItems[indexPath.row]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        
        let timestampText = dateFormatter.string(from: historyItem.timestamp)
        let actionColor = getActionColor(for: historyItem.action)
        
        // Setup cell content
        cell.textLabel?.text = historyItem.fridgeItem.name
        cell.detailTextLabel?.text = "\(historyItem.action.rawValue) • \(timestampText) • Qty: \(historyItem.fridgeItem.quantity)"
        
        // Add action icon
        let iconImageView = UIImageView(image: UIImage(systemName: getActionIcon(for: historyItem.action)))
        iconImageView.tintColor = actionColor
        iconImageView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        cell.accessoryView = iconImageView
        
        // Add colored indicator on the left
        cell.contentView.subviews.forEach { view in
            if view.tag == 998 {
                view.removeFromSuperview()
            }
        }
        
        let indicatorView = UIView(frame: CGRect(x: 0, y: 0, width: 4, height: 44))
        indicatorView.backgroundColor = actionColor
        indicatorView.tag = 998
        cell.contentView.addSubview(indicatorView)
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            indicatorView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
            indicatorView.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
            indicatorView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor),
            indicatorView.widthAnchor.constraint(equalToConstant: 4)
        ])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
