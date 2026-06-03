//
//  NotesListView.swift
//  NotesApp
//
//  Created by Valentyna Kharkova on 20.03.2026.
//

import SwiftUI
import SwiftData

struct NotesListView: View {
    
    @Environment(\.modelContext) private var context
    @Query private var notes: [Note]
    
    @State private var viewModel: NotesViewModel?
    var folder: Folder?
    var pinnedOnly: Bool


    //MARK: Init
    init(folder: Folder? = nil, pinnedOnly: Bool = false) {
        self.folder = folder
        self.pinnedOnly = pinnedOnly

        if let folder {
            let folder = folder.name
            _notes = Query(
                filter: #Predicate<Note> { note in
                    note.folder?.name == folder
                }, sort: \.dateModified, order: .reverse)
        } else if pinnedOnly {
            _notes = Query(filter: #Predicate<Note> { note in
                note.isPinned == true
            }, sort: \.dateModified, order: .reverse)
        } else {
            _notes = Query(sort: \.dateModified, order: .reverse)
        }
    }
    
    var pinnedNotes: [Note] {
        notes.filter{$0.isPinned}
    }
    var unpinnedNotes: [Note] {
        notes.filter{!$0.isPinned}
    }
    //MARK: Group Notes by Month and Year
    var groupedNotes: [(key: String, value: [Note])] {
        let grouped = Dictionary(grouping: unpinnedNotes) { note -> String in
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM yyyy"
            return formatter.string(from: note.dateModified)
        }
        return grouped.sorted { a, b in
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM yyyy"
            let dateA = formatter.date(from: a.key) ?? .now
            let dateB = formatter.date(from: b.key) ?? .now
            return dateA > dateB
        }
    }
    
    var body: some View {
            List {
                //MARK: Pinned Section
                if !pinnedNotes.isEmpty {
                    Section("Pinned") {
                        pinnedSection

                    }
                }
                //MARK: Grouped by Month and Year
                groupedNotesSection

            }
            .navigationTitle(folder?.name ?? "All Notes")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        NewNoteView(folder: folder)
                    } label: {
                        Image(systemName: "square.and.pencil")
                    }
                }
            }
            .onAppear {
                viewModel = NotesViewModel(context: context)
            }
    }
    var pinnedSection: some View {
                ForEach(pinnedNotes) { note in
                    NavigationLink {
                        NotesDetailView(note: note)
                    } label: {
                        NoteRow(note: note)
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            viewModel?.softDeleteNote(note)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .swipeActions(edge: .leading) {
                        Button {
                            viewModel?.togglePin(note)
                        } label: {
                            let title = note.isPinned ? "Unpin" : "Pin"
                            let imageName = note.isPinned ? "pin.slash.fill" : "pin.fill"
                            Label(title, systemImage: imageName)
                        }
                        .tint(.orange)
                    }
                }
    }
    
    var groupedNotesSection: some View {
        ForEach(groupedNotes, id: \.key) { group in
            Section(group.key) {
                ForEach(group.value) { note in
                    NavigationLink {
                        NotesDetailView(note: note)
                    } label: {
                        NoteRow(note: note)
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            viewModel?.softDeleteNote(note)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .swipeActions(edge: .leading) {
                        Button {
                            viewModel?.togglePin(note)
                        } label: {
                            let title = note.isPinned ? "Unpin" : "Pin"
                            let imageName = note.isPinned ? "pin.slash.fill" : "pin.fill"
                            Label(title, systemImage: imageName)
                        }
                        .tint(.orange)
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        NotesListView( pinnedOnly: false)
    }
    .modelContainer(for: [Note.self, Folder.self], inMemory: true)
}
