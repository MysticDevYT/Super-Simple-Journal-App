# JournalApp

A minimal, distraction-free journaling app for macOS.
Which I vibecoded cuz I dont know how to build macOS apps

## Features

### Core Functionality
- **Daily Journal Entries**: Create and edit journal entries for any date
- **Markdown Support**: Write entries in markdown format
- **Image Attachments**: Drag and drop images into entries
- **Auto-Save**: Entries are automatically saved as you type

### Navigation
- **Calendar View**: Browse entries by date using the built-in calendar
- **Previous/Next Navigation**: Navigate between days with arrow buttons
- **Quick Jump**: Jump directly to today

### Organization
- **Entry Statistics**: Track total entries and monthly entry count
- **Visual Indicators**: Dots on calendar dates indicate existing entries

### Appearance
- **Theme Toggle**: Switch between light and dark modes
- **Customizable Font Size**: Adjust editor text size with Cmd+/Cmd-

### Export
- **Export Entries**: Save journal entries as markdown files
###(DOES NOT WORK YET)

### Data Storage
- **Local File Storage**: Entries stored as markdown files in `~/Library/Containers/tks.JournalApp/Data/Documents/Journal/`
- **Directory Structure**: Each entry stored in date-named folders (`YYYY-MM-DD/entry.md`)

## Keyboard Shortcuts

| Action | Shortcut |
|--------|----------|
| Increase Font Size | Cmd + + |
| Decrease Font Size | Cmd + - |
| Export Entry | Cmd + Shift + E |
| Toggle Theme | Cmd + Shift + T |

## File Structure

```
Documents/Journal/
├── 2024-01-01/
│   ├── entry.md
│   └── image.png
├── 2024-01-02/
│   └── entry.md
└── ...
```

## System Requirements

- macOS 15.5 or later
