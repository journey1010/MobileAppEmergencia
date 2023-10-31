import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:app_emergen/services/authenticate.dart';

part 'reset_password_state.dart';

class ResetPasswordCubit extends Cubit<ResetPasswordState> {
  final UserAuthentication _userAuthentication = UserAuthentication();

  ResetPasswordCubit() : super(ResetPasswordInitial());

  resetPassword(String email) async {
    try {
      await _userAuthentication.resetPassword(email);
      emit(ResetPasswordDone());
    } catch (error) {
      emit(ResetPasswordFailureState(errorMessage: error.toString()));
    }
  }

  checkValidField(GlobalKey<FormState> key) {
    if (key.currentState?.validate() ?? false) {
      key.currentState!.save();
      emit(ValidResetPasswordField());
    } else {
      emit(ResetPasswordFailureState(errorMessage: 'Invalid email address.'));
    }
  }
}
