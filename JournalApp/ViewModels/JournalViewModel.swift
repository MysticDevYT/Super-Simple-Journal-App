//
//  JournalViewModel.swift
//  JournalApp
//
//  Main view model managing journal state
//

import Foundation
import Combine
import SwiftUI

@MainActor
final class JournalViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var currentEntry: Entry?
    @Published var selectedDate: Date = Date()
    @Published var currentDate: Date = Date()
    @Published var isDarkTheme: Bool = true
    @Published var isSaving: Bool = false
    @Published var lastSaveTime: Date?
    
    // MARK: - Dependencies
    
    let storageManager: FileStorageManager
    
    // MARK: - Private Properties
    
    private var cancellables = Set<AnyCancellable>()
    private let saveSubject = PassthroughSubject<String, Never>()
    private var saveCancellable: AnyCancellable?
    
    // MARK: - Initialization
    
    init(storageManager: FileStorageManager = .shared) {
        self.storageManager = storageManager
        
        setupAutoSave()
        loadCurrentEntry()
    }
    
    // MARK: - Auto-Save Setup
    
    private func setupAutoSave() {
        saveCancellable = saveSubject
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] content in
                self?.performSave(content)
            }
    }
    
    private func performSave(_ content: String) {
        guard let entry = currentEntry else {
            // Create new entry
            let newEntry = Entry(date: currentDate, content: content)
            currentEntry = newEntry
            storageManager.saveEntry(newEntry)
            lastSaveTime = Date()
            return
        }
        
        // Update existing entry
        var updatedEntry = entry
        updatedEntry.content = content
        updatedEntry.updatedAt = Date()
        currentEntry = updatedEntry
        storageManager.saveEntry(updatedEntry)
        lastSaveTime = Date()
    }
    
    // MARK: - Entry Management
    
    func loadEntry(for date: Date) {
        let normalizedDate = Calendar.current.startOfDay(for: date)
        
        if let entry = storageManager.loadEntry(for: normalizedDate) {
            currentEntry = entry
        } else {
            // Create placeholder entry (content saved on first keystroke)
            currentEntry = Entry(date: normalizedDate)
        }
        
        currentDate = normalizedDate
        selectedDate = normalizedDate
    }
    
    func updateEntry(_ content: String) {
        guard let entry = currentEntry else {
            // Create new entry on first typing
            let newEntry = Entry(date: currentDate, content: content)
            currentEntry = newEntry
            saveSubject.send(content)
            return
        }
        
        // Don't save if content hasn't changed
        guard entry.content != content else { return }
        
        currentEntry?.content = content
        saveSubject.send(content)
    }
    
    // MARK: - Formatting
    
    func applyBold() {
        insertMarkdown("**", "**")
    }
    
    func applyItalic() {
        insertMarkdown("*", "*")
    }
    
    func applyHeading() {
        insertMarkdown("## ", "")
    }
    
    func applyBulletList() {
        insertMarkdown("- ", "")
    }
    
    func applyNumberedList() {
        insertMarkdown("1. ", "")
    }
    
    private func insertMarkdown(_ prefix: String, _ suffix: String) {
        guard let entry = currentEntry else { return }
        
        // This will be implemented with full NSTextView integration
        // For now, just trigger auto-save
        currentEntry?.content = prefix + entry.content + suffix
        saveSubject.send(currentEntry?.content ?? "")
    }
}