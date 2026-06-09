# NotesApp 📝

A full-featured notes application for iOS, inspired by Apple Notes, as a part of my portfolio. It was build with SwiftUI, SwiftData and deep UIKit integration for rich text editing. 

## Screenshots 
<img width="660" height="1434" alt="IMG_7959" src="https://github.com/user-attachments/assets/5e735c33-f80d-425e-b4cd-6008146ce351" />
<img width="660" height="1434" alt="IMG_7960" src="https://github.com/user-attachments/assets/b130f3cb-6862-4dbc-a213-2656f47f9316" />
<img width="660" height="1434" alt="IMG_7963" src="https://github.com/user-attachments/assets/5d5192d1-8518-491b-82ac-3ea51cc0a1c9" />
<img width="660" height="1434" alt="IMG_7962" src="https://github.com/user-attachments/assets/18906a7a-7615-42a1-ac5a-fd3faa078b9f" />
<img width="660" height="1434" alt="IMG_7964" src="https://github.com/user-attachments/assets/1341d61a-1e94-4d3a-b277-39ee27d16aae" />
<img width="660" height="1434" alt="IMG_7965" src="https://github.com/user-attachments/assets/987c34e9-102b-4816-9fcf-66b0ae0bf464" />
<img width="660" height="1434" alt="IMG_7967" src="https://github.com/user-attachments/assets/06c0d9d5-c118-42f8-9b4f-384c61cc507b" />
<img width="660" height="1434" alt="IMG_7961" src="https://github.com/user-attachments/assets/d4d2d87d-6140-44c3-a0b4-acd232dafd16" />
<img width="660" height="1434" alt="IMG_7968" src="https://github.com/user-attachments/assets/6ef19766-17d2-489a-b27e-04d3a4c81713" />
<img width="660" height="1434" alt="IMG_7969" src="https://github.com/user-attachments/assets/78144d7d-eec5-4f28-b859-f1693711049f" />
<img width="660" height="1434" alt="IMG_7970" src="https://github.com/user-attachments/assets/d8e9bb49-edd1-40c7-8402-d9197eb688c2" />
<img width="660" height="1434" alt="IMG_7971" src="https://github.com/user-attachments/assets/1c4e8554-f545-4e9d-a52c-b4a1f63eef3e" />

## Video 
https://github.com/user-attachments/assets/a8793181-a312-4e90-8ed8-61afdc3b6c80

## Features 
### Notes 
1. Create, edit, and delete notes with a title and rich text body;
2. Notes are grouped by time period: Today, Previous 7 Days, Previous 30 Days, by month, and by year;
3. Pin notes to keep them at the top of the list;
4. Move notes between folders;
5. Note preview in the list shows date modified and body excerpt;
6. Soft delete with 30-day recovery window — notes are automatically purged after 30 days

### Rich Text Editor 
1. **Text Styles** - Title, Heading, Subheading, Body via a popover picker;
2. **Formatting** - Bold, Italic, Underline, Strikethrough;
3. **ALignment** - Left, Certer, Right;
4. **Lists** - Dash, Numbered, Bullet;
5. **Checklists** - Interactive checkboxes with tap-to-toggle, completed items get strikethrough and dimmed color;
6. Pressing Enter on a checklist line creates a new checkbox automatically;
7. Pressing Enter on an empty checklist line exits the checklist;
8. Swipe down to dismiss the keyboard while reading.

### Folders 
1. Create and name custom folders;
2. Rename folders via an inline alert;
3. Reorder folders via drag-and-drop;
4. Soft delete folders - moves all contained notes to Recently Deleted;
5. Search across folders and notes simultaneously from the main screen.

### Recently Deleted 
1. Deleted notes are moved to a Recently Deleted section;
2. Notes are automatically permanently deleted after 30 days;
3. Restore individual notes or all notes at once;
4. Permanently delete individual notes or all notes at once;
5. Edit mode with multi-select for batch restore or delete.

### Search 
1. Search bar on the Folders screen filters both folders and notes in real time;
2. Notes are matched against both title and body content.

## Tech Stack 
1. **SwiftUI** - all Views, Navigation, Toolbar, Search;
2. **SwiftData** - Persistent storage with @Model, @Query, @Bindable;
3. **UIKit** - UITextView for rich text editing;
4. **UIViewRepresentable** - SwiftUI <--> UIKit bridge;
5. **NSAttributedString** - Rich text storage and manipulation;
6. **NSTextStorage** - Direct text editing with beginEditing/endEditing;
7. **NSTextAttachment** - Checkbox rendering with SF Symbols;
8. **NSTextList** - Bullet, numbered, and dash list formatting;
9. **NSParagraphStyle** - Indentation, alignment, list configuration;
10. **UIPanGestureRecognizer** - Swipe-to-dismiss keyboard;
11. **UITapGestureRecognizer** - Checkbox tap detection;
12. **RTF encoding** - Attributed text serialized to Data via RTF for SwiftData storage.

## Architecture 
```
NotesApp/
├── Models/
│   ├── Note.swift               — SwiftData model; RTF encode/decode for attributed body
│   └── Folder.swift             — SwiftData model with nullify delete rule for notes
│
├── ViewModels/
│   ├── NotesViewModel.swift     — CRUD for notes and folders; soft delete; pin; move
│   └── RichTextEditorViewModel.swift — Owns UITextView instance; bridges state to SwiftUI
│
├── Views/
│   ├── FoldersView.swift        — Root screen; folder list; search; navigation
│   ├── NotesListView.swift      — Notes grouped by date; pin section; swipe actions
│   ├── NotesDetailView.swift    — Edit existing note; auto-save on disappear
│   ├── NewNoteView.swift        — Create new note with Save button
│   ├── NewFolderView.swift      — Sheet for creating a new folder
│   ├── RecentlyDeletedView.swift — Soft-deleted notes; batch restore and delete
│   ├── NoteRow.swift            — List row with title, date, and body preview
│   └── FormattingToolbar.swift  — Horizontal scroll toolbar above the keyboard
│
└── RichTextEditor/
    ├── RichTextEditor.swift           — UIViewRepresentable base + Coordinator
    ├── RichTextEditor+Enums.swift     — TextStyle and ListType enums
    ├── RichTextEditor+Formatting.swift — Bold, italic, underline, strikethrough, alignment, text style
    ├── RichTextEditor+Lists.swift     — NSTextList insertion, toggling, cursor restoration
    ├── RichTextEditor+Checklist.swift — Checkbox insert, toggle, Enter key handling
    └── RichTextEditor+Helpers.swift   — NSTextAttachment factory, UITextView extensions
```
## Key Design Decisions 
1. **UIKit UITextView over native SwiftUI TextEditor** -  SwiftUI's TextEditor with AttributedString (iOS 18) was explored but lacks the control needed for checklists, list indentation, and gesture handling. UITextView with NSAttributedString provides direct access to NSTextStorage; 
2. **ViewModel owns UITextView** - RichTextEditorViewModel creates and owns the UITextView instance, passing it into both RichTextEditor (for rendering) and FormattingToolbar (for formatting). This avoids duplicating state and keeps the view layer thin;
**NSTextAttachment subclasses for checkbox state** - Checkbox state is tracked via UncheckedAttachment and CheckedAttachment subclasses rather than image comparison. This makes toggle detection reliable with a simple is check;
3. **RTF serialization for SwiftData** - NSAttributedString is encoded to Data using RTF format and stored in Note.bodyData. On read, it is decoded back. This preserves all formatting attributes including fonts, colors, lists, and attachments across sessions;
4. **Soft delete pattern** - Notes and folders are never immediately deleted. An isDeleted flag moves them to Recently Deleted, and a deleteDate enables automatic cleanup after 30 days via cleanupExpiredNotes.

## Challenges 
1. **Formatting Toolbar** - Building a toolbar that controls a UIKit UITextView from SwiftUI required bridging two different worlds. Passing the UITextView instance and Coordinator through the view hierarchy without losing state was the first hurdle. Getting lists, checklists, alignment, and cursor position to behave like Apple Notes took significant iteration — each feature had its own edge cases;
2. **Checklists and Lists** - NSTextAttachment (checklists) and NSTextList (bullet/numbered/dash) are fundamentally different systems that don't share indentation logic. Making them look and behave consistently required careful matching of firstLineHeadIndent, headIndent, and kern. The Enter key behavior, cursor jumping, and empty line edge cases each needed separate handling;
3. **SwiftData Integration** - NSAttributedString cannot be stored directly in SwiftData. The solution was to encode it to RTF Data and decode it on read. Designing the Note model so that rich text survived save/load cycles without losing formatting took careful testing.

## Requirements

- iOS 26.0+
- Xcode 26+
- Swift 5.0+

## Author
Valentyna Kharkova — Junior iOS Developer
Building a native iOS portfolio | 2026





















