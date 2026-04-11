class ValidatePasswordUseCase {
  const ValidatePasswordUseCase();

  /// Returns an error message string if the password is invalid, or null if valid.
  String? call(String value) {
    if (value.isEmpty) return null;
    if (value.length < 8) return 'Minimum 8 characters required';
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>0-9]'))) {
      return 'Requires a symbol or number';
    }
    return null;
  }
}
