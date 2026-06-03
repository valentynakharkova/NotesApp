//
//  NotesViewModel.swift
//  NotesApp
//
//  Created by Valentyna Kharkova on 19.03.2026.
//

import SwiftUI
import SwiftData
import UIKit

@Observable
class NotesViewModel {
    private var context: ModelContext
    
    init(context: ModelContext) {
        self.context = context
    }
    
    //MARK: Add Note
    func addNote(title: String, attributedBody: NSAttributedString = NSAttributedString(), folder: Folder? = nil) {
        let note = Note(title: title)
        note.folder = folder
        note.setAttributedBody(attributedBody)
        context.insert(note)
        saveContext()
    }
//    func addNote(title: String, body: AttributedString = AttributedString(), folder: Folder? = nil) {
//        let note = Note(title: title, body: body)
//        note.folder = folder
//        context.insert(note)
//        saveContext()
//    }
    //MARK: Save Context
    private func saveContext() {
        do {
            try context.save()
        } catch  {
            print("Error saving: \(error.localizedDescription)")
        }
    }
    
    //MARK: Edit Note
    func editNote(_ note: Note, _ title: String, _ body: NSAttributedString = NSAttributedString()) {
        note.title = title
        note.setAttributedBody(body)
        saveContext()
    }
    
    //MARK: Soft Delete Note
    func softDeleteNote(_ note: Note) {
        note.isDeleted = true
        note.deleteDate = .now
        note.isPinned = false
        saveContext()
    }
    
    //MARK: Restore Note
    func restoreNote(_ note: Note) {
        note.isDeleted = false
        note.deleteDate = nil
        saveContext()
    }
        
    //MARK: Permanently Delete Note
    func permanentlyDeleteNote(_ note: Note) {
        context.delete(note)
        saveContext()
    }
    
    //MARK: Cleanup expires Notes older than 30 days
    func clenupExpiredNotes(notes: [Note]) {
        let expiredNotes = Calendar.current.date(byAdding: .day, value: -30, to: .now) ?? .now
        for note in notes {
            if let deleteDate = note.deleteDate, deleteDate < expiredNotes {
                context.delete(note)
            }
        }
        saveContext()
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
    
    //MARK: Soft Delete Folder
    func softDeleteFolder(_ folder: Folder) {
        folder.isDeleted = true
        folder.deleteDate = .now
        folder.isPinned = false
        for note in folder.notes {
            note.isDeleted = true
            note.deleteDate = .now
        }
        context.delete(folder)
        saveContext()
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
