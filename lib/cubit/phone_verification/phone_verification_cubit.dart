import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'phone_verification_state.dart';

class PhoneVerificationCubit extends Cubit<PhoneVerificationState> {
  PhoneVerificationCubit() : super(const PhoneVerificationStateEmpty());

  void erase() {
    emit(const PhoneVerificationStateEmpty());
  }

  void setVerification(PhoneVerificationStateSent data) {
    emit(data);
  }
}
