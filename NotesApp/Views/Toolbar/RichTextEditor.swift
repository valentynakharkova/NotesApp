//
//  RichTextEditor.swift
//  NotesApp
//
//  Created by Valentyna Kharkova on 26.05.2026.
//

import SwiftUI
import UIKit

class UncheckedAttachment: NSTextAttachment {}
class CheckedAttachment: NSTextAttachment {}

struct RichTextEditor: UIViewRepresentable {
    
    @Binding var attributedText: NSAttributedString
    var textView: UITextView
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // Create UIKit View (calls one time)
    func makeUIView(context: Context) -> UITextView {
        textView.isEditable = true
        textView.isScrollEnabled = true
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.backgroundColor = .clear
        textView.textColor = .label
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
        textView.delegate = context.coordinator
        
        let tap = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleTap(_:)))
        
        tap.delegate = context.coordinator
        textView.addGestureRecognizer(tap)
        
        return textView
    }
    // Update UIKIt View when SwiftUI State changing
    func updateUIView(_ uiView: UITextView, context: Context) {
        if uiView.attributedText != attributedText {
            uiView.attributedText = attributedText
        }
    }
    
    //MARK: - Coordinator
    class Coordinator: NSObject, UITextViewDelegate, UIGestureRecognizerDelegate {
        var parent: RichTextEditor
        
        init(_ parent: RichTextEditor) {
            self.parent = parent
        }
        // Called every time the user types something
        func textViewDidChange(_ textView: UITextView) {
            parent.attributedText = textView.attributedText
            
            var attrs = textView.typingAttributes
            
            if attrs[.font] == nil {
                attrs[.font] = UIFont.systemFont(ofSize: 16)
            }
            
            if attrs[.foregroundColor] == nil  ||
                (attrs[.foregroundColor] as? UIColor) == .secondaryLabel {
                    attrs[.foregroundColor] = UIColor.label
                }
            
            if textView.typingAttributes as NSDictionary != attrs as NSDictionary {
                textView.typingAttributes = attrs
            }
        }
        
        //MARK: - Gesture Recognizer
        func gestureRecognizer(
            _ gestureRecognizer: UIGestureRecognizer,
            shouldRecognizeSimultaneouslyWith other: UIGestureRecognizer
        ) -> Bool {
            return true
        }
    }
}

//MARK: - Extension
extension UITextView {
    func nsRange(from textRange: UITextRange) -> NSRange {
        let start = offset(from: beginningOfDocument, to: textRange.start)
        let end = offset(from: beginningOfDocument, to: textRange.end)
        return NSRange(location: start, length: end - start)
    }
    
    var cursorNSRange: NSRange {
        guard let selectedTextRange = selectedTextRange else {
            return NSRange(location: 0, length: 0)
        }
        return nsRange(from: selectedTextRange)
    }
}
