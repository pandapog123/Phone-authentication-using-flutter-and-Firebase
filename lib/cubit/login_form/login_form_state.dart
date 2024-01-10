part of 'login_form_cubit.dart';

class LoginFormState extends Equatable {
  const LoginFormState({
    required this.phoneCode,
    this.currentInput = "",
    this.loading = false,
    this.inputValid = false,
  });

  final CountryCode phoneCode;
  final String currentInput;
  final bool loading;
  final bool inputValid;

  @override
  List<Object?> get props => [
        phoneCode,
        currentInput,
        loading,
        inputValid,
      ];
}
