//
//  DateDisplayView.swift
//  JournalApp
//
//  Date header display above entry
//

import SwiftUI

struct DateDisplayView: View {
    let date: Date
    let showCreatedAt: Bool
    
    init(date: Date, showCreatedAt: Bool = true) {
        self.date = date
        self.showCreatedAt = showCreatedAt
    }
    
    private var formattedDate: String {
        date.displayDateString()
    }
    
    private var relativeDate: String {
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else if calendar.isDateInTomorrow(date) {
            return "Tomorrow"
        } else {
            return formattedDate
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(relativeDate)
                .font(.system(size: 28, weight: .semibold))
                .foregroundColor(.primary)
            
            if showCreatedAt {
                Text(formattedDate)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary.opacity(0.8))
            }
        }
    }
}

struct DateDisplayView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            DateDisplayView(date: Date())
            DateDisplayView(date: Date().addingTimeInterval(-86400))
            DateDisplayView(date: Date().addingTimeInterval(86400))
        }
        .padding()
    }
}