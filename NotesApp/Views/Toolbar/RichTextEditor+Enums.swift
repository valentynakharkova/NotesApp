//
//  RichTextEditor+Enums.swift
//  NotesApp
//
//  Created by Valentyna Kharkova on 30.05.2026.
//

import SwiftUI
import UIKit


extension RichTextEditor {
    //MARK: - Enums
    enum TextStyle: CaseIterable {
        case title, heading, subheading, body
        
        var font: UIFont {
            switch self {
            case .title:
                return UIFont.systemFont(ofSize: 28, weight: .bold)
            case .heading:
                return UIFont.systemFont(ofSize: 22, weight: .bold)
            case .subheading:
                return UIFont.systemFont(ofSize: 18, weight: .semibold)
            case .body:
                return UIFont.systemFont(ofSize: 16, weight: .regular)
            }
        }
        
        var label: String {
            switch self {
            case .title:
                return "Title"
            case .heading:
                return "Heading"
            case .subheading:
                return "Subheading"
            case .body:
                return "Body"
            }
        }
        
        var swiftUIFont: Font {
            switch self {
            case .title:
                return .system(size: 28, weight: .bold)
            case .heading:
                return .system(size: 22, weight: .bold)
            case .subheading:
                return .system(size: 18, weight: .semibold)
            case .body:
                return .system(size: 16, weight: .regular)
            }
        }
    }
    
    enum ListType {
        case bullet, numbered, dash
    }
}
