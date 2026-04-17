//
//  NotesViewModel.swift
//  NotesApp
//
//  Created by Valentyna Kharkova on 19.03.2026.
//

import SwiftUI
import SwiftData

@Observable
class NotesViewModel {
    private var context: ModelContext
    
    init(context: ModelContext) {
        self.context = context
    }
    
    //MARK: Add Note
    func addNote(title: String, body: String, folder: Folder? = nil) {
        let note = Note(title: title, body: body)
        note.folder = folder
        context.insert(note)
        saveContext()
    }
    //MARK: Save Context
    private func saveContext() {
        do {
            try context.save()
        } catch  {
            print("Error saving: \(error.localizedDescription)")
        }
    }
    
    //MARK: Edit Note
    func editNote(_ note: Note, _ title: String, _ body: String) {
        note.title = title
        note.body = body
        saveContext()
    }
    
    //MARK: Delete Note
    func deleteNote(_ note: Note) {
        context.delete(note)
    }
    
    //MARK: Save Note
    func saveNote() {
        saveContext()
    }
    
    //MARK: Toggle Pin Note
    func togglePin(_ note: Note) {
        note.isPinned.toggle()
        saveContext()
    }
    
    //MARK: Add Folder
    func addFolder(name: String) {
        let folder = Folder(name: name)
        context.insert(folder)
        saveContext()
    }
    
    //MARK: Delete Folder
    func deleteFolder(_ folder: Folder) {
        context.delete(folder)
    }
    
    //MARK: Save Folder
    func saveFolder(_ folder: Folder) {
        saveContext()
    }
    
    //MARK: Toggle Pin folder
    func togglePin(_ folder: Folder) {
        folder.isPinned.toggle()
        saveContext()
    }
    
    //MARK: Move Folder
    func moveFolder(folders: [Folder], source: IndexSet, destination: Int) {
        var reordered = folders
        reordered.move(fromOffsets: source, toOffset: destination)
        for (index, folder) in reordered.enumerated() {
            folder.order = index
        }
        saveContext()
    }
}
