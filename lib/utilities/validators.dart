class Validators {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    // Check for at least one letter and one number
    if (!RegExp(r'^(?=.*[a-zA-Z])(?=.*[0-9])').hasMatch(value)) {
      return 'Password must contain at least one letter and one number';
    }
    return null;
  }

  // Confirm password 
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  // Name validation
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your name';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters long';
    }
    if (value.trim().length > 50) {
      return 'Name cannot be longer than 50 characters';
    }
    
    // Check for valid characters (letters, spaces, hyphens, apostrophes)
    if (!RegExp(r"^[a-zA-Z\s\-']+$").hasMatch(value.trim())) {
      return 'Name can only contain letters, spaces, hyphens, and apostrophes';
    } 
    return null;
  }

  // Survey title validation
  static String? validateSurveyTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a survey title';
    }
    if (value.trim().length < 3) {
      return 'Title must be at least 3 characters long';
    }
    if (value.trim().length > 100) {
      return 'Title cannot be longer than 100 characters';
    }
    return null;
  }

  // Survey description validation
  static String? validateSurveyDescription(String? value) {
    if (value != null && value.trim().length > 500) {
      return 'Description cannot be longer than 500 characters';
    } 
    return null;
  }

  // Question text validation
  static String? validateQuestionText(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter question text';
    }

    if (value.trim().length < 3) {
      return 'Question must be at least 3 characters long';
    }
    if (value.trim().length > 200) {
      return 'Question cannot be longer than 200 characters';
    }
    return null;
  }

  // Multiple choice option validation
  static String? validateOption(String? value) {
    if (value == null || value.isEmpty) {
      return 'Option cannot be empty';
    }
    if (value.trim().length > 100) {
      return 'Option cannot be longer than 100 characters';
    }
    return null;
  }

  // URL validation
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return null; 
    }
    final urlRegex = RegExp(
      r'^https?:\/\/(?:www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b(?:[-a-zA-Z0-9()@:%_\+.~#?&=]*)$',
    );
    if (!urlRegex.hasMatch(value)) {
      return 'Please enter a valid URL';
    }
        return null;
  }

  // Phone number validation
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Phone is optional
    }
    // Remove all non-digit characters
    final digitsOnly = value.replaceAll(RegExp(r'\D'), ''); 
    if (digitsOnly.length < 10) {
      return 'Phone number must be at least 10 digits';
    }
    if (digitsOnly.length > 15) {
      return 'Phone number cannot be longer than 15 digits';
    }
    return null;
  }

  // Age validation
  static String? validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your age';
    }
    final age = int.tryParse(value);
    if (age == null) {
      return 'Please enter a valid age';
    }
    if (age < 13) {
      return 'You must be at least 13 years old';
    }
    if (age > 120) {
      return 'Please enter a valid age';
    }
    return null;
  }

  // Required field validation
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Please enter $fieldName';
    }
    return null;
  }
  // Length validation
  static String? validateLength(
    String? value,
    String fieldName, {
    int? minLength,
    int? maxLength,
  }) {
    if (value == null || value.isEmpty) {
      return 'Please enter $fieldName';
    }
    if (minLength != null && value.trim().length < minLength) {
      return '$fieldName must be at least $minLength characters long';
    }
    if (maxLength != null && value.trim().length > maxLength) {
      return '$fieldName cannot be longer than $maxLength characters';
    }
    return null;
  }

  // Number validation
  static String? validateNumber(
    String? value,
    String fieldName, {
    double? min,
    double? max,
  }) {
    if (value == null || value.isEmpty) {
      return 'Please enter $fieldName';
    }
    final number = double.tryParse(value);
    if (number == null) {
      return 'Please enter a valid number for $fieldName';
    }
    if (min != null && number < min) {
      return '$fieldName must be at least $min';
    }
    if (max != null && number > max) {
      return '$fieldName cannot be greater than $max';
    }
    return null;
  }

  // File size validation
  static String? validateFileSize(int? fileSize, {int maxSizeInMB = 10}) {
    if (fileSize == null) return null;
    final maxSizeInBytes = maxSizeInMB * 1024 * 1024;
    if (fileSize > maxSizeInBytes) {
      return 'File size cannot exceed ${maxSizeInMB}MB';
    }
    return null;
  }

  // File extension validation
  static String? validateFileExtension(
    String? fileName,
    List<String> allowedExtensions,
  ) {
    if (fileName == null || fileName.isEmpty) return null;
    final extension = fileName.split('.').last.toLowerCase();
    if (!allowedExtensions.contains(extension)) {
      return 'Only ${allowedExtensions.join(', ')} files are allowed';
    }
    return null;
  }
}