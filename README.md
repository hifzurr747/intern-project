# TaskFlow — Flutter Internship Project

A complete Flutter Task Management App built as part of a 3-week internship program. The app covers all concepts from Week 1, Week 2, and Week 3 in a single unified project.

---

## 📱 App Flow

```
Splash Screen → Login Screen → Main Screen
                                ├── Tasks Tab (Task Manager)
                                └── Counter Tab (Counter App)
```

---

## 🗂️ Project Structure

```
taskflow_app/
├── pubspec.yaml
└── lib/
    ├── main.dart
    ├── models/
    │   └── task.dart
    ├── services/
    │   └── storage_service.dart
    └── screens/
        ├── splash_screen.dart
        ├── login_screen.dart
        ├── main_screen.dart
        ├── home_screen.dart
        ├── counter_screen.dart
        ├── todo_screen.dart
        └── add_edit_task_screen.dart
```

---

## ✅ Features Covered

### Week 1 — Basic Flutter Development & UI Building
- Login Screen with two `TextFormField` widgets (Email + Password)
- `Forgot Password?` Text widget
- Email format validation using Regex
- Password empty check (min 6 characters)
- Navigation from Login Screen to Home Screen using `Navigator.push()`
- UI built with `Column`, `Row`, `Container`, `Padding`

### Week 2 — Data Management & Persistent Storage
- Counter App with `setState` (Increment, Decrement, Reset)
- Counter value saved using `SharedPreferences` — persists after restart
- To-Do List with `ListView`
- Add, display, and delete tasks
- Tasks saved using `SharedPreferences`

### Week 3 — Final Project & Finishing Touches
- Full Task Management App (Home Screen with task list)
- Add, Delete, and Mark tasks as Complete
- Data persistence using `SharedPreferences`
- Custom `AppBar` with title and action buttons
- Icons from the `Icons` library
- Filter tasks: All / Pending / Done
- Progress bar showing completion percentage
- Swipe to delete with Undo snackbar
- Edit existing tasks
- **Bonus: Splash Screen** with fade + scale animation ✅

---

## 🛠️ Setup Instructions

### Prerequisites
- Flutter SDK installed ([flutter.dev](https://flutter.dev))
- Android Studio or VS Code
- Android Emulator or physical device connected

### Steps to Run

```bash
# 1. Clone or download the project
cd taskflow_app

# 2. Install dependencies
flutter pub get

# 3. Run the app
flutter run
```

### Build APK

```bash
flutter build apk --release
```

APK will be at: `build/app/outputs/flutter-apk/app-release.apk`

---

## 📦 Dependencies

| Package | Version | Purpose |
|---|---|---|
| `flutter` | SDK | Core framework |
| `shared_preferences` | ^2.2.3 | Local persistent storage |
| `cupertino_icons` | ^1.0.6 | iOS style icons |

---

## 🔐 Test Login Credentials

```
Email:    test@example.com
Password: 123456
```

---

## 📋 Deliverables Checklist

- [x] Login screen with navigation to home screen
- [x] Form validation (email format + password not empty)
- [x] Counter app with setState
- [x] SharedPreferences for counter persistence
- [x] To-Do list with ListView and local storage
- [x] Task Management App (add, delete, mark complete)
- [x] Custom AppBar with action buttons
- [x] Icons from Icons library
- [x] Data persistence using SharedPreferences
- [x] GitHub repository with README and setup instructions
- [x] Splash Screen (Bonus ✅)

---

## 👨‍💻 Developer Notes

- All screens are in `lib/screens/`
- `StorageService` handles all SharedPreferences read/write operations
- `Task` model uses `encode()` / `decode()` for storage serialization
- `mounted` checks added after every async operation to prevent setState on disposed widgets
- Deprecated `withOpacity()` replaced with explicit `Color` hex values throughout
