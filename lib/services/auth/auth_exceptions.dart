// login exceptions
class UserNotFoundAuthException implements Exception {}
class InvalidCredentialsAuthException implements Exception {}


// register exceptions
class WeakPasswordAuthException implements Exception {}
class EmailAlreadyInUseAuthException implements Exception {}
class InvalidEmailAuthException implements Exception {}

// generic exception
class GenericAuthException implements Exception {}
class UserNotLoggedInAuthException implements Exception {}

