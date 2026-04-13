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
    
    @Relationship(deleteRule: .cascade) var notes: [Note]
    
    init(name: String) {
        self.name = name
        self.dateCreated = .now
        self.notes = []
    }
}
