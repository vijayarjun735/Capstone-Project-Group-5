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
    
    private var colorPreviewView: UIView!
    private var colorPreviewLabel: UILabel!
    private var favoriteButton: UIButton!
    private var categoryPickerView: UIPickerView
    
    weak var delegate: AddEditItemDelegate?
    var itemToEdit: FridgeItem?
    var editingIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCategoryPicker()
        setupColorPreview()
        populateFields()
        applyTheme()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applyTheme()
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
        
        expirationDatePicker.isHidden = !expirationSwitch.isOn
        
        nameTextField.delegate = self
        quantityTextField.delegate = self
        categoryTextField.delegate = self
        
        quantityTextField.keyboardType = .numberPad
        
        expirationDatePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
    }
    
    private func setupCategoryPicker() {
        categoryPickerView = UIPickerView()
        categoryPickerView.delegate = self
        categoryPickerView.dataSource = self
        
        categoryTextField.inputView = categoryPickerView
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(categoryPickerDone))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([flexSpace, doneButton], animated: false)
        
        categoryTextField.inputAccessoryView = toolbar
    }
    
    @objc private func categoryPickerDone() {
        categoryTextField.resignFirstResponder()
    }
    
   
    private func setupColorPreview() {
        let containerView = UIView()
        containerView.backgroundColor = UIColor.systemBackground
        containerView.layer.cornerRadius = 8
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.systemGray4.cgColor
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        colorPreviewView = UIView()
        colorPreviewView.layer.cornerRadius = 12
        colorPreviewView.translatesAutoresizingMaskIntoConstraints = false
        
        colorPreviewLabel = UILabel()
        colorPreviewLabel.text = "Color Preview"
        colorPreviewLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        colorPreviewLabel.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(colorPreviewView)
        containerView.addSubview(colorPreviewLabel)
        view.addSubview(containerView)
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            containerView.bottomAnchor.constraint(equalTo: favoriteButton.topAnchor, constant: -20),
            containerView.heightAnchor.constraint(equalToConstant: 60),
            
            colorPreviewView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            colorPreviewView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            colorPreviewView.widthAnchor.constraint(equalToConstant: 24),
            colorPreviewView.heightAnchor.constraint(equalToConstant: 24),
            
            colorPreviewLabel.leadingAnchor.constraint(equalTo: colorPreviewView.trailingAnchor, constant: 12),
            colorPreviewLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            colorPreviewLabel.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -16)
        ])
        
        updateColorPreview()
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
    
    private func updateColorPreview() {
        guard let colorPreviewView = colorPreviewView,
              let colorPreviewLabel = colorPreviewLabel else {
            return
        }
        
        guard expirationSwitch.isOn else {
            colorPreviewView.backgroundColor = UIColor.systemGray
            colorPreviewLabel.text = "No expiration date set"
            return
        }
        
        let selectedDate = expirationDatePicker.date
        let calendar = Calendar.current
        let today = Date()
        let daysUntilExpiration = calendar.dateComponents([.day], from: today, to: selectedDate).day ?? 0
        
        let colorAndMessage = getExpirationColorAndMessage(daysUntilExpiration: daysUntilExpiration)
        colorPreviewView.backgroundColor = colorAndMessage.0
        colorPreviewLabel.text = colorAndMessage.1
    }
    
    private func getExpirationColorAndMessage(daysUntilExpiration: Int) -> (UIColor, String) {
        if daysUntilExpiration < 0 {
            return (.red, "Already expired")
        } else if daysUntilExpiration <= 3 {
            return (.red, "Expiring soon (\(daysUntilExpiration) days)")
        } else if daysUntilExpiration <= 7 {
            return (.orange, "Expiring in \(daysUntilExpiration) days")
        } else {
            return (.systemGreen, "Fresh (\(daysUntilExpiration) days left)")
        }
    }
    
    @objc private func datePickerValueChanged() {
        updateColorPreview()
    }
    
    private func populateFields() {
        guard let item = itemToEdit else {
            categoryTextField.text = FridgeDataManager.predefinedCategories[0]
            return
        }
        
        nameTextField.text = item.name
        quantityTextField.text = "\(item.quantity)"
        categoryTextField.text = item.category

        
        if let categoryIndex = FridgeDataManager.predefinedCategories.firstIndex(of: item.category) {
            categoryPickerView.selectRow(categoryIndex, inComponent: 0, animated: false)
        }
        
        if let expirationDate = item.expirationDate {
            expirationSwitch.isOn = true
            expirationDatePicker.date = expirationDate
            expirationDatePicker.isHidden = false
        } else {
            expirationSwitch.isOn = false
            expirationDatePicker.isHidden = true
        }
        
        DispatchQueue.main.async {
            self.updateColorPreview()
        }
    }
    
    @IBAction func expirationSwitchChanged(_ sender: UISwitch) {
        expirationDatePicker.isHidden = !sender.isOn
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        
        updateColorPreview()
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
            var updatedItem = itemToEdit!
            updatedItem.name = name
            updatedItem.quantity = quantity
            updatedItem.category = category
            updatedItem.expirationDate = expirationDate

            
            delegate?.didUpdateItem(updatedItem, at: editingIndex)
        } else {
            let newItem = FridgeItem(
                name: name,
                quantity: quantity,
                expirationDate: expirationDate,
                category: category,

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

