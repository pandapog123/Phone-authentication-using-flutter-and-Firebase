import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:phone_auth_firebase/bloc/auth/auth_repository.dart';
import 'package:phone_auth_firebase/cubit/login_form/login_form_cubit.dart';
import 'package:phone_auth_firebase/cubit/phone_verification/phone_verification_cubit.dart';
import 'package:phone_auth_firebase/widgets/otp_input.dart';

class VerifyCodeRoute extends StatefulWidget {
  const VerifyCodeRoute({super.key});

  @override
  State<VerifyCodeRoute> createState() => _VerifyCodeRouteState();
}

class _VerifyCodeRouteState extends State<VerifyCodeRoute> {
  late VerifyCodeRouteState state;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  verifyCode() async {
    final loginFormCubit = context.read<LoginFormCubit>();
    final loginFormState = loginFormCubit.state;

    if (!loginFormState.inputValid || state.currentInput.length != 6) {
      return;
    }

    final phoneVerificationCubit = context.read<PhoneVerificationCubit>();
    final phoneVerificationState = phoneVerificationCubit.state;

    if (phoneVerificationState.isEmpty ||
        phoneVerificationState.verificationId == null) {
      return;
    }

    final authRepository = context.read<AuthenticationRepository>();

    setState(() {
      state.setLoading(true);
    });

    try {
      await authRepository.verifyCode(
        verificationId: phoneVerificationState.verificationId!,
        smsCode: state.currentInput,
      );

      setState(() {
        state.setLoading(false);
      });
    } on FirebaseAuthException catch (error) {
      if (scaffoldKey.currentContext != null) {
        SnackBar snackBar = SnackBar(
          content: Text(error.message ??
              "An error occured with the phone authentication"),
        );

        ScaffoldMessenger.of(scaffoldKey.currentContext!)
            .showSnackBar(snackBar);
      }

      setState(() {
        state.setLoading(false);
      });
    } on Exception catch (_) {
      if (scaffoldKey.currentContext != null) {
        SnackBar snackBar = const SnackBar(
          content: Text("An error occured with the phone authentication"),
        );

        ScaffoldMessenger.of(scaffoldKey.currentContext!)
            .showSnackBar(snackBar);
      }

      setState(() {
        state.setLoading(false);
      });
    }
  }

  Widget adaptiveAction(
      {required BuildContext context,
      required VoidCallback onPressed,
      required Widget child,
      bool? primary}) {
    final ThemeData theme = Theme.of(context);
    if (primary == true) {
      switch (theme.platform) {
        case TargetPlatform.iOS:
          return CupertinoButton(onPressed: onPressed, child: child);
        default:
          return TextButton(onPressed: onPressed, child: child);
      }
    }

    switch (theme.platform) {
      case TargetPlatform.iOS:
        return CupertinoButton(onPressed: onPressed, child: child);
      default:
        return TextButton(onPressed: onPressed, child: child);
    }
  }

  routeBack() {
    if (scaffoldKey.currentContext == null) {
      return;
    }

    showDialog<void>(
      context: scaffoldKey.currentContext!,
      builder: (BuildContext context) {
        final theme = Theme.of(context);

        return AlertDialog.adaptive(
          title: const Text('Want to go back?'),
          content: const Text(
              "If you go back the code we've sent you will be invalid."),
          actions: [
            adaptiveAction(
              context: context,
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "Cancel",
                style: theme.textTheme.titleMedium,
              ),
            ),
            adaptiveAction(
              context: context,
              onPressed: () {
                Navigator.of(context).pop();
                context.pop();
              },
              child: Text(
                "Go back",
                style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary),
              ),
              primary: true,
            ),
            // TextButton(
            //   style: TextButton.styleFrom(
            //     textStyle: Theme.of(context).textTheme.labelLarge,
            //   ),
            //   child: const Text('Cancel'),
            //   onPressed: () {
            //     Navigator.of(context).pop();
            //   },
            // ),
            // FilledButton(
            //   style: FilledButton.styleFrom(
            //     textStyle: Theme.of(context).textTheme.labelLarge,
            //   ),
            //   child: const Text('Go back'),
            //   onPressed: () {
            //     context.pop();
            //   },
            // ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    state = VerifyCodeRouteState();
  }

  @override
  Widget build(BuildContext context) {
    final loginFormCubit = context.watch<LoginFormCubit>();
    final loginFormState = loginFormCubit.state;

    final theme = Theme.of(context);

    if (!loginFormState.inputValid) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Invalid Phone number", style: theme.textTheme.titleLarge),
            ],
          ),
        ),
      );
    }

    final phoneNumber =
        "${loginFormState.phoneCode.dialCode} ${loginFormState.currentInput}";

    return Scaffold(
      key: scaffoldKey,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Enter the code",
                style: theme.textTheme.displaySmall
                    ?.copyWith(fontWeight: FontWeight.bold, height: 1.2),
              ),
              const SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Enter the code we sent to ",
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  Text(
                    phoneNumber,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              OTPInput(
                disabled: state.loading,
                onInput: (value) {
                  setState(() {
                    state.setCurrentInput(value);
                  });
                },
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: !state.loading && state.currentInput.length == 6
                    ? verifyCode
                    : null,
                style: FilledButton.styleFrom(
                  textStyle: theme.textTheme.titleLarge?.copyWith(),
                  padding: const EdgeInsets.all(12.0),
                  alignment: Alignment.center,
                  minimumSize: const Size.fromHeight(0),
                ),
                child: state.loading
                    ? const CircularProgressIndicator.adaptive()
                    : const Text("Verify code"),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: state.loading ? null : routeBack,
        disabledElevation: 0,
        backgroundColor: state.loading
            ? theme.colorScheme.outlineVariant
            : theme.colorScheme.primaryContainer,
        child: state.loading
            ? const CircularProgressIndicator.adaptive()
            : const Icon(Icons.arrow_back),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startDocked,
    );
  }
}

class VerifyCodeRouteState {
  bool _loading = false;
  String _currentInput = "";

  bool get loading => _loading;
  String get currentInput => _currentInput;

  setLoading(bool newLoading) {
    _loading = newLoading;
  }

  setCurrentInput(String newInput) {
    _currentInput = newInput;
  }
}
