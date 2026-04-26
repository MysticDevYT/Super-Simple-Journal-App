//
//  MonthNavigator.swift
//  JournalApp
//
//  Month and year navigation in calendar
//

import SwiftUI

struct MonthNavigator: View {
    @Binding var currentMonth: Date
    let onMonthChange: (Date) -> Void
    
    private let calendar = Calendar.current
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentMonth)
    }
    
    var body: some View {
        HStack {
            Button(action: goToPreviousMonth) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .buttonStyle(PlainButtonStyle())
            .help("Previous month")
            
            Spacer()
            
            Text(monthYearString)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.primary)
                .help("Current month")
            
            Spacer()
            
            Button(action: goToNextMonth) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .buttonStyle(PlainButtonStyle())
            .help("Next month")
        }
        .padding(.horizontal, 16)
    }
    
    private func goToPreviousMonth() {
        if let newMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) {
            currentMonth = newMonth
            onMonthChange(newMonth)
        }
    }
    
    private func goToNextMonth() {
        if let newMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) {
            currentMonth = newMonth
            onMonthChange(newMonth)
        }
    }
}