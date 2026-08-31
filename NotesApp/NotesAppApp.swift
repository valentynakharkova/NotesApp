//
//  NotesAppApp.swift
//  NotesApp
//
//  Created by Valentyna Kharkova on 19.03.2026.
//

import SwiftUI
import SwiftData

@main
struct NotesAppApp: App {

    var body: some Scene {
        WindowGroup {
            FoldersView()
        }
        .modelContainer(for: [Note.self, Folder.self])
    }
}
