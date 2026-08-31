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
        let attachment = makeCheckboxAttachment(checked: false)
        
        let checklistStyle = NSMutableParagraphStyle()
        checklistStyle.firstLineHeadIndent = 8
        checklistStyle.headIndent = 24
                
        func makeAttachmentString() -> NSAttributedString {
            let attachmentString = NSMutableAttributedString(attachment: attachment)
            attachmentString.append(NSAttributedString(
                string: " ",
                attributes: [
                    .font: UIFont.systemFont(ofSize: 16),
                    .foregroundColor: UIColor.label,
                    .paragraphStyle: checklistStyle,
                    //MARK: Kern sets the spacing, or kerning, between characters
                    .kern: 4
                ]
            ))
            attachmentString.addAttribute(.paragraphStyle, value: checklistStyle, range: NSRange(location: 0, length: attachmentString.length))
            return attachmentString
        }
        
        let defaultTypingAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16),
            .foregroundColor: UIColor.label,
            .paragraphStyle: checklistStyle
        ]
        
        guard storage.length > 0 else {
            let attachmentString = makeAttachmentString()
            storage.beginEditing()
            storage.setAttributedString(attachmentString)
            storage.endEditing()
            
            if let pos = textView.position(from: textView.beginningOfDocument, offset: 2) {
                textView.selectedTextRange = textView.textRange(from: pos, to: pos)
            }
            textView.typingAttributes = defaultTypingAttrs
            parent.attributedText = textView.attributedText
            return
        }
        
        guard let selectedTextRange = textView.selectedTextRange else { return }
        let range = textView.nsRange(from: selectedTextRange)
        let text = textView.text as NSString
        let lineRange = text.lineRange(for: NSRange(location: range.location, length: 0))
        
        guard lineRange.location <= storage.length else { return }
        
        var hasCheckbox = false
        if lineRange.location < storage.length {
            hasCheckbox = storage.attribute(
                .attachment,
                at: lineRange.location,
                effectiveRange: nil
            ) is NSTextAttachment
        }
        
        if hasCheckbox {
            storage.beginEditing()
            let removeRange = NSRange(location: lineRange.location, length: 2)
            if removeRange.location + removeRange.length <= storage.length {
                storage.deleteCharacters(in: removeRange)
            }
            storage.endEditing()
            
            textView.typingAttributes = defaultTypingAttrs
            parent.attributedText = textView.attributedText
            return
        }
        
        let lineText: String
        if lineRange.location < storage.length {
            lineText = text.substring(with: lineRange).trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            lineText = ""
        }
        
        if lineText.isEmpty {
            let attachmentString = makeAttachmentString()
            
            storage.beginEditing()
            storage.insert(attachmentString, at: lineRange.location)
            storage.endEditing()
            
            let cursorOffset = lineRange.location + 2
            if let pos = textView.position(from: textView.beginningOfDocument, offset: cursorOffset) {
                textView.selectedTextRange = textView.textRange(from: pos, to: pos)
            }
            textView.typingAttributes = defaultTypingAttrs
            parent.attributedText = textView.attributedText
            return
        }
        
        let attachmentString = makeAttachmentString()
        
        storage.beginEditing()
        storage.insert(attachmentString, at: lineRange.location)
        storage.endEditing()
        
        let newCursorOffset = range.location + 2
        if let pos = textView.position(from: textView.beginningOfDocument, offset: newCursorOffset) {
            textView.selectedTextRange = textView.textRange(from: pos, to: pos)
        }
        textView.typingAttributes = defaultTypingAttrs
        parent.attributedText = textView.attributedText
    }
    
    //MARK: - Toggle Checkmark
    func toggleCheckmark(at location: Int, in textView: UITextView) {
        let storage = textView.textStorage
        guard location < storage.length else { return }
        
        var effectiveRange = NSRange()
        guard let attachment = storage.attribute(
            .attachment,
            at: location,
            effectiveRange: &effectiveRange
        ) as? NSTextAttachment else { return }
        
        let isChecked = attachment is CheckedAttachment
        
        let newAttachment = makeCheckboxAttachment(checked: !isChecked)
        
        let text = textView.text as NSString
        let lineRange = text.lineRange(for: NSRange(location: location, length: 0))
        let textStart = lineRange.location + 2
        let textLength = max(0, lineRange.length - 2)
        
        storage.beginEditing()
        
        let newAttachmentString = NSMutableAttributedString(attachment: newAttachment)
        newAttachmentString.append(
            NSAttributedString(
                string: " ",
                attributes: [
                    .font: UIFont.systemFont(ofSize: 16),
                    .foregroundColor: UIColor.label,
                    .kern: 4
                ]
            )
        )
        
        let checklistStyle = NSMutableParagraphStyle()
        checklistStyle.firstLineHeadIndent = 8
        checklistStyle.headIndent = 24
        newAttachmentString.addAttribute(.paragraphStyle, value: checklistStyle, range: NSRange(location: 0, length: newAttachmentString.length))
        
        storage.replaceCharacters(in: NSRange(location: effectiveRange.location, length: 2), with: newAttachmentString)
        
        if textLength > 0 {
            let textRange = NSRange(location: textStart, length: textLength)
            if !isChecked {
                storage.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: textRange)
                storage.addAttribute(.foregroundColor, value: UIColor.secondaryLabel, range: textRange)
            } else {
                storage.removeAttribute(.strikethroughStyle, range: textRange)
                storage.addAttribute(.foregroundColor, value: UIColor.label, range: textRange)
            }
        }
        
        storage.endEditing()
        
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
        
        guard let position = textView.closestPosition(to: point) else { return }
        let location = textView.offset(from: textView.beginningOfDocument, to: position)
        
        let storage = textView.textStorage
        guard location < storage.length else { return }
        
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
            guard storage.attribute(.attachment, at: lineRange.location, effectiveRange: nil) is NSTextAttachment else {
                return true
            }
        
        let lineText = nsText.substring(with: lineRange)
        let contentOnly = lineText.replacingOccurrences(of: "\u{FFFC}", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        if contentOnly.isEmpty {
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
        
        let newAttachment = makeCheckboxAttachment(checked: false)
        let newLine = NSMutableAttributedString(string: "\n")
        newLine.append(NSAttributedString(attachment: newAttachment))
        newLine.append(NSAttributedString(
            string: " ",
            attributes: [
                .font: UIFont.systemFont(ofSize: 16),
                .foregroundColor: UIColor.label,
                .kern: 4
            ]
        ))
        
        let checklistStyle = NSMutableParagraphStyle()
        checklistStyle.firstLineHeadIndent = 8
        checklistStyle.headIndent = 24
        newLine.addAttribute(.paragraphStyle, value: checklistStyle, range: NSRange(location: 0, length: newLine.length))
        
        storage.beginEditing()
        storage.insert(newLine, at: range.location)
        storage.endEditing()
        
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
