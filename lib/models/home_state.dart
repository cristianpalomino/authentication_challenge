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
