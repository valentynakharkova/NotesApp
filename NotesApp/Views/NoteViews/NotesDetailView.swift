//
//  NotesDetailView.swift
//  NotesApp
//
//  Created by Valentyna Kharkova on 13.04.2026.
//

import SwiftUI
import SwiftData
import Combine
 
struct NotesDetailView: View {
 
    @Environment(\.modelContext) private var context
    @Bindable var note: Note
    @StateObject private var editorViewModel = RichTextEditorViewModel()
    private var viewModel: NotesViewModel { NotesViewModel(context: context) }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            TextField("Title", text: $note.title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding([.horizontal, .top])
                .padding(.bottom, 8)
                .onChange(of: note.title) { save() }

            RichTextEditor(attributedText: $editorViewModel.attributedText, textView: editorViewModel.textView)
        }
        .safeAreaInset(edge: .bottom) {
            FormattingToolbar(textView: editorViewModel.textView, coordinator: editorViewModel.coordinator)
                    .padding(.bottom, 8)
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            editorViewModel.load(note.attributedBody)
        }
        .onDisappear {
            save()
        }
    }
 
    private func save() {
        note.setAttributedBody(editorViewModel.currentText())
        note.dateModified = .now
        viewModel.saveNote()
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Note.self, configurations: config)
    let note = Note(title: "Test Note")
    container.mainContext.insert(note)
    return NavigationStack {
        NotesDetailView(note: note)
    }
    .modelContainer(container)
}
