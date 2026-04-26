//
//  Constants.swift
//  JournalApp
//
//  App-wide constants
//

import Foundation

struct Constants {
    // Auto-save
    static let autoSaveDebounceMs = 500
    
    // Image limits
    static let maxImageFileSize = 5 * 1024 * 1024 // 5MB
    static let maxImageDimensions: CGFloat = 2048
    
    // Journal directory
    static let journalDirectoryName = "Journal"
    
    // UI
    static let sidebarWidth: CGFloat = 280
    static let sidebarMinWidth: CGFloat = 240
    static let sidebarMaxWidth: CGFloat = 350
    static let minWindowWidth: CGFloat = 900
    static let minWindowHeight: CGFloat = 600
}