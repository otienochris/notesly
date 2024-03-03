import 'package:flutter/foundation.dart';

const String idColumn = 'id';
const String userIdColumn = 'user_id';
const String textColumn = 'text';
const String isUploadedColumn = 'is_uploaded';

@immutable
class DatabaseNote {
  final int id;
  final int userId;
  final String text;
  final bool isUploaded;

  const DatabaseNote({
    required this.id,
    required this.userId,
    required this.text,
    required this.isUploaded,
  });

  DatabaseNote.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        text = map[textColumn] as String,
        isUploaded = (map[isUploadedColumn] as int) == 1 ? true : false;

  @override
  String toString() =>
      'Notes, ID = $id, userId = $userId, isUploadToCloud = $isUploaded, text = $text';

  @override
  bool operator ==(covariant DatabaseNote other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}
