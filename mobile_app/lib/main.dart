
import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import 'screens/add_vehicle_screen.dart';
import 'screens/my_vehicles_screen.dart';
import 'screens/find_workshop_screen.dart';

void main() {
  runApp(const SmartAutoCareApp());
}

class SmartAutoCareApp extends StatelessWidget {
  const SmartAutoCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Auto Care',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1565C0),
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7FB),
        fontFamily: 'Roboto',
      ),
      home: const WelcomeScreen(),

      // APP NAVIGATION ROUTES
      routes: {
        '/login': (context) => const LoginScreen(),
        '/add-vehicle': (context) => const AddVehicleScreen(),
        '/my-vehicles': (context) => const MyVehiclesScreen(),
        '/find-workshop': (context) => const FindWorkshopScreen(),
      },
    );
  }
}

// ============================================================
// WELCOME SCREEN
// ============================================================

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  static const Color navy = Color(0xFF102A43);
  static const Color blue = Color(0xFF1565C0);
  static const Color lightBlue = Color(0xFFEAF3FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 20,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Column(
                children: [
                  // BRAND HEADER
                  Row(
                    children: [
                      Container(
                        height: 48,
                        width: 48,
                        decoration: BoxDecoration(
                          color: blue,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.directions_car_filled_rounded,
                          color: Colors.white,
                          size: 29,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Smart Auto Care',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: navy,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              'Your car, our responsibility',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blueGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 35),

                  // MAIN CONTENT
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final bool wide = constraints.maxWidth > 700;

                      final Widget textSection = Column(
                        crossAxisAlignment: wide
                            ? CrossAxisAlignment.start
                            : CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: lightBlue,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Text(
                              'WELCOME TO',
                              style: TextStyle(
                                color: blue,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),

                          const SizedBox(height: 22),

                          Text(
                            'Smarter Care\nfor Your Vehicle',
                            textAlign: wide
                                ? TextAlign.left
                                : TextAlign.center,
                            style: TextStyle(
                              fontSize: wide ? 43 : 34,
                              height: 1.15,
                              fontWeight: FontWeight.w800,
                              color: navy,
                            ),
                          ),

                          const SizedBox(height: 18),

                          const Text(
                            'Manage your vehicle, find trusted workshops, '
                                'book services, and keep everything organized '
                                'in one convenient place.',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.8,
                              color: Colors.blueGrey,
                            ),
                          ),

                          const SizedBox(height: 28),

                          SizedBox(
                            width: wide ? 230 : double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                    const LoginScreen(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: blue,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
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
                                  Icon(Icons.arrow_forward_rounded),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 18),

                          const Text(
                            'Simple • Reliable • Convenient',
                            style: TextStyle(
                              color: Colors.blueGrey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      );

                      final Widget illustration = Container(
                        height: 310,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF1565C0),
                              Color(0xFF42A5F5),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Positioned(
                              top: 25,
                              right: 25,
                              child: Icon(
                                Icons.settings_rounded,
                                size: 75,
                                color: Colors.white.withValues(alpha: 0.18),
                              ),
                            ),
                            Positioned(
                              bottom: 20,
                              left: 20,
                              child: Icon(
                                Icons.build_circle_rounded,
                                size: 65,
                                color: Colors.white.withValues(alpha: 0.20),
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height: 150,
                                  width: 150,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(
                                      alpha: 0.15,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.directions_car_filled_rounded,
                                    size: 100,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  'Your Journey, Our Care',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 21,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 7),
                                const Text(
                                  'Everything your vehicle needs',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );

                      if (wide) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 5,
                              child: textSection,
                            ),
                            const SizedBox(width: 45),
                            Expanded(
                              flex: 4,
                              child: illustration,
                            ),
                          ],
                        );
                      }

                      return Column(
                        children: [
                          textSection,
                          const SizedBox(height: 35),
                          illustration,
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 40),

                  // FEATURES
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final bool wide = constraints.maxWidth > 600;

                      final features = [
                        const FeatureItem(
                          icon: Icons.car_repair_rounded,
                          title: 'Vehicle Care',
                          description:
                          'Keep track of your vehicles and maintenance.',
                        ),
                        const FeatureItem(
                          icon: Icons.location_on_rounded,
                          title: 'Find Workshops',
                          description:
                          'Discover workshops for your vehicle needs.',
                        ),
                        const FeatureItem(
                          icon: Icons.calendar_month_rounded,
                          title: 'Easy Booking',
                          description:
                          'Plan and manage your service appointments.',
                        ),
                      ];

                      if (wide) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: features
                              .map(
                                (feature) => Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: feature,
                              ),
                            ),
                          )
                              .toList(),
                        );
                      }

                      return Column(
                        children: features
                            .map(
                              (feature) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: feature,
                          ),
                        )
                            .toList(),
                      );
                    },
                  ),

                  const SizedBox(height: 30),

                  const Divider(color: Color(0xFFE0E6ED)),

                  const SizedBox(height: 15),

                  const Text(
                    'Smart Auto Care © 2026',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blueGrey,
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

// ============================================================
// FEATURE CARD
// ============================================================

class FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const FeatureItem({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8EDF3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 45,
            width: 45,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF3FF),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF1565C0),
              size: 25,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF102A43),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              fontSize: 13,
              height: 1.6,
              color: Colors.blueGrey,
            ),
          ),
        ],
      ),
    );
  }
}
