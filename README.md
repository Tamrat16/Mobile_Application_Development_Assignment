# Personal Expense Tracker

**Course:** Mobile Application Development  
**Unit:** 5 – Local Storage & Data Persistence in Flutter  
**Student Name:** Sisay Leykun
                  Tamrat Arage
                  Yasin Jama
  

---

## 📱 Overview

The app is a modern, offline‑first expense tracker that demonstrates three key local storage techniques in Flutter:

- **Secure PIN** (encrypted)
- **SQLite database** for structured expense records
- **SharedPreferences** for user preferences (currency, theme)

The app asks the user to set a 4‑digit PIN on first launch, then protects all expense data. It supports full CRUD operations, monthly summaries with a bar chart, currency selection, and dark/light theme.

---

## 🚀 How to Run the Project

### Prerequisites
- Flutter SDK 3.16 or later
- Android Studio / VS Code with Flutter extensions
- Android emulator **or** a physical Android device (USB debugging enabled)

> ⚠️ **Important:** This app uses `sqflite` and `flutter_secure_storage` – these packages do **not** work on the web. You must run on an Android/iOS device or emulator.

### Steps

1. **Clone the repository**  
   ```bash
   git clone https://github.com/Tamrat16/Mobile_Application_Development_Assignment/edit/main/README.md
   cd your-repo-name
