//
//  CalendarViewModel.swift
//  JournalApp
//
//  View model for calendar state management
//

import Foundation
import Combine

final class CalendarViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var currentMonth: Date = Date()
    @Published var selectedDate: Date = Date()
    @Published var datesWithEntries: Set<Date> = []
    
    // MARK: - Private Properties
    
    private let calendar = Calendar.current
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed Properties
    
    var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentMonth)
    }
    
    var daysInMonth: [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth),
              let firstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start),
              let lastWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.end - 1) else {
            return []
        }
        
        var dates: [Date] = []
        var date = firstWeek.start
        
        while date < lastWeek.end {
            dates.append(date)
            date = calendar.date(byAdding: .day, value: 1, to: date) ?? date
        }
        
        return dates
    }
    
    var weekdaySymbols: [String] {
        calendar.shortWeekdaySymbols
    }
    
    // MARK: - Initialization
    
    init() {
        loadCurrentMonth()
        loadEntryDates()
    }
    
    // MARK: - Navigation
    
    func goToPreviousMonth() {
        if let newMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) {
            currentMonth = newMonth
        }
    }
    
    func goToNextMonth() {
        if let newMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) {
            currentMonth = newMonth
        }
    }
    
    func goToToday() {
        selectedDate = Date()
    }
    
    func selectDate(_ date: Date) {
        selectedDate = calendar.startOfDay(for: date)
    }
    
    // MARK: - Helpers
    
    func isSelected(_ date: Date) -> Bool {
        calendar.isDate(date, inSameDayAs: selectedDate)
    }
    
    func isToday(_ date: Date) -> Bool {
        calendar.isDate(date, inSameDayAs: Date())
    }
    
    func isInCurrentMonth(_ date: Date) -> Bool {
        calendar.isDate(date, equalTo: currentMonth, toGranularity: .month)
    }
    
    func hasEntry(for date: Date) -> Bool {
        datesWithEntries.contains(calendar.startOfDay(for: date))
    }
    
    // MARK: - Private
    
    private func loadCurrentMonth() {
        currentMonth = Date()
    }
    
    private func loadEntryDates() {
        // Entry dates will be loaded from FileStorageManager
    }
    
    func refreshEntries() {
        // Called when entries change
    }
}