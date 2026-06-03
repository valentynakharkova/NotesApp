//
//  NewFolderView.swift
//  NotesApp
//
//  Created by Valentyna Kharkova on 20.03.2026.
//

import SwiftUI
import SwiftData

struct NewFolderView: View {
    
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String = ""
    @State private var viewModel: NotesViewModel?
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    TextField("New Folder", text: $title)
                    if !title.isEmpty {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.gray.opacity(0.8))
                            .onTapGesture {
                                title = ""
                            }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .foregroundStyle(.gray.opacity(0.1))
                }
                .padding()
                Spacer()
            
            }
            .navigationTitle("New Folder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }

                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        guard !title.isEmpty else { return }
                            viewModel?.addFolder(name: title)
                            dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                            .foregroundStyle(.white)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.indigo)
                }
            }
            .onAppear {
                viewModel = NotesViewModel(context: context)
            }
        }
    }
}

#Preview {
    NewFolderView()
        .modelContainer(for: Folder.self, inMemory: true)
}
