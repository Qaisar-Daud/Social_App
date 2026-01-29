# Glintor

Glintor is a modern social media application built with **Flutter** and **Firebase**, inspired by platforms like Facebook. The app focuses on real-time interaction, smooth performance, and a scalable architecture suitable for production-ready mobile applications.

---

## 🚀 Features

- 🔐 **Complete Authentication System**
    - Email and password authentication
    - Secure user sessions

- 🧑‍💼 **User Profiles**
    - Profile customization (avatar, bio, personal details)
    - Persistent user data

- 📝 **Posts & Interactions**
    - Create text and media posts
    - Like, comment, and share posts
    - Save posts to view later

- 💬 **Real-time Chat**
    - One-to-one messaging
    - Firebase-powered real-time updates

- 🎥 **Video Watching**
    - Smooth in-app video playback experience

- ⚡ **Fast & Responsive UI**
    - Optimized Flutter widgets
    - Clean and user-friendly interface

---

## 🧱 Architecture & Tech Stack

- **Framework:** Flutter
- **Backend:** Firebase (Authentication, Firestore, Storage)
- **Architecture Pattern:** MVC (Model–View–Controller)
- **State Management:** Provider
- **Local Storage:** Hive

The project follows a clean and scalable architecture with a clear separation of concerns.

---

## 📁 Folder Structure

- **lib/
- **├── models/ # Data models
- **├── views/ # UI screens and widgets
- **├── controllers/ # Controllers and business logic
- **├── services/ # Firebase and helper services
- **├── providers/ # State management (Provider)
- **├── utils/ # Constants and utilities
- **└── main.dart # Application entry point


---

## 🔧 Setup & Installation

1. Clone the repository

git clone https://github.com/Qaisar-Daud/Social_App.git


2. Install dependencies

flutter pub get


3. Configure Firebase
- Create a Firebase project
- Add Android and/or iOS apps
- Download and add the configuration files:
    - `google-services.json`
    - `GoogleService-Info.plist`

4. Run the app

flutter run


---

## 🛠️ State Management

Glintor uses **Provider** for state management to keep the codebase simple, efficient, and easy to scale. UI logic and business logic are clearly separated.

---

## 💾 Local Storage

**Hive** is used for:
- Caching user data
- Saving posts for later viewing
- Improving app performance and offline experience

---

## 🔐 Security

- Firebase Authentication for secure login
- Firestore security rules to protect user data
- Proper handling of client-side and backend logic

---

## 📌 Future Improvements

- Push notifications
- Group chats
- Stories feature
- Advanced search and recommendations

---

## 🤝 Contribution

Contributions, issues, and feature requests are welcome.  
Feel free to fork the repository and submit a pull request.

---

## 📄 License

This project is intended for educational and portfolio purposes.  
You are free to explore and learn from the codebase.

---

## ✨ Author

Developed with ❤️ using Flutter and Firebase.

**Glintor** – Connect. Share. Engage.

---
