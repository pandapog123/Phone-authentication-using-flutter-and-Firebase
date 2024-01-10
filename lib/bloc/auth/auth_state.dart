part of 'auth_bloc.dart';

class User extends Equatable {
  const User({
    required this.id,
    this.phoneNumber,
  });

  final String id;
  final String? phoneNumber;

  static const empty = User(id: '');

  bool get isEmpty => this == User.empty;
  bool get isNotEmpty => this != User.empty;

  @override
  List<Object?> get props => [phoneNumber, id];
}
