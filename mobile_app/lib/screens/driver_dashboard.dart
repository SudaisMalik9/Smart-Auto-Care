import 'package:flutter/material.dart';

const Color driverBlue = Color(0xFF1565C0);
const Color driverNavy = Color(0xFF102A43);
const Color driverBackground = Color(0xFFF5F7FB);

class DriverDashboard extends StatefulWidget {
  const DriverDashboard({super.key});

  @override
  State<DriverDashboard> createState() => _DriverDashboardState();
}

class _DriverDashboardState extends State<DriverDashboard> {
  int _selectedIndex = 0;
  int _selectedVehicleIndex = 0;

  final Map<String, String> owner = {
    'name': 'Ahmed Faisal',
    'phone': '0300-1234567',
    'email': 'owner@example.com',
  };

  final List<Map<String, String>> vehicles = [
    {
      'name': 'Toyota Corolla',
      'registration': 'ABC-123',
      'year': '2022',
      'color': 'White',
      'type': 'Sedan',
      'fuel': 'Petrol',
      'status': 'Active',
    },
    {
      'name': 'Honda Civic',
      'registration': 'XYZ-456',
      'year': '2023',
      'color': 'Black',
      'type': 'Sedan',
      'fuel': 'Petrol',
      'status': 'Active',
    },
    {
      'name': 'Suzuki Alto',
      'registration': 'LEA-789',
      'year': '2021',
      'color': 'Silver',
      'type': 'Hatchback',
      'fuel': 'Petrol',
      'status': 'Active',
    },
  ];

  final List<Map<String, String>> trips = [
    {
      'title': 'Office Duty',
      'vehicle': 'Toyota Corolla',
      'date': '01 Nov 2026',
      'time': '08:00 AM',
      'pickup': 'Home',
      'destination': 'Owner Office',
      'status': 'Upcoming',
    },
    {
      'title': 'Family Trip',
      'vehicle': 'Honda Civic',
      'date': '31 Oct 2026',
      'time': '05:00 PM',
      'pickup': 'Home',
      'destination': 'Islamabad',
      'status': 'Completed',
    },
    {
      'title': 'Shopping Trip',
      'vehicle': 'Suzuki Alto',
      'date': '30 Oct 2026',
      'time': '11:00 AM',
      'pickup': 'Home',
      'destination': 'Commercial Market',
      'status': 'Completed',
    },
  ];

  final List<Map<String, String>> maintenance = [
    {
      'vehicle': 'Toyota Corolla',
      'task': 'Engine Oil Change',
      'date': '05 Nov 2026',
      'status': 'Due Soon',
    },
    {
      'vehicle': 'Honda Civic',
      'task': 'Tyre Inspection',
      'date': '10 Nov 2026',
      'status': 'Upcoming',
    },
  ];

  final List<Map<String, String>> schedule = [
    {
      'day': 'Monday - Friday',
      'time': '08:00 AM - 06:00 PM',
      'task': 'Regular Duty',
    },
    {
      'day': 'Saturday',
      'time': '09:00 AM - 02:00 PM',
      'task': 'As Assigned by Owner',
    },
    {'day': 'Sunday', 'time': 'Day Off', 'task': 'Weekly Rest'},
  ];

  Map<String, String> get selectedVehicle => vehicles[_selectedVehicleIndex];

  int get completedTrips =>
      trips.where((t) => t['status'] == 'Completed').length;

  int get upcomingTrips => trips.where((t) => t['status'] == 'Upcoming').length;

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildHome(),
      _buildTripsPage(),
      _buildVehiclesPage(),
      _buildProfilePage(),
    ];

    return Scaffold(
      backgroundColor: driverBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: driverNavy),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Row(
          children: [
            Icon(Icons.directions_car_filled, color: driverBlue),
            SizedBox(width: 10),
            Text(
              'Smart Auto Care',
              style: TextStyle(
                color: driverNavy,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: driverNavy),
            onPressed: () => _showMessage('No new notifications.'),
          ),
        ],
      ),
      body: SafeArea(
        child: IndexedStack(index: _selectedIndex, children: pages),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFE7F0FF),
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(
            icon: Icon(Icons.route_outlined),
            label: 'Trips',
          ),
          NavigationDestination(
            icon: Icon(Icons.directions_car_outlined),
            label: 'Vehicles',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  // HOME DASHBOARD

  Widget _buildHome() {
    return _pageLayout(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome, Driver! 👋',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: driverNavy,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Manage your assigned vehicles and daily duties.',
            style: TextStyle(color: Colors.blueGrey),
          ),

          const SizedBox(height: 22),

          _buildOwnerCard(),

          const SizedBox(height: 25),

          const Text("Today's Overview", style: _headingStyle),
          const SizedBox(height: 14),

          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width > 650 ? 3 : 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _statCard(
                'Assigned Vehicles',
                '${vehicles.length}',
                Icons.directions_car,
                driverBlue,
              ),
              _statCard(
                'Completed Trips',
                '$completedTrips',
                Icons.check_circle_outline,
                Colors.teal,
              ),
              _statCard(
                'Upcoming Trips',
                '$upcomingTrips',
                Icons.calendar_month,
                Colors.orange,
              ),
            ],
          ),

          const SizedBox(height: 25),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('My Assigned Vehicles', style: _headingStyle),
              TextButton(
                onPressed: () {
                  setState(() => _selectedIndex = 2);
                },
                child: const Text('View All'),
              ),
            ],
          ),

          const SizedBox(height: 10),

          ...vehicles.map(_buildVehicleCard),

          const SizedBox(height: 20),

          const Text('Today’s Duty Schedule', style: _headingStyle),
          const SizedBox(height: 12),

          _buildScheduleCard(),

          const SizedBox(height: 25),

          const Text('Upcoming Trips', style: _headingStyle),
          const SizedBox(height: 12),

          ...trips.where((t) => t['status'] == 'Upcoming').map(_buildTripCard),

          const SizedBox(height: 25),

          const Text('Maintenance Reminders', style: _headingStyle),
          const SizedBox(height: 12),

          ...maintenance.map(_buildMaintenanceCard),
        ],
      ),
    );
  }

  // OWNER INFORMATION

  Widget _buildOwnerCard() {
    return _card(
      child: Row(
        children: [
          const CircleAvatar(
            radius: 28,
            backgroundColor: Color(0xFFEAF3FF),
            child: Icon(Icons.person, color: driverBlue, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Vehicle Owner',
                  style: TextStyle(fontSize: 12, color: Colors.blueGrey),
                ),
                const SizedBox(height: 4),
                Text(
                  owner['name']!,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: driverNavy,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  owner['phone']!,
                  style: const TextStyle(color: Colors.blueGrey, fontSize: 12),
                ),
              ],
            ),
          ),
          const Icon(Icons.verified, color: Colors.green),
        ],
      ),
    );
  }

  // STATISTICS

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: driverNavy,
            ),
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
          ),
        ],
      ),
    );
  }

  // VEHICLE CARD

  Widget _buildVehicleCard(Map<String, String> vehicle) {
    return _card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF3FF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.directions_car_filled,
              color: driverBlue,
              size: 34,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vehicle['name']!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: driverNavy,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  vehicle['registration']!,
                  style: const TextStyle(color: Colors.blueGrey),
                ),
                const SizedBox(height: 4),
                Text(
                  '${vehicle['year']} • ${vehicle['color']} • ${vehicle['fuel']}',
                  style: const TextStyle(fontSize: 11, color: Colors.blueGrey),
                ),
              ],
            ),
          ),
          const Icon(Icons.verified, color: Colors.green),
        ],
      ),
    );
  }

  // DUTY SCHEDULE

  Widget _buildScheduleCard() {
    return _card(
      child: Column(
        children: schedule.map((item) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                const Icon(Icons.access_time, color: driverBlue),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['day']!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: driverNavy,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['task']!,
                        style: const TextStyle(
                          color: Colors.blueGrey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  item['time']!,
                  style: const TextStyle(
                    fontSize: 11,
                    color: driverBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // TRIP CARD

  Widget _buildTripCard(Map<String, String> trip) {
    return _card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.route, color: driverBlue),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  trip['title']!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: driverNavy,
                    fontSize: 16,
                  ),
                ),
              ),
              _statusBadge(trip['status']!),
            ],
          ),
          const Divider(height: 24),
          _detailRow(Icons.directions_car, 'Vehicle', trip['vehicle']!),
          _detailRow(
            Icons.calendar_today,
            'Date & Time',
            '${trip['date']} • ${trip['time']}',
          ),
          _detailRow(Icons.my_location, 'Pickup', trip['pickup']!),
          _detailRow(
            Icons.location_on_outlined,
            'Destination',
            trip['destination']!,
          ),
        ],
      ),
    );
  }

  // TRIP HISTORY PAGE

  Widget _buildTripsPage() {
    return _pageLayout(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Trip Records', style: _headingStyle),
          const SizedBox(height: 8),
          const Text(
            'View journeys assigned by your vehicle owner.',
            style: TextStyle(color: Colors.blueGrey),
          ),
          const SizedBox(height: 20),

          if (trips.isEmpty)
            _emptyCard(
              Icons.route,
              'No trip records',
              'Your assigned journeys will appear here.',
            )
          else
            ...trips.map(_buildTripCard),
        ],
      ),
    );
  }

  // VEHICLES PAGE

  Widget _buildVehiclesPage() {
    return _pageLayout(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('My Vehicles', style: _headingStyle),
          const SizedBox(height: 8),
          const Text(
            'Vehicles assigned to you by the owner.',
            style: TextStyle(color: Colors.blueGrey),
          ),
          const SizedBox(height: 20),

          const Text(
            'Select Vehicle',
            style: TextStyle(fontWeight: FontWeight.bold, color: driverNavy),
          ),
          const SizedBox(height: 10),

          DropdownButtonFormField<int>(
            value: _selectedVehicleIndex,
            isExpanded: true,
            decoration: const InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(),
            ),
            items: List.generate(
              vehicles.length,
              (index) => DropdownMenuItem(
                value: index,
                child: Text(
                  '${vehicles[index]['name']} - '
                  '${vehicles[index]['registration']}',
                ),
              ),
            ),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedVehicleIndex = value;
                });
              }
            },
          ),

          const SizedBox(height: 20),

          _buildSelectedVehicleDetails(),
        ],
      ),
    );
  }

  Widget _buildSelectedVehicleDetails() {
    final vehicle = selectedVehicle;

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Icon(
              Icons.directions_car_filled,
              size: 75,
              color: driverBlue,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              vehicle['name']!,
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: driverNavy,
              ),
            ),
          ),
          const SizedBox(height: 20),
          _detailRow(
            Icons.confirmation_number_outlined,
            'Registration',
            vehicle['registration']!,
          ),
          _detailRow(Icons.calendar_today, 'Model Year', vehicle['year']!),
          _detailRow(Icons.palette_outlined, 'Color', vehicle['color']!),
          _detailRow(Icons.category_outlined, 'Vehicle Type', vehicle['type']!),
          _detailRow(
            Icons.local_gas_station_outlined,
            'Fuel Type',
            vehicle['fuel']!,
          ),
          _detailRow(
            Icons.verified_outlined,
            'Assignment Status',
            vehicle['status']!,
          ),
        ],
      ),
    );
  }

  // MAINTENANCE CARD

  Widget _buildMaintenanceCard(Map<String, String> item) {
    return _card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const Icon(Icons.build_circle_outlined, color: driverBlue, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['task']!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: driverNavy,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item['vehicle']!,
                  style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
                ),
                Text(
                  'Due: ${item['date']}',
                  style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
                ),
              ],
            ),
          ),
          _statusBadge(item['status']!),
        ],
      ),
    );
  }

  // PROFILE PAGE

  Widget _buildProfilePage() {
    return _pageLayout(
      child: Column(
        children: [
          const CircleAvatar(
            radius: 48,
            backgroundColor: Color(0xFFEAF3FF),
            child: Icon(Icons.person, color: driverBlue, size: 55),
          ),
          const SizedBox(height: 14),
          const Text(
            'Driver Account',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: driverNavy,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'driver@example.com',
            style: TextStyle(color: Colors.blueGrey),
          ),
          const SizedBox(height: 25),

          _profileOption(Icons.person_outline, 'Personal Information'),
          _profileOption(Icons.badge_outlined, 'Driving Licence'),
          _profileOption(Icons.verified_user_outlined, 'Verification Status'),
          _profileOption(Icons.contact_phone_outlined, 'Owner Contact Details'),
          _profileOption(Icons.help_outline, 'Help & Support'),
          _profileOption(Icons.logout, 'Log Out'),
        ],
      ),
    );
  }

  Widget _profileOption(IconData icon, String title) {
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE5EAF0)),
      ),
      child: ListTile(
        leading: Icon(icon, color: driverBlue),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _showMessage('$title will be implemented later.'),
      ),
    );
  }

  // REUSABLE COMPONENTS

  Widget _pageLayout({required Widget child}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: child,
        ),
      ),
    );
  }

  Widget _card({required Widget child, EdgeInsetsGeometry? margin}) {
    return Container(
      width: double.infinity,
      margin: margin,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5EAF0)),
      ),
      child: child,
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 19, color: driverBlue),
          const SizedBox(width: 10),
          SizedBox(
            width: 105,
            child: Text(
              label,
              style: const TextStyle(color: Colors.blueGrey, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: driverNavy,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    final isDue = status == 'Due Soon';

    final color = status == 'Completed'
        ? Colors.green
        : isDue
        ? Colors.orange
        : driverBlue;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _emptyCard(IconData icon, String title, String subtitle) {
    return _card(
      child: Column(
        children: [
          Icon(icon, size: 40, color: driverBlue),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: driverNavy,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.blueGrey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  static const TextStyle _headingStyle = TextStyle(
    fontSize: 19,
    fontWeight: FontWeight.bold,
    color: driverNavy,
  );
}
