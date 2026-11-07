import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:jdonut/core/error/failure.dart';

part 'submit_state.freezed.dart';

/// State of a step's Continue action.
@freezed
abstract class SubmitState with _$SubmitState {
  const factory SubmitState({
    @Default(false) bool isSubmitting,
    Failure? failure,
  }) = _SubmitState;
}
