# super_dbtx

A powerful, lightweight, and developer‑friendly **SQLite Database Utility Package** for Flutter.
Designed to simplify database management, boost productivity, and provide clean abstraction layers over **Sqflite**.

---

## 🚀 About the Package

`super_dbtx` is a utility‑driven database toolkit created for Flutter developers who want:

- Clean and readable database code
- Reusable helpers for CRUD operations
- Easy debugging with built‑in logging
- Safe execution with custom exception handling
- Flexible table management utilities

It wraps around **Sqflite** and unlocks a smoother way to handle local storage operations.

---

## 💡 Why super_dbtx?

Managing raw SQL queries and boilerplate can get messy.
`super_dbtx` solves that by offering:

### ✔ Structured DB Utilities

- Create tables
- Drop tables
- Recreate database
- Run batch queries
- Execute safe SQL commands

### ✔ Error‑safe implementation

Custom exceptions ensure your app does NOT expose raw Sqflite errors.

### ✔ Built‑in Logger

Every significant database action is logged for debugging.

### ✔ Highly Extensible

Designed to be integrated into:

- POS systems
- Inventory apps
- Local‑first apps
- Offline‑based Flutter apps
- Any system needing structured local DB

---

## 📦 Features

- Drop all tables instantly
- Reinitialize database
- Safe wrapper over Sqflite APIs
- Custom exceptions for clean UI error messages
- Logger for all DB actions
- CRUD helper base ready to extend

---

📥 Installation

Add the dependency in your pubspec.yaml:

```
dependencies:
  super_dbtx: ^1.0.0
```

Then import:
`import 'package:super_dbtx/super_dbtx.dart';`

## 📁 Package Architecture Diagram

```
lib/
├── super_dbtx.dart # Public API exports
└── src/
├── crud/                      # Repository + Query builders
│ ├── base_crud_repo.dart
│ ├── crud_repo.dart
│ └── query_builder.dart
│
├── db/                        # Core database engine
│ ├── super_database.dart
│ ├── db_utils.dart
│ ├── db_logger.dart
│ ├── db_exceptions.dart
│ ├── db_initializer.dart
│ └── db_backup.dart
│
└── utils/                     # Safety + helper utilities
└── safe_executor.dart
```

---

## Basic Usage

### **1️⃣ Initialize DB**

```dart
final db = await openDatabase(
  await DBUtils.databasePath("app.db"),
  version: 1,
  onCreate: (db, version) async {
    // Create tables here
  },
);
```

### **2️⃣ Drop All Tables**

```dart
await DBUtils.dropAll(db, [
  "users",
  "products",
  "orders",
]);
```

### **3️⃣ Check Column Info (PRAGMA)**

```dart
final columns = await DBUtils.getTableColumns(db, "users");
print(columns);
```

---

### CRUD Example with Model Class

1. Create a model

```class User {
  final int? id;
  final String name;

  User({this.id, required this.name});

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
  };

  static User fromMap(Map<String, dynamic> map) => User(
    id: map['id'],
    name: map['name'],
  );
}
```

2. Create a User Repository

```
class UserRepo extends BaseCrudRepo<User> {
  UserRepo(super.db) : super(table: 'users');

  @override
  User fromMap(Map<String, dynamic> map) => User.fromMap(map);
}
```

3. Using the Repo

```
final db = await SuperDatabase.initialize('app.db');
final userRepo = UserRepo(db);

await userRepo.insert(User(name: "Sheik"));
final users = await userRepo.getAll();

print(users.first.name); // Sheik
```

---

## 📌 Requirements

- Flutter SDK
- Dart >= 3.0
- Sqflite plugin

---

## 🤝 Contributing

Feel free to raise issues or submit pull requests at:
👉 **GitHub Repo:** [https://github.com/SheikMohideen007/super_dbtx](https://github.com/SheikMohideen007/super_dbtx)

---

## 📄 License

This project is licensed under the **MIT License**.

---

## ❤️ Support

If this package helped you, give it a ⭐ on GitHub!

Made with care for developers who love clean database code 🤝
