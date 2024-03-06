import 'dart:async';
import 'dart:developer';

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

  List<DatabaseNote> _notes = [];

  // singleton
  NotesService._shareInstance() {
    _notesStreamController =
        StreamController<List<DatabaseNote>>.broadcast(onListen: () {
      _notesStreamController.sink.add(_notes);
    });
  }

  static final NotesService _shared = NotesService._shareInstance();

  factory NotesService() => _shared;

  late final StreamController<List<DatabaseNote>> _notesStreamController;

  Stream<List<DatabaseNote>> get allNotes => _notesStreamController.stream;

  Future<void> _cacheNotes() async {
    final allNotes = await getAllNotes();
    _notes = allNotes.toList();
    _notesStreamController.add(_notes);
  }

  /// retrieve a user from db by email
  Future<DatabaseUser> getUser({required String email}) async {
    await _ensureDbIsOpen();
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
    await _ensureDbIsOpen();
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
    await _ensureDbIsOpen();
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

      // create user table
      await db.execute(createUserTable);
      // create notes table
      await db.execute(createNotesTable);

      await _cacheNotes();
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentDirectoryException();
    }
  }

  // notes functionalities

  /// create a note for an existing user
  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    await _ensureDbIsOpen();
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

    // add note to cache
    _notes.add(note);
    _notesStreamController.add(_notes);

    return note;
  }

  /// delete note by id
  Future<void> deleteNote({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deleteCount = await db.delete(
      notesTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (deleteCount == 0) {
      throw CouldNotDeleteTheNoteException();
    } else {
      _notes.removeWhere((note) => note.id == id);
      _notesStreamController.add(_notes);
    }
  }

  /// truncate note table (truncate)
  Future<int> deleteAllNote() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletionCount = await db.delete(
      notesTable,
    );

    _notes = [];
    _notesStreamController.add(_notes);
    return deletionCount;
  }

  /// get note by id
  Future<DatabaseNote> getNoteById({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final notes = await db.query(notesTable, where: 'id = ?', whereArgs: [id]);
    if (notes.isEmpty) {
      throw CouldNotFindNotesException();
    } else {
      final note = DatabaseNote.fromRow(notes.first);
      _notes.removeWhere((it) => it.id == id);
      _notes.add(note);
      _notesStreamController.add(_notes);
      return note;
    }
  }

  /// get all notes from the database
  Future<Iterable<DatabaseNote>> getAllNotes() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final notes = await db.query(notesTable);
    if (notes.isEmpty) {
      throw CouldNotFindNotesException();
    } else {
      log('Found ${notes.length} notes');

      return notes.map((note) {
        log(note.toString());
        var databaseNote = DatabaseNote.fromRow(note);
        log(databaseNote.text);
        return databaseNote;
      });
    }
  }

  /// update notes
  Future<DatabaseNote> updateNote(
      {required DatabaseNote note, required String text}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    await getNoteById(id: note.id);
    final updatesCount = await db.update(
      notesTable,
      {textColumn: text, isUploadedColumn: 0},
      where: 'id = ?',
      whereArgs: [note.id],
    );

    if (updatesCount == 0) {
      throw CouldNotUpdateNotesException();
    } else {
      final updatedNote = await getNoteById(id: note.id);
      _notes.removeWhere((it) => it.id == updatedNote.id);
      _notes.add(updatedNote);
      _notesStreamController.add(_notes);
      return updatedNote;
    }
  }

  /// Get or create a user that already exists in auth provider
  Future<DatabaseUser> getOrCreateUser({required String email}) async {
    try {
      return await getUser(email: email);
    } on UserNotFoundException {
      return await createUser(email: email);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _ensureDbIsOpen() async {
    try {
      await open();
    } on DatabaseAlreadyOpenedException {
      // empty
    }
  }
}
