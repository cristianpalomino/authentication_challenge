import 'package:authentication_challenge/providers.dart';
import 'package:authentication_challenge/repositories/repository.dart';
import 'package:authentication_challenge/utils/validators.dart';
import 'package:authentication_challenge/view_models/email_view_model.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter/material.dart';

import 'email_view_model_test.mocks.dart';

@GenerateMocks([Validator, AuthRepository])
void main() {
  late MockValidator mockValidator;
  late MockAuthRepository mockAuthRepository;
  late ProviderContainer container;
  late EmailViewModel viewModel;

  setUp(() {
    mockValidator = MockValidator();
    mockAuthRepository = MockAuthRepository();

    container = ProviderContainer(
      overrides: [
        validatorProvider.overrideWithValue(mockValidator),
        authRepositoryProvider.overrideWithValue(mockAuthRepository),
        verificationIdProvider.overrideWith((ref) => null),
      ],
    );

    viewModel = container.read(emailViewModelProvider.notifier);
  });

  tearDown(() {
    container.dispose();
  });

  group('EmailViewModel Tests', () {
    const testEmail = 'test@example.com';
    const testCode = '123456';
    const testVerificationId = 'test-verification-id';
    const testUserId = 'test-user-id';

    test('setEmail updates state correctly with valid email', () {
      when(mockValidator.validateEmail(testEmail)).thenReturn(null);

      viewModel.setEmail(testEmail);

      final state = container.read(emailViewModelProvider);
      expect(state.email, testEmail);
      expect(state.isValid, true);
      expect(state.error, null);
      verify(mockValidator.validateEmail(testEmail)).called(1);
    });

    test('setEmail updates state correctly with invalid email', () {
      const invalidEmail = 'invalid-email';
      const errorMessage = 'Invalid email format';
      when(mockValidator.validateEmail(invalidEmail)).thenReturn(errorMessage);

      viewModel.setEmail(invalidEmail);

      final state = container.read(emailViewModelProvider);
      expect(state.email, invalidEmail);
      expect(state.isValid, false);
      expect(state.error, errorMessage);
      verify(mockValidator.validateEmail(invalidEmail)).called(1);
    });

    test('setCode updates state correctly with valid code', () {
      when(mockValidator.validateCode(testCode)).thenReturn(null);

      viewModel.setCode(testCode);

      final state = container.read(emailViewModelProvider);
      expect(state.code, testCode);
      expect(state.isCodeValid, true);
      expect(state.codeError, null);
      verify(mockValidator.validateCode(testCode)).called(1);
    });

    test('setCode updates state correctly with invalid code', () {
      const invalidCode = '123';
      const errorMessage = 'Code must be 6 numeric digits';
      when(mockValidator.validateCode(invalidCode)).thenReturn(errorMessage);

      viewModel.setCode(invalidCode);

      final state = container.read(emailViewModelProvider);
      expect(state.code, invalidCode);
      expect(state.isCodeValid, false);
      expect(state.codeError, errorMessage);
      verify(mockValidator.validateCode(invalidCode)).called(1);
    });

    test(
        'sendVerificationCode success updates state and verificationIdProvider',
        () async {
      when(mockValidator.validateEmail(testEmail)).thenReturn(null);
      viewModel.setEmail(testEmail);
      final response = {
        'verification_id': testVerificationId,
        'message': 'Code sent!'
      };
      when(mockAuthRepository.sendAuthCode(testEmail))
          .thenAnswer((_) async => response);

      await viewModel.sendVerificationCode();

      final state = container.read(emailViewModelProvider);
      expect(state.isLoading, false);
      expect(state.successMessage, 'Code sent!');
      expect(state.error, null);
      expect(container.read(verificationIdProvider), testVerificationId);
      verify(mockAuthRepository.sendAuthCode(testEmail)).called(1);
    });

    test('sendVerificationCode handles missing verification_id', () async {
      when(mockValidator.validateEmail(testEmail)).thenReturn(null);
      viewModel.setEmail(testEmail);
      final response = {'message': 'Something went wrong'};
      when(mockAuthRepository.sendAuthCode(testEmail))
          .thenAnswer((_) async => response);

      await viewModel.sendVerificationCode();

      final state = container.read(emailViewModelProvider);
      expect(state.isLoading, false);
      expect(state.error, 'Failed to get verification ID.');
      expect(state.successMessage, null);
      expect(container.read(verificationIdProvider), null);
      verify(mockAuthRepository.sendAuthCode(testEmail)).called(1);
    });

    test('sendVerificationCode handles FirebaseFunctionsException', () async {
      when(mockValidator.validateEmail(testEmail)).thenReturn(null);
      viewModel.setEmail(testEmail);
      final exception = FirebaseFunctionsException(
          message: 'Network error', code: 'unavailable');
      when(mockAuthRepository.sendAuthCode(testEmail)).thenThrow(exception);

      await viewModel.sendVerificationCode();

      final state = container.read(emailViewModelProvider);
      expect(state.isLoading, false);
      expect(state.error, 'Network error');
      expect(state.successMessage, null);
      expect(container.read(verificationIdProvider), null);
      verify(mockAuthRepository.sendAuthCode(testEmail)).called(1);
    });

    test('sendVerificationCode handles generic Exception', () async {
      when(mockValidator.validateEmail(testEmail)).thenReturn(null);
      viewModel.setEmail(testEmail);
      final exception = Exception('Something broke');
      when(mockAuthRepository.sendAuthCode(testEmail)).thenThrow(exception);

      await viewModel.sendVerificationCode();

      final state = container.read(emailViewModelProvider);
      expect(state.isLoading, false);
      expect(state.error, 'An unexpected error occurred.');
      expect(state.successMessage, null);
      expect(container.read(verificationIdProvider), null);
      verify(mockAuthRepository.sendAuthCode(testEmail)).called(1);
    });

    test('sendVerificationCode does nothing if email is invalid', () async {
      when(mockValidator.validateEmail('invalid')).thenReturn('Invalid email');
      viewModel.setEmail('invalid');

      await viewModel.sendVerificationCode();

      final state = container.read(emailViewModelProvider);
      expect(state.isLoading, false);
      verifyNever(mockAuthRepository.sendAuthCode(any));
    });

    test(
        'cancelVerification success clears verificationId and resets code state',
        () async {
      container.read(verificationIdProvider.notifier).state =
          testVerificationId;
      when(mockValidator.validateCode(testCode)).thenReturn(null);
      viewModel.setCode(testCode);
      when(mockAuthRepository.deleteAuthCode(testVerificationId))
          .thenAnswer((_) async => {});

      await viewModel.cancelVerification();

      final state = container.read(emailViewModelProvider);
      expect(state.isLoading, false);
      expect(state.code, '');
      expect(state.isCodeValid, false);
      expect(state.error, null);
      expect(container.read(verificationIdProvider), null);
      verify(mockAuthRepository.deleteAuthCode(testVerificationId)).called(1);
    });

    test('cancelVerification handles FirebaseFunctionsException', () async {
      container.read(verificationIdProvider.notifier).state =
          testVerificationId;
      final exception = FirebaseFunctionsException(
          message: 'Deletion failed', code: 'internal');
      when(mockAuthRepository.deleteAuthCode(testVerificationId))
          .thenThrow(exception);

      await viewModel.cancelVerification();

      final state = container.read(emailViewModelProvider);
      expect(state.isLoading, false);
      expect(state.error, 'Deletion failed');
      expect(container.read(verificationIdProvider), testVerificationId);
      verify(mockAuthRepository.deleteAuthCode(testVerificationId)).called(1);
    });

    test('cancelVerification handles generic Exception', () async {
      container.read(verificationIdProvider.notifier).state =
          testVerificationId;
      final exception = Exception('Something broke');
      when(mockAuthRepository.deleteAuthCode(testVerificationId))
          .thenThrow(exception);

      await viewModel.cancelVerification();

      final state = container.read(emailViewModelProvider);
      expect(state.isLoading, false);
      expect(state.error, 'An unexpected error occurred during cancellation.');
      expect(container.read(verificationIdProvider), testVerificationId);
      verify(mockAuthRepository.deleteAuthCode(testVerificationId)).called(1);
    });

    test('cancelVerification does nothing if verificationId is null', () async {
      container.read(verificationIdProvider.notifier).state = null;

      await viewModel.cancelVerification();

      final state = container.read(emailViewModelProvider);
      expect(state.isLoading, false);
      verifyNever(mockAuthRepository.deleteAuthCode(any));
    });

    test('verifyCode success updates state and clears verificationId',
        () async {
      container.read(verificationIdProvider.notifier).state =
          testVerificationId;
      when(mockValidator.validateCode(testCode)).thenReturn(null);
      viewModel.setCode(testCode);
      final response = {
        'status': 'success',
        'user_id': testUserId,
        'message': 'Verified!'
      };
      when(mockAuthRepository.verifyAuthCode(testVerificationId, testCode))
          .thenAnswer((_) async => response);

      await viewModel.verifyCode(MockBuildContext());

      final state = container.read(emailViewModelProvider);
      expect(state.isLoading, false);
      expect(state.isVerified, true);
      expect(state.successMessage, 'Verified!');
      expect(state.code, '');
      expect(state.isCodeValid, false);
      expect(state.codeError, null);
      expect(container.read(verificationIdProvider), null);
      verify(mockAuthRepository.verifyAuthCode(testVerificationId, testCode))
          .called(1);
    });

    test('verifyCode handles failure response', () async {
      container.read(verificationIdProvider.notifier).state =
          testVerificationId;
      when(mockValidator.validateCode(testCode)).thenReturn(null);
      viewModel.setCode(testCode);
      final response = {'status': 'failure', 'message': 'Invalid code'};
      when(mockAuthRepository.verifyAuthCode(testVerificationId, testCode))
          .thenAnswer((_) async => response);

      await viewModel.verifyCode(MockBuildContext());

      final state = container.read(emailViewModelProvider);
      expect(state.isLoading, false);
      expect(state.isVerified, false);
      expect(state.codeError, 'Invalid code');
      expect(state.successMessage, null);
      expect(container.read(verificationIdProvider), testVerificationId);
      verify(mockAuthRepository.verifyAuthCode(testVerificationId, testCode))
          .called(1);
    });

    test('verifyCode handles FirebaseFunctionsException', () async {
      container.read(verificationIdProvider.notifier).state =
          testVerificationId;
      when(mockValidator.validateCode(testCode)).thenReturn(null);
      viewModel.setCode(testCode);
      final exception = FirebaseFunctionsException(
          message: 'Verification failed', code: 'invalid-argument');
      when(mockAuthRepository.verifyAuthCode(testVerificationId, testCode))
          .thenThrow(exception);

      await viewModel.verifyCode(MockBuildContext());

      final state = container.read(emailViewModelProvider);
      expect(state.isLoading, false);
      expect(state.isVerified, false);
      expect(state.codeError, 'Failed to verify code. Please try again.');
      expect(container.read(verificationIdProvider), testVerificationId);
      verify(mockAuthRepository.verifyAuthCode(testVerificationId, testCode))
          .called(1);
    });

    test('verifyCode handles generic Exception', () async {
      container.read(verificationIdProvider.notifier).state =
          testVerificationId;
      when(mockValidator.validateCode(testCode)).thenReturn(null);
      viewModel.setCode(testCode);
      final exception = Exception('Something broke');
      when(mockAuthRepository.verifyAuthCode(testVerificationId, testCode))
          .thenThrow(exception);

      await viewModel.verifyCode(MockBuildContext());

      final state = container.read(emailViewModelProvider);
      expect(state.isLoading, false);
      expect(state.isVerified, false);
      expect(state.error, 'An unexpected error occurred during verification.');
      expect(state.codeError, null);
      expect(container.read(verificationIdProvider), testVerificationId);
      verify(mockAuthRepository.verifyAuthCode(testVerificationId, testCode))
          .called(1);
    });

    test('verifyCode does nothing if code is invalid', () async {
      container.read(verificationIdProvider.notifier).state =
          testVerificationId;
      when(mockValidator.validateCode('invalid')).thenReturn('Invalid code');
      viewModel.setCode('invalid');

      await viewModel.verifyCode(MockBuildContext());

      final state = container.read(emailViewModelProvider);
      expect(state.isLoading, false);
      verifyNever(mockAuthRepository.verifyAuthCode(any, any));
    });

    test('verifyCode does nothing if verificationId is null', () async {
      container.read(verificationIdProvider.notifier).state = null;
      when(mockValidator.validateCode(testCode)).thenReturn(null);
      viewModel.setCode(testCode);

      await viewModel.verifyCode(MockBuildContext());

      final state = container.read(emailViewModelProvider);
      expect(state.isLoading, false);
      verifyNever(mockAuthRepository.verifyAuthCode(any, any));
    });

    test('clearSuccessMessage clears the success message', () async {
      when(mockValidator.validateEmail(testEmail)).thenReturn(null);
      viewModel.setEmail(testEmail);
      when(mockAuthRepository.sendAuthCode(testEmail)).thenAnswer((_) async =>
          {'verification_id': 'vid', 'message': 'Initial success'});

      await viewModel.sendVerificationCode();
      await pumpEventQueue();

      expect(container.read(emailViewModelProvider).successMessage,
          'Initial success');

      viewModel.clearSuccessMessage();
      await pumpEventQueue();

      final state = container.read(emailViewModelProvider);
      expect(state.successMessage, null);
    });
  });
}

class MockBuildContext extends Mock implements BuildContext {}
