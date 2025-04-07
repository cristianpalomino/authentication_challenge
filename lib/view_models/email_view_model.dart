import 'package:authentication_challenge/models/email_state.dart';
import 'package:authentication_challenge/repositories/repository.dart';
import 'package:authentication_challenge/utils/validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:authentication_challenge/providers.dart';
import 'package:cloud_functions/cloud_functions.dart';

class EmailViewModel extends StateNotifier<EmailState> {
  final Ref _ref;
  final Validator _validator;
  final AuthRepository _authRepository;

  EmailViewModel(this._ref, this._validator, this._authRepository)
      : super(const EmailState());

  void setEmail(String email) {
    final String? emailError = _validator.validateEmail(email);
    state = state.copyWith(
      email: email,
      isValid: emailError == null,
      error: emailError,
      clearSuccessMessage: true,
    );
  }

  void setCode(String code) {
    final String? codeError = _validator.validateCode(code);
    state = state.copyWith(
      code: code,
      isCodeValid: codeError == null,
      codeError: codeError,
    );
  }

  Future<void> sendVerificationCode() async {
    if (!state.isValid || state.isLoading) return;
    state =
        state.copyWith(isLoading: true, error: null, clearSuccessMessage: true);

    try {
      final responseData = await _authRepository.sendAuthCode(state.email);

      final verificationId = responseData?['verification_id'] as String?;
      final message = responseData?['message'] as String?;

      if (verificationId != null) {
        print(
            'Email: ${state.email}, Verification ID received: $verificationId, Message: $message');
        _ref.read(verificationIdProvider.notifier).state = verificationId;
        state = state.copyWith(isLoading: false, successMessage: message);
      } else {
        print('Error: Verification ID missing or invalid in response');
        state = state.copyWith(
            isLoading: false, error: 'Failed to get verification ID.');
      }
    } on FirebaseFunctionsException catch (e) {
      print('FirebaseFunctionsException sending code: ${e.code} ${e.message}');
      state = state.copyWith(
          isLoading: false,
          error: e.message ?? 'Failed to send code. Please try again.');
    } catch (e) {
      print('Error sending verification code: $e');
      state = state.copyWith(
          isLoading: false, error: 'An unexpected error occurred.');
    }
  }

  void clearSuccessMessage() {
    if (state.successMessage != null) {
      state = state.copyWith(clearSuccessMessage: true);
    }
  }

  Future<void> cancelVerification() async {
    final verificationId = _ref.read(verificationIdProvider);
    if (verificationId == null) {
      print('No verification ID found to cancel.');
      return;
    }

    state = state.copyWith(
        isLoading: true,
        error: null,
        codeError: null,
        clearSuccessMessage: true);
    print('Attempting to cancel verification ID: $verificationId');

    try {
      await _authRepository.deleteAuthCode(verificationId);

      print('Successfully cancelled verification ID: $verificationId');
      _ref.read(verificationIdProvider.notifier).state = null;
      state = state.copyWith(isLoading: false, code: '', isCodeValid: false);
    } on FirebaseFunctionsException catch (e) {
      print(
          'FirebaseFunctionsException cancelling verification: ${e.code} ${e.message}');
      state = state.copyWith(
          isLoading: false,
          error: e.message ?? 'Failed to cancel verification.');
    } catch (e) {
      print('Error cancelling verification: $e');
      state = state.copyWith(
          isLoading: false,
          error: 'An unexpected error occurred during cancellation.');
    }
  }

  Future<void> verifyCode(BuildContext context) async {
    final verificationId = _ref.read(verificationIdProvider);
    if (!state.isCodeValid || state.isLoading || verificationId == null) {
      print(
          'Verification prerequisites not met: isCodeValid=${state.isCodeValid}, isLoading=${state.isLoading}, verificationId=$verificationId');
      return;
    }

    state = state.copyWith(isLoading: true, codeError: null, error: null);
    print('Attempting to verify code: ${state.code} with ID: $verificationId');

    try {
      final responseData =
          await _authRepository.verifyAuthCode(verificationId, state.code);

      final status = responseData?['status'] as String?;
      final userId = responseData?['user_id'] as String?;
      final message =
          responseData?['message'] as String? ?? 'Code verified successfully!';

      if (status == 'success' && userId != null) {
        print('Successfully verified code for user ID: $userId');
        _ref.read(verificationIdProvider.notifier).state = null;
        state = state.copyWith(
          isLoading: false,
          isVerified: true,
          successMessage: message,
          code: '',
          isCodeValid: false,
        );
      } else {
        final errorMessage =
            responseData?['message'] as String? ?? 'Code verification failed.';
        print('Error: Code verification failed. Message: $errorMessage');
        state = state.copyWith(isLoading: false, codeError: errorMessage);
      }
    } on FirebaseFunctionsException catch (e) {
      print(
          'FirebaseFunctionsException verifying code: ${e.code} ${e.message}');
      state = state.copyWith(
          isLoading: false,
          codeError: 'Failed to verify code. Please try again.');
    } catch (e) {
      print('Error verifying code: $e');
      state = state.copyWith(
          isLoading: false,
          error: 'An unexpected error occurred during verification.');
    }
  }
}
