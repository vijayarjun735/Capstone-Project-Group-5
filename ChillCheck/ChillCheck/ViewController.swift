//
//  ViewController.swift
//  ChillCheck
//
//  Created by Arjun V on 2025-05-18.
//

import UIKit

class FridgeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
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
        
        // If you registered a plain UITableViewCell in code, keep this.
        // Otherwise, make sure your storyboard cell has the Identifier "FridgeItemCell"
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
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fridgeItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue a cell with the same identifier you set in the storyboard ("FridgeItemCell")
        let cell = tableView.dequeueReusableCell(withIdentifier: "FridgeItemCell", for: indexPath)
        let item = fridgeItems[indexPath.row]
        
        // Configure text labels (you can adjust formatting as desired)
        cell.textLabel?.text = item.name
        let qtyString = "Qty: \(item.quantity)"
        
        if let exp = item.expirationDate {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            let dateString = formatter.string(from: exp)
            cell.detailTextLabel?.text = "\(qtyString)  •  Exp: \(dateString)"
        } else {
            cell.detailTextLabel?.text = qtyString
        }
        
        return cell
    }
    
    // Enable swipe-to-delete
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // 1. Remove from data source
            fridgeItems.remove(at: indexPath.row)
            // 2. Persist the updated array
            saveFridgeItems()
            // 3. Animate deletion in the table view
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    // (Optional) If you want to show a “Delete” button instead of the default,
    // implement this and return a custom title/styles:
    /*
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Remove"
    }
    */
    
    // MARK: - UITableViewDelegate
    
    // (If you want to allow tapping a row to edit, etc.; otherwise these can be empty)
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Example: perform edit segue
        let selectedItem = fridgeItems[indexPath.row]
        performSegue(withIdentifier: "showEditItem", sender: selectedItem)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // Prepare for segue to Add/Edit screen if you need to pass the tapped item
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showEditItem",
           let nav = segue.destination as? UINavigationController,
           let editVC = nav.topViewController as? AddEditItemViewController,
           let itemToEdit = sender as? FridgeItem {
            editVC.existingItem = itemToEdit
        }
    }
}
