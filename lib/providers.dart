import 'package:authentication_challenge/models/email_state.dart';
import 'package:authentication_challenge/models/home_state.dart';
import 'package:authentication_challenge/view_models/email_view_model.dart';
import 'package:authentication_challenge/view_models/home_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:authentication_challenge/utils/validators.dart';
import 'package:authentication_challenge/repositories/repository.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) {
    return FirebaseRepository();
  },
);

final validatorProvider = Provider<Validator>(
  (ref) {
    return AppValidator();
  },
);

final verificationIdProvider = StateProvider<String?>(
  (ref) => null,
);

final emailViewModelProvider =
    StateNotifierProvider<EmailViewModel, EmailState>(
  (ref) {
    final validator = ref.watch(validatorProvider);
    final authRepository = ref.watch(authRepositoryProvider);
    return EmailViewModel(ref, validator, authRepository);
  },
);

final homeViewModelProvider = StateNotifierProvider<HomeViewModel, HomeState>(
  (ref) {
    final authRepository = ref.watch(authRepositoryProvider);
    return HomeViewModel(authRepository);
  },
);
