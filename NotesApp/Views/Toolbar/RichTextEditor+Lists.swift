//
//  RichTextEditor+Lists.swift
//  NotesApp
//
//  Created by Valentyna Kharkova on 30.05.2026.
//

import Foundation
import UIKit

extension RichTextEditor.Coordinator {
    
    //MARK: - Insert List
    func insertList(_ type: RichTextEditor.ListType, in textView: UITextView) {
        let newMarkerFormat: NSTextList.MarkerFormat
        switch type {
        case .bullet:   newMarkerFormat = .disc
        case .numbered: newMarkerFormat = NSTextList.MarkerFormat("{decimal}.")
        case .dash:     newMarkerFormat = .hyphen
        }
        
        func makeStyle(with list: NSTextList?) -> NSMutableParagraphStyle {
            let style = NSMutableParagraphStyle()
            if let list {
                style.textLists = [list]
                style.firstLineHeadIndent = 8
                style.headIndent = 24
                style.tabStops = []
                style.defaultTabInterval = 0
            }
            return style
        }
        
        func makeAttrs(style: NSParagraphStyle) -> [NSAttributedString.Key: Any] {
            [
                .font: UIFont.systemFont(ofSize: 16),
                .foregroundColor: UIColor.label,
                .paragraphStyle: style
            ]
        }
        
        let storage = textView.textStorage
        
        guard textView.text.count > 0 else {
            let list = NSTextList(markerFormat: newMarkerFormat, options: 0)
            let style = makeStyle(with: list)
            let attrs = makeAttrs(style: style)
            
            textView.insertText(" ")
            
            let range = (textView.text as NSString).paragraphRange(for: NSRange(location: 0, length: 0))
            storage.beginEditing()
            storage.addAttributes(attrs, range: range)
            storage.endEditing()
            
            textView.selectedTextRange = textView.textRange(
                from: textView.beginningOfDocument,
                to: textView.beginningOfDocument
            )
            textView.typingAttributes = attrs
            parent.attributedText = textView.attributedText
            return
        }
        
        let selectedRange: NSRange
        if let sel = textView.selectedTextRange, !sel.isEmpty {
            selectedRange = textView.nsRange(from: sel)
        } else {
            selectedRange = textView.cursorNSRange
        }
        
        let text = textView.text as NSString
        let fullRange = text.paragraphRange(for: selectedRange)
        
        guard fullRange.location <= storage.length else { return }
        
        var existingStyle: NSParagraphStyle? = nil
        if fullRange.location < storage.length {
            existingStyle = storage.attribute(
                .paragraphStyle,
                at: fullRange.location,
                effectiveRange: nil
            ) as? NSParagraphStyle
        }
        
        let isSameType = existingStyle?.textLists.first?.markerFormat == newMarkerFormat
        let newList: NSTextList? = isSameType ? nil : NSTextList(markerFormat: newMarkerFormat, options: 0)
        
        if fullRange.length == 0 || fullRange.location == storage.length {
            let style = makeStyle(with: newList)
            let attrs = makeAttrs(style: style)
            
            storage.beginEditing()
            let spaceString = NSAttributedString(string: " ", attributes: attrs)
            storage.insert(spaceString, at: fullRange.location)
            storage.endEditing()
            
            if let pos = textView.position(from: textView.beginningOfDocument, offset: fullRange.location) {
                textView.selectedTextRange = textView.textRange(from: pos, to: pos)
            }
            textView.typingAttributes = attrs
            parent.attributedText = textView.attributedText
            return
        }
        
        var paragraphRanges: [NSRange] = []
        text.enumerateSubstrings(in: fullRange, options: .byParagraphs) { _, _, enclosing, _ in
            paragraphRanges.append(enclosing)
        }
        
        var insertionOffset = 0
        
        for rawRange in paragraphRanges {
            let range = NSRange(location: rawRange.location + insertionOffset, length: rawRange.length)
            let currentText = (textView.text as NSString)
                .substring(with: range)
                .trimmingCharacters(in: .whitespacesAndNewlines)
            
            let style: NSMutableParagraphStyle
            if currentText.isEmpty {
                style = makeStyle(with: newList)
                let attrs = makeAttrs(style: style)
                
                let insertAt = NSRange(location: range.location, length: 0)
                storage.beginEditing()
                storage.replaceCharacters(in: insertAt, with: " ")
                storage.addAttributes(attrs, range: NSRange(location: range.location, length: 1))
                storage.endEditing()
                
                insertionOffset += 1
            } else {
                let existing = storage.attribute(
                    .paragraphStyle,
                    at: range.location,
                    effectiveRange: nil
                ) as? NSParagraphStyle
                
                style = NSMutableParagraphStyle()
                if let existing { style.setParagraphStyle(existing) }
                
                if isSameType {
                    style.textLists = []
                    style.headIndent = 0
                    style.firstLineHeadIndent = 0
                } else if let list = newList {
                    style.textLists = [list]
                    style.firstLineHeadIndent = 8
                    style.headIndent = 20
                    style.tabStops = []
                    style.defaultTabInterval = 0
                }
                
                storage.beginEditing()
                storage.addAttribute(.paragraphStyle, value: style, range: range)
                storage.endEditing()
            }
        }
        
        let currentFont = textView.typingAttributes[.font] as? UIFont ?? UIFont.systemFont(ofSize: 16)
        let finalStyle = makeStyle(with: newList)
        textView.typingAttributes = makeAttrs(style: finalStyle).merging(
            [.font: currentFont], uniquingKeysWith: { _, new in new }
        )
        parent.attributedText = textView.attributedText
    }
}

