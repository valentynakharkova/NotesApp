//
//  NewNoteView.swift
//  NotesApp
//
//  Created by Valentyna Kharkova on 19.03.2026.
//

import SwiftUI
import SwiftData
import Combine
 
struct NewNoteView: View {
 
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
 
    var folder: Folder?
 
    @State private var title: String = ""
    @StateObject private var editorViewModel = RichTextEditorViewModel()
    
    private var viewModel: NotesViewModel { NotesViewModel(context: context) }
    
    private var isSaveDisabled: Bool {
        title.isEmpty && editorViewModel.attributedText.string.isEmpty
    }
 
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TextField("Title", text: $title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding([.horizontal, .top])
                    .padding(.bottom, 8)
                RichTextEditor(attributedText: $editorViewModel.attributedText, textView: editorViewModel.textView)
                        .safeAreaInset(edge: .bottom) {
                            FormattingToolbar(textView: editorViewModel.textView, coordinator: editorViewModel.coordinator)
                }
            }
            .navigationTitle("New Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        guard !title.isEmpty else { return }
                        viewModel.addNote(
                            title: title,
                            attributedBody: editorViewModel.currentText(),
                            folder: folder
                        )
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(isSaveDisabled)
                }
            }
        }
    }
}

#Preview {
    NewNoteView()
        .modelContainer(for: [Note.self, Folder.self], inMemory: true)
}
