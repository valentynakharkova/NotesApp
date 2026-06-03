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
}
