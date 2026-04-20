//
//  Note.swift
//  NotesApp
//
//  Created by Valentyna Kharkova on 19.03.2026.
//

import SwiftData
import Foundation

@Model
class Note {
    var title: String
    var body: String
    var dateCreated: Date
    var dateModified: Date
    var isPinned: Bool
    var isDeleted: Bool
    var folder: Folder?
    var deleteDate: Date?
    
    init(title: String, body: String, folder: Folder? = nil) {
        self.title = title
        self.body = body
        self.dateCreated = .now
        self.dateModified = .now
        self.isPinned = false
        self.isDeleted = false
        self.folder = folder
    }
}
