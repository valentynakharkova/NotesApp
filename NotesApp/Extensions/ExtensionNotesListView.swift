//
//  ExtensionNotesListView.swift
//  NotesApp
//
//  Created by Valentyna Kharkova on 17.04.2026.
//

import SwiftData
import SwiftUI

extension NotesListView {
    private func groupTitle(for date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        
        if calendar.isDateInToday(date) {
            return "Today"
        } else if let daysAgo = calendar.dateComponents([.day], from: date, to: .now).day {
            if daysAgo <= 7 {
                return "Previous 7 Days"
            } else if daysAgo <= 30 {
                return "Previous 30 Days"
            } else {
                let formatter = DateFormatter()
                if calendar.component(.year, from: date) == calendar.component(.year, from: .now) {
                    formatter.dateFormat = "MMMM"
                } else {
                    formatter.dateFormat = "yyyy"
                }
                return formatter.string(from: date)
            }
        }
        return "Older"
    }
    
    var groupedNotes: [(key: String, value: [Note])] {
        let grouped = Dictionary(grouping: unpinnedNotes) { note in
            groupTitle(for: note.dateModified)
        }
        let priorityOrder = ["Today", "Previous 7 Days", "Previous 30 Days"]
        return grouped.sorted { a, b in
            let indexA = priorityOrder.firstIndex(of: a.key)
            let indexB = priorityOrder.firstIndex(of: b.key)
            
            switch (indexA, indexB) {
            case let (a?, b?): return a < b
            case (nil, _?): return false
            case (_?, nil): return true
            case (nil, nil):
                let formatter = DateFormatter()
                let now = Date()
                let calendar = Calendar.current
                
                // Try month name (same year)
                formatter.dateFormat = "MMMM"
                if let dateA = formatter.date(from: a.key),
                 let dateB = formatter.date(from: b.key) {
                    return dateA > dateB
                }
                // Try year
                formatter.dateFormat = "yyyy"
                if let dateA = formatter.date(from: a.key),
                   let dateB = formatter.date(from: b.key) {
                    return dateA > dateB
                }
                return false
            }
        }
    }
}
