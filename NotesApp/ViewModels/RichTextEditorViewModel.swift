//
//  RichTextEditorViewModel.swift
//  NotesApp
//
//  Created by Valentyna Kharkova on 27.05.2026.
//

import SwiftUI
import UIKit
import Combine

class RichTextEditorViewModel: ObservableObject {
    
    @Published var attributedText = NSAttributedString(string: "")
    let textView = UITextView()
    let coordinator: RichTextEditor.Coordinator
    
    init() {
        let editor = RichTextEditor(
            attributedText: .constant(NSAttributedString()),
            textView: textView
        )
        self.coordinator = RichTextEditor.Coordinator(editor)
        
        self.coordinator.parent = RichTextEditor(
            attributedText: Binding(
                get: { self.attributedText },
                set: { self.attributedText = $0 }
            ),
            textView: textView
        )
    }
    
    func load(_ text: NSAttributedString) {
        attributedText = text
        textView.attributedText = text
    }
    
    func currentText() -> NSAttributedString {
        return textView.attributedText
    }
}
