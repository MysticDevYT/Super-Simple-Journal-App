//
//  NSTextViewRepresentable.swift
//  JournalApp
//
//  Bridging NSTextView to SwiftUI for rich text editing
//

import SwiftUI
import AppKit

struct NSTextViewRepresentable: NSViewRepresentable {
    @Binding var text: String
    @Binding var isEditable: Bool
    var fontSize: CGFloat = 14
    
    let onTextChange: (String) -> Void
    let onDrop: (NSItemProvider) -> Bool
    
    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSTextView.scrollableTextView()
        let textView = scrollView.documentView as! NSTextView
        
        textView.isEditable = isEditable
        textView.isSelectable = true
        textView.isRichText = true
        textView.allowsUndo = true
        textView.isAutomaticSpellingCorrectionEnabled = false
        textView.font = NSFont.systemFont(ofSize: fontSize)
        textView.textContainer?.containerSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        textView.textContainer?.widthTracksTextView = true
        
        textView.string = text
        textView.delegate = context.coordinator
        textView.registerForDraggedTypes([.fileURL])
        
        return scrollView
    }
    
    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = scrollView.documentView as? NSTextView else { return }
        
        if textView.string != text {
            let cursorPos = textView.selectedRange().location
            textView.string = text
            if cursorPos <= text.count {
                textView.setSelectedRange(NSRange(location: cursorPos, length: 0))
            }
        }
        
        textView.isEditable = isEditable
        textView.font = NSFont.systemFont(ofSize: fontSize)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, NSTextViewDelegate, NSDraggingDestination {
        var parent: NSTextViewRepresentable?
        
        init(parent: NSTextViewRepresentable) {
            self.parent = parent
            super.init()
        }
        
        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            let newText = textView.string
            
            if parent?.text != newText {
                parent?.text = newText
                parent?.onTextChange(newText)
            }
        }
        
        func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
            return sender.draggingPasteboard.canReadItem(withDataConformingToTypes: ["public.image", "public.file-url"]) ? .copy : []
        }
        
        func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
            guard let item = sender.draggingPasteboard.pasteboardItems?.first else { return false }
            
            if let fileURLData = item.data(forType: .fileURL),
               let fileURL = URL(dataRepresentation: fileURLData, relativeTo: nil) {
                let ext = fileURL.pathExtension.lowercased()
                if ["png", "jpg", "jpeg", "gif", "tiff"].contains(ext) {
                    let provider = NSItemProvider(contentsOf: fileURL)
                    return parent?.onDrop(provider ?? NSItemProvider()) ?? false
                }
            }
            return false
        }
    }
}