//
//  CalendarDayView.swift
//  JournalApp
//
//  Individual calendar day cell
//

import SwiftUI

struct CalendarDayView: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let hasEntry: Bool
    let isCurrentMonth: Bool
    
    var body: some View {
        ZStack(alignment: .center) {
            // Background for selected/today
            if isSelected {
                Circle()
                    .fill(Color.accentColor.opacity(0.3))
            } else if isToday {
                Circle()
                    .stroke(Color.accentColor, lineWidth: 1.5)
            }
            
            // Day number
            Text(dayString)
                .font(.system(size: 12, weight: isToday ? .semibold : .regular))
                .foregroundColor(textColor)
                .opacity(isCurrentMonth ? 1.0 : 0.5)
                
            // Entry indicator
            if hasEntry {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        entryIndicator
                            .offset(x: 0, y: -2)
                    }
                }
            }
        }
        .frame(height: 28)
        .contentShape(Rectangle())
    }
    
    private var dayString: String {
        String(Calendar.current.component(.day, from: date))
    }
    
    private var textColor: Color {
        if isSelected {
            return Color.accentColor
        } else if isToday {
            return Color.accentColor
        } else {
            return Color.primary
        }
    }
    
    private var entryIndicator: some View {
        Circle()
            .fill(Color.accentColor)
            .frame(width: 4, height: 4)
    }
}