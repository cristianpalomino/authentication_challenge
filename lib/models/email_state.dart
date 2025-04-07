class EmailState {
  final String email;
  final bool isLoading;
  final String? error;
  final bool isValid;
  final String? successMessage;
  final String code;
  final bool isCodeValid;
  final String? codeError;
  final bool isVerified;

  const EmailState({
    this.email = '',
    this.isLoading = false,
    this.error,
    this.isValid = false,
    this.successMessage,
    this.code = '',
    this.isCodeValid = false,
    this.codeError,
    this.isVerified = false,
  });

  EmailState copyWith({
    String? email,
    bool? isLoading,
    String? error,
    bool? isValid,
    String? successMessage,
    bool clearSuccessMessage = false,
    String? code,
    bool? isCodeValid,
    String? codeError,
    bool? isVerified,
  }) {
    return EmailState(
      email: email ?? this.email,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isValid: isValid ?? this.isValid,
      successMessage:
          clearSuccessMessage ? null : successMessage ?? this.successMessage,
      code: code ?? this.code,
      isCodeValid: isCodeValid ?? this.isCodeValid,
      codeError: codeError,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}
