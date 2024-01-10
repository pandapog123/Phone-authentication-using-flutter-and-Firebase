import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AuthRoute extends StatefulWidget {
  const AuthRoute({super.key});

  @override
  State<AuthRoute> createState() => _AuthRouteState();
}

class _AuthRouteState extends State<AuthRoute> {
  handleLoginClick() {
    context.go("/auth/login");
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(16.0),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Text(
                    "Phone sign in",
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "This application was built using Flutter and Firebase!",
                    style: theme.textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              FilledButton(
                onPressed: handleLoginClick,
                style: FilledButton.styleFrom(
                  textStyle: theme.textTheme.headlineSmall?.copyWith(),
                  padding: const EdgeInsets.all(16.0),
                  alignment: Alignment.center,
                  minimumSize: const Size.fromHeight(0),
                ),
                child: const Text("Log in"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
