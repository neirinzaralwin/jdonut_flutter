import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';

@freezed
abstract class User with _$User {
  const factory User({
    required String id,
    required String phone,
    required String firstName,
    required DateTime dateOfBirth,
    String? lastName,
  }) = _User;
}
