import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:phone_auth_firebase/cubit/login_form/login_form_cubit.dart';
import 'package:phone_auth_firebase/widgets/otp_input.dart';

class VerifyCodeRoute extends StatefulWidget {
  const VerifyCodeRoute({super.key});

  @override
  State<VerifyCodeRoute> createState() => _VerifyCodeRouteState();
}

class _VerifyCodeRouteState extends State<VerifyCodeRoute> {
  late VerifyCodeRouteState state;

  verifyCode() {}

  routeBack() {
    context.pop();
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

    final phoneNumber =
        "${loginFormState.phoneCode.dialCode} ${loginFormState.currentInput}";

    final theme = Theme.of(context);

    return Scaffold(
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
              OTPInput(onInput: (_) {}),
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

  bool get loading => _loading;

  setLoading(newLoading) {
    _loading = newLoading;
  }
}
