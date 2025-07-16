//
//  HistoryItem.swift
//  ChillCheck
//
//  Created by Arjun V on 2025-07-16.
//

import Foundation

// MARK: - FridgeItem Model
struct FridgeItem: Codable {
    var id: UUID
    var name: String
    var quantity: Int
    var expirationDate: Date?
    var category: String
    var isFavorite: Bool
    
    init(name: String, quantity: Int, expirationDate: Date? = nil, category: String = "Other", isFavorite: Bool = false) {
        self.id = UUID()
        self.name = name
        self.quantity = quantity
        self.expirationDate = expirationDate
        self.category = category
        self.isFavorite = isFavorite
    }
}

// MARK: - Data Manager for Persistence
class FridgeDataManager {
    static let shared = FridgeDataManager()
    private let userDefaults = UserDefaults.standard
    private let fridgeItemsKey = "FridgeItems"
    
    private init() {}
    
    func saveFridgeItems(_ items: [FridgeItem]) {
        do {
            let data = try JSONEncoder().encode(items)
            userDefaults.set(data, forKey: fridgeItemsKey)
        } catch {
            print("Failed to save fridge items: \(error)")
        }
    }
    
    func loadFridgeItems() -> [FridgeItem] {
        guard let data = userDefaults.data(forKey: fridgeItemsKey) else {
            return []
        }
        
        do {
            let items = try JSONDecoder().decode([FridgeItem].self, from: data)
            return items
        } catch {
            print("Failed to load fridge items: \(error)")
            return []
        }
    }
    
    static let predefinedCategories = [
        "Dairy",
        "Meat",
        "Vegetables",
        "Fruits",
        "Beverages",
        "Snacks",
        "Frozen",
        "Condiments",
        "Grains",
        "Other"
    ]
}

