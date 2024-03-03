import 'package:flutter/foundation.dart';

const idColumn = 'id';
const emailColumn = 'email';

@immutable
class DatabaseUser {
  final int id;
  final String email;

  const DatabaseUser({
    required this.id,
    required this.email,
  });

  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;

  @override
  String toString() => 'Person, ID =$id, email = $email';

  @override
  bool operator ==(covariant DatabaseUser other) =>
      email == other.email && id == other.id;

  @override
  int get hashCode => id.hashCode + email.hashCode;
}
