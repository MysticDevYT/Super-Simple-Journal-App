//
//  EditorView.swift
//  JournalApp
//
//  Main editor view with formatting toolbar
//

import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct EditorView: View {
    @EnvironmentObject var journalViewModel: JournalViewModel
    
    @State private var text: String = ""
    @State private var showingImageDropZone = false
    @State private var fontSize: CGFloat = 14
    
    private let minFontSize: CGFloat = 10
    private let maxFontSize: CGFloat = 32
    
    var body: some View {
        VStack(spacing: 0) {
            // Date header
            headerView
            
            Divider()
            
            // Formatting toolbar
            formattingToolbar
            
            Divider()
            
            // Text editor
            textEditor
            
            // Status bar
            statusBar
        }
        .background(backgroundColor)
        .onAppear {
            loadCurrentEntry()
        }
        .onChange(of: journalViewModel.currentEntry) { _ in
            loadCurrentEntry()
        }
        .onReceive(NotificationCenter.default.publisher(for: .changeFontSize)) { notification in
            if let delta = notification.object as? CGFloat {
                zoom(delta)
            }
        }
    }
    
    // MARK: - Views
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(journalViewModel.currentDate.displayDateString())
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.primary)
                
                if let entry = journalViewModel.currentEntry {
                    Text("Created: \(entry.createdAt.formatted())")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Export button
            Button(action: exportCurrentEntry) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            .buttonStyle(PlainButtonStyle())
            .help("Export entry")
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
    
    private var formattingToolbar: some View {
        HStack(spacing: 16) {
            // Image button
            Button(action: insertImage) {
                Image(systemName: "photo")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            .buttonStyle(PlainButtonStyle())
            .help("Insert Image")
            
            Divider()
                .frame(height: 20)
            
            // Zoom
            HStack(spacing: 8) {
Button(action: { zoom(-2) }) {
            Image(systemName: "minus.magnifyingglass")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
        .buttonStyle(PlainButtonStyle())
        
        Text("\(Int(fontSize))pt")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(width: 45)
                
                Button(action: { zoom(2) }) {
                    Image(systemName: "plus.magnifyingglass")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            Spacer()
            
            // Word count
            Text(wordCount)
                .font(.caption)
                .foregroundColor(.secondary)
                .monospacedDigit()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
    }
    
    private var textEditor: some View {
        VStack(spacing: 0) {
            NSTextViewRepresentable(
                text: $text,
                isEditable: .constant(true),
                fontSize: fontSize,
                onTextChange: handleTextChange,
                onDrop: handleImageDrop
            )
            .background(Color.clear)
            
            // Drop zone indicator
            if showingImageDropZone {
                dropZoneOverlay
            }
            
            // Image gallery
            imageGallery
        }
    }
    
    private var imageGallery: some View {
        let images = extractImageFilenames()
        
        return Group {
            if !images.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(images, id: \.self) { filename in
                            ImageThumbnail(filename: filename, date: journalViewModel.currentDate)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                }
                .frame(height: 80)
                .background(Color.secondary.opacity(0.05))
            }
        }
    }
    
    private func extractImageFilenames() -> [String] {
        // Extract image filenames from markdown: ![name](filename)
        var filenames: [String] = []
        let pattern = #"!\[([^\]]+)\]\(([^)]+)\)"#
        
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
        let range = NSRange(text.startIndex..., in: text)
        let matches = regex.matches(in: text, range: range)
        
        for match in matches {
            if match.numberOfRanges > 2,
               let filenameRange = Range(match.range(at: 2), in: text) {
                filenames.append(String(text[filenameRange]))
            }
        }
        
        return filenames
    }
    
    private var dropZoneOverlay: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.accentColor.opacity(0.1))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.accentColor, style: StrokeStyle(lineWidth: 2, dash: [5, 5]))
            )
            .overlay(
                VStack {
                    Image(systemName: "photo")
                        .font(.system(size: 48))
                        .foregroundColor(.accentColor)
                    Text("Drop image here")
                        .font(.headline)
                        .foregroundColor(.accentColor)
                }
            )
            .padding()
    }
    
    private var statusBar: some View {
        HStack {
            // Save status
            if journalViewModel.isSaving {
                Text("Saving...")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else if let lastSave = journalViewModel.lastSaveTime {
                Text("Saved: \(lastSave, style: .time)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Entry status
            if journalViewModel.currentEntry?.isEmpty == false {
                Text("Entry saved")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                Text("Empty entry")
                    .font(.caption)
                    .foregroundColor(.secondary.opacity(0.6))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 6)
        .background(Color.secondary.opacity(0.05))
    }
    
    // MARK: - Properties
    
    private var wordCount: String {
        let count = text.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .count
        return "\(count) words"
    }
    
    private var backgroundColor: Color {
        #if os(macOS)
        Color(NSColor.textBackgroundColor)
        #else
        Color(.systemBackground)
        #endif
    }
    
    // MARK: - Actions
    
    private func loadCurrentEntry() {
        text = journalViewModel.currentEntry?.content ?? ""
    }
    
    private func handleTextChange(_ newText: String) {
        journalViewModel.updateEntry(newText)
    }
    
    private func handleImageDrop(_ provider: NSItemProvider) -> Bool {
        showingImageDropZone = false
        
        // Capture journalViewModel reference
        let viewModel = journalViewModel
        
        // Try to load image data directly
        if provider.hasItemConformingToTypeIdentifier("public.png") {
            provider.loadDataRepresentation(forTypeIdentifier: "public.png") { data, error in
                guard let data = data, error == nil else { return }
                DispatchQueue.main.async {
                    self.processDroppedImageData(data, filename: "dropped.png", viewModel: viewModel)
                }
            }
            return true
        } else if provider.hasItemConformingToTypeIdentifier("public.jpeg") {
            provider.loadDataRepresentation(forTypeIdentifier: "public.jpeg") { data, error in
                guard let data = data, error == nil else { return }
                DispatchQueue.main.async {
                    self.processDroppedImageData(data, filename: "dropped.jpg", viewModel: viewModel)
                }
            }
            return true
        } else if provider.hasItemConformingToTypeIdentifier("public.image") {
            provider.loadDataRepresentation(forTypeIdentifier: "public.image") { data, error in
                guard let data = data, error == nil else { return }
                DispatchQueue.main.async {
                    self.processDroppedImageData(data, filename: "dropped.png", viewModel: viewModel)
                }
            }
            return true
        }
        
        return false
    }
    
    private func processDroppedImageData(_ data: Data, filename: String, viewModel: JournalViewModel) {
        // Save image and add reference to entry
        if let savedFilename = viewModel.saveImage(data, named: filename) {
            let imageRef = "\n\n![\(filename)](\(savedFilename))\n"
            let newContent = text + imageRef
            text = newContent
            viewModel.updateEntry(newContent)
        }
    }
    
    private func insertImage() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.png, .jpeg, .gif, .tiff]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        
        if panel.runModal() == .OK, let url = panel.url {
            do {
                let data = try Data(contentsOf: url)
                if let savedFilename = journalViewModel.saveImage(data, named: url.lastPathComponent) {
                    let imageRef = "\n\n![\(url.lastPathComponent)](\(savedFilename))\n"
                    text = text + imageRef
                    journalViewModel.updateEntry(text)
                }
            } catch {
                print("Failed to load image: \(error)")
            }
        }
    }
    
    private func zoom(_ delta: CGFloat) {
        fontSize = min(max(fontSize + delta, minFontSize), maxFontSize)
    }
    
    private func exportCurrentEntry() {
        NotificationCenter.default.post(name: .exportEntry, object: nil)
    }
}

struct EditorView_Previews: PreviewProvider {
    static var previews: some View {
        EditorView()
            .environmentObject(JournalViewModel())
    }
}