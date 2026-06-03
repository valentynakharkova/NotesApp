//
//  RichTextEditor+Formatting.swift
//  NotesApp
//
//  Created by Valentyna Kharkova on 30.05.2026.
//

import Foundation
import UIKit

extension RichTextEditor.Coordinator {
    //MARK: - Text Style
    func textFormat(_ textStyle: RichTextEditor.TextStyle, in textView: UITextView) {
        let range: NSRange
        if let selectedTextRange = textView.selectedTextRange,
           !selectedTextRange.isEmpty {
            range = textView.nsRange(from: selectedTextRange)
        } else {
            range = textView.cursorNSRange
        }
        let storage = textView.textStorage
        storage.beginEditing()
        storage.addAttribute(.font, value: textStyle.font, range: range)
        storage.endEditing()
        parent.attributedText = textView.attributedText
    }
    //MARK: - Bold Style
    func toggleBold(in textView: UITextView) {
        applyFontTraits(.traitBold, in: textView)
    }
    //MARK: - Italic Style
    func toggleItalic(in textView: UITextView) {
        applyFontTraits(.traitItalic, in: textView)
    }
    //MARK: - Underline Style
    func toggleUnderline( in textView: UITextView) {
        guard let selectedTextRange = textView.selectedTextRange, !selectedTextRange.isEmpty else { return }
        let range = textView.nsRange(from: selectedTextRange)
        let storage = textView.textStorage
        let existing = storage.attribute(.underlineStyle, at: range.location, effectiveRange: nil) as? Int
        let isUnderlined = existing == NSUnderlineStyle.single.rawValue
        storage.beginEditing()
        if isUnderlined {
            storage.removeAttribute(.underlineStyle, range: range)
        } else {
            storage.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)
        }
        storage.endEditing()
        
        parent.attributedText = textView.attributedText
    }
    //MARK: - Strikethrough Style
    func toggleStrikethrough( in textView: UITextView) {
        guard let selectedTextRange = textView.selectedTextRange, !selectedTextRange.isEmpty else { return }
        let range = textView.nsRange(from: selectedTextRange)
        let storage = textView.textStorage
        let existing = storage.attribute(.strikethroughStyle, at: range.location, effectiveRange: nil) as? Int
        let isStrikethrough = existing == NSUnderlineStyle.single.rawValue
        storage.beginEditing()
        if isStrikethrough {
            storage.removeAttribute(.strikethroughStyle, range: range)
        } else {
            storage.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: range)
        }
        storage.endEditing()
        
        parent.attributedText = textView.attributedText
    }
    
    //MARK: - Alignment
    func setAlignment(_ alignment: NSTextAlignment, in textView: UITextView) {
        let range: NSRange
        if let selectedTextRange = textView.selectedTextRange, !selectedTextRange.isEmpty {
            range = textView.nsRange(from: selectedTextRange)
        } else {
            range = textView.cursorNSRange
        }
        let storage = textView.textStorage
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = alignment
        let fullRange = (textView.text as NSString)
            .paragraphRange(for: range)
        storage.beginEditing()
        storage.addAttribute(.paragraphStyle, value: paragraphStyle, range: fullRange)
        storage.endEditing()
        
        parent.attributedText = textView.attributedText
    }
    
    
    //MARK: - Font Helpers
    // for bold and italic fonts
    func applyFontTraits(_ trait: UIFontDescriptor.SymbolicTraits, in textView: UITextView) {
        guard let selectedTextRange = textView.selectedTextRange, !selectedTextRange.isEmpty else { return }
        let range = textView.nsRange(from: selectedTextRange)
        let storage = textView.textStorage
        
        // Get the current font of the selected text
        // if there is no font — use the system 16pt as a fallback
        let currentFont = storage.attribute(.font, at: range.location, effectiveRange: nil) as? UIFont ?? UIFont.systemFont(ofSize: 16)
        // Check if this trait (bold or italic) already exists
        let hasTrait = currentFont.fontDescriptor.symbolicTraits.contains(trait)
        
        // Copy the current traits and add or remove the desired ones
        var newTraits = currentFont.fontDescriptor.symbolicTraits
        if hasTrait {
            newTraits.remove(trait)
        } else {
            newTraits.insert(trait)
        }
        
        // Create a new FontDescriptor with updated traits
        // guard let — because withSymbolicTraits can return nil
        // if the font does not support this trait
        guard let fontDescriptor = currentFont.fontDescriptor.withSymbolicTraits(newTraits) else { return }
        // Create a new UIFont while keeping the original size
        let newFont = UIFont(descriptor: fontDescriptor, size: currentFont.pointSize)
        storage.beginEditing()
        storage.addAttribute(.font, value: newFont, range: range)
        storage.endEditing()
        
        parent.attributedText = textView.attributedText
    }
}
