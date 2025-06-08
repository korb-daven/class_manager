class Validators {
  static String? validateRequired(String? value) {
    return (value == null || value.trim().isEmpty) ? 'This field is required' : null;
  }

  static String? validateEmail(String? value) {
    final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w]{2,4}$');
    if (value == null || value.isEmpty) return 'Email is required';
    if (!emailRegex.hasMatch(value)) return 'Enter a valid email';
    return null;
  }

  static String? validatePhone(String? value) {
    final phoneRegex = RegExp(r'^\d{8,15}$'); // adjust as needed
    if (value == null || value.isEmpty) return 'Phone is required';
    if (!phoneRegex.hasMatch(value)) return 'Enter a valid phone number';
    return null;
  }
}