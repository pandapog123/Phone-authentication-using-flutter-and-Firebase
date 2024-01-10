import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phone_auth_firebase/bloc/auth/auth_repository.dart';
import 'package:phone_auth_firebase/firebase_options.dart';
import 'package:phone_auth_firebase/root.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final firebaseAuth = FirebaseAuth.instance;

  final authenticationRepository =
      AuthenticationRepository(firebaseAuth: firebaseAuth);

  runApp(RootState(
    authenticationRepository: authenticationRepository,
  ));
}
