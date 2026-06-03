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
    @Query(filter: #Predicate<Folder> { $0.isDeleted == false },
           sort: \Folder.order, order: .forward) private var folders: [Folder]
    @Query(filter: #Predicate<Note> { $0.isDeleted == false }) private var allNoes: [Note]
    
    
    @State private var viewModel: NotesViewModel?
    @State private var showNewFolder: Bool = false
    @State private var folderToEdit: Folder? = nil
    @State private var editedName: String = ""
    @State private var searchText: String = ""
    
    //MARK: Search filtered Folders
    var filteredFolders: [Folder] {
        if searchText.isEmpty {
            return folders
        } else {
            return folders.filter { $0.name.localizedStandardContains(searchText) }
        }
    }
    //MARK: Search filtered Notes
    var filteredNotes: [Note] {
        if searchText.isEmpty {
            return []
        } else {
            return allNoes.filter {
                $0.title.localizedStandardContains(searchText) ||
                $0.attributedBody.string.localizedStandardContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                if searchText.isEmpty {
                    mainSection
                } else {
                    filteredFoldersSection
                    
                    filteredNotesSection
                }
            }
            .searchable(text: $searchText, prompt: "Search")
            .navigationTitle("Folders")
            //MARK: Toolbar
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showNewFolder = true
                    } label: {
                        Image(systemName: "folder.badge.plus.fill")
                            .foregroundStyle(.indigo)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    EditButton()
                        .foregroundStyle(.primary)
                        .tint(.indigo)
                }
                if #available(iOS 26, *) {
                    DefaultToolbarItem(kind: .search, placement: .bottomBar)
                }
                ToolbarItemGroup(placement: .bottomBar) {
                    Spacer()
                    NavigationLink {
                        NewNoteView()
                    } label: {
                        Image(systemName: "square.and.pencil")
                            .foregroundStyle(.indigo)
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
    @ViewBuilder
    private var mainSection: some View {
        //MARK: All Notes Folder
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
        //MARK: My Folders
        ForEach(folders) { folder in
            NavigationLink {
                NotesListView(folder: folder)
            } label: {
                Label {
                    Text(folder.name)
                } icon: {
                    Image(systemName: "folder.fill")
                        .foregroundStyle(.indigo)
                }
            }
            .swipeActions(edge: .trailing) {
                Button(role: .destructive) {
                    viewModel?.softDeleteFolder(folder)
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
                        .tint(.blue)
                }
            }
        }
        .onMove { source, destination in
            viewModel?.moveFolder(folders: folders, source: source, destination: destination)
        }
        
        //MARK: Recently Deleted Notes
        NavigationLink {
            RecentlyDeletedView()
        } label: {
            Label {
                Text("Recently Deleted")
            } icon: {
                Image(systemName: "trash")
                    .foregroundStyle(.indigo)
            }
        }
    }
    
    @ViewBuilder
    private var filteredFoldersSection: some View {
        if !filteredFolders.isEmpty {
            Section("Folders") {
                ForEach(filteredFolders) { folder in
                    NavigationLink {
                        NotesListView(folder: folder)
                    } label: {
                        Label {
                            Text(folder.name)
                        } icon: {
                            Image(systemName: "folder.fill")
                                .foregroundStyle(.indigo)
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var filteredNotesSection: some View {
        if !filteredNotes.isEmpty {
            Section("Notes") {
                ForEach(filteredNotes) { note in
                    NavigationLink {
                        NotesDetailView(note: note)
                    } label: {
                        NoteRow(note: note)
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
