//
//  HistoryItem.swift
//  ChillCheck
//
//  Created by Arjun V on 2025-07-16.
//

import Foundation

// MARK: - History Item Model
struct HistoryItem: Codable {
    var id: UUID
    var fridgeItem: FridgeItem
    var action: HistoryAction
    var timestamp: Date
    
    init(fridgeItem: FridgeItem, action: HistoryAction) {
        self.id = UUID()
        self.fridgeItem = fridgeItem
        self.action = action
        self.timestamp = Date()
    }
}

enum HistoryAction: String, Codable {
    case added = "Added"
    case removed = "Removed"
    case updated = "Updated"
}

// MARK: - History Data Manager Extension
extension FridgeDataManager {
    private var historyItemsKey: String { "HistoryItems" }
    
    func saveHistoryItems(_ items: [HistoryItem]) {
        do {
            let data = try JSONEncoder().encode(items)
            UserDefaults.standard.set(data, forKey: historyItemsKey)
        } catch {
            print("Failed to save history items: \(error)")
        }
    }
    
    func loadHistoryItems() -> [HistoryItem] {
        guard let data = UserDefaults.standard.data(forKey: historyItemsKey) else {
            return []
        }
        
        do {
            let items = try JSONDecoder().decode([HistoryItem].self, from: data)
            return items.sorted { $0.timestamp > $1.timestamp } // Most recent first
        } catch {
            print("Failed to load history items: \(error)")
            return []
        }
    }
    
    func addHistoryItem(_ item: FridgeItem, action: HistoryAction) {
        var historyItems = loadHistoryItems()
        let historyItem = HistoryItem(fridgeItem: item, action: action)
        historyItems.insert(historyItem, at: 0) // Add to beginning
        
        // Keep only last 100 history items to prevent unlimited growth
        if historyItems.count > 100 {
            historyItems = Array(historyItems.prefix(100))
        }
        
        saveHistoryItems(historyItems)
    }
}
