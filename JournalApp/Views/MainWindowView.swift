//
//  MainWindowView.swift
//  JournalApp
//
//  Main window with split layout
//

import SwiftUI
import AppKit

struct MainWindowView: View {
    @EnvironmentObject var journalViewModel: JournalViewModel
    @State private var sidebarWidth: CGFloat = 280
    
    var body: some View {
        HSplitView {
            EditorView()
                .environmentObject(journalViewModel)
            
            SidebarView(journalViewModel: journalViewModel)
                .frame(minWidth: 280, idealWidth: 280, maxWidth: 350)
        }
        .frame(minWidth: 900, minHeight: 600)
        .onAppear {
            journalViewModel.navigateToDate(Date())
        }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.willBecomeActiveNotification)) { _ in
            journalViewModel.loadCurrentEntry()
        }
        .onReceive(NotificationCenter.default.publisher(for: .exportEntry)) { _ in
            DispatchQueue.main.async {
                self.exportEntry()
            }
        }
        .preferredColorScheme(journalViewModel.isDarkTheme ? .dark : .light)
    }
    
    private func exportEntry() {
        let entry = journalViewModel.currentEntry
        let date = journalViewModel.currentDate
        let filename = "\(date.journalDateString()).md"
        let dateDisplay = date.displayDateString()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let panel = NSSavePanel()
            panel.nameFieldStringValue = filename
            
            if panel.runModal() == .OK, let url = panel.url {
                var content = "# \(dateDisplay)\n\n\(entry?.content ?? "")"
                try? content.write(to: url, atomically: true, encoding: .utf8)
            }
        }
    }
}

// MARK: - Theme Modifier

struct ThemeModifier: ViewModifier {
    @EnvironmentObject var journalViewModel: JournalViewModel
    
    func body(content: Content) -> some View {
        content
            .preferredColorScheme(journalViewModel.isDarkTheme ? .dark : .light)
    }
}

extension View {
    func applyTheme(_ journalViewModel: JournalViewModel) -> some View {
        self.modifier(ThemeModifier())
            .environmentObject(journalViewModel)
    }
}

struct MainWindowView_Previews: PreviewProvider {
    static var previews: some View {
        MainWindowView()
            .environmentObject(JournalViewModel())
            .frame(width: 1200, height: 800)
    }
}