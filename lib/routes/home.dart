import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phone_auth_firebase/bloc/auth/auth_bloc.dart';
import 'package:phone_auth_firebase/bloc/auth/auth_repository.dart';

class HomeRoute extends StatefulWidget {
  const HomeRoute({super.key});

  @override
  State<HomeRoute> createState() => _HomeRouteState();
}

class _HomeRouteState extends State<HomeRoute> {
  @override
  Widget build(BuildContext context) {
    final authBloc = context.watch<AuthBloc>();
    final userState = authBloc.state;

    if (userState.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text("You are not signed in."),
        ),
      );
    }

    final theme = Theme.of(context);
    final authRepository = context.watch<AuthenticationRepository>();

    return Scaffold(
      body: SafeArea(
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("ID: ${userState.id}",
                      style: theme.textTheme.titleMedium),
                  Text("Phone number: ${userState.phoneNumber}",
                      style: theme.textTheme.titleMedium),
                  const SizedBox(height: 32),
                ],
              ),
              FilledButton(
                onPressed: authRepository.logOut,
                style: FilledButton.styleFrom(
                  textStyle: theme.textTheme.titleLarge?.copyWith(),
                  padding: const EdgeInsets.all(12.0),
                  alignment: Alignment.center,
                  minimumSize: const Size.fromHeight(0),
                  backgroundColor: theme.colorScheme.error,
                ),
                child: const Text("Log out"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
