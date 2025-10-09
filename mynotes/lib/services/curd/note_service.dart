import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseAlreadyOpenException implements Exception {}

class UnableToGetDocumentsDirectly implements Exception {}

class DatabaseIsNotOpen implements Exception {}

class NoteService {
  Database? _database;

  Future<DatabaseUser> createUser({required String email}) async {
    final db = _getDatabaseOrThrow();

    final result = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
  }

  Database _getDatabaseOrThrow() {
    final db = _database;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      return db;
    }
  }

  Future<void> close() async {
    final db = _database;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      await db.close();
      _database = null;
    }
  }

  Future<void> open() async {
    if (_database != null) {
      throw DatabaseAlreadyOpenException();
    }

    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _database = db;

      const createUserTable = '''CREATE TABLE IF NOT EXISTS "USER" (
        "id"	INTEGER NOT NULL,
	      "email"	TEXT NOT NULL UNIQUE,
	      PRIMARY KEY("id" AUTOINCREMENT)
      );''';
      // create user table
      await db.execute(createUserTable);

      const createNoteTable = '''CREATE TABLE "NOTE" (
          "id"	INTEGER NOT NULL,
          "user_id"	INTEGER NOT NULL,
          "text"	TEXT,
          "is_synced_with_cloud"	INTEGER DEFAULT 0,
          PRIMARY KEY("id" AUTOINCREMENT),
          FOREIGN KEY("user_id") REFERENCES "USER"("id")
          );''';

      // create note table
      await db.execute(createNoteTable);
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectly();
    }
  }
}

@immutable
class DatabaseUser {
  final int id;
  final String email;
  const DatabaseUser({required this.id, required this.email});

  DatabaseUser.fromRow(Map<String, Object?> map)
    : id = map[idColumn] as int,
      email = map[emailColumn] as String;

  @override
  String toString() {
    return 'Peron, ID = $id, email = $email';
  }

  @override
  bool operator ==(covariant DatabaseUser other) {
    return id == other.id;
  }

  @override
  int get hashCode => id.hashCode;
}

@immutable
class DatabaseNote {
  final int id;
  final int userId;
  final String text;
  final bool isSyncedWithCloud;

  const DatabaseNote({
    required this.id,
    required this.userId,
    required this.text,
    required this.isSyncedWithCloud,
  });

  DatabaseNote.fromRow(Map<String, Object?> map)
    : id = map[idColumn] as int,
      userId = map[userIdColumn] as int,
      text = map[textColumn] as String,
      isSyncedWithCloud = (map[isSyncedWithCloudColumn] as int) == 1
          ? true
          : false;
}

const dbName = 'notes.db';
const userTable = 'USER';
const noteTable = 'NOTE';
const idColumn = 'id';
const emailColumn = 'email';
const userIdColumn = 'user_id';
const textColumn = 'text';
const isSyncedWithCloudColumn = 'is_synced_with_cloud';
