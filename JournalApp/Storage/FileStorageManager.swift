//
//  FileStorageManager.swift
//  JournalApp
//
//  Manages local file storage for journal entries
//

import Foundation
import Combine

final class FileStorageManager: ObservableObject {
    static let shared = FileStorageManager()
    
    private let fileManager = FileManager.default
    private let journalDirectoryName = "Journal"
    
    @Published var entries: Set<Date> = []
    
    private init() {
        loadEntryDates()
    }
    
    // MARK: - Directory Management
    
    private var documentsDirectory: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private var journalDirectory: URL {
        documentsDirectory.appendingPathComponent(journalDirectoryName)
    }
    
    private func createJournalDirectoryIfNeeded() {
        do {
            try fileManager.createDirectory(at: journalDirectory, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Error creating journal directory: \(error)")
        }
    }
    
    private func entryDirectory(for date: Date) -> URL {
        let dateString = date.journalDateString()
        return journalDirectory.appendingPathComponent(dateString)
    }
    
    private func createEntryDirectoryIfNeeded(for date: Date) {
        let directory = entryDirectory(for: date)
        do {
            try fileManager.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Error creating entry directory: \(error)")
        }
    }
    
    // MARK: - Entry Operations
    
    func loadEntry(for date: Date) -> Entry? {
        createJournalDirectoryIfNeeded()
        let directory = entryDirectory(for: date)
        let entryFile = directory.appendingPathComponent("entry.md")
        
        guard fileManager.fileExists(atPath: entryFile.path) else {
            return nil
        }
        
        do {
            let data = try Data(contentsOf: entryFile)
            let content = String(data: data, encoding: .utf8) ?? ""
            
            // Load image metadata
            let imageAttachments = try loadImageAttachments(for: date)
            
            let entry = Entry(
                date: date,
                content: content,
                createdAt: try fileManager.attributesOfItem(atPath: entryFile.path)[.creationDate] as? Date ?? date,
                updatedAt: try fileManager.attributesOfItem(atPath: entryFile.path)[.modificationDate] as? Date ?? date,
                imageAttachments: imageAttachments
            )
            
            return entry
        } catch {
            print("Error loading entry: \(error)")
            return nil
        }
    }
    
    func saveEntry(_ entry: Entry) {
        createJournalDirectoryIfNeeded()
        createEntryDirectoryIfNeeded(for: entry.date)
        
        let directory = entryDirectory(for: entry.date)
        let entryFile = directory.appendingPathComponent("entry.md")
        
        do {
            try entry.content.write(to: entryFile, atomically: true, encoding: .utf8)
            entries.insert(entry.date.startOfDay)
        } catch {
            print("Error saving entry: \(error)")
        }
    }
    
    func hasEntry(for date: Date) -> Bool {
        let directory = entryDirectory(for: date)
        let entryFile = directory.appendingPathComponent("entry.md")
        return fileManager.fileExists(atPath: entryFile.path)
    }
    
    func deleteEntry(for date: Date) {
        let directory = entryDirectory(for: date)
        do {
            try fileManager.removeItem(at: directory)
        } catch {
            print("Error deleting entry: \(error)")
        }
    }
    
    // MARK: - Image Operations
    
    func saveImage(_ imageData: Data, named originalName: String, for date: Date) -> String? {
        createEntryDirectoryIfNeeded(for: date)
        let directory = entryDirectory(for: date)
        
        let fileExtension = URL(fileURLWithPath: originalName).pathExtension
        let filename = UUID().uuidString + "." + fileExtension
        let imageFile = directory.appendingPathComponent(filename)
        
        do {
            try imageData.write(to: imageFile)
            return filename
        } catch {
            print("Error saving image: \(error)")
            return nil
        }
    }
    
    func loadImage(named filename: String, for date: Date) -> Data? {
        let directory = entryDirectory(for: date)
        let imageFile = directory.appendingPathComponent(filename)
        
        guard fileManager.fileExists(atPath: imageFile.path) else {
            return nil
        }
        
        do {
            return try Data(contentsOf: imageFile)
        } catch {
            print("Error loading image: \(error)")
            return nil
        }
    }
    
    private func loadImageAttachments(for date: Date) throws -> [ImageAttachment] {
        let directory = entryDirectory(for: date)
        guard fileManager.fileExists(atPath: directory.path) else {
            return []
        }
        
        let contents = try fileManager.contentsOfDirectory(atPath: directory.path)
        let imageFiles = contents.filter { $0 != "entry.md" && $0.hasSuffix(".png") || $0.hasSuffix(".jpg") || $0.hasSuffix(".jpeg") || $0.hasSuffix(".gif") }
        
        return imageFiles.compactMap { filename in
            let filePath = directory.appendingPathComponent(filename).path
            guard let attributes = try? fileManager.attributesOfItem(atPath: filePath),
                  let fileSize = attributes[.size] as? Int else {
                return nil
            }
            
            let mimeType: String
            if filename.hasSuffix(".png") {
                mimeType = "image/png"
            } else if filename.hasSuffix(".gif") {
                mimeType = "image/gif"
            } else {
                mimeType = "image/jpeg"
            }
            
            return ImageAttachment(
                filename: filename,
                originalName: filename,
                fileSize: fileSize,
                mimeType: mimeType
            )
        }
    }
    
    // MARK: - Entry Date Management
    
    private func loadEntryDates() {
        createJournalDirectoryIfNeeded()
        
        do {
            let contents = try fileManager.contentsOfDirectory(atPath: journalDirectory.path)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            for folderName in contents {
                if let date = dateFormatter.date(from: folderName) {
                    entries.insert(date)
                }
            }
        } catch {
            print("Error loading entry dates: \(error)")
        }
    }
    
    // MARK: - Export
    
    func exportEntry(for date: Date, to url: URL) throws {
        guard let entry = loadEntry(for: date) else {
            throw JournalError.entryNotFound
        }
        
        var markdownContent = """
        # \(date.displayDateString())
        
        \(entry.content)
        """
        
        if !entry.imageAttachments.isEmpty {
            markdownContent += "\n\n## Images\n"
            for attachment in entry.imageAttachments {
                markdownContent += "\n![\(attachment.originalName)](\(attachment.filename))\n"
            }
        }
        
        try markdownContent.write(to: url, atomically: true, encoding: .utf8)
    }
}

// MARK: - Errors

enum JournalError: Error {
    case entryNotFound
    case directoryCreationFailed
    case fileWriteFailed
    case fileReadFailed
    case invalidDate
}