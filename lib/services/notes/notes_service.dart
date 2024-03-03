import 'dart:async';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart'
    show MissingPlatformDirectoryException, getApplicationDocumentsDirectory;
import 'package:sqflite/sqflite.dart';

import '../../model/entities/database_note.dart';
import '../../model/entities/database_user.dart';
import 'crud_exception.dart';
import 'db_constants.dart';


class NotesService {
  Database? _db;

  /// retrieve a user from db by email
  Future<DatabaseUser> getUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final List<Map<String, Object?>> result = await db.query(usersTable,
        limit: 1, where: 'email = ?', whereArgs: [email.toLowerCase()]);

    if (result.isEmpty) {
      throw UserNotFoundException();
    } else {
      return DatabaseUser.fromRow(result.first);
    }
  }

  /// insert a new user to the db by providing the user's email
  Future<DatabaseUser> createUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final List<Map<String, Object?>> results = await db.query(
      usersTable,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );

    if (results.isNotEmpty) {
      throw UserAlreadyExistsException();
    } else {
      final int id =
          await db.insert(usersTable, {emailColumn: email.toLowerCase()});
      return Future.value(DatabaseUser(id: id, email: email));
    }
  }

  /// delete a user from db using their email
  Future<void> deleteUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final deleteCount = await db.delete(
      usersTable,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );

    if (deleteCount != 1) {
      throw CouldNotDeleteUserException();
    }
  }

  /// internal method to return db or throw exception if db is not yet initialized
  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseNotOpenException();
    } else {
      return db;
    }
  }

  /// Close the db
  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseNotOpenException();
    } else {
      await db.close();
      _db = null;
    }
  }

  /// Open the db
  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenedException();
    }

    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;

      await db.execute(createUserTable);
      await db.execute(createNotesTable);
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentDirectoryException();
    }
  }

  // notes functionalities

  /// create a note for an existing user
  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    final db = _getDatabaseOrThrow();

    // ensure user/ owner exists in the db
    final DatabaseUser dbUser = await getUser(email: owner.email);
    if (dbUser != owner) {
      throw UserNotFoundException();
    }

    const text = '';
    // create notes for the owner
    final noteId = await db.insert(notesTable,
        {userIdColumn: owner.id, textColumn: text, isUploadedColumn: 0});

    final note = DatabaseNote(
      id: noteId,
      userId: owner.id,
      text: text,
      isUploaded: false,
    );

    return note;
  }

  /// delete note by id
  Future<void> deleteNote({required int id}) async {
    final db = _getDatabaseOrThrow();
    final deleteCount = await db.delete(
      notesTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (deleteCount == 0) {
      throw CouldNotDeleteTheNoteException();
    }
  }

  /// truncate note table (truncate)
  Future<int> deleteAllNote() async {
    final db = _getDatabaseOrThrow();
    return await db.delete(
      notesTable,
    );
  }

  /// get note by id
  Future<DatabaseNote> getNoteById({required int id}) async {
    final db = _getDatabaseOrThrow();
    final notes = await db.query(notesTable, where: 'id = ?', whereArgs: [id]);
    if (notes.isEmpty) {
      throw CouldNotFindNotesException();
    } else {
      return DatabaseNote.fromRow(notes.first);
    }
  }

  /// get all notes
  Future<Iterable<DatabaseNote>> getAllNotes() async {
    final db = _getDatabaseOrThrow();
    final notes = await db.query(notesTable);
    if (notes.isEmpty) {
      throw CouldNotFindNotesException();
    } else {
      return notes.map((note) => DatabaseNote.fromRow(note));
    }
  }

  Future<DatabaseNote> updateNote({required DatabaseNote note, required String text}) async {
    final db = _getDatabaseOrThrow();
    await getNoteById(id: note.id);
    final updatesCount = await db.update(notesTable, {textColumn: text, isUploadedColumn: 0});

    if(updatesCount == 0) {
      throw CouldNotUpdateNotesException();
    } else {
      return await getNoteById(id: note.id);
    }
  }
}

