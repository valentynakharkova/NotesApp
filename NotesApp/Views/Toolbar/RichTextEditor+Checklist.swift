//
//  RichTextEditor+Checklist.swift
//  NotesApp
//
//  Created by Valentyna Kharkova on 30.05.2026.
//

import Foundation
import UIKit

extension RichTextEditor.Coordinator {
    //MARK: - Insert Checklist
    func insertChecklist(in textView: UITextView) {
        let storage = textView.textStorage
        
        // Create unchecked attachment
        let attachment = makeCheckboxAttachment(checked: false)
        // checked = false → contents = nil (не встановлюємо)
        
        let attachmentString = NSMutableAttributedString(attachment: attachment)
        attachmentString.append(NSAttributedString(
            string: " ",
            attributes: [
                .font: UIFont.systemFont(ofSize: 16),
                .foregroundColor: UIColor.label
            ]
        ))
        
        // Empty text
        guard storage.length > 0 else {
            storage.beginEditing()
            storage.setAttributedString(attachmentString)
            storage.endEditing()
            
            // Move cursor after checkbox
            if let pos = textView.position(from: textView.beginningOfDocument, offset: 2) {
                textView.selectedTextRange = textView.textRange(from: pos, to: pos)
            }
            
            textView.typingAttributes = [
                .font: UIFont.systemFont(ofSize: 16),
                .foregroundColor: UIColor.label
            ]
            
            parent.attributedText = textView.attributedText
            return
        }
        
        guard let selectedTextRange = textView.selectedTextRange else { return }
        let range = textView.nsRange(from: selectedTextRange)
        let text = textView.text as NSString
        let lineRange = text.lineRange(for: NSRange(location: range.location, length: 0))
        
        // Check if checkbox already exists at beginning of line
        guard lineRange.location < storage.length else { return }
        
        let hasCheckbox = storage.attribute(
            .attachment,
            at: lineRange.location,
            effectiveRange: nil
        ) is NSTextAttachment
        
        storage.beginEditing()
        if hasCheckbox {
            // Remove checkbox and space
            let removeRange = NSRange(location: lineRange.location, length: 2)
            storage.deleteCharacters(in: removeRange)
        } else {
            // Insert checkbox
            storage.insert(attachmentString, at: lineRange.location)
        }
        storage.endEditing()
        
        parent.attributedText = textView.attributedText
    }
    
    //MARK: - Toggle Checkmark
    func toggleCheckmark(at location: Int, in textView: UITextView) {
        let storage = textView.textStorage
        guard location < storage.length else { return }
        
        // Check if attachment exists
        var effectiveRange = NSRange()
        guard let attachment = storage.attribute(
            .attachment,
            at: location,
            effectiveRange: &effectiveRange
        ) as? NSTextAttachment else { return }
        
        let isChecked = attachment is CheckedAttachment
        
        // Create new attachment with opposite state
        let newAttachment = makeCheckboxAttachment(checked: !isChecked)
        
        // Find text range after checkbox in this line
        let text = textView.text as NSString
        let lineRange = text.lineRange(for: NSRange(location: location, length: 0))
        let textStart = lineRange.location + 2
        let textLength = max(0, lineRange.length - 2)
        
        storage.beginEditing()
        
        // Replace attachment
        let newAttachmentString = NSMutableAttributedString(attachment: newAttachment)
        newAttachmentString.append(NSAttributedString(
            string: " ",
            attributes: [.font: UIFont.systemFont(ofSize: 16), .foregroundColor: UIColor.label]
        ))
        storage.replaceCharacters(in: NSRange(location: effectiveRange.location, length: 2), with: newAttachmentString)
        
        // Apply or remove strikethrough
        if textLength > 0 {
            let textRange = NSRange(location: textStart, length: textLength)
            if !isChecked {
                // → checked: add strikethrough and gray color
                storage.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: textRange)
                storage.addAttribute(.foregroundColor, value: UIColor.secondaryLabel, range: textRange)
            } else {
                // → unchecked: remove strikethrough
                storage.removeAttribute(.strikethroughStyle, range: textRange)
                storage.addAttribute(.foregroundColor, value: UIColor.label, range: textRange)
            }
        }
        
        storage.endEditing()
        
        // Reset typingAttributes
        textView.typingAttributes = [
            .font: UIFont.systemFont(ofSize: 16),
            .foregroundColor: UIColor.label
        ]
        
        parent.attributedText = textView.attributedText
    }
    //MARK: - Handle Tap
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        guard let textView = gesture.view as? UITextView else { return }
        
        let point = gesture.location(in: textView)
        
        // Find character position under tap
        guard let position = textView.closestPosition(to: point) else { return }
        let location = textView.offset(from: textView.beginningOfDocument, to: position)
        
        let storage = textView.textStorage
        guard location < storage.length else { return }
        
        // React only if tap on attachment
        guard storage.attribute(.attachment, at: location, effectiveRange: nil) is NSTextAttachment else { return }
        
        toggleCheckmark(at: location, in: textView)
    }

    //MARK: - Text View shouldChangeTextIn
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard text == "\n" else { return true }
        
        let storage = textView.textStorage
        guard range.location > 0 else { return true }
        
        let nsText = textView.text as NSString
        let lineRange = nsText.lineRange(for: NSRange(location: range.location, length: 0))
        guard lineRange.location < storage.length else { return true }
        
        let existingStyle = storage.attribute(
                .paragraphStyle,
                at: lineRange.location,
                effectiveRange: nil
            ) as? NSParagraphStyle
            
            if let lists = existingStyle?.textLists, !lists.isEmpty {
                return true
            }            
            // Check if current line has checkbox
            guard storage.attribute(.attachment, at: lineRange.location, effectiveRange: nil) is NSTextAttachment else {
                return true
            }
        
        // Check if line is empty (only checkbox)
        let lineText = nsText.substring(with: lineRange)
        let contentOnly = lineText.replacingOccurrences(of: "\u{FFFC}", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        if contentOnly.isEmpty {
            // Empty line — remove checkbox and exit mode
            storage.beginEditing()
            storage.deleteCharacters(in: lineRange)
            storage.insert(NSAttributedString(string: "\n"), at: lineRange.location)
            storage.endEditing()
            
            if let pos = textView.position(from: textView.beginningOfDocument, offset: lineRange.location + 1) {
                textView.selectedTextRange = textView.textRange(from: pos, to: pos)
            }
            parent.attributedText = textView.attributedText
            return false
        }
        
        // Add new line with checkbox
        let newAttachment = makeCheckboxAttachment(checked: false)
        let newLine = NSMutableAttributedString(string: "\n")
        newLine.append(NSAttributedString(attachment: newAttachment))
        newLine.append(NSAttributedString(
            string: " ",
            attributes: [
                .font: UIFont.systemFont(ofSize: 16),
                .foregroundColor: UIColor.label
            ]
        ))
        
        storage.beginEditing()
        storage.insert(newLine, at: range.location)
        storage.endEditing()
        
        // Move cursor after new checkbox
        if let pos = textView.position(from: textView.beginningOfDocument, offset: range.location + 3) {
            textView.selectedTextRange = textView.textRange(from: pos, to: pos)
        }
        
        textView.typingAttributes = [
            .font: UIFont.systemFont(ofSize: 16),
            .foregroundColor: UIColor.label
        ]
        
        parent.attributedText = textView.attributedText
        return false
    }
    
    //MARK: - Text View primaryActionFor
    func textView(
        _ textView: UITextView,
        primaryActionFor textItem: UITextItem,
        defaultAction: UIAction
    ) -> UIAction? {
        if case .textAttachment = textItem.content {
            return UIAction { [weak self] _ in
                self?.toggleCheckmark(at: textItem.range.location, in: textView)
            }
        }
        return defaultAction
    }
}
