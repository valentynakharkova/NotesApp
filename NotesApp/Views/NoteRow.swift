//
//  NoteRow.swift
//  NotesApp
//
//  Created by Valentyna Kharkova on 13.04.2026.
//

import SwiftUI
import SwiftData

struct NoteRow: View {
    
    let note: Note
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(note.title.isEmpty ? "New Note" : note.title)
                .font(.headline)
                .lineLimit(1)
            HStack(spacing: 8) {
                Text(note.dateModified.formatted(.dateTime.day().month().year()))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(note.body.isEmpty ? "No additional Text" : note.body)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Note.self, configurations: config)
    let note = Note(title: "Test note", body: "Test body")
    container.mainContext.insert(note)
    return NoteRow(note: note)
        .modelContainer(container)
}
