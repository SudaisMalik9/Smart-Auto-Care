import 'package:flutter/material.dart';

import 'add_vehicle_screen.dart';
import 'find_workshop_screen.dart';
import 'book_service_screen.dart';

const Color dashboardBlue = Color(0xFF1565C0);
const Color dashboardNavy = Color(0xFF102A43);
const Color dashboardBackground = Color(0xFFF5F7FB);

class VehicleOwnerDashboard extends StatefulWidget {
  const VehicleOwnerDashboard({super.key});

  @override
  State<VehicleOwnerDashboard> createState() => _VehicleOwnerDashboardState();
}

class _VehicleOwnerDashboardState extends State<VehicleOwnerDashboard> {
  int _selectedIndex = 0;

  // Temporary demo data. Firebase will be integrated later.
  final List<Map<String, dynamic>> _vehicles = [
    {
      'registrationNumber': 'ABC-123',
      'make': 'Honda',
      'model': 'Civic',
      'year': 2022,
      'type': 'Car',
      'fuelType': 'Petrol',
      'transmission': 'Automatic',
      'mileage': 45000,
      'color': 'White',
    },
    {
      'registrationNumber': 'XYZ-456',
      'make': 'Toyota',
      'model': 'Corolla',
      'year': 2021,
      'type': 'Car',
      'fuelType': 'Petrol',
      'transmission': 'Automatic',
      'mileage': 60000,
      'color': 'Silver',
    },
  ];

  final List<Map<String, String>> _bookings = [
    {
      'service': 'General Maintenance',
      'workshop': 'Demo Workshop',
      'date': '30 Oct 2026',
      'time': '10:00 AM',
      'status': 'Upcoming',
    },
  ];

  final List<Map<String, String>> _activities = [
    {
      'service': 'Oil Change',
      'vehicle': 'Honda Civic',
      'date': '15 Oct 2026',
      'status': 'Completed',
    },
    {
      'service': 'General Inspection',
      'vehicle': 'Toyota Corolla',
      'date': '02 Oct 2026',
      'status': 'Completed',
    },
  ];

  Future<void> _openAddVehicle() async {
    final vehicle = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (context) => const AddVehicleScreen()),
    );

    if (!mounted || vehicle == null) return;

    setState(() {
      _vehicles.add(vehicle);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${vehicle['make']} ${vehicle['model']} added successfully!',
        ),
      ),
    );
  }

  // Find Workshop: opens workshop discovery and receives confirmed booking.
  Future<void> _openFindWorkshop() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (context) => const FindWorkshopScreen()),
    );

    if (!mounted || result == null) return;

    final booking = <String, String>{};

    result.forEach((key, value) {
      booking[key] = value?.toString() ?? '';
    });

    setState(() {
      _bookings.insert(0, booking);
    });

    _showMessage('Your service booking has been added successfully!');
  }

  // Book Service: opens the booking form and adds the returned booking.
  Future<void> _openBookService() async {
    final result = await Navigator.push<dynamic>(
      context,
      MaterialPageRoute(builder: (context) => const BookServiceScreen()),
    );

    if (!mounted || result == null || result is! Map) return;

    final booking = <String, String>{};

    result.forEach((key, value) {
      booking[key.toString()] = value?.toString() ?? '';
    });

    setState(() {
      _bookings.insert(0, booking);
    });

    _showMessage('Your service booking has been added successfully!');
  }

  void _openVehicles() {
    setState(() {
      _selectedIndex = 1;
    });
  }

  void _openBookings() {
    setState(() {
      _selectedIndex = 2;
    });
  }

  void _openProfile() {
    setState(() {
      _selectedIndex = 3;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildHome(),
      _buildVehiclesPage(),
      _buildBookingsPage(),
      _buildProfilePage(),
    ];

    return Scaffold(
      backgroundColor: dashboardBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: dashboardNavy),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Row(
          children: [
            Icon(
              Icons.directions_car_filled_rounded,
              color: dashboardBlue,
              size: 30,
            ),
            SizedBox(width: 10),
            Text(
              'Smart Auto Care',
              style: TextStyle(
                color: dashboardNavy,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: dashboardNavy,
            ),
            onPressed: () {
              _showMessage('No new notifications.');
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: IndexedStack(index: _selectedIndex, children: pages),
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        selectedIndex: _selectedIndex,
        indicatorColor: const Color(0xFFE7F0FF),
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.grid_view_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.directions_car_outlined),
            label: 'Vehicles',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            label: 'Bookings',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // HOME DASHBOARD
  // ---------------------------------------------------------

  Widget _buildHome() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 850;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1150),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hello, Vehicle Owner! 👋',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: dashboardNavy,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Manage your vehicles and keep them running smoothly.',
                    style: TextStyle(fontSize: 14, color: Colors.blueGrey),
                  ),
                  const SizedBox(height: 26),

                  _buildBanner(),

                  const SizedBox(height: 28),

                  const Text(
                    'Overview',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: dashboardNavy,
                    ),
                  ),
                  const SizedBox(height: 15),

                  GridView.count(
                    crossAxisCount: wide ? 3 : 1,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: wide ? 1.65 : 2.5,
                    children: [
                      _StatCard(
                        icon: Icons.directions_car_rounded,
                        label: 'My Vehicles',
                        value: '${_vehicles.length}',
                        subtitle: 'Registered vehicles',
                        color: dashboardBlue,
                        onTap: _openVehicles,
                      ),
                      _StatCard(
                        icon: Icons.calendar_month_rounded,
                        label: 'Upcoming',
                        value: '${_bookings.length}',
                        subtitle: 'Service booking',
                        color: Colors.teal,
                        onTap: _openBookings,
                      ),
                      _StatCard(
                        icon: Icons.check_circle_outline_rounded,
                        label: 'Completed',
                        value: '${_activities.length}',
                        subtitle: 'Services completed',
                        color: Colors.deepPurple,
                        onTap: () {
                          _showMessage(
                            'Service history will be expanded next.',
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: dashboardNavy,
                    ),
                  ),
                  const SizedBox(height: 15),

                  GridView.count(
                    crossAxisCount: wide ? 4 : 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: wide ? 1.5 : 1.15,
                    children: [
                      _QuickAction(
                        icon: Icons.add_circle_outline_rounded,
                        title: 'Add Vehicle',
                        onTap: _openAddVehicle,
                      ),

                      // FIND WORKSHOP BUTTON
                      _QuickAction(
                        icon: Icons.search_rounded,
                        title: 'Find Workshop',
                        onTap: _openFindWorkshop,
                      ),

                      // BOOK SERVICE BUTTON
                      _QuickAction(
                        icon: Icons.event_available_outlined,
                        title: 'Book Service',
                        onTap: _openBookService,
                      ),

                      _QuickAction(
                        icon: Icons.history_rounded,
                        title: 'Service History',
                        onTap: () {
                          _showMessage(
                            'Service history screen is coming next.',
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Upcoming Booking',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: dashboardNavy,
                        ),
                      ),
                      TextButton(
                        onPressed: _openBookings,
                        child: const Text('View all'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  if (_bookings.isEmpty)
                    _emptyCard(
                      icon: Icons.calendar_month_outlined,
                      title: 'No upcoming bookings',
                      subtitle: 'Your future appointments will appear here.',
                    )
                  else
                    ..._bookings
                        .take(2)
                        .map(
                          (booking) => _BookingTile(
                            booking: booking,
                            onTap: _openBookings,
                          ),
                        ),

                  const SizedBox(height: 26),

                  const Text(
                    'Recent Activity',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: dashboardNavy,
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (_activities.isEmpty)
                    _emptyCard(
                      icon: Icons.history_rounded,
                      title: 'No recent activity',
                      subtitle: 'Your completed services will appear here.',
                    )
                  else
                    ..._activities
                        .take(4)
                        .map((activity) => _ActivityTile(activity: activity)),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
        ),
        borderRadius: BorderRadius.circular(23),
      ),
      child: const Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Vehicle,\nOur Priority',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    height: 1.2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Reliable care, all in one place.',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ],
            ),
          ),
          SizedBox(width: 15),
          Icon(Icons.car_repair_rounded, size: 60, color: Colors.white),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // VEHICLES PAGE
  // ---------------------------------------------------------

  Widget _buildVehiclesPage() {
    return _pageContainer(
      title: 'My Vehicles',
      subtitle: 'Manage your registered vehicles.',
      action: ElevatedButton.icon(
        onPressed: _openAddVehicle,
        icon: const Icon(Icons.add),
        label: const Text('Add Vehicle'),
      ),
      child: _vehicles.isEmpty
          ? _emptyCard(
              icon: Icons.directions_car_outlined,
              title: 'No vehicles registered',
              subtitle: 'Add your first vehicle to get started.',
            )
          : Column(
              children: _vehicles.map((vehicle) {
                return Card(
                  color: Colors.white,
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: const BorderSide(color: Color(0xFFE5EAF0)),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(18),
                    leading: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF3FF),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.directions_car_filled_rounded,
                        color: dashboardBlue,
                        size: 29,
                      ),
                    ),
                    title: Text(
                      '${vehicle['make']} ${vehicle['model']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: dashboardNavy,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '${vehicle['registrationNumber']}\n'
                        '${vehicle['year']} • ${vehicle['color']} • '
                        '${vehicle['mileage']} km',
                      ),
                    ),
                    isThreeLine: true,
                    trailing: IconButton(
                      tooltip: 'Delete vehicle',
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.redAccent,
                      ),
                      onPressed: () {
                        _confirmDeleteVehicle(vehicle);
                      },
                    ),
                  ),
                );
              }).toList(),
            ),
    );
  }

  void _confirmDeleteVehicle(Map<String, dynamic> vehicle) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Remove Vehicle?'),
          content: Text(
            'Do you want to remove ${vehicle['make']} ${vehicle['model']}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _vehicles.remove(vehicle);
                });
                Navigator.pop(dialogContext);
                _showMessage('Vehicle removed.');
              },
              child: const Text('Remove', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // ---------------------------------------------------------
  // BOOKINGS PAGE
  // ---------------------------------------------------------

  Widget _buildBookingsPage() {
    return _pageContainer(
      title: 'My Bookings',
      subtitle: 'View your service appointments.',
      child: Column(
        children: [
          if (_bookings.isEmpty)
            _emptyCard(
              icon: Icons.calendar_month_outlined,
              title: 'No bookings yet',
              subtitle: 'Your appointments will appear here.',
            )
          else
            ..._bookings.map(
              (booking) => _BookingTile(
                booking: booking,
                onTap: () {
                  _showMessage(
                    '${booking['service']} at ${booking['workshop']}',
                  );
                },
              ),
            ),
          const SizedBox(height: 18),
          _emptyCard(
            icon: Icons.info_outline_rounded,
            title: 'Booking management',
            subtitle: 'Create and manage appointments when the booking screen is added.',
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // PROFILE PAGE
  // ---------------------------------------------------------

  Widget _buildProfilePage() {
    return _pageContainer(
      title: 'My Profile',
      subtitle: 'Manage your account information.',
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE5EAF0)),
            ),
            child: const Column(
              children: [
                CircleAvatar(
                  radius: 42,
                  backgroundColor: Color(0xFFEAF3FF),
                  child: Icon(
                    Icons.person_rounded,
                    size: 48,
                    color: dashboardBlue,
                  ),
                ),
                SizedBox(height: 14),
                Text(
                  'Vehicle Owner',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: dashboardNavy,
                  ),
                ),
                SizedBox(height: 6),
                Text('Demo account', style: TextStyle(color: Colors.blueGrey)),
              ],
            ),
          ),
          const SizedBox(height: 15),
          _profileOption(
            icon: Icons.person_outline_rounded,
            title: 'Personal Information',
            onTap: () => _showMessage('Profile editing will be added later.'),
          ),
          _profileOption(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            onTap: () =>
                _showMessage('Notification settings will be added later.'),
          ),
          _profileOption(
            icon: Icons.help_outline_rounded,
            title: 'Help & Support',
            onTap: () => _showMessage('Help and support will be added later.'),
          ),
          _profileOption(
            icon: Icons.logout_rounded,
            title: 'Log Out',
            onTap: _confirmLogout,
          ),
        ],
      ),
    );
  }

  void _confirmLogout() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Log Out'),
          content: const Text('Do you want to return to the login screen?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text('Log Out'),
            ),
          ],
        );
      },
    );
  }

  // ---------------------------------------------------------
  // REUSABLE COMPONENTS
  // ---------------------------------------------------------

  Widget _pageContainer({
    required String title,
    required String subtitle,
    required Widget child,
    Widget? action,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: dashboardNavy,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.blueGrey),
                  ),
                  if (action != null) ...[const SizedBox(height: 18), action],
                  const SizedBox(height: 22),
                  child,
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _emptyCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5EAF0)),
      ),
      child: Column(
        children: [
          Icon(icon, color: dashboardBlue, size: 38),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: dashboardNavy,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.blueGrey, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _profileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE5EAF0)),
      ),
      child: ListTile(
        leading: Icon(icon, color: dashboardBlue),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}

// ---------------------------------------------------------
// STAT CARD
// ---------------------------------------------------------

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(19),
      child: Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(19),
          border: Border.all(color: const Color(0xFFE5EAF0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 21),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Colors.blueGrey,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 13),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 27,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.blueGrey, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// QUICK ACTION
// ---------------------------------------------------------

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE5EAF0)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: dashboardBlue, size: 29),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: dashboardNavy,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// UPCOMING BOOKING TILE
// ---------------------------------------------------------

class _BookingTile extends StatelessWidget {
  final Map<String, String> booking;
  final VoidCallback onTap;

  const _BookingTile({required this.booking, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFFE5EAF0)),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(16),
        leading: const CircleAvatar(
          radius: 25,
          backgroundColor: Color(0xFFEAF3FF),
          child: Icon(Icons.build_rounded, color: dashboardBlue),
        ),
        title: Text(
          booking['service'] ?? 'Service',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: dashboardNavy,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 7),
          child: Text(
            '${booking['workshop'] ?? ''}\n'
            '${booking['date'] ?? ''} • ${booking['time'] ?? ''}',
          ),
        ),
        isThreeLine: true,
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: Colors.blueGrey,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// RECENT ACTIVITY TILE
// ---------------------------------------------------------

class _ActivityTile extends StatelessWidget {
  final Map<String, String> activity;

  const _ActivityTile({required this.activity});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(17),
        side: const BorderSide(color: Color(0xFFE5EAF0)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFE3F4F1),
          child: Icon(Icons.check_circle_rounded, color: Colors.teal),
        ),
        title: Text(
          activity['service'] ?? 'Service',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: dashboardNavy,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(
            '${activity['vehicle'] ?? ''} • '
            '${activity['status'] ?? ''}',
          ),
        ),
        trailing: Text(
          activity['date'] ?? '',
          style: const TextStyle(fontSize: 10, color: Colors.blueGrey),
        ),
      ),
    );
  }
}
