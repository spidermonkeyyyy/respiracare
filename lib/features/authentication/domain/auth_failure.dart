/// Typed authentication failures for Supabase Auth.
///
/// Provides a closed union (sealed class hierarchy) with factory constructors
/// on the sealed class for ergonomic construction (AuthFailure.invalidCredentials()).
/// Subclasses expose [userMessage] for UI display.
library respiracare.features.authentication.domain.auth_failure;

sealed class AuthFailure {
  const AuthFailure();

  /// Human-readable message for the user.
  String get userMessage;

  // Factory constructors for ergonomic usage: AuthFailure.invalidCredentials()
  const factory AuthFailure.invalidCredentials() = InvalidCredentials;
  const factory AuthFailure.emailAlreadyRegistered() = EmailAlreadyRegistered;
  const factory AuthFailure.weakPassword() = WeakPassword;
  const factory AuthFailure.invalidEmailFormat() = InvalidEmailFormat;
  const factory AuthFailure.networkFailure() = NetworkFailure;
  const factory AuthFailure.sessionExpired() = SessionExpired;
  const factory AuthFailure.unknown([String? message]) = UnknownFailure;
}

class InvalidCredentials extends AuthFailure {
  const InvalidCredentials();
  @override
  String get userMessage => "Invalid email or password. Please try again.";
}

class EmailAlreadyRegistered extends AuthFailure {
  const EmailAlreadyRegistered();
  @override
  String get userMessage =>
      "This email is already registered. Please sign in instead.";
}

class WeakPassword extends AuthFailure {
  const WeakPassword();
  @override
  String get userMessage =>
      "Password is too weak. Use at least 8 characters with letters and numbers.";
}

class InvalidEmailFormat extends AuthFailure {
  const InvalidEmailFormat();
  @override
  String get userMessage =>
      "Please enter a valid email address.";
}

class NetworkFailure extends AuthFailure {
  const NetworkFailure();
  @override
  String get userMessage =>
      "Network error. Please check your connection and try again.";
}

class SessionExpired extends AuthFailure {
  const SessionExpired();
  @override
  String get userMessage =>
      "Your session has expired. Please sign in again.";
}

class UnknownFailure extends AuthFailure {
  const UnknownFailure([this.message]);
  final String? message;

  @override
  String get userMessage => message ?? "An unexpected error occurred. Please try again.";
}