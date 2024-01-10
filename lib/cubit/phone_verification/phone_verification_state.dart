part of 'phone_verification_cubit.dart';

sealed class PhoneVerificationState extends Equatable {
  const PhoneVerificationState({
    this.verificationId,
    this.resendToken,
  });

  final String? verificationId;
  final int? resendToken;

  bool get isEmpty;
  bool get isNotEmpty => !isEmpty;

  @override
  List<Object?> get props => [verificationId, resendToken];
}

final class PhoneVerificationStateEmpty extends PhoneVerificationState {
  const PhoneVerificationStateEmpty();

  @override
  bool get isEmpty => true;
}

final class PhoneVerificationStateSent extends PhoneVerificationState {
  const PhoneVerificationStateSent({
    required this.verificationId,
    this.resendToken,
  });

  @override
  final String verificationId;

  @override
  final int? resendToken;

  @override
  bool get isEmpty => false;
}
