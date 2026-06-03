//
//  Note.swift
//  NotesApp
//
//  Created by Valentyna Kharkova on 19.03.2026.
//

import SwiftData
import Foundation
import UIKit

@Model
class Note {
    var title: String
    var bodyData: Data
    var dateCreated: Date
    var dateModified: Date
    var isPinned: Bool
    var isDeleted: Bool
    var folder: Folder?
    var deleteDate: Date?
    
    init(title: String, folder: Folder? = nil) {
        self.title = title
        self.bodyData = Data()
        self.dateCreated = .now
        self.dateModified = .now
        self.isPinned = false
        self.isDeleted = false
        self.folder = folder
    }
    
    // Data -> NSAttributedString
    var attributedBody: NSAttributedString {
        get {
            guard !bodyData.isEmpty,
                  let attributed = try? NSAttributedString(
                    data: bodyData,
                    options: [.documentType: NSAttributedString.DocumentType.rtf],
                    documentAttributes: nil
                  ) else {
                return NSAttributedString()
            }
            return attributed
        }
    }
    // NSAttributedString -> Data
    func setAttributedBody(_ attributed: NSAttributedString) {
        guard let data = try? attributed.data(
            from: NSRange(location: 0, length: attributed.length),
            documentAttributes: [.documentType: NSAttributedString.DocumentType.rtf]
        ) else { return }
        self.bodyData = data
    }
}
