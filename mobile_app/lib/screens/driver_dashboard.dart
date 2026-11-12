import 'package:material_ui/material_ui.dart';

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

  // Demo driver account details. These will later be linked to Firebase.
  String _driverName = 'Driver Account';
  String _driverEmail = 'driver@example.com';
  String _driverPhone = '0301-9876543';
  final String _licenceNumber = 'DL-123456';
  final String _licenceExpiry = '31 Dec 2027';
  final bool _tripNotifications = true;
  final bool _maintenanceNotifications = true;
  final bool _ownerNotifications = true;
  final Set<String> _acknowledgedMaintenance = {};

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

  int get upcomingTrips => trips
      .where((t) => t['status'] == 'Upcoming' || t['status'] == 'In Progress')
      .length;

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _openNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _DriverNotificationsPage(
          trips: trips,
          maintenance: maintenance,
          tripNotifications: _tripNotifications,
          maintenanceNotifications: _maintenanceNotifications,
          ownerNotifications: _ownerNotifications,
        ),
      ),
    );
  }

  void _showOwnerContact() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Vehicle Owner Contact'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _dialogDetail('Name', owner['name']),
            _dialogDetail('Phone', owner['phone']),
            _dialogDetail('Email', owner['email']),
            const SizedBox(height: 8),
            const Text(
              'Your assigned vehicles and duties are managed by this owner.',
              style: TextStyle(color: Colors.blueGrey, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _dialogDetail(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 62,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value ?? 'Not provided')),
        ],
      ),
    );
  }

  void _showTripDetails(Map<String, String> trip) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final status = trip['status'] ?? 'Upcoming';
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        trip['title'] ?? 'Assigned Trip',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: driverNavy,
                        ),
                      ),
                    ),
                    _statusBadge(status),
                  ],
                ),
                const Divider(height: 25),
                _detailRow(
                  Icons.directions_car,
                  'Vehicle',
                  trip['vehicle'] ?? '',
                ),
                _detailRow(
                  Icons.calendar_today,
                  'Date & Time',
                  '${trip['date']} • ${trip['time']}',
                ),
                _detailRow(Icons.my_location, 'Pickup', trip['pickup'] ?? ''),
                _detailRow(
                  Icons.location_on_outlined,
                  'Destination',
                  trip['destination'] ?? '',
                ),
                const SizedBox(height: 8),
                if (status == 'Upcoming')
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() => trip['status'] = 'In Progress');
                        Navigator.pop(sheetContext);
                        _showMessage('Trip marked as In Progress.');
                      },
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Start Trip'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: driverBlue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  )
                else if (status == 'In Progress')
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() => trip['status'] = 'Completed');
                        Navigator.pop(sheetContext);
                        _showMessage('Trip marked as Completed.');
                      },
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Complete Trip'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  )
                else
                  const Text(
                    'This trip has been completed.',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showMaintenanceDetails(Map<String, String> item) {
    final key = '${item['vehicle']}_${item['task']}';
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(item['task'] ?? 'Maintenance Reminder'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _dialogDetail('Vehicle', item['vehicle']),
            _dialogDetail('Due date', item['date']),
            _dialogDetail('Status', item['status']),
            const SizedBox(height: 8),
            const Text(
              'Please coordinate with the vehicle owner before arranging maintenance.',
              style: TextStyle(color: Colors.blueGrey, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
          if (!_acknowledgedMaintenance.contains(key))
            TextButton(
              onPressed: () {
                setState(() => _acknowledgedMaintenance.add(key));
                Navigator.pop(dialogContext);
                _showMessage('Reminder acknowledged.');
              },
              child: const Text('Acknowledge'),
            )
          else
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'Acknowledged',
                style: TextStyle(color: Colors.green),
              ),
            ),
        ],
      ),
    );
  }

  void _openProfilePage(String page) async {
    switch (page) {
      case 'Personal Information':
        final result = await Navigator.push<Map<String, String>>(
          context,
          MaterialPageRoute(
            builder: (_) => _DriverPersonalInfoPage(
              name: _driverName,
              email: _driverEmail,
              phone: _driverPhone,
            ),
          ),
        );
        if (!mounted || result == null) return;
        setState(() {
          _driverName = result['name'] ?? _driverName;
          _driverEmail = result['email'] ?? _driverEmail;
          _driverPhone = result['phone'] ?? _driverPhone;
        });
        _showMessage('Personal information updated.');
        break;
      case 'Driving Licence':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => _DriverLicencePage(
              licenceNumber: _licenceNumber,
              expiry: _licenceExpiry,
            ),
          ),
        );
        break;
      case 'Verification Status':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const _DriverVerificationPage()),
        );
        break;
      case 'Owner Contact Details':
        _showOwnerContact();
        break;
      case 'Help & Support':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const _DriverHelpPage()),
        );
        break;
      case 'Log Out':
        _confirmLogout();
        break;
    }
  }

  void _confirmLogout() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text(
          'Are you sure you want to log out of your driver account?',
        ),
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
            child: const Text('Log Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
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
            onPressed: _openNotifications,
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
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: _showOwnerContact,
      child: _card(
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
                    style: const TextStyle(
                      color: Colors.blueGrey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.verified, color: Colors.green),
          ],
        ),
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
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => _showTripDetails(trip),
      child: _card(
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
      ),
    );
  }

  // TRIP HISTORY PAGE

  String _tripFilter = 'All';

  Widget _buildTripsPage() {
    final visibleTrips = trips.where((trip) {
      if (_tripFilter == 'All') return true;
      return trip['status'] == _tripFilter;
    }).toList();
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
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['All', 'Upcoming', 'In Progress', 'Completed'].map((
              filter,
            ) {
              final selected = _tripFilter == filter;
              return ChoiceChip(
                label: Text(filter),
                selected: selected,
                selectedColor: const Color(0xFFE7F0FF),
                onSelected: (_) => setState(() => _tripFilter = filter),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          if (visibleTrips.isEmpty)
            _emptyCard(
              Icons.route,
              'No trip records',
              'No trips match this status.',
            )
          else
            ...visibleTrips.map(_buildTripCard),
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
            initialValue: _selectedVehicleIndex,
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
    final reminderKey = '${item['vehicle']}_${item['task']}';
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => _showMaintenanceDetails(item),
      child: _card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            const Icon(
              Icons.build_circle_outlined,
              color: driverBlue,
              size: 32,
            ),
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
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.blueGrey,
                    ),
                  ),
                  Text(
                    'Due: ${item['date']}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.blueGrey,
                    ),
                  ),
                ],
              ),
            ),
            if (_acknowledgedMaintenance.contains(reminderKey))
              const Icon(Icons.check_circle, color: Colors.green)
            else
              _statusBadge(item['status']!),
          ],
        ),
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
          Text(
            _driverName,
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: driverNavy,
            ),
          ),
          const SizedBox(height: 6),
          Text(_driverEmail, style: TextStyle(color: Colors.blueGrey)),
          const SizedBox(height: 25),

          _profileOption(Icons.person_outline, 'Personal Information'),
          _profileOption(Icons.badge_outlined, 'Driving Licence'),
          _profileOption(Icons.verified_user_outlined, 'Verification Status'),
          _profileOption(Icons.contact_phone_outlined, 'Owner Contact Details'),
          _profileOption(Icons.notifications_outlined, 'Notifications'),
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
        onTap: title == 'Notifications'
            ? _openNotifications
            : () => _openProfilePage(title),
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
        color: color.withValues(alpha: 0.10),
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

// =========================================================
// DRIVER SUB-PAGES
// =========================================================

class _DriverPersonalInfoPage extends StatefulWidget {
  final String name;
  final String email;
  final String phone;

  const _DriverPersonalInfoPage({
    required this.name,
    required this.email,
    required this.phone,
  });

  @override
  State<_DriverPersonalInfoPage> createState() =>
      _DriverPersonalInfoPageState();
}

class _DriverPersonalInfoPageState extends State<_DriverPersonalInfoPage> {
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _phone;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.name);
    _email = TextEditingController(text: widget.email);
    _phone = TextEditingController(text: widget.phone);
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _save() {
    if (_name.text.trim().isEmpty || _email.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name and email are required.')),
      );
      return;
    }
    Navigator.pop(context, {
      'name': _name.text.trim(),
      'email': _email.text.trim(),
      'phone': _phone.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: driverBackground,
      appBar: AppBar(
        title: const Text('Personal Information'),
        backgroundColor: Colors.white,
        foregroundColor: driverNavy,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _field('Full Name', _name, Icons.person_outline),
          _field(
            'Email Address',
            _email,
            Icons.email_outlined,
            type: TextInputType.emailAddress,
          ),
          _field(
            'Phone Number',
            _phone,
            Icons.phone_outlined,
            type: TextInputType.phone,
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: driverBlue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Save Changes'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType type = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: driverBlue),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(13)),
        ),
      ),
    );
  }
}

class _DriverLicencePage extends StatelessWidget {
  final String licenceNumber;
  final String expiry;

  const _DriverLicencePage({required this.licenceNumber, required this.expiry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: driverBackground,
      appBar: AppBar(
        title: const Text('Driving Licence'),
        backgroundColor: Colors.white,
        foregroundColor: driverNavy,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Card(
          color: Colors.white,
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.badge_outlined, color: driverBlue, size: 42),
                const SizedBox(height: 16),
                _line('Licence Number', licenceNumber),
                _line('Expiry Date', expiry),
                _line('Record Status', 'Demo record — verification pending'),
                const SizedBox(height: 10),
                const Text(
                  'Licence details are demonstration data. Actual documents and verification will be connected later.',
                  style: TextStyle(color: Colors.blueGrey, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _line(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.blueGrey, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: driverNavy,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

class _DriverVerificationPage extends StatelessWidget {
  const _DriverVerificationPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: driverBackground,
      appBar: AppBar(
        title: const Text('Verification Status'),
        backgroundColor: Colors.white,
        foregroundColor: driverNavy,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          Card(
            color: Colors.white,
            elevation: 0,
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(Icons.pending_actions, color: Colors.orange, size: 48),
                  SizedBox(height: 12),
                  Text(
                    'Demo Verification',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: driverNavy,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'No live identity or licence verification is connected yet. Verification status will be updated when the owner/admin verification workflow is implemented.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.blueGrey, height: 1.4),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DriverNotificationsPage extends StatelessWidget {
  final List<Map<String, String>> trips;
  final List<Map<String, String>> maintenance;
  final bool tripNotifications;
  final bool maintenanceNotifications;
  final bool ownerNotifications;

  const _DriverNotificationsPage({
    required this.trips,
    required this.maintenance,
    required this.tripNotifications,
    required this.maintenanceNotifications,
    required this.ownerNotifications,
  });

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];
    if (tripNotifications) {
      for (final trip in trips.where(
        (t) => t['status'] == 'Upcoming' || t['status'] == 'In Progress',
      )) {
        items.add(
          _notificationTile(
            Icons.route,
            'Assigned trip: ${trip['title']}',
            '${trip['date']} • ${trip['time']}',
          ),
        );
      }
    }
    if (maintenanceNotifications) {
      for (final item in maintenance) {
        items.add(
          _notificationTile(
            Icons.build_circle_outlined,
            '${item['task']} reminder',
            '${item['vehicle']} • Due ${item['date']}',
          ),
        );
      }
    }
    if (ownerNotifications) {
      items.add(
        _notificationTile(
          Icons.person_outline,
          'Vehicle owner',
          'Your assigned vehicles and duties are managed by ${'Ahmed Faisal'}.',
        ),
      );
    }

    return Scaffold(
      backgroundColor: driverBackground,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.white,
        foregroundColor: driverNavy,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Your Updates',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: driverNavy,
            ),
          ),
          const SizedBox(height: 14),
          if (items.isEmpty)
            const Card(
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.all(22),
                child: Text(
                  'Notifications are turned off or there are no current updates.',
                ),
              ),
            )
          else
            ...items,
        ],
      ),
    );
  }

  Widget _notificationTile(IconData icon, String title, String subtitle) {
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFEAF3FF),
          child: Icon(icon, color: driverBlue),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
      ),
    );
  }
}

class _DriverHelpPage extends StatelessWidget {
  const _DriverHelpPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: driverBackground,
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: Colors.white,
        foregroundColor: driverNavy,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Driver Help',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: driverNavy,
            ),
          ),
          const SizedBox(height: 14),
          _faq(
            'Who assigns my vehicles?',
            'Your linked vehicle owner assigns vehicles to you. You cannot add or remove owner vehicles from the driver account.',
          ),
          _faq(
            'Who assigns my trips?',
            'Trips and duty details are assigned by your linked vehicle owner. Contact the owner if a trip detail needs to be changed.',
          ),
          _faq(
            'How do I update a trip?',
            'Open the trip details. You can mark an upcoming trip as In Progress and then mark it Completed when the journey is finished.',
          ),
          _faq(
            'What should I do about maintenance reminders?',
            'Review the vehicle and due date, acknowledge the reminder, and coordinate with the vehicle owner before arranging maintenance.',
          ),
          _faq(
            'Are changes saved permanently?',
            'This version uses local demo data. Changes reset when the app restarts. Firebase synchronization will be added later.',
          ),
        ],
      ),
    );
  }

  Widget _faq(String question, String answer) {
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              answer,
              style: const TextStyle(color: Colors.blueGrey, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
