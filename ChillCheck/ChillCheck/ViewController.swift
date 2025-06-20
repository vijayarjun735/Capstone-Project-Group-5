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
    
    var fridgeItems: [FridgeItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadFridgeItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadFridgeItems()
    }
    
    private func setupUI() {
        title = "My Fridge"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "FridgeItemCell")
    }
    
    private func loadFridgeItems() {
        fridgeItems = FridgeDataManager.shared.loadFridgeItems()
        tableView.reloadData()
    }
    
    private func saveFridgeItems() {
        FridgeDataManager.shared.saveFridgeItems(fridgeItems)
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
                editItemVC.itemToEdit = fridgeItems[indexPath.row]
                editItemVC.editingIndex = indexPath.row
            }
        }
    }
}

// MARK: - TableView DataSource and Delegate
extension FridgeViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fridgeItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FridgeItemCell", for: indexPath)
        let item = fridgeItems[indexPath.row]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        
        var subtitle = "Quantity: \(item.quantity)"
        if let expirationDate = item.expirationDate {
            subtitle += " • Expires: \(dateFormatter.string(from: expirationDate))"
        }
        
        cell.textLabel?.text = item.name
        cell.detailTextLabel?.text = subtitle
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "showEditItem", sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            fridgeItems.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            saveFridgeItems()
        }
    }
}

// MARK: - AddEditItemDelegate
extension FridgeViewController: AddEditItemDelegate {
    func didAddItem(_ item: FridgeItem) {
        fridgeItems.append(item)
        saveFridgeItems()
        tableView.reloadData()
    }
    
    func didUpdateItem(_ item: FridgeItem, at index: Int) {
        fridgeItems[index] = item
        saveFridgeItems()
        tableView.reloadData()
    }
}

