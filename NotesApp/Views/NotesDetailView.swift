//
//  NotesDetailView.swift
//  NotesApp
//
//  Created by Valentyna Kharkova on 13.04.2026.
//

import SwiftUI
import SwiftData

struct NotesDetailView: View {
    
    @Environment(\.modelContext) private var context
    
    @Bindable var note: Note
    @State private var viewModel: NotesViewModel?
        
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            TextField("Title", text: $note.title)
                .font(.largeTitle)
                .fontWeight(.bold)
            TextField("Start typing", text: $note.body)
                .font(.body)
            
            Spacer()
        }
        .padding()
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel = NotesViewModel(context: context)
        }
        .onChange(of: note.title) {
            note.dateModified = .now
            viewModel?.saveNote()
        }
        .onChange(of: note.body) {
            note.dateModified = .now
            viewModel?.saveNote()
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Note.self, configurations: config)
    let note = Note(title: "Test Note", body: "This is a preview note body")
    container.mainContext.insert(note)
    return NavigationStack {
        NotesDetailView(note: note)
    }
    .modelContainer(container)
}
