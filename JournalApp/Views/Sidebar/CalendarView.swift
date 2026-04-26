//
//  CalendarView.swift
//  JournalApp
//
//  Monthly calendar grid for date navigation
//

import SwiftUI

struct CalendarView: View {
    @ObservedObject var journalViewModel: JournalViewModel
    @State private var currentMonth: Date = Date()
    
    private let calendar = Calendar.current
    private let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
    
    private let weekdaySymbols = Calendar.current.shortWeekdaySymbols
    
    var body: some View {
        VStack(spacing: 16) {
            // Month navigation
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
                
                Text(monthFormatter.string(from: currentMonth))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            
            // Weekday headers
            HStack(spacing: 0) {
                ForEach(0..<7) { index in
                    Text(String(weekdaySymbols[index].prefix(2)))
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 12)
            
            // Calendar grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 2) {
                ForEach(daysInMonth(), id: \.self) { date in
                    CalendarDayCell(
                        date: date,
                        isSelected: isSelected(date),
                        isToday: isToday(date),
                        hasEntry: journalViewModel.hasEntry(for: date),
                        isInCurrentMonth: isInCurrentMonth(date)
                    )
                    .onTapGesture {
                        selectDate(date)
                    }
                }
            }
            .padding(.horizontal, 12)
            
            // Selected date indicator
            Divider()
            
            VStack(spacing: 4) {
                Text("Selected")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(journalViewModel.selectedDate.displayDateString())
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.primary)
            }
            .padding(.vertical, 8)
        }
        .padding(.vertical, 16)
    }
    
    // MARK: - Calendar Logic
    
    private func daysInMonth() -> [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start),
              let monthLastWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.end - 1) else {
            return []
        }
        
        var dates: [Date] = []
        var currentDate = monthFirstWeek.start
        
        while currentDate <= monthLastWeek.end {
            dates.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        return dates
    }
    
    private func isSelected(_ date: Date) -> Bool {
        calendar.isDate(date, inSameDayAs: journalViewModel.selectedDate)
    }
    
    private func isToday(_ date: Date) -> Bool {
        calendar.isDate(date, inSameDayAs: Date())
    }
    
    private func isInCurrentMonth(_ date: Date) -> Bool {
        calendar.isDate(date, equalTo: currentMonth, toGranularity: .month)
    }
    
    private func selectDate(_ date: Date) {
        journalViewModel.selectedDate = date
        journalViewModel.currentDate = date
        journalViewModel.loadEntry(for: date)
    }
    
    private func previousMonth() {
        currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
    }
    
    private func nextMonth() {
        currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
    }
}

struct CalendarDayCell: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let hasEntry: Bool
    let isInCurrentMonth: Bool
    
    var body: some View {
        ZStack {
            // Background selection
            if isSelected {
                Circle()
                    .fill(Color.accentColor.opacity(0.2))
            } else if isToday {
                Circle()
                    .stroke(Color.accentColor, lineWidth: 1.5)
            }
            
            // Day number
            Text(String(Calendar.current.component(.day, from: date)))
                .font(.system(size: 12, weight: isToday ? .semibold : .regular))
                .foregroundColor(isInCurrentMonth ? .primary : .secondary.opacity(0.5))
                .opacity(isInCurrentMonth ? 1.0 : 0.6)
                
            // Entry indicator dot
            if hasEntry {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Circle()
                            .fill(Color.accentColor)
                            .frame(width: 4, height: 4)
                            .offset(x: 0, y: -2)
                    }
                }
            }
        }
        .frame(height: 28)
        .contentShape(Rectangle())
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView(journalViewModel: JournalViewModel())
            .frame(width: 280, height: 400)
    }
}