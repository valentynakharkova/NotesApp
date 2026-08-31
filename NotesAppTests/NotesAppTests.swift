//
//  NotesAppTests.swift
//  NotesAppTests
//
//  Created by Valentyna Kharkova on 19.03.2026.
//

import XCTest
import SwiftData
@testable import NotesApp


final class NotesAppTests: XCTestCase {
    
    var container: ModelContainer!
    var context: ModelContext!
    var viewModel: NotesViewModel!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let schema = Schema([Note.self, Folder.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        container = try ModelContainer(for: schema, configurations: [config])
        context = ModelContext(container)
        viewModel = NotesViewModel(context: context)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        container = nil
        context = nil
        viewModel = nil
    }
    
    func testAddNote() throws {
        // Given
        XCTAssertEqual(try context.fetch(FetchDescriptor<Note>()).count, 0)
        // When
        viewModel.addNote(title: "Buy milk")
        // Then
        let notes = try context.fetch(FetchDescriptor<Note>())
        XCTAssertEqual(notes.count, 1)
        XCTAssertEqual(notes.first?.title, "Buy milk")
        XCTAssertFalse(notes.first?.isTrashed ?? true)
    }
    
    func testEditNote() throws {
        // Given
        viewModel.addNote(title: "Old note")
        let note = try XCTUnwrap(try context.fetch(FetchDescriptor<Note>()).first)
        let originalModifiedDate = note.dateModified
        // When
        viewModel.editNote(note, "New note")
        // Then
        XCTAssertEqual(note.title, "New note")
        _ = originalModifiedDate
    }
    
    func testTogglePinNote() throws {
        // Given
        viewModel.addNote(title: "Important note")
        let note = try XCTUnwrap(try context.fetch(FetchDescriptor<Note>()).first)
        XCTAssertFalse(note.isPinned)
 
        // When
        viewModel.togglePin(note)
 
        // Then
        XCTAssertTrue(note.isPinned)
 
        // When (toggle again)
        viewModel.togglePin(note)
 
        // Then
        XCTAssertFalse(note.isPinned)
    }

    func testSoftDeleteNote() throws {
        // Given
        viewModel.addNote(title: "Temporary note")
        let note = try XCTUnwrap(try context.fetch(FetchDescriptor<Note>()).first)
        viewModel.togglePin(note) // перевіримо, що pin теж скидається
 
        // When
        viewModel.softDeleteNote(note)
 
        // Then
        XCTAssertTrue(note.isTrashed)
        XCTAssertNotNil(note.deleteDate)
        XCTAssertFalse(note.isPinned)
    }
 
    func testRestoreNote() throws {
        // Given
        viewModel.addNote(title: "Restore note")
        let note = try XCTUnwrap(try context.fetch(FetchDescriptor<Note>()).first)
        viewModel.softDeleteNote(note)
        XCTAssertTrue(note.isTrashed)
 
        // When
        viewModel.restoreNote(note)
 
        // Then
        XCTAssertFalse(note.isTrashed)
        XCTAssertNil(note.deleteDate)
    }
 
    func testPermanentlyDeleteNote() throws {
        // Given
        viewModel.addNote(title: "Permanently delete note")
        let note = try XCTUnwrap(try context.fetch(FetchDescriptor<Note>()).first)
 
        // When
        viewModel.permanentlyDeleteNote(note)
 
        // Then
        let notes = try context.fetch(FetchDescriptor<Note>())
        XCTAssertEqual(notes.count, 0)
    }
 
    func testClenupExpiredNotes() throws {
        // Given
        viewModel.addNote(title: "Expired note")
        let expiredNote = try XCTUnwrap(try context.fetch(FetchDescriptor<Note>()).first)
        expiredNote.isTrashed = true
        expiredNote.deleteDate = Calendar.current.date(byAdding: .day, value: -31, to: .now)
 
        viewModel.addNote(title: "New deleted note")
        let allNotes = try context.fetch(FetchDescriptor<Note>())
        let freshNote = try XCTUnwrap(allNotes.first(where: { $0.title == "New deleted note" }))
        freshNote.isTrashed = true
        freshNote.deleteDate = Calendar.current.date(byAdding: .day, value: -5, to: .now)
 
        // When
        viewModel.clenupExpiredNotes(notes: try context.fetch(FetchDescriptor<Note>()))
 
        // Then
        let remaining = try context.fetch(FetchDescriptor<Note>())
        XCTAssertEqual(remaining.count, 1)
        XCTAssertEqual(remaining.first?.title, "New deleted note")
    }
 
    // MARK: - Folder tests
 
    func testAddFolder() throws {
        // Given
        XCTAssertEqual(try context.fetch(FetchDescriptor<Folder>()).count, 0)
 
        // When
        viewModel.addFolder(name: "Work")
 
        // Then
        let folders = try context.fetch(FetchDescriptor<Folder>())
        XCTAssertEqual(folders.count, 1)
        XCTAssertEqual(folders.first?.name, "Work")
    }
 
    func testTogglePinFolder() throws {
        // Given
        viewModel.addFolder(name: "Personal")
        let folder = try XCTUnwrap(try context.fetch(FetchDescriptor<Folder>()).first)
 
        // When
        viewModel.togglePin(folder)
 
        // Then
        XCTAssertTrue(folder.isPinned)
    }
 
    func testSoftDeleteFolder() throws {
        // Given
        viewModel.addFolder(name: "Temporary folder")
        let folder = try XCTUnwrap(try context.fetch(FetchDescriptor<Folder>()).first)
        viewModel.addNote(title: "Нотатка в папці", folder: folder)
 
        // When
        viewModel.softDeleteFolder(folder)
 
        // Then
        let folders = try context.fetch(FetchDescriptor<Folder>())
        XCTAssertEqual(folders.count, 0, "Permanently delete folder, not soft-delete")
        let notes = try context.fetch(FetchDescriptor<Note>())
        XCTAssertEqual(notes.count, 1)
        XCTAssertTrue(notes.first?.isTrashed ?? false)
    }
 
    func testMoveFolder() throws {
        // Given
        viewModel.addFolder(name: "A")
        viewModel.addFolder(name: "B")
        viewModel.addFolder(name: "C")
 
        var folders = try context.fetch(FetchDescriptor<Folder>())
            .sorted(by: { $0.order < $1.order })
 
        // When
        viewModel.moveFolder(folders: folders, source: IndexSet(integer: 0), destination: 3)
 
        // Then
        folders = try context.fetch(FetchDescriptor<Folder>())
            .sorted(by: { $0.order < $1.order })
 
        XCTAssertEqual(folders.map(\.name), ["B", "C", "A"])
    }
}
