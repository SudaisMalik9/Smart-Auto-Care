import 'package:flutter/material.dart';

import 'login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  static const Color primaryBlue = Color(0xFF1565C0);
  static const Color backgroundColor = Color(0xFFF5F7FB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        height: 54,
                        width: 54,
                        decoration: BoxDecoration(
                          color: primaryBlue,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.directions_car_filled,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Smart Auto Care',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF18324D),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Your car, our responsibility',
                            style: TextStyle(
                              color: Colors.blueGrey,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 52),
                  const Text(
                    'WELCOME TO',
                    style: TextStyle(
                      color: primaryBlue,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Smarter Care\nfor Your Vehicle',
                    style: TextStyle(
                      fontSize: 38,
                      height: 1.15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF18324D),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Manage your vehicles, find trusted workshops, '
                    'book services and keep your maintenance history '
                    'in one convenient place.',
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.7,
                      color: Colors.blueGrey,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFD9E8FF), Color(0xFFF0F5FF)],
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                      Icons.directions_car_filled,
                      size: 100,
                      color: primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: _FeatureCard(
                          icon: Icons.directions_car,
                          title: 'Vehicle Care',
                          subtitle: 'Manage vehicles',
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _FeatureCard(
                          icon: Icons.build,
                          title: 'Find Workshops',
                          subtitle: 'Book services',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        );
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Get Started',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 10),
                          Icon(Icons.arrow_forward),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Center(
                    child: Text(
                      'Vehicle management made simple',
                      style: TextStyle(color: Colors.blueGrey, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE1EAF5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF1565C0), size: 26),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF18324D),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
          ),
        ],
      ),
    );
  }
}
