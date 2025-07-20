//
//  SuggestionsViewController.swift
//  ChillCheck
//
//  Created by Stalin on 20/07/25.
//


import UIKit

class SuggestionsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    private var suggestedItems: [FridgeItem] = []
    private var expiredItems: [FridgeItem] = []
    private var expiringSoonItems: [FridgeItem] = []
    private var expiringTodayItems: [FridgeItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadSuggestedItems()
        applyTheme()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadSuggestedItems()
        applyTheme()
    }
    
    private func setupUI() {
        title = "Use Today"
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SuggestionCell")
        tableView.separatorStyle = .none
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshSuggestions), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    @objc private func refreshSuggestions() {
        loadSuggestedItems()
        tableView.refreshControl?.endRefreshing()
    }
    
    private func loadSuggestedItems() {
        let allItems = FridgeDataManager.shared.loadFridgeItems()
        categorizeItems(allItems)
        tableView.reloadData()
    }
    
    private func categorizeItems(_ items: [FridgeItem]) {
        let calendar = Calendar.current
        let today = Date()
        
        expiredItems = []
        expiringTodayItems = []
        expiringSoonItems = []
        
        for item in items {
            guard let expirationDate = item.expirationDate else { continue }
            
            let daysUntilExpiration = calendar.dateComponents([.day], from: today, to: expirationDate).day ?? 0
            
            if daysUntilExpiration < 0 {
                expiredItems.append(item)
            } else if daysUntilExpiration == 0 {
                expiringTodayItems.append(item)
            } else if daysUntilExpiration <= 2 {
                expiringSoonItems.append(item)
            }
        }
        
        // Sort by expiration date (most urgent first)
        expiredItems.sort { ($0.expirationDate ?? Date.distantFuture) < ($1.expirationDate ?? Date.distantFuture) }
        expiringTodayItems.sort { ($0.expirationDate ?? Date.distantFuture) < ($1.expirationDate ?? Date.distantFuture) }
        expiringSoonItems.sort { ($0.expirationDate ?? Date.distantFuture) < ($1.expirationDate ?? Date.distantFuture) }
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
    
    private func getSectionTitle(for section: Int) -> String {
        switch section {
        case 0:
            return expiredItems.isEmpty ? "" : "Already Expired"
        case 1:
            return expiringTodayItems.isEmpty ? "" : "Expiring Today"
        case 2:
            return expiringSoonItems.isEmpty ? "" : "Expiring in 1-2 Days"
        default:
            return ""
        }
    }
    
    private func getSectionDescription(for section: Int) -> String {
        switch section {
        case 0:
            return expiredItems.isEmpty ? "" : "Use immediately or discard"
        case 1:
            return expiringTodayItems.isEmpty ? "" : "Perfect for today's meals"
        case 2:
            return expiringSoonItems.isEmpty ? "" : "Plan to use soon"
        default:
            return ""
        }
    }
    
    private func getSectionColor(for section: Int) -> UIColor {
        switch section {
        case 0:
            return .systemRed
        case 1:
            return .systemOrange
        case 2:
            return .systemYellow
        default:
            return .systemGray
        }
    }
    
    private func getItemsForSection(_ section: Int) -> [FridgeItem] {
        switch section {
        case 0:
            return expiredItems
        case 1:
            return expiringTodayItems
        case 2:
            return expiringSoonItems
        default:
            return []
        }
    }
    
    private func formatExpirationText(for item: FridgeItem) -> String {
        guard let expirationDate = item.expirationDate else { return "" }
        
        let calendar = Calendar.current
        let today = Date()
        let daysUntilExpiration = calendar.dateComponents([.day], from: today, to: expirationDate).day ?? 0
        
        if daysUntilExpiration < 0 {
            let daysExpired = abs(daysUntilExpiration)
            return "Expired \(daysExpired) day\(daysExpired == 1 ? "" : "s") ago"
        } else if daysUntilExpiration == 0 {
            return "Expires today"
        } else {
            return "Expires in \(daysUntilExpiration) day\(daysUntilExpiration == 1 ? "" : "s")"
        }
    }
    
    private func showEmptyStateView() -> UIView {
        let emptyView = UIView()
        emptyView.backgroundColor = .clear
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let iconImageView = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
        iconImageView.tintColor = .systemGreen
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = "All Good!"
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        
        let messageLabel = UILabel()
        messageLabel.text = "No items need urgent attention today.\nYour fridge items are staying fresh!"
        messageLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        messageLabel.textColor = .secondaryLabel
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        
        stackView.addArrangedSubview(iconImageView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(messageLabel)
        
        emptyView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalToConstant: 80),
            iconImageView.heightAnchor.constraint(equalToConstant: 80),
            
            stackView.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor, constant: -50),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: emptyView.leadingAnchor, constant: 40),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: emptyView.trailingAnchor, constant: -40)
        ])
        
        return emptyView
    }
}

// MARK: - TableView DataSource and Delegate
extension SuggestionsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        let totalItems = expiredItems.count + expiringTodayItems.count + expiringSoonItems.count
        if totalItems == 0 {
            tableView.backgroundView = showEmptyStateView()
            return 0
        } else {
            tableView.backgroundView = nil
            return 3
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let items = getItemsForSection(section)
        return items.isEmpty ? 0 : items.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let items = getItemsForSection(section)
        if items.isEmpty { return nil }
        
        let headerView = UIView()
        headerView.backgroundColor = .clear
        
        let containerView = UIView()
        containerView.backgroundColor = getSectionColor(for: section).withAlphaComponent(0.1)
        containerView.layer.cornerRadius = 12
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = getSectionTitle(for: section)
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = getSectionColor(for: section)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = getSectionDescription(for: section)
        descriptionLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let countLabel = UILabel()
        countLabel.text = "\(items.count) item\(items.count == 1 ? "" : "s")"
        countLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        countLabel.textColor = getSectionColor(for: section)
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(descriptionLabel)
        containerView.addSubview(countLabel)
        headerView.addSubview(containerView)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: countLabel.leadingAnchor, constant: -8),
            
            countLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            countLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            descriptionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            descriptionLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
        ])
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let items = getItemsForSection(section)
        return items.isEmpty ? 0 : 80
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SuggestionCell", for: indexPath)
        let items = getItemsForSection(indexPath.section)
        let item = items[indexPath.row]
        
        cell.textLabel?.text = item.name
        cell.detailTextLabel?.text = "Qty: \(item.quantity) • \(item.category) • \(formatExpirationText(for: item))"
     
        cell.backgroundColor = .clear
        cell.contentView.backgroundColor = .systemBackground
        cell.contentView.layer.cornerRadius = 8
        cell.contentView.layer.masksToBounds = true
  
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 1)
        cell.layer.shadowOpacity = 0.1
        cell.layer.shadowRadius = 2
        cell.layer.masksToBounds = false
    
        cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)

        cell.contentView.subviews.forEach { view in
            if view.tag == 1000 {
                view.removeFromSuperview()
            }
        }
        
        let indicatorView = UIView()
        indicatorView.backgroundColor = getSectionColor(for: indexPath.section)
        indicatorView.layer.cornerRadius = 2
        indicatorView.tag = 1000
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        cell.contentView.addSubview(indicatorView)
        
        NSLayoutConstraint.activate([
            indicatorView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 8),
            indicatorView.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 8),
            indicatorView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -8),
            indicatorView.widthAnchor.constraint(equalToConstant: 4)
        ])
 
        if item.isFavorite {
            let starImageView = UIImageView(image: UIImage(systemName: "star.fill"))
            starImageView.tintColor = .systemYellow
            starImageView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
            cell.accessoryView = starImageView
        } else {
            cell.accessoryView = nil
            cell.accessoryType = .disclosureIndicator
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let items = getItemsForSection(indexPath.section)
        let item = items[indexPath.row]
        
  
        showItemActionSheet(for: item)
    }
    
    private func showItemActionSheet(for item: FridgeItem) {
        let actionSheet = UIAlertController(title: item.name, message: "What would you like to do?", preferredStyle: .actionSheet)
        
        let useAction = UIAlertAction(title: "Mark as Used", style: .default) { _ in
            self.markItemAsUsed(item)
        }
        
        let editAction = UIAlertAction(title: "Edit Item", style: .default) { _ in
            self.editItem(item)
        }
        
        let removeAction = UIAlertAction(title: "Remove from Fridge", style: .destructive) { _ in
            self.removeItem(item)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        actionSheet.addAction(useAction)
        actionSheet.addAction(editAction)
        actionSheet.addAction(removeAction)
        actionSheet.addAction(cancelAction)
 
        if let popover = actionSheet.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        present(actionSheet, animated: true)
    }
    
    private func markItemAsUsed(_ item: FridgeItem) {
        removeItem(item)
        
        let alert = UIAlertController(title: "Item Used", message: "\(item.name) has been marked as used and removed from your fridge.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func editItem(_ item: FridgeItem) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let navController = storyboard.instantiateViewController(withIdentifier: "Modal-Nav") as? UINavigationController,
           let editVC = navController.topViewController as? AddEditItemViewController {
            
            var allItems = FridgeDataManager.shared.loadFridgeItems()
            if let index = allItems.firstIndex(where: { $0.id == item.id }) {
                editVC.itemToEdit = item
                editVC.editingIndex = index
                editVC.delegate = self
                present(navController, animated: true)
            }
        }
    }
    
    private func removeItem(_ item: FridgeItem) {
        var allItems = FridgeDataManager.shared.loadFridgeItems()
        if let index = allItems.firstIndex(where: { $0.id == item.id }) {
            allItems.remove(at: index)
            FridgeDataManager.shared.saveFridgeItems(allItems)
            FridgeDataManager.shared.addHistoryItem(item, action: .removed)
            loadSuggestedItems()
        }
    }
}

// MARK: - AddEditItemDelegate
extension SuggestionsViewController: AddEditItemDelegate {
    func didAddItem(_ item: FridgeItem) {
    }
    
    func didUpdateItem(_ item: FridgeItem, at index: Int) {
        var allItems = FridgeDataManager.shared.loadFridgeItems()
        allItems[index] = item
        FridgeDataManager.shared.saveFridgeItems(allItems)
        FridgeDataManager.shared.addHistoryItem(item, action: .updated)
        loadSuggestedItems()
    }
}
