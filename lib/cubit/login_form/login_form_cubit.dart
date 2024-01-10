import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:phone_auth_firebase/utils/country_phone_codes.dart';
import 'package:phone_number/phone_number.dart';

part 'login_form_state.dart';

class LoginFormCubit extends Cubit<LoginFormState> {
  LoginFormCubit(
      {required CountryCode phoneCode, required this.phoneNumberUtil})
      : super(LoginFormState(phoneCode: phoneCode));

  final PhoneNumberUtil phoneNumberUtil;

  UniqueKey? _changeId;

  setCurrentInput(String newInput) async {
    _changeId = UniqueKey();
    final tempId = _changeId;

    final result = await phoneNumberUtil.validate(newInput,
        regionCode: state.phoneCode.code);

    if (_changeId == tempId) {
      emit(LoginFormState(
        phoneCode: state.phoneCode,
        loading: state.loading,
        currentInput: newInput,
        inputValid: result,
      ));
    }
  }

  setLoading(bool newValue) {
    emit(LoginFormState(
      phoneCode: state.phoneCode,
      currentInput: state.currentInput,
      inputValid: state.inputValid,
      loading: newValue,
    ));
  }

  setCountryCode(CountryCode phoneCode) {
    emit(LoginFormState(
      phoneCode: phoneCode,
    ));
  }
}
