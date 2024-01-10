import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import "package:equatable/equatable.dart";
import 'package:phone_auth_firebase/bloc/auth/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, User> {
  AuthBloc({required AuthenticationRepository authenticationRepository})
      : super(User.empty) {
    _authenticationRepository = authenticationRepository;

    on<AuthUserChanged>(_onUserChanged);

    on<AuthLogOutRequested>(_onLogoutRequested);

    _userSubscription = authenticationRepository.user.listen(
      (user) => add(AuthUserChanged(user)),
    );
  }

  late final AuthenticationRepository _authenticationRepository;
  late final StreamSubscription<User> _userSubscription;

  void _onUserChanged(AuthUserChanged event, Emitter<User> emit) {
    emit(event.user);
  }

  void _onLogoutRequested(AuthLogOutRequested event, Emitter<User> emit) {
    unawaited(_authenticationRepository.logOut());
  }

  @override
  Future<void> close() {
    _userSubscription.cancel();
    return super.close();
  }
}
