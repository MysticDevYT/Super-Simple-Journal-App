//
//  SidebarView.swift
//  JournalApp
//
//  Right sidebar containing calendar and navigation
//

import SwiftUI

struct SidebarView: View {
    @ObservedObject var journalViewModel: JournalViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            // Calendar
            CalendarView(journalViewModel: journalViewModel)
                .padding(.vertical, 16)
            
            Divider()
            
            // Navigation toolbar
            HStack(spacing: 16) {
                Button(action: previousDay) {
                    Label("Previous Day", systemImage: "chevron.left")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(PlainButtonStyle())
                .help("Go to previous day")
                
                Spacer()
                
                Button(action: nextDay) {
                    Label("Next Day", systemImage: "chevron.right")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(PlainButtonStyle())
                .help("Go to next day")
                
                Spacer()
                
                Button(action: backToToday) {
                    Label("Today", systemImage: "calendar.badge.clock")
                        .font(.system(size: 11))
                        .foregroundColor(.accentColor)
                }
                .buttonStyle(PlainButtonStyle())
                .help("Go to today")
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            
            Divider()
            
            // Stats
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Total Entries")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(journalViewModel.totalEntries)")
                        .font(.caption)
                        .foregroundColor(.primary)
                        .fontWeight(.medium)
                }
                
                HStack {
                    Text("This Month")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(journalViewModel.monthEntries)")
                        .font(.caption)
                        .foregroundColor(.primary)
                        .fontWeight(.medium)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            
            Spacer()
        }
        .frame(width: 280)
        .background(Color(NSColor.windowBackgroundColor))
    }
    
    private func previousDay() {
        let calendar = Calendar.current
        if let newDate = calendar.date(byAdding: .day, value: -1, to: journalViewModel.currentDate) {
            journalViewModel.navigateToDate(newDate)
        }
    }
    
    private func nextDay() {
        let calendar = Calendar.current
        if let newDate = calendar.date(byAdding: .day, value: 1, to: journalViewModel.currentDate) {
            journalViewModel.navigateToDate(newDate)
        }
    }
    
    private func backToToday() {
        journalViewModel.navigateToDate(Date())
    }
}

struct SidebarView_Previews: PreviewProvider {
    static var previews: some View {
        SidebarView(journalViewModel: JournalViewModel())
            .frame(height: 600)
    }
}