//
//  FilterDelegate.swift
//  ChillCheck
//
//  Created by JAISON ABRAHAM on 2025-07-15.
//

import UIKit

protocol FilterDelegate: AnyObject {
    func didApplyFilter(_ filter: ExpiryFilter)
}

enum ExpiryFilter: String, CaseIterable {
    case all = "All Items"
    case expired = "Expired"
    case expiringSoon = "Expiring Soon (1-3 days)"
    case expiringThisWeek = "Expiring This Week (4-7 days)"
    case fresh = "Fresh (8+ days)"
    case noExpiration = "No Expiration Date"
}

class FilterViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var resetButton: UIBarButtonItem!
    
    weak var delegate: FilterDelegate?
    var currentFilter: ExpiryFilter = .all
    
    private let filters = ExpiryFilter.allCases
    
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
        title = "Filter by Expiry"
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "FilterCell")
        
        resetButton.target = self
        resetButton.action = #selector(resetButtonTapped)
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
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    @objc private func resetButtonTapped() {
        currentFilter = .all
        tableView.reloadData()
        dismiss(animated: true) {
            self.delegate?.didApplyFilter(.all)
        }
    }
    
    private func getFilterDescription(for filter: ExpiryFilter) -> String {
        switch filter {
        case .all:
            return "Show all items in your fridge"
        case .expired:
            return "Items that have already expired"
        case .expiringSoon:
            return "Items expiring in 1-3 days"
        case .expiringThisWeek:
            return "Items expiring in 4-7 days"
        case .fresh:
            return "Items with 8 or more days left"
        case .noExpiration:
            return "Items without expiration dates"
        }
    }
    
    private func getFilterColor(for filter: ExpiryFilter) -> UIColor {
        switch filter {
        case .all:
            return .systemBlue
        case .expired:
            return .systemRed
        case .expiringSoon:
            return .systemRed
        case .expiringThisWeek:
            return .systemOrange
        case .fresh:
            return .systemGreen
        case .noExpiration:
            return .systemGray
        }
    }
    
    private func getFilterIcon(for filter: ExpiryFilter) -> String {
        switch filter {
        case .all:
            return "list.bullet"
        case .expired:
            return "exclamationmark.triangle.fill"
        case .expiringSoon:
            return "clock.fill"
        case .expiringThisWeek:
            return "calendar"
        case .fresh:
            return "leaf.fill"
        case .noExpiration:
            return "infinity"
        }
    }
}

// MARK: - TableView DataSource and Delegate
extension FilterViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterCell", for: indexPath)
        let filter = filters[indexPath.row]
        
        // Setup cell content
        cell.textLabel?.text = filter.rawValue
        cell.detailTextLabel?.text = getFilterDescription(for: filter)
        
        // Add checkmark for current filter
        if filter == currentFilter {
            cell.accessoryType = .checkmark
            cell.tintColor = getFilterColor(for: filter)
        } else {
            cell.accessoryType = .none
        }
        
        // Add colored indicator and icon
        cell.contentView.subviews.forEach { view in
            if view.tag == 997 || view.tag == 996 {
                view.removeFromSuperview()
            }
        }
        
        // Color indicator
        let indicatorView = UIView(frame: CGRect(x: 0, y: 0, width: 4, height: 60))
        indicatorView.backgroundColor = getFilterColor(for: filter)
        indicatorView.tag = 997
        cell.contentView.addSubview(indicatorView)
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            indicatorView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
            indicatorView.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
            indicatorView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor),
            indicatorView.widthAnchor.constraint(equalToConstant: 4)
        ])
        
        // Icon
        let iconImageView = UIImageView(image: UIImage(systemName: getFilterIcon(for: filter)))
        iconImageView.tintColor = getFilterColor(for: filter)
        iconImageView.tag = 996
        iconImageView.contentMode = .scaleAspectFit
        cell.contentView.addSubview(iconImageView)
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: indicatorView.trailingAnchor, constant: 16),
            iconImageView.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        // Adjust text label leading constraint
        if let textLabel = cell.textLabel {
            textLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                textLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12)
            ])
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        currentFilter = filters[indexPath.row]
        tableView.reloadData()
        
        dismiss(animated: true) {
            self.delegate?.didApplyFilter(self.currentFilter)
        }
    }
}
