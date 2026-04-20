//
//  Folder.swift
//  NotesApp
//
//  Created by Valentyna Kharkova on 20.03.2026.
//

import Foundation
import SwiftData

@Model
class Folder {
    var name: String
    var dateCreated: Date
    var isPinned: Bool = false
    var order: Int
    var isDeleted: Bool = false
    var deleteDate: Date?
    
    @Relationship(deleteRule: .nullify, inverse: \Note.folder) var notes: [Note]
    
    init(name: String, order: Int = 0) {
        self.name = name
        self.dateCreated = .now
        self.isPinned = false
        self.order = order
        self.notes = []
        self.isDeleted = false
    }
}
