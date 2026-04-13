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
    @Query(sort: \Note.dateCreated, order: .reverse) private var notes: [Note]
    
    @State private var viewModel: NotesViewModel?
    
    
    var body: some View {
            List {
                ForEach(notes) { note in
                    NavigationLink {
                        NotesDetailView(note: note)
                    } label: {
                        NoteRow(note: note)
                    }
                    
                }
            }
            .navigationTitle("All Notes")
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

#Preview {
    NavigationStack {
        NotesListView()
    }
    .modelContainer(for: [Note.self, Folder.self], inMemory: true)
}
