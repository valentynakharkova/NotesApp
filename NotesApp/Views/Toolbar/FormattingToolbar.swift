//
//  FormattingToolbar.swift
//  NotesApp
//
//  Created by Valentyna Kharkova on 21.05.2026.
//

import SwiftUI


struct FormattingToolbar: View {
    let textView: UITextView
    let coordinator: RichTextEditor.Coordinator
    @State private var showTextStyle: Bool = false
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 24) {
                // text format
                toolbarButton(icon: "textformat", action: {
                    showTextStyle.toggle()
                })
                .popover(isPresented: $showTextStyle) {
                    textStylePopup
                }
                // checklist
                toolbarButton(icon: "checklist", action: { coordinator.insertChecklist(in: textView) } )
                // bold
                toolbarButton(icon: "bold", action: { coordinator.toggleBold(in: textView)})
                // italic
                toolbarButton(icon: "italic", action: {coordinator.toggleItalic(in: textView)})
                // underline
                toolbarButton(icon: "underline", action: {coordinator.toggleUnderline(in: textView)})
                // strikethrough
                toolbarButton(icon: "strikethrough", action: {coordinator.toggleStrikethrough(in: textView)})
                // bullet list
                toolbarButton(icon: "list.bullet", action: {coordinator.insertList(.bullet, in: textView)})
                // numbered list
                toolbarButton(icon: "list.number", action: {coordinator.insertList(.numbered, in: textView)})
                // dash list
                toolbarButton(icon: "list.dash", action: {coordinator.insertList(.dash, in: textView)})
                // left alignment
                toolbarButton(icon: "text.alignleft", action: {coordinator.setAlignment(.left, in: textView)})
                // center alignment
                toolbarButton(icon: "text.aligncenter", action: {coordinator.setAlignment(.center, in: textView)})
                // right alignment
                toolbarButton(icon: "text.alignright", action: {coordinator.setAlignment(.right, in: textView)})
            }
        }
        .padding(12)
        .foregroundStyle(.primary)
        .font(.system(size: 24))
        .glassEffect()
        .padding(.bottom, 8)
        
    }
    private func toolbarButton(icon: String, action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            Image(systemName: icon)
        }
    }
    
    private var textStylePopup: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(RichTextEditor.TextStyle.allCases, id: \.label) { style in
                Button {
                    coordinator.textFormat(style, in: textView)
                    showTextStyle = false
                } label: {
                    Text(style.label)
                        .font(style.swiftUIFont)
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 10)
        .presentationCompactAdaptation(.popover)
    }
}

#Preview {
    let textView = UITextView()
    let editor = RichTextEditor(
        attributedText: .constant(NSAttributedString(string: "Hello")),
        textView: textView
    )
    
    return FormattingToolbar(
        textView: textView,
        coordinator: editor.makeCoordinator()
    )
    .padding()
    .background(Color(.systemBackground))
}
