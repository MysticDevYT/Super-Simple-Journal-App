//
//  String+Extensions.swift
//  JournalApp
//
//  String utility extensions
//

import Foundation

extension String {
    func truncate(to maxLength: Int, ellipsis: String = "...") -> String {
        guard count > maxLength else { return self }
        return String(prefix(maxLength)) + ellipsis
    }
    
    func wordCount() -> Int {
        let words = self.components(separatedBy: .whitespacesAndNewlines)
        return words.filter { !$0.isEmpty }.count
    }
    
    func isValidImageFilename() -> Bool {
        let validExtensions = ["png", "jpg", "jpeg", "gif", "tiff", "webp"]
        let ext = (self as NSString).pathExtension.lowercased()
        return validExtensions.contains(ext)
    }
}