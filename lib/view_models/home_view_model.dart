import 'package:authentication_challenge/models/home_state.dart';
import 'package:authentication_challenge/repositories/repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_functions/cloud_functions.dart';

class HomeViewModel extends StateNotifier<HomeState> {
  final AuthRepository _authRepository;

  HomeViewModel(this._authRepository) : super(const HomeState());

  Future<void> callCloudFunction() async {
    state = state.copyWith(isLoading: true, error: null, response: null);
    try {
      final responseData = await _authRepository.callHelloWorld();

      if (responseData != null) {
        state = state.copyWith(isLoading: false, response: responseData);
      } else {
        state = state.copyWith(
            isLoading: false, error: 'Invalid response data type');
      }
    } on FirebaseFunctionsException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
