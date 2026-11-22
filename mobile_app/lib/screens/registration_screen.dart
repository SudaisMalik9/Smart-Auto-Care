
import 'package:material_ui/material_ui.dart';

import '../services/auth_service.dart';
import 'vehicle_owner_dashboard.dart';

const Color _primaryBlue = Color(0xFF1565C0);
const Color _backgroundColor = Color(0xFFF5F7FB);
const Color _navyColor = Color(0xFF102A43);

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateRequired(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your $label.';
    }
    return null;
  }

  String? _validateUsername(String? value) {
    final username = value?.trim() ?? '';

    if (username.isEmpty) {
      return 'Please enter a username.';
    }

    if (username.length < 3) {
      return 'Username must contain at least 3 characters.';
    }

    if (!RegExp(r'^[a-zA-Z0-9@.+_-]+$').hasMatch(username)) {
      return 'Use letters, numbers and @ . + - _ only.';
    }

    return null;
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Please enter your email address.';
    }

    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Please enter a valid email address.';
    }

    return null;
  }

  String? _validatePhone(String? value) {
    final phone = value?.trim() ?? '';

    if (phone.isEmpty) {
      return 'Please enter your phone number.';
    }

    final digits = phone.replaceAll(RegExp(r'[\s+()-]'), '');

    if (!RegExp(r'^\d{10,15}$').hasMatch(digits)) {
      return 'Please enter a valid phone number.';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password.';
    }

    if (value.length < 6) {
      return 'Password must contain at least 6 characters.';
    }

    return null;
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate() || _isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create a CUSTOMER account using the existing Django API.
      await AuthService.register(
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        password: _passwordController.text,
        passwordConfirm: _confirmPasswordController.text,
      );

      if (!mounted) return;

      // Log in immediately after successful registration.
      await AuthService.login(
        identifier: _usernameController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      // The account already exists and is logged in.
      // A phone update failure must not make registration appear unsuccessful.
      String? phoneWarning;

      try {
        await AuthService.updateCustomerPhone(
          _phoneController.text.trim(),
        );
      } catch (error) {
        phoneWarning =
            'Your account was created, but your phone number could not '
            'be saved. You can update it later.';
      }

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const VehicleOwnerDashboard(),
        ),
        (route) => false,
      );

      if (phoneWarning != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(phoneWarning),
            backgroundColor: Colors.orange.shade800,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (error) {
      if (!mounted) return;

      final message = error.toString().replaceFirst('Exception: ', '');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red.shade700,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFD8DEE8)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: _primaryBlue,
          width: 1.5,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: _navyColor,
        ),
      ),
    );
  }

  Widget _textField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(label),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          obscureText: obscureText,
          decoration: _inputDecoration(
            hint: hint,
            icon: icon,
            suffixIcon: suffixIcon,
          ),
          validator: validator,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 0,
        foregroundColor: _navyColor,
        title: const Text(
          'Create Account',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.person_add_alt_1_rounded,
                      size: 58,
                      color: _primaryBlue,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Join Smart Auto Care',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: _navyColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Create your Vehicle Owner account to get started.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blueGrey,
                      ),
                    ),
                    const SizedBox(height: 30),

                    _textField(
                      label: 'Username',
                      hint: 'Choose a username',
                      icon: Icons.alternate_email,
                      controller: _usernameController,
                      validator: _validateUsername,
                    ),
                    const SizedBox(height: 18),

                    _textField(
                      label: 'First Name',
                      hint: 'Enter your first name',
                      icon: Icons.person_outline,
                      controller: _firstNameController,
                      textCapitalization: TextCapitalization.words,
                      validator: (value) =>
                          _validateRequired(value, 'first name'),
                    ),
                    const SizedBox(height: 18),

                    _textField(
                      label: 'Last Name',
                      hint: 'Enter your last name',
                      icon: Icons.person_outline,
                      controller: _lastNameController,
                      textCapitalization: TextCapitalization.words,
                      validator: (value) =>
                          _validateRequired(value, 'last name'),
                    ),
                    const SizedBox(height: 18),

                    _textField(
                      label: 'Email Address',
                      hint: 'Enter your email address',
                      icon: Icons.email_outlined,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateEmail,
                    ),
                    const SizedBox(height: 18),

                    _textField(
                      label: 'Phone Number',
                      hint: 'Enter your phone number',
                      icon: Icons.phone_outlined,
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      validator: _validatePhone,
                    ),
                    const SizedBox(height: 18),

                    _textField(
                      label: 'Password',
                      hint: 'Create a password',
                      icon: Icons.lock_outline,
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      validator: _validatePassword,
                      suffixIcon: IconButton(
                        tooltip: _obscurePassword
                            ? 'Show password'
                            : 'Hide password',
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 18),

                    _textField(
                      label: 'Confirm Password',
                      hint: 'Re-enter your password',
                      icon: Icons.lock_outline,
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password.';
                        }

                        if (value != _passwordController.text) {
                          return 'Passwords do not match.';
                        }

                        return null;
                      },
                      suffixIcon: IconButton(
                        tooltip: _obscureConfirmPassword
                            ? 'Show password'
                            : 'Hide password',
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword =
                                !_obscureConfirmPassword;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 28),

                    SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryBlue,
                          foregroundColor: Colors.white,
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 23,
                                width: 23,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                'Create Account',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Flexible(
                          child: Text(
                            'Already have an account?',
                            style: TextStyle(color: Colors.black87),
                          ),
                        ),
                        TextButton(
                          onPressed: _isLoading
                              ? null
                              : () => Navigator.pop(context),
                          child: const Text('Login'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
