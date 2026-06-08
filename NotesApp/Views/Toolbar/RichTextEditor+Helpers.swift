//
//  RichTextEditor+Helpers.swift
//  NotesApp
//
//  Created by Valentyna Kharkova on 30.05.2026.
//

import Foundation
import UIKit

extension RichTextEditor.Coordinator {
    
    // MARK: - Checkbox Attachment
    func makeCheckboxAttributedString(checked: Bool) -> NSMutableAttributedString {
        let attachment = makeCheckboxAttachment(checked: checked)
        let result = NSMutableAttributedString(attachment: attachment)
        result.append(NSAttributedString(
            string: " ",
            attributes: [
                .font: UIFont.systemFont(ofSize: 16),
                .foregroundColor: UIColor.label
            ]
        ))
        return result
    }
    
    // Create NSTextAttachment with SF Symbol
    func makeCheckboxAttachment(checked: Bool) -> NSTextAttachment {
        let attachment = checked ? CheckedAttachment() : UncheckedAttachment()
        
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
            .applying(UIImage.SymbolConfiguration(paletteColors: [checked ? .systemIndigo : .label]))
        let imageName = checked ? "checkmark.circle.fill" : "circle"
        attachment.image = UIImage(systemName: imageName, withConfiguration: config)
        attachment.bounds = CGRect(x: 0, y: -3, width: 20, height: 20)
        
        return attachment
    }
}
