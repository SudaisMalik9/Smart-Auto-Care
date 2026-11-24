import 'package:material_ui/material_ui.dart';

import '../services/auth_service.dart';
import 'vehicle_owner_dashboard.dart';
import 'workshop_dashboard.dart';
import 'admin_dashboard.dart';
import 'registration_screen.dart';
import 'forgot_password_screen.dart';

const Color primaryBlue = Color(0xFF1565C0);
const Color backgroundColor = Color(0xFFF5F7FB);
const Color navyColor = Color(0xFF102A43);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate() || _isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = await AuthService.login(
        identifier: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      final role = user['role']?.toString().toUpperCase();

      switch (role) {
        case 'CUSTOMER':
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const VehicleOwnerDashboard(),
            ),
          );
          break;

        case 'WORKSHOP_OWNER':
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const WorkshopDashboard()),
          );
          break;

        case 'ADMIN':
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AdminDashboard()),
          );
          break;

        case 'MECHANIC':
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Login successful. Mechanic dashboard integration '
                'is not part of the current mobile integration stage.',
              ),
            ),
          );
          break;

        default:
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Your account role is not supported yet: $role'),
            ),
          );
      }
    } catch (error) {
      if (!mounted) return;

      final message = error.toString().replaceFirst('Exception: ', '');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red.shade700),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _forgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ForgotPasswordScreen(initialEmail: _emailController.text.trim()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
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
                    const SizedBox(height: 20),

                    const Icon(
                      Icons.directions_car_filled_rounded,
                      size: 62,
                      color: primaryBlue,
                    ),

                    const SizedBox(height: 14),

                    const Text(
                      'Smart Auto Care',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: navyColor,
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Your car, our responsibility',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.blueGrey, fontSize: 14),
                    ),

                    const SizedBox(height: 42),

                    const Text(
                      'Welcome Back!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: navyColor,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Log in to manage your vehicle and services.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.blueGrey, fontSize: 14),
                    ),

                    const SizedBox(height: 28),

                    const Text(
                      'Email or Username',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 8),

                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        hintText: 'Enter your email or username',
                        prefixIcon: const Icon(Icons.person_outline_rounded),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFFD8DEE8),
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your email or username.';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'Password',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 8),

                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _login(),
                      decoration: InputDecoration(
                        hintText: 'Enter your password',
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
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
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFFD8DEE8),
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password.';
                        }

                        return null;
                      },
                    ),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _isLoading ? null : _forgotPassword,
                        child: const Text('Forgot Password?'),
                      ),
                    ),

                    const SizedBox(height: 8),

                    SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
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
                                'Login',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account? ",
                          style: TextStyle(color: Colors.black87),
                        ),
                        TextButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const RegistrationScreen(),
                                    ),
                                  );
                                },
                          child: const Text('Create Account'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      'Secure vehicle care, all in one place.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.blueGrey, fontSize: 12),
                    ),

                    const SizedBox(height: 20),
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
