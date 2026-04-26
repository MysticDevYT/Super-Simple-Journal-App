//
//  Entry.swift
//  JournalApp
//
//  Model representing a journal entry
//

import Foundation
import SwiftUI

struct Entry: Identifiable, Codable, Equatable {
    let id: UUID
    let date: Date
    var content: String
    var createdAt: Date
    var updatedAt: Date
    var imageAttachments: [ImageAttachment]
    
    init(id: UUID = UUID(), date: Date, content: String = "", createdAt: Date = Date(), updatedAt: Date = Date(), imageAttachments: [ImageAttachment] = []) {
        self.id = id
        self.date = date
        self.content = content
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.imageAttachments = imageAttachments
    }
    
    static func == (lhs: Entry, rhs: Entry) -> Bool {
        lhs.id == rhs.id && lhs.content == rhs.content && lhs.date == rhs.date
    }
    
    var isEmpty: Bool {
        content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

struct ImageAttachment: Identifiable, Codable {
    let id: UUID
    let filename: String
    let originalName: String
    let fileSize: Int
    let mimeType: String
    
    init(id: UUID = UUID(), filename: String, originalName: String, fileSize: Int, mimeType: String) {
        self.id = id
        self.filename = filename
        self.originalName = originalName
        self.fileSize = fileSize
        self.mimeType = mimeType
    }
}

// MARK: - Date Extensions
extension Date {
    func journalDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: self)
    }
    
    func displayDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: self)
    }
    
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
    
    var endOfDay: Date {
        Calendar.current.date(byAdding: .day, value: 1, to: startOfDay) ?? self
    }
}