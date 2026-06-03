//
//  RecentlyDeletedView.swift
//  NotesApp
//
//  Created by Valentyna Kharkova on 18.04.2026.
//

import SwiftUI
import SwiftData

struct RecentlyDeletedView: View {
    
    @Environment(\.modelContext) private var context
    
    @Query(filter: #Predicate<Folder> {$0.isDeleted == true},
           sort: \Folder.deleteDate, order: .reverse) private var deletedFolders: [Folder]
    @Query(filter: #Predicate<Note> { $0.isDeleted == true },
           sort: \Note.deleteDate, order: .reverse) private var deletedNotes: [Note]
    
    @State private var viewModel: NotesViewModel?
    @State private var isEditing: Bool = false
    @State private var selectedNotes: Set<PersistentIdentifier> = []
    @State private var selectedFolders: Set<PersistentIdentifier> = []
    
    var hasSelection: Bool {
        !selectedNotes.isEmpty || !selectedFolders.isEmpty
    }
    
    var isEmpty: Bool {
        deletedFolders.isEmpty && deletedNotes.isEmpty
    }
    
    var body: some View {
        List {
            //MARK: Deleted Notes
            if !deletedNotes.isEmpty {
                Section {
                        ForEach(deletedNotes) { note in
                            HStack {
                                if isEditing {
                                    Image(systemName: selectedNotes.contains(note.id) ? "checkmark.circle.fill" : "circle")
                                        .font(.title2)
                                        .foregroundStyle(selectedNotes.contains(note.id) ? .indigo : .gray)
                                }
                                NavigationLink {
                                    NotesDetailView(note: note)
                                } label: {
                                    NoteRow(note: note)
                                }
                            }
                            .onTapGesture {
                                guard isEditing else { return }
                                toggleNote(note)
                            }
                        }
                }
            }
        }
        .navigationTitle("Recently Deleted")
        //MARK: Toolbar
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if isEditing {
                    Button {
                        isEditing.toggle()
                        selectedNotes.removeAll()
                        selectedFolders.removeAll()
                    } label: {
                        Image(systemName: "checkmark")
                            .foregroundStyle(.white)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.indigo)
                } else {
                    Button {
                        isEditing.toggle()
                        selectedNotes.removeAll()
                        selectedFolders.removeAll()
                    } label: {
                        Text("Edit")
                    }
                }
            }
            ToolbarItemGroup(placement: .bottomBar) {
                if isEditing {
                    Button {
                        restoreSelected()
                    } label: {
                        Text("Restore")
                    }
                    
                    Spacer()
                    
                    Button {
                        deleteSelected()
                    } label: {
                        Text("Delete")
                    }
                } else {
                    Button {
                        restoreAll()
                    } label: {
                        Text("Restore All")
                    }
                    
                    Spacer()
                    
                    Button {
                        deleteAll()
                    } label: {
                        Text("Delete All")
                    }
                }
            }

        }
        .onAppear {
            viewModel = NotesViewModel(context: context)
            viewModel?.clenupExpiredNotes(notes: deletedNotes)
//            viewModel?.clenupExpiredFolders(folders: deletedFolders)
        }
        .overlay {
            if isEmpty {
                ContentUnavailableView("No Deleted Items", systemImage: "trash")
            }
        }
    }
}

#Preview {
    NavigationStack {
        RecentlyDeletedView()
    }
    .modelContainer(for: [Note.self, Folder.self], inMemory: true)
}


//MARK: Private Extension
private extension RecentlyDeletedView {
    func toggleNote(_ note: Note) {
        if selectedNotes.contains(note.id) {
            selectedNotes.remove(note.id)
        } else {
            selectedNotes.insert(note.id)
        }
    }
    
//    func toggleFolder(_ folder: Folder) {
//        if selectedFolders.contains(folder.id) {
//            selectedFolders.remove(folder.id)
//        } else {
//            selectedFolders.insert(folder.id)
//        }
//    }
    
    func restoreSelected() {
        selectedNotes.forEach { id in
            if let note = deletedNotes.first(where: { $0.id == id }) {
                viewModel?.restoreNote(note)
            }
        }
//        selectedFolders.forEach { id in
//            if let folder = deletedFolders.first(where: { $0.id == id }) {
//                viewModel?.restoreFolder(folder)
//            }
//        }
        selectedNotes.removeAll()
//        selectedFolders.removeAll()
        isEditing = false
    }
    
    func deleteSelected() {
        selectedNotes.forEach { id in
            if let note = deletedNotes.first(where: { $0.id == id }) {
                viewModel?.permanentlyDeleteNote(note)
            }
        }
//        selectedFolders.forEach { id in
//            if let folder = deletedFolders.first(where: { $0.id == id }) {
//                viewModel?.permanentlyDeleteFolder(folder)
//            }
//        }
        selectedNotes.removeAll()
//        selectedFolders.removeAll()
        isEditing = false
    }
    
    func restoreAll() {
        deletedNotes.forEach { viewModel?.restoreNote($0) }
//        deletedFolders.forEach { viewModel?.restoreFolder($0) }
    }
    
    func deleteAll() {
        deletedNotes.forEach { viewModel?.permanentlyDeleteNote($0) }
//        deletedFolders.forEach { viewModel?.permanentlyDeleteFolder($0) }
    }
}

