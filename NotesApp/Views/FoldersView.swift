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
    @Query(sort: \Folder.order, order: .forward) private var folders: [Folder]
    
    @State private var viewModel: NotesViewModel?
    @State private var showNewFolder: Bool = false
    @State private var folderToEdit: Folder? = nil
    @State private var editedName: String = ""
    
    var body: some View {
        NavigationStack {
            List {
                //MARK: All Notes Folder
                    NavigationLink {
                        NotesListView()
                    } label: {
                        Label {
                            Text("All Notes")
                        } icon: {
                            Image(systemName: "folder.fill")
                                .foregroundStyle(.primary)
                        }

                    }
                //MARK: My Folders
                    ForEach(folders) { folder in
                        NavigationLink {
                            NotesListView(folder: folder)
                        } label: {
                            Label {
                                Text(folder.name)
                            } icon: {
                                Image(systemName: "folder.fill")
                                    .foregroundStyle(.primary)
                            }
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                viewModel?.deleteFolder(folder)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .swipeActions(edge: .trailing) {
                            Button {
                                folderToEdit = folder
                                editedName = folder.name
                            } label: {
                                Label("Edit", systemImage: "pencil")
                                    .background(Color.blue)
                            }
                        }
                    }
                    .onMove { source, destination in
                        viewModel?.moveFolder(folders: folders, source: source, destination: destination)
                    }
//                    .onDelete { IndexSet in
//                        IndexSet.forEach { index in
//                            viewModel?.deleteFolder(folders[index])
//                        }
//                    }
            }
            .navigationTitle("Folders")
            //MARK: Toolbar
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
            .alert("Edit Folder", isPresented: Binding(
                get: { folderToEdit != nil },
                set: { if !$0 { folderToEdit = nil } }
            )) {
                TextField("Folder Name", text: $editedName)
                Button("Save") {
                    if let folder = folderToEdit {
                        folderToEdit?.name = editedName
                        viewModel?.saveFolder(folder)
                        folderToEdit = nil
                    }
                }
            }
        }
    }
}

#Preview {
    FoldersView()
        .modelContainer(for: [Note.self, Folder.self], inMemory: true)
}
