//
//  AddEditItemViewController.swift
//  ChillCheck
//
//  Created by Arjun V on 2025-06-04.
//

import UIKit

class AddEditItemViewController: UIViewController {

    // MARK: – New properties for “Edit” mode
    var existingItem: FridgeItem?
    var itemIndex: Int?

    // MARK: – IBOutlets (as you already have them)
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var quantityTextField: UITextField!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var expirationSwitch: UISwitch!
    @IBOutlet weak var expirationDatePicker: UIDatePicker!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad() 
        
        // If we came in “Edit” mode, populate fields:
        if let itemToEdit = existingItem {
            nameTextField.text = itemToEdit.name
            quantityTextField.text = "\(itemToEdit.quantity)"
            categoryTextField.text = itemToEdit.category
            
            if let expDate = itemToEdit.expirationDate {
                expirationSwitch.isOn = true
                expirationDatePicker.date = expDate
                expirationDatePicker.isHidden = false
            } else {
                expirationSwitch.isOn = false
                expirationDatePicker.isHidden = true
            }
        } else {
            // “Add” mode: hide the date picker until switch is on
            expirationSwitch.isOn = false
            expirationDatePicker.isHidden = true
        }
    }

    // MARK: – IBActions

    @IBAction func expirationSwitchChanged(_ sender: UISwitch) {
        expirationDatePicker.isHidden = !sender.isOn
    }

    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        // Validate name and quantity
        guard
            let name = nameTextField.text, !name.isEmpty,
            let qtyText = quantityTextField.text, let quantity = Int(qtyText)
        else {
            // You might want to show an “alert” here if fields are invalid
            return
        }

        // Build a FridgeItem from the form
        let category = categoryTextField.text ?? "Other"
        let expirationDate = expirationSwitch.isOn ? expirationDatePicker.date : nil
        let newItem = FridgeItem(name: name, quantity: quantity, expirationDate: expirationDate, category: category)

        // Load the current list, update or append, then save
        var allItems = FridgeDataManager.shared.loadFridgeItems()
        if let index = itemIndex {
            // We came from “Edit” – replace the old item
            allItems[index] = newItem
        } else {
            // We came from “Add” – append
            allItems.append(newItem)
        }

        FridgeDataManager.shared.saveFridgeItems(allItems)
        dismiss(animated: true, completion: nil)
    }
}
