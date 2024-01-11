import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:phone_auth_firebase/bloc/auth/auth_repository.dart';
import 'package:phone_auth_firebase/cubit/login_form/login_form_cubit.dart';
import 'package:phone_auth_firebase/cubit/phone_verification/phone_verification_cubit.dart';
import 'package:phone_auth_firebase/utils/country_phone_codes.dart';
import 'package:phone_number/phone_number.dart';

class LoginRoute extends StatefulWidget {
  const LoginRoute({super.key});

  @override
  State<LoginRoute> createState() => _LoginRouteState();
}

class _LoginRouteState extends State<LoginRoute> {
  late LoginRouteState state;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  CountryCode? tempCode;

  routeBack() {
    context.go("/auth");
  }

  changeCountryCode() {
    if (scaffoldKey.currentContext == null) {
      return;
    }

    showModalBottomSheet(
      context: scaffoldKey.currentContext!,
      isScrollControlled: true,
      useSafeArea: true,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      showDragHandle: true,
      builder: (context) {
        return CountryCodeBottomSheet(
          onSelect: (countryCode) {
            context.read<LoginFormCubit>().setCountryCode(countryCode);

            setState(() {
              state.dispose();
              state.setCountryCode(countryCode);
            });
          },
        );
      },
    );
  }

  submitPhoneNumber() async {
    if (context.read<LoginFormCubit>().state.loading ||
        !context.read<LoginFormCubit>().state.inputValid) {
      return;
    }

    context.read<LoginFormCubit>().setLoading(true);

    try {
      final authenticationRepository = context.read<AuthenticationRepository>();
      final loginFormState = context.read<LoginFormCubit>().state;

      await authenticationRepository.phoneSignIn(
          "${loginFormState.phoneCode.dialCode} ${loginFormState.currentInput}",
          codeSent: (verificationId, resendToken) async {
        context
            .read<PhoneVerificationCubit>()
            .setVerification(PhoneVerificationStateSent(
              verificationId: verificationId,
              resendToken: resendToken,
            ));

        context.push("/auth/verify-code");

        context.read<LoginFormCubit>().setLoading(false);
      }, verificationFailed: (error) {
        if (scaffoldKey.currentContext != null) {
          SnackBar snackBar = SnackBar(
            content: Text(error.message ??
                "An error occured with the phone authentication"),
          );

          ScaffoldMessenger.of(scaffoldKey.currentContext!)
              .showSnackBar(snackBar);
        }

        context.read<LoginFormCubit>().setLoading(false);
      });
    } on PhoneAuthError catch (error) {
      if (scaffoldKey.currentContext != null) {
        const SnackBar snackBar = SnackBar(
          content: Text("An error occured with the phone authentication"),
        );

        ScaffoldMessenger.of(scaffoldKey.currentContext!)
            .showSnackBar(snackBar);
      }
    } on Exception catch (error) {
      if (scaffoldKey.currentContext != null) {
        const SnackBar snackBar = SnackBar(
          content: Text("Unknown error occured"),
        );

        ScaffoldMessenger.of(scaffoldKey.currentContext!)
            .showSnackBar(snackBar);
      }
    }
  }

  @override
  void initState() {
    super.initState();

    state = LoginRouteState(
      phoneNumberUtil: PhoneNumberUtil(),
      regionCode: context.read<LoginFormCubit>().state.phoneCode.code,
      changeCallback: () async {
        await context.read<LoginFormCubit>().setCurrentInput(
              state.phoneNumberEditingController.text,
            );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loginFormCubit = context.watch<LoginFormCubit>();
    final loginFormState = loginFormCubit.state;

    return Scaffold(
      key: scaffoldKey,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Enter your phone number",
                style: theme.textTheme.displaySmall
                    ?.copyWith(fontWeight: FontWeight.bold, height: 1.2),
              ),
              const SizedBox(height: 8),
              Text(
                "We'll send you a code to verify your phone number",
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Column(
                    children: [
                      InkWell(
                        onTap:
                            loginFormState.loading ? null : changeCountryCode,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.only(
                            top: 10,
                            bottom: 10,
                            right: 12,
                            left: 4,
                          ),
                          decoration: BoxDecoration(
                            color: loginFormState.loading
                                ? theme.colorScheme.outlineVariant
                                : null,
                            border: Border.all(
                              width: 1,
                              color: theme.colorScheme.outlineVariant,
                            ),
                            borderRadius: BorderRadiusDirectional.circular(8),
                          ),
                          child: Row(children: [
                            const Icon(Icons.arrow_drop_down),
                            Text(
                              loginFormState.phoneCode.flag,
                              style: theme.textTheme.headlineMedium,
                            ),
                          ]),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      autofocus: true,
                      keyboardType: TextInputType.phone,
                      controller: state.phoneNumberEditingController,
                      style: theme.textTheme.titleMedium,
                      enabled: !loginFormState.loading,
                      autofillHints: const [
                        AutofillHints.telephoneNumber,
                      ],
                      decoration: InputDecoration(
                        prefix: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                            loginFormState.phoneCode.dialCode,
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                        hintText: "123-456-7890",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        contentPadding: const EdgeInsets.all(16.0),
                        filled: true,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: loginFormState.inputValid && !loginFormState.loading
                    ? submitPhoneNumber
                    : null,
                style: FilledButton.styleFrom(
                  textStyle: theme.textTheme.titleLarge?.copyWith(),
                  padding: const EdgeInsets.all(12.0),
                  alignment: Alignment.center,
                  minimumSize: const Size.fromHeight(0),
                ),
                child: loginFormState.loading
                    ? const CircularProgressIndicator.adaptive()
                    : const Text("Send code"),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: loginFormState.loading ? null : routeBack,
        disabledElevation: 0,
        backgroundColor: loginFormState.loading
            ? theme.colorScheme.outlineVariant
            : theme.colorScheme.primaryContainer,
        child: loginFormState.loading
            ? const CircularProgressIndicator.adaptive()
            : const Icon(Icons.arrow_back),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startDocked,
    );
  }
}

class CountryCodeBottomSheet extends StatefulWidget {
  final Function(CountryCode) onSelect;

  const CountryCodeBottomSheet({
    required this.onSelect,
    super.key,
  });

  @override
  State<CountryCodeBottomSheet> createState() => _CountryCodeBottomSheetState();
}

class _CountryCodeBottomSheetState extends State<CountryCodeBottomSheet> {
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final filteredCountryList = parsedCountryPhoneCodes.where((code) {
      final codeContainsQuery =
          code.code.toLowerCase().contains(searchQuery.toLowerCase());
      final dialCodeContainsQuery =
          code.dialCode.toLowerCase().contains(searchQuery.toLowerCase());
      final nameContainsQuery =
          code.name.toLowerCase().contains(searchQuery.toLowerCase());

      return codeContainsQuery || dialCodeContainsQuery || nameContainsQuery;
    });

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: Container(),
        actions: [
          IconButton(
            onPressed: Navigator.of(context).pop,
            icon: const Icon(Icons.close),
          ),
        ],
        title: const Text("Choose a country"),
        elevation: 1,
        scrolledUnderElevation: 1,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SearchBar(
              textStyle: MaterialStatePropertyAll(theme.textTheme.titleMedium),
              leading: const Icon(Icons.search),
              padding:
                  const MaterialStatePropertyAll(EdgeInsets.only(left: 16)),
              hintText: "Search for a country",
              elevation: const MaterialStatePropertyAll(10),
              shadowColor: const MaterialStatePropertyAll(Colors.transparent),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
        ),
      ),
      body: ListView.separated(
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              widget.onSelect(filteredCountryList.elementAt(index));
              Navigator.of(context).pop();
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          filteredCountryList.elementAt(index).flag,
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            filteredCountryList.elementAt(index).name,
                            style: theme.textTheme.titleMedium,
                            overflow: TextOverflow.fade,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    filteredCountryList.elementAt(index).dialCode,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        separatorBuilder: (context, index) {
          return const Divider(height: 1);
        },
        itemCount: filteredCountryList.length,
      ),
    );
  }
}

class LoginRouteState {
  LoginRouteState({
    required this.changeCallback,
    required this.phoneNumberUtil,
    required String regionCode,
  }) {
    _phoneNumberEditingController = PhoneNumberEditingController(
      phoneNumberUtil,
      regionCode: regionCode,
      behavior: PhoneInputBehavior.strict,
    );

    _phoneNumberEditingController.addListener(changeCallback);
  }

  PhoneNumberUtil phoneNumberUtil;
  Function() changeCallback;

  late PhoneNumberEditingController _phoneNumberEditingController;

  PhoneNumberEditingController get phoneNumberEditingController =>
      _phoneNumberEditingController;

  setCountryCode(CountryCode countryCode) {
    _phoneNumberEditingController = PhoneNumberEditingController(
      phoneNumberUtil,
      regionCode: countryCode.code,
      behavior: PhoneInputBehavior.strict,
    );

    _phoneNumberEditingController.addListener(changeCallback);
  }

  dispose() {
    _phoneNumberEditingController.dispose();
  }
}
