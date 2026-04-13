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
    @Query(sort: \Folder.dateCreated, order: .forward) private var folders: [Folder]
    
    @State private var viewModel: NotesViewModel?
    @State private var showNewNote: Bool = false
    @State private var showNewFolder: Bool = false

    var body: some View {
        NavigationStack {
            List {
                //MARK: All Notes Folder
                Section {
                    NavigationLink {
                        NotesListView()
                    } label: {
                        Label {
                            Text("All Notes")
                        } icon: {
                            Image(systemName: "folder.fill")
                                .foregroundStyle(.indigo)
                        }

                    }
                }
                ForEach(folders) { folder in
                    
                }
            }
            .navigationTitle("Folders")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showNewFolder = true
                    } label: {
                        Image(systemName: "folder.badge.plus")
                    }
                }
            }
            .onAppear {
                viewModel = NotesViewModel(context: context)
            }
            .sheet(isPresented: $showNewFolder) {
                NewFolderView()
            }
        }
    }
}

#Preview {
    FoldersView()
        .modelContainer(for: Note.self, inMemory: true)
}
