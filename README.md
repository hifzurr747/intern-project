# Flutter Internship — Week 3: TaskFlow App

## Overview
Final Task Management App combining all concepts from Weeks 1 & 2.

## Project Structure
```
lib/
├── main.dart
├── models/
│   └── task.dart                   ← Task data model
├── services/
│   └── storage_service.dart        ← SharedPreferences layer
└── screens/
    ├── splash_screen.dart          ← Animated splash (Bonus ✅)
    ├── home_screen.dart            ← Main task list screen
    └── add_edit_task_screen.dart   ← Add & Edit form
```

## Features
| Feature | Detail |
|---|---|
| Splash Screen | Fade + scale animation, auto-navigates after 2.5s (**Bonus ✅**) |
| Task List | `ListView` with created-time labels |
| Add Task | FAB + AppBar button → `AddEditTaskScreen` |
| Edit Task | Pre-filled form, updates in place |
| Delete Task | Swipe left or trash icon, with **Undo** snackbar |
| Mark Complete | Animated checkbox, strikethrough text |
| Filter | All / Pending / Done chips with live counts |
| Progress Bar | Visual completion % in header |
| Persistence | All tasks saved via `SharedPreferences` |
| Custom AppBar | Title + Add + Clear-completed actions |

## Setup & Run
```bash
flutter pub get
flutter run
```

## Build APK
```bash
flutter build apk --release
```
