//
//  NewNoteView.swift
//  NotesApp
//
//  Created by Valentyna Kharkova on 19.03.2026.
//

import SwiftUI
import SwiftData

struct NewNoteView: View {
    
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String = ""
    @State private var noteBody: String = ""
    @State private var viewModel: NotesViewModel?
    
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                TextField("Title", text: $title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                TextField("Start writing...", text: $noteBody)
                    .font(.body)
                    .foregroundStyle(.primary)
                
                Spacer()
            }
            .padding()
            .navigationTitle("New Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        guard !title.isEmpty else { return }
                        viewModel?.addNote(title: title, body: noteBody)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(title.isEmpty)
                }
            }
            .onAppear {
                viewModel = NotesViewModel(context: context)
            }
        }
    }
}

#Preview {
    NewNoteView()
        .modelContainer(for: Note.self, inMemory: true)
}
