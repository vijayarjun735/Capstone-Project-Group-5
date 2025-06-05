//
//  AddEditItemViewController.swift
//  ChillCheck
//
//  Created by Arjun V on 2025-06-04.
//

import UIKit

protocol AddEditItemDelegate: AnyObject {
    func didAddItem(_ item: FridgeItem)
    func didUpdateItem(_ item: FridgeItem, at index: Int)
}

class AddEditItemViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var quantityTextField: UITextField!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var expirationDatePicker: UIDatePicker!
    @IBOutlet weak var expirationSwitch: UISwitch!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    weak var delegate: AddEditItemDelegate?
    var itemToEdit: FridgeItem?
    var editingIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        populateFields()
    }
    
    private func setupUI() {
        if itemToEdit != nil {
            title = "Edit Item"
        } else {
            title = "Add Item"
        }
        
        expirationDatePicker.datePickerMode = .date
        expirationDatePicker.preferredDatePickerStyle = .wheels
        expirationDatePicker.minimumDate = Date()
        
        // Initially hide date picker
        expirationDatePicker.isHidden = !expirationSwitch.isOn
        
        nameTextField.delegate = self
        quantityTextField.delegate = self
        categoryTextField.delegate = self
        
        quantityTextField.keyboardType = .numberPad
    }
    
    private func populateFields() {
        guard let item = itemToEdit else { return }
        
        nameTextField.text = item.name
        quantityTextField.text = "\(item.quantity)"
        categoryTextField.text = item.category
        
        if let expirationDate = item.expirationDate {
            expirationSwitch.isOn = true
            expirationDatePicker.date = expirationDate
            expirationDatePicker.isHidden = false
        } else {
            expirationSwitch.isOn = false
            expirationDatePicker.isHidden = true
        }
    }
    
    @IBAction func expirationSwitchChanged(_ sender: UISwitch) {
        expirationDatePicker.isHidden = !sender.isOn
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        guard let name = nameTextField.text, !name.isEmpty,
              let quantityText = quantityTextField.text, !quantityText.isEmpty,
              let quantity = Int(quantityText) else {
            showAlert(message: "Please fill in all required fields")
            return
        }
        
        let category = categoryTextField.text?.isEmpty == false ? categoryTextField.text! : "Other"
        let expirationDate = expirationSwitch.isOn ? expirationDatePicker.date : nil
        
        if let editingIndex = editingIndex {
            // Update existing item
            var updatedItem = itemToEdit!
            updatedItem.name = name
            updatedItem.quantity = quantity
            updatedItem.category = category
            updatedItem.expirationDate = expirationDate
            
            delegate?.didUpdateItem(updatedItem, at: editingIndex)
        } else {
            // Add new item
            let newItem = FridgeItem(
                name: name,
                quantity: quantity,
                expirationDate: expirationDate,
                category: category
            )
            delegate?.didAddItem(newItem)
        }
        
        dismiss(animated: true)
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension AddEditItemViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameTextField {
            quantityTextField.becomeFirstResponder()
        } else if textField == quantityTextField {
            categoryTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
}

