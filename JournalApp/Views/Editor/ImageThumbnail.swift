//
//  ImageThumbnail.swift
//  JournalApp
//
//  Image thumbnail view for gallery
//

import SwiftUI

struct ImageThumbnail: View {
    let filename: String
    let date: Date
    
    @State private var imageData: Data?
    @State private var isLoading = true
    
    var body: some View {
        Group {
            if let data = imageData, let nsImage = NSImage(data: data) {
                Image(nsImage: nsImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 70, height: 70)
                    .clipped()
            } else if isLoading {
                ProgressView()
                    .frame(width: 70, height: 70)
            } else {
                VStack {
                    Image(systemName: "photo")
                        .foregroundColor(.secondary)
                    Text("Error")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .frame(width: 70, height: 70)
                .background(Color.secondary.opacity(0.1))
            }
        }
        .frame(width: 70, height: 70)
        .cornerRadius(6)
        .help(filename)
        .onAppear {
            loadImage()
        }
    }
    
    private func loadImage() {
        isLoading = true
        DispatchQueue.global(qos: .userInitiated).async {
            let data = FileStorageManager.shared.loadImage(named: filename, for: date)
            DispatchQueue.main.async {
                self.imageData = data
                self.isLoading = false
            }
        }
    }
}