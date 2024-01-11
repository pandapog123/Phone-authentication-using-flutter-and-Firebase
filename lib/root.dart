import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:phone_auth_firebase/bloc/auth/auth_bloc.dart';
import 'package:phone_auth_firebase/bloc/auth/auth_repository.dart';
import 'package:phone_auth_firebase/cubit/login_form/login_form_cubit.dart';
import 'package:phone_auth_firebase/cubit/phone_verification/phone_verification_cubit.dart';
import 'package:phone_auth_firebase/routes/auth/login.dart';
import 'package:phone_auth_firebase/routes/auth/main.dart';
import 'package:phone_auth_firebase/routes/auth/verify_code.dart';
import 'package:phone_auth_firebase/routes/home.dart';
import 'package:phone_auth_firebase/utils/country_phone_codes.dart';
import 'package:phone_number/phone_number.dart';

class RootState extends StatelessWidget {
  const RootState({
    required this.authenticationRepository,
    super.key,
  });

  final AuthenticationRepository authenticationRepository;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) {
            return AuthBloc(authenticationRepository: authenticationRepository);
          },
        ),
        RepositoryProvider.value(
          value: authenticationRepository,
        ),
      ],
      child: const RootApp(),
    );
  }
}

class RootApp extends StatelessWidget {
  const RootApp({super.key});

  @override
  Widget build(BuildContext context) {
    final userState = context.watch<AuthBloc>().state;

    final router = GoRouter(
      initialLocation: "/",
      routes: [
        GoRoute(
          path: "/auth",
          routes: [
            ShellRoute(
              pageBuilder: (context, state, child) {
                return CustomTransitionPage(
                  child: MultiBlocProvider(
                    providers: [
                      BlocProvider(
                        create: (context) => PhoneVerificationCubit(),
                      ),
                      BlocProvider(
                        create: (context) => LoginFormCubit(
                          phoneCode: CountryCode(
                            name: "United States",
                            flag: "🇺🇸",
                            code: "US",
                            dialCode: "+1",
                          ),
                          phoneNumberUtil: PhoneNumberUtil(),
                        ),
                      ),
                    ],
                    child: child,
                  ),
                  transitionDuration: Durations.short4,
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                );
              },
              routes: [
                GoRoute(
                  path: "login",
                  pageBuilder: (context, state) {
                    return CustomTransitionPage(
                      child: const LoginRoute(),
                      transitionDuration: Durations.short4,
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        return FadeTransition(
                          opacity: animation,
                          child: child,
                        );
                      },
                    );
                  },
                ),
                GoRoute(
                  path: "verify-code",
                  pageBuilder: (context, state) {
                    return CustomTransitionPage(
                      child: const VerifyCodeRoute(),
                      transitionDuration: Durations.short4,
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        return FadeTransition(
                          opacity: animation,
                          child: child,
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ],
          pageBuilder: (context, state) {
            return CustomTransitionPage(
              child: const AuthRoute(),
              transitionDuration: Durations.short4,
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
            );
          },
          redirect: (context, state) {
            if (userState.isNotEmpty) {
              return "/";
            }
          },
        ),
        GoRoute(
          path: "/",
          pageBuilder: (context, state) {
            return CustomTransitionPage(
              child: const HomeRoute(),
              transitionDuration: Durations.short4,
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
            );
          },
          redirect: (context, state) {
            if (userState.isEmpty) {
              return "/auth";
            }
          },
        ),
      ],
    );

    return MaterialApp.router(
      theme: ThemeData.light(
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark(
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
