//
//  JournalViewModel+Extensions.swift
//  JournalApp
//
//  Additional methods for JournalViewModel
//

import Foundation
import Combine
import AppKit
import UniformTypeIdentifiers

extension JournalViewModel {
    // MARK: - Current Entry Management
    
    func loadCurrentEntry() {
        loadEntry(for: currentDate)
    }
    
    // MARK: - Navigation
    
    func navigateToDate(_ date: Date) {
        selectedDate = date
        currentDate = date
        loadEntry(for: date)
    }
    
    // MARK: - Entry Statistics
    
    var totalEntries: Int {
        storageManager.entries.count
    }
    
    var monthEntries: Int {
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: Date())
        let currentYear = calendar.component(.year, from: Date())
        
        return storageManager.entries.filter { date in
            calendar.component(.month, from: date) == currentMonth &&
            calendar.component(.year, from: date) == currentYear
        }.count
    }
    
    // MARK: - Image Handling
    
    func handleImageDrop(_ provider: NSItemProvider, completion: @escaping (Bool) -> Void) {
        provider.loadDataRepresentation(forTypeIdentifier: "public.image") { [weak self] data, error in
            guard let data = data, error == nil else {
                completion(false)
                return
            }
            
            // Compress image if needed
            let compressedData = self?.compressImageData(data) ?? data
            
            DispatchQueue.main.async {
                guard let self = self else {
                    completion(false)
                    return
                }
                
                let filename = "image_\(UUID().uuidString).png"
                if let savedFilename = self.storageManager.saveImage(compressedData, named: filename, for: self.currentDate) {
                    // Add image reference to current entry
                    let imageRef = "\n\n![Image](\(savedFilename))\n"
                    if let currentEntry = self.currentEntry {
                        let updatedContent = currentEntry.content + imageRef
                        self.updateEntry(updatedContent)
                    } else {
                        let newEntry = Entry(date: self.currentDate, content: imageRef)
                        self.currentEntry = newEntry
                        self.storageManager.saveEntry(newEntry)
                    }
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
    }
    
    private func compressImageData(_ data: Data) -> Data {
        // Simple compression - if data is larger than 1MB, reduce quality
        if data.count > 1_000_000 {
            // For now, return as-is. In a full implementation,
            // we'd use ImageIO to compress the image
            return data
        }
        return data
    }
    
    // MARK: - Theme Management
    
    func toggleTheme() {
        isDarkTheme.toggle()
        // In a full implementation, save to UserDefaults
    }
    
    // MARK: - Export
    
    // MARK: - Entry Check
    
    func hasEntry(for date: Date) -> Bool {
        storageManager.hasEntry(for: date)
    }
    
    // MARK: - Image Save
    
    func saveImage(_ data: Data, named filename: String) -> String? {
        storageManager.saveImage(data, named: filename, for: currentDate)
    }
}
