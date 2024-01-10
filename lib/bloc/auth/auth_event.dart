part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {
  const AuthEvent();
}

final class AuthLogOutRequested extends AuthEvent {
  const AuthLogOutRequested();
}

final class AuthUserChanged extends AuthEvent {
  const AuthUserChanged(this.user);

  final User user;
}
