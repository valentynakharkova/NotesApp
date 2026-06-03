//
//  RichTextEditor+Lists.swift
//  NotesApp
//
//  Created by Valentyna Kharkova on 30.05.2026.
//

import Foundation
import UIKit

extension RichTextEditor.Coordinator {
    
    // MARK: - Lists
    
    func insertList(_ type: RichTextEditor.ListType, in textView: UITextView) {
        let text = textView.text as NSString
        
        // Determine new marker format
        let newMarkerFormat: NSTextList.MarkerFormat
        switch type {
        case .bullet:   newMarkerFormat = .disc
        case .numbered: newMarkerFormat = NSTextList.MarkerFormat("{decimal}.")
        case .dash:     newMarkerFormat = .hyphen
        }
        
        // Empty text — insert space so marker appears
        guard text.length > 0 else {
            textView.insertText(" ")
            
            let list = NSTextList(markerFormat: newMarkerFormat, options: 0)
            let style = NSMutableParagraphStyle()
            style.textLists = [list]
            style.firstLineHeadIndent = 16
            style.headIndent = 32
            
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 16),
                .foregroundColor: UIColor.label,
                .paragraphStyle: style
            ]
            
            let updatedText = textView.text as NSString
            let range = updatedText.paragraphRange(for: NSRange(location: 0, length: 0))
            textView.textStorage.beginEditing()
            textView.textStorage.addAttributes(attrs, range: range)
            textView.textStorage.endEditing()
            
            if let pos = textView.position(from: textView.beginningOfDocument, offset: 0) {
                textView.selectedTextRange = textView.textRange(from: pos, to: pos)
            }
            
            textView.typingAttributes = attrs
            parent.attributedText = textView.attributedText
            return
        }
        
        let selectedRange: NSRange
        if let selectedTextRange = textView.selectedTextRange,
           !selectedTextRange.isEmpty {
            selectedRange = textView.nsRange(from: selectedTextRange)
        } else {
            selectedRange = textView.cursorNSRange
        }
        
        let fullRange = text.paragraphRange(for: selectedRange)
        let storage = textView.textStorage
        guard fullRange.location < storage.length else { return }
        
        // Declare everything here — before any use
        let existingStyle = storage.attribute(
            .paragraphStyle,
            at: fullRange.location,
            effectiveRange: nil
        ) as? NSParagraphStyle
        let existingList = existingStyle?.textLists.first
        let isSameType = existingList?.markerFormat == newMarkerFormat
        let newList: NSTextList? = isSameType ? nil : NSTextList(markerFormat: newMarkerFormat, options: 0)
        
        // Cursor on empty line — only typingAttributes
        if fullRange.length == 0 {
            let style = NSMutableParagraphStyle()
            if let list = newList {
                style.textLists = [list]
                style.firstLineHeadIndent = 16
                style.headIndent = 32
            }
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 16),
                .foregroundColor: UIColor.label,
                .paragraphStyle: style
            ]
            textView.typingAttributes = attrs
            parent.attributedText = textView.attributedText
            return
        }
        
        var paragraphRanges: [NSRange] = []
        (textView.text as NSString).enumerateSubstrings(
            in: fullRange,
            options: .byParagraphs
        ) { _, _, enclosingRange, _ in
            paragraphRanges.append(enclosingRange)
        }
        
        storage.beginEditing()
        
        for paragraphRange in paragraphRanges {
            let paragraphText = text.substring(with: paragraphRange)
                .trimmingCharacters(in: .whitespacesAndNewlines)
            
            if paragraphText.isEmpty {
                let newStyle = NSMutableParagraphStyle()
                if let list = newList {
                    newStyle.textLists = [list]
                    newStyle.firstLineHeadIndent = 16
                    newStyle.headIndent = 32
                    newStyle.tabStops = []
                    newStyle.defaultTabInterval = 0
                }
                storage.addAttribute(.paragraphStyle, value: newStyle, range: paragraphRange)
                continue
            }
            
            let paraStyle = storage.attribute(
                .paragraphStyle,
                at: paragraphRange.location,
                effectiveRange: nil
            ) as? NSParagraphStyle
            
            let newStyle = NSMutableParagraphStyle()
            if let existing = paraStyle {
                newStyle.setParagraphStyle(existing)
            }
            
            if isSameType {
                newStyle.textLists = []
                newStyle.headIndent = 0
                newStyle.firstLineHeadIndent = 0
            } else if let list = newList {
                newStyle.textLists = [list]
                newStyle.firstLineHeadIndent = 16
                newStyle.headIndent = 32
                newStyle.tabStops = []
                newStyle.defaultTabInterval = 0
            }
            
            storage.addAttribute(.paragraphStyle, value: newStyle, range: paragraphRange)
        }
        
        storage.endEditing()
        
        let currentFont = textView.typingAttributes[.font] as? UIFont ?? UIFont.systemFont(ofSize: 16)
        textView.typingAttributes = [
            .font: currentFont,
            .foregroundColor: UIColor.label
        ]
        
        parent.attributedText = textView.attributedText
    }
}
