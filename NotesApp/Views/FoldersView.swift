//
//  FoldersView.swift
//  NotesApp
//
//  Created by Valentyna Kharkova on 19.03.2026.
//

import SwiftUI
import SwiftData

struct FoldersView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Note.dateCreated, order: .reverse) private var notes: [Note]
    
    @State private var viewModel: NotesViewModel?
    @State private var showNewNote: Bool = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(notes) { note in
                    Text(note.title)
                }
                .onDelete { IndexSet in
                    IndexSet.forEach { index in
                        viewModel?.deleteNote(notes[index])
                    }
                }
            }
            .navigationTitle("Folders")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        NewNoteView()
                    } label: {
                        Image(systemName: "square.and.pencil")
                    }
                }
            }
            .onAppear {
                viewModel = NotesViewModel(context: context)
            }
        }
    }
}

#Preview {
    FoldersView()
        .modelContainer(for: Note.self, inMemory: true)
}
