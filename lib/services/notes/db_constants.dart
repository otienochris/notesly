const dbName = 'notesly.db';
const notesTable = "Notes";
const usersTable = "User";

const createUserTable = '''CREATE TABLE IF NOT EXISTS "User" (
	          "id"	INTEGER NOT NULL,
	          "email"	TEXT NOT NULL UNIQUE,
	          PRIMARY KEY("id" AUTOINCREMENT)
      );''';

const createNotesTable = '''CREATE TABLE IF NOT EXISTS "Notes" (
        "id"	INTEGER NOT NULL,
        "user_id"	INTEGER NOT NULL,
        "text"	TEXT,
        "is_uploaded"	INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY("user_id") REFERENCES "User"("id"),
        PRIMARY KEY("id" AUTOINCREMENT)
      );''';
