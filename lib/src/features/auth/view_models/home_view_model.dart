import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_functions/cloud_functions.dart';

final homeViewModelProvider =
    StateNotifierProvider<HomeViewModel, HomeState>((ref) {
  return HomeViewModel();
});

class HomeViewModel extends StateNotifier<HomeState> {
  HomeViewModel() : super(const HomeState());

  final _functions = FirebaseFunctions.instance;

  Future<void> callCloudFunction() async {
    state = state.copyWith(isLoading: true, error: null, response: null);
    try {
      final callable = _functions.httpsCallable('hello_world');
      final result = await callable.call();
      final responseData = result.data as String?;

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

class HomeState {
  final bool isLoading;
  final String? error;
  final String? response;

  const HomeState({
    this.isLoading = false,
    this.error,
    this.response,
  });

  HomeState copyWith({
    bool? isLoading,
    String? error,
    String? response,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      response: response ?? this.response,
    );
  }
}
