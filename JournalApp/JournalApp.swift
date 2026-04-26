//
//  JournalApp.swift
//  JournalApp
//
//  A minimal, distraction-free journaling app for macOS
//

import SwiftUI
import AppKit

@main
struct JournalApp: App {
    @StateObject private var journalViewModel = JournalViewModel()
    
    var body: some Scene {
        WindowGroup {
            MainWindowView()
                .environmentObject(journalViewModel)
                .frame(minWidth: 900, minHeight: 600)
        }
        .windowStyle(.titleBar)
        .commands {
            CommandGroup(replacing: .newItem) { }
            CommandGroup(replacing: .saveItem) { }
            
            CommandGroup(after: .textEditing) {
                Button("Increase Font Size") {
                    NotificationCenter.default.post(name: .changeFontSize, object: 2)
                }
                .keyboardShortcut("+", modifiers: .command)
                
                Button("Decrease Font Size") {
                    NotificationCenter.default.post(name: .changeFontSize, object: -2)
                }
                .keyboardShortcut("-", modifiers: .command)
            }
            
            CommandMenu("Journal") {
                Button("Export Entry...") {
                    NotificationCenter.default.post(name: .exportEntry, object: nil)
                }
                .keyboardShortcut("e", modifiers: [.command, .shift])
                
                Divider()
                
                Button("Toggle Theme") {
                    journalViewModel.toggleTheme()
                }
                .keyboardShortcut("t", modifiers: [.command, .shift])
            }
        }
    }
}

extension Notification.Name {
    static let changeFontSize = Notification.Name("changeFontSize")
    static let exportEntry = Notification.Name("exportEntry")
}