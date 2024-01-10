import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:phone_auth_firebase/bloc/auth/auth_bloc.dart';

class PhoneAuthError implements Exception {}

class LogOutError implements Exception {}

class AuthenticationRepository {
  AuthenticationRepository({required firebase_auth.FirebaseAuth firebaseAuth}) {
    _firebaseAuth = firebaseAuth;
  }

  late final firebase_auth.FirebaseAuth _firebaseAuth;

  Stream<User> get user {
    return _firebaseAuth.authStateChanges().map((firebaseUser) {
      final user = firebaseUser == null ? User.empty : firebaseUser.toUser;

      return user;
    });
  }

  Future<void> phoneSignIn(
    String phoneNumber, {
    required void Function(String, int?) codeSent,
    required void Function(firebase_auth.FirebaseAuthException)
        verificationFailed,
  }) async {
    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (credential) async {
          await _firebaseAuth.signInWithCredential(credential);
        },
        verificationFailed: (error) {
          verificationFailed(error);
        },
        codeSent: (verificationId, resendToken) {
          codeSent(verificationId, resendToken);
        },
        codeAutoRetrievalTimeout: (_) {},
      );
    } catch (error) {
      throw PhoneAuthError();
    }
  }

  Future<void> logOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (error) {
      throw LogOutError();
    }
  }
}

extension on firebase_auth.User {
  User get toUser {
    return User(id: uid, phoneNumber: phoneNumber);
  }
}
