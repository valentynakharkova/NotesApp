//
//  NotesListView.swift
//  NotesApp
//
//  Created by Valentyna Kharkova on 20.03.2026.
//

import SwiftUI
import SwiftData

struct NotesListView: View {
    
    @Environment(\.modelContext) private var context
    @Query(sort: \Note.dateCreated, order: .reverse) private var notes: [Note]
    
    @State private var viewModel: NotesViewModel?
    
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(notes) { note in
                    
                }
            }
            .navigationTitle("All Notes")
        }
    }
}

#Preview {
    NotesListView()
}
