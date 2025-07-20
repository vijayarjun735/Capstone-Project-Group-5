//
//  ViewController.swift
//  ChillCheck
//
//  Created by Arjun V on 2025-05-18.
//

import UIKit

class FridgeViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var fridgeItems: [FridgeItem] = []
    var filteredFridgeItems: [FridgeItem] = []
    var isSearching = false
    var currentFilter: ExpiryFilter = .all
    
    private var itemCountLabel: UILabel!
    private var filterStatusLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupItemCountLabel()
        setupFilterStatusLabel()
        loadFridgeItems()
        applyTheme()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadFridgeItems()
        applyTheme()
    }
    
    private func setupUI() {
        title = "Chill Check"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "FridgeItemCell")
        
        searchBar.delegate = self
        searchBar.placeholder = "Search fridge items..."
        searchBar.showsCancelButton = false
        
        setupMenuButton()
    }
    
    private func setupItemCountLabel() {
        itemCountLabel = UILabel()
        itemCountLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        itemCountLabel.textColor = .secondaryLabel
        itemCountLabel.textAlignment = .center
        itemCountLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(itemCountLabel)
        
        NSLayoutConstraint.activate([
            itemCountLabel.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 8),
            itemCountLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            itemCountLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            itemCountLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    private func setupFilterStatusLabel() {
        filterStatusLabel = UILabel()
        filterStatusLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        filterStatusLabel.textColor = .systemBlue
        filterStatusLabel.textAlignment = .center
        filterStatusLabel.translatesAutoresizingMaskIntoConstraints = false
        filterStatusLabel.isHidden = true
        
        view.addSubview(filterStatusLabel)
        
        NSLayoutConstraint.activate([
            filterStatusLabel.topAnchor.constraint(equalTo: itemCountLabel.bottomAnchor, constant: 4),
            filterStatusLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            filterStatusLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            filterStatusLabel.heightAnchor.constraint(equalToConstant: 16)
        ])
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: filterStatusLabel.bottomAnchor, constant: 8).isActive = true
    }
    
    private func updateItemCountLabel() {
        let displayedItems = isSearching ? filteredFridgeItems : fridgeItems
        let favoriteCount = displayedItems.filter { $0.isFavorite }.count
        
        if isSearching {
            itemCountLabel.text = "\(displayedItems.count) items found (\(favoriteCount) favorites)"
        } else {
            itemCountLabel.text = "\(displayedItems.count) total items (\(favoriteCount) favorites)"
        }
    }
    
    private func updateFilterStatusLabel() {
        if currentFilter == .all {
            filterStatusLabel.isHidden = true
        } else {
            filterStatusLabel.isHidden = false
            filterStatusLabel.text = "Filtered by: \(currentFilter.rawValue) • Tap menu to change"
        }
    }
    
    private func setupMenuButton() {
        let menuButton = UIBarButtonItem(
            image: UIImage(systemName: "line.horizontal.3"),
            style: .plain,
            target: self,
            action: #selector(menuButtonTapped)
        )
        navigationItem.leftBarButtonItem = menuButton
    }
    
    @objc private func menuButtonTapped() {
        performSegue(withIdentifier: "showMenu", sender: nil)
    }
    
    private func toggleDarkMode() {
        let currentMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        UserDefaults.standard.set(!currentMode, forKey: "isDarkMode")
        applyTheme()
    }
    
    private func applyTheme() {
        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        
        if #available(iOS 13.0, *) {
            view.window?.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
        } else {
            navigationController?.navigationBar.barStyle = isDarkMode ? .black : .default
            tableView.backgroundColor = isDarkMode ? .black : .white
        }
    }
    
    private func confirmDeleteAllData() {
        let alertController = UIAlertController(
            title: "Delete All Data",
            message: "Are you sure you want to delete all fridge items? This action cannot be undone.",
            preferredStyle: .alert
        )
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.deleteAllData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
    
    private func deleteAllData() {
        fridgeItems.removeAll()
        filteredFridgeItems.removeAll()
        saveFridgeItems()
        tableView.reloadData()
        updateItemCountLabel()
        
        // Update notifications after deleting all data
        NotificationManager.shared.updateNotificationContent()
        
        let successAlert = UIAlertController(
            title: "Success",
            message: "All data has been deleted.",
            preferredStyle: .alert
        )
        successAlert.addAction(UIAlertAction(title: "OK", style: .default))
        present(successAlert, animated: true)
    }
    
    private func loadFridgeItems() {
        fridgeItems = FridgeDataManager.shared.loadFridgeItems()
        sortItemsByFavorites()
        applyCurrentFilter()
        updateItemCountLabel()
        updateFilterStatusLabel()
    }
    
    private func sortItemsByFavorites() {
        fridgeItems.sort { $0.isFavorite && !$1.isFavorite }
    }
    
    private func saveFridgeItems() {
        FridgeDataManager.shared.saveFridgeItems(fridgeItems)
    }
    
    private func applyCurrentFilter() {
        let itemsToFilter = fridgeItems
        
        switch currentFilter {
        case .all:
            filteredFridgeItems = itemsToFilter
        case .expired:
            filteredFridgeItems = itemsToFilter.filter { item in
                guard let expirationDate = item.expirationDate else { return false }
                return expirationDate < Date()
            }
        case .expiringSoon:
            filteredFridgeItems = itemsToFilter.filter { item in
                guard let expirationDate = item.expirationDate else { return false }
                let calendar = Calendar.current
                let daysUntilExpiration = calendar.dateComponents([.day], from: Date(), to: expirationDate).day ?? 0
                return daysUntilExpiration >= 0 && daysUntilExpiration <= 3
            }
        case .expiringThisWeek:
            filteredFridgeItems = itemsToFilter.filter { item in
                guard let expirationDate = item.expirationDate else { return false }
                let calendar = Calendar.current
                let daysUntilExpiration = calendar.dateComponents([.day], from: Date(), to: expirationDate).day ?? 0
                return daysUntilExpiration >= 4 && daysUntilExpiration <= 7
            }
        case .fresh:
            filteredFridgeItems = itemsToFilter.filter { item in
                guard let expirationDate = item.expirationDate else { return false }
                let calendar = Calendar.current
                let daysUntilExpiration = calendar.dateComponents([.day], from: Date(), to: expirationDate).day ?? 0
                return daysUntilExpiration >= 8
            }
        case .noExpiration:
            filteredFridgeItems = itemsToFilter.filter { $0.expirationDate == nil }
        }
     
        if isSearching, let searchText = searchBar.text, !searchText.isEmpty {
            filteredFridgeItems = filteredFridgeItems.filter { item in
                item.name.lowercased().contains(searchText.lowercased()) ||
                item.category.lowercased().contains(searchText.lowercased())
            }
        }

        filteredFridgeItems.sort { $0.isFavorite && !$1.isFavorite }
        tableView.reloadData()
    }
    
    private func getExpirationColor(for item: FridgeItem) -> UIColor {
        guard let expirationDate = item.expirationDate else {
            return .label
        }
        
        let calendar = Calendar.current
        let today = Date()
        let daysUntilExpiration = calendar.dateComponents([.day], from: today, to: expirationDate).day ?? 0
        
        if daysUntilExpiration < 0 {
            return .red
        } else if daysUntilExpiration <= 3 {
            return .red
        } else if daysUntilExpiration <= 7 {
            return .orange
        } else {
            return .systemGreen
        }
    }
    
    private func showHistory() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let historyNav = storyboard.instantiateViewController(withIdentifier: "HistoryNav") as? UINavigationController {
            present(historyNav, animated: true)
        }
    }
    
    private func showFilter() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let filterNav = storyboard.instantiateViewController(withIdentifier: "FilterNav") as? UINavigationController,
           let filterVC = filterNav.topViewController as? FilterViewController {
            filterVC.delegate = self
            filterVC.currentFilter = currentFilter
            present(filterNav, animated: true)
        }
    }
    
    private func showSuggestions() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let suggestionsNav = storyboard.instantiateViewController(withIdentifier: "SuggestionsNav") as? UINavigationController {
            present(suggestionsNav, animated: true)
        }
    }
    
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "showAddItem", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAddItem" {
            if let navController = segue.destination as? UINavigationController,
               let addItemVC = navController.topViewController as? AddEditItemViewController {
                addItemVC.delegate = self
            }
        } else if segue.identifier == "showEditItem" {
            if let navController = segue.destination as? UINavigationController,
               let editItemVC = navController.topViewController as? AddEditItemViewController,
               let indexPath = sender as? IndexPath {
                editItemVC.delegate = self
                let itemsArray = filteredFridgeItems
                editItemVC.itemToEdit = itemsArray[indexPath.row]
                if let originalIndex = fridgeItems.firstIndex(where: { $0.id == itemsArray[indexPath.row].id }) {
                    editItemVC.editingIndex = originalIndex
                }
            }
        } else if segue.identifier == "showMenu" {
            if let navController = segue.destination as? UINavigationController,
               let menuVC = navController.topViewController as? MenuViewController {
                menuVC.delegate = self
            }
        }
    }
}

extension FridgeViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            isSearching = false
        } else {
            isSearching = true
        }
        applyCurrentFilter()
        updateItemCountLabel()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
        isSearching = false
        applyCurrentFilter()
        updateItemCountLabel()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

// MARK: - TableView DataSource and Delegate
extension FridgeViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredFridgeItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FridgeItemCell", for: indexPath)
        let item = filteredFridgeItems[indexPath.row]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        
        var subtitle = "Quantity: \(item.quantity) • Category: \(item.category)"
        if let expirationDate = item.expirationDate {
            subtitle += " • Expires: \(dateFormatter.string(from: expirationDate))"
        }
        
        cell.textLabel?.text = item.name
        cell.detailTextLabel?.text = subtitle
        
        if item.isFavorite {
            let starImageView = UIImageView(image: UIImage(systemName: "star.fill"))
            starImageView.tintColor = .systemYellow
            starImageView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
            cell.accessoryView = starImageView
        } else {
            cell.accessoryView = nil
            cell.accessoryType = .disclosureIndicator
        }
        
        let expirationColor = getExpirationColor(for: item)
        cell.textLabel?.textColor = expirationColor
        
        cell.contentView.subviews.forEach { view in
            if view.tag == 999 {
                view.removeFromSuperview()
            }
        }
        
        if item.expirationDate != nil {
            let indicatorView = UIView(frame: CGRect(x: 0, y: 0, width: 4, height: 44))
            indicatorView.backgroundColor = expirationColor
            indicatorView.tag = 999
            cell.contentView.addSubview(indicatorView)
            indicatorView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                indicatorView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
                indicatorView.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
                indicatorView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor),
                indicatorView.widthAnchor.constraint(equalToConstant: 4)
            ])
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "showEditItem", sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let itemToDelete = filteredFridgeItems[indexPath.row]
 
            FridgeDataManager.shared.addHistoryItem(itemToDelete, action: .removed)
            
            if let originalIndex = fridgeItems.firstIndex(where: { $0.id == itemToDelete.id }) {
                fridgeItems.remove(at: originalIndex)
            }
            filteredFridgeItems.remove(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: .fade)
            saveFridgeItems()
            updateItemCountLabel()
            
            // Update notifications after removing an item
            NotificationManager.shared.updateNotificationContent()
        }
    }
}

// MARK: - AddEditItemDelegate
extension FridgeViewController: AddEditItemDelegate {
    func didAddItem(_ item: FridgeItem) {
        fridgeItems.append(item)
        sortItemsByFavorites()
        saveFridgeItems()
    
        FridgeDataManager.shared.addHistoryItem(item, action: .added)
        
        // Update notifications after adding an item
        NotificationManager.shared.updateNotificationContent()
        
        applyCurrentFilter()
        updateItemCountLabel()
    }
    
    func didUpdateItem(_ item: FridgeItem, at index: Int) {
        let oldItem = fridgeItems[index]
        fridgeItems[index] = item
        sortItemsByFavorites()
        saveFridgeItems()
        FridgeDataManager.shared.addHistoryItem(item, action: .updated)
        
        // Update notifications after updating an item
        NotificationManager.shared.updateNotificationContent()
        
        applyCurrentFilter()
        updateItemCountLabel()
    }
}

// MARK: - Menu Delegate
extension FridgeViewController: MenuDelegate {
    func didSelectDarkModeToggle() {
        toggleDarkMode()
    }
    
    func didSelectDeleteAllData() {
        confirmDeleteAllData()
    }
    
    func didSelectHistory() {
        showHistory()
    }
    
    func didSelectFilter() {
        showFilter()
    }
    
    func didSelectSuggestions() {
        showSuggestions()
    }
}

// MARK: - Filter Delegate
extension FridgeViewController: FilterDelegate {
    func didApplyFilter(_ filter: ExpiryFilter) {
        currentFilter = filter
        applyCurrentFilter()
        updateItemCountLabel()
        updateFilterStatusLabel()
    }
}
