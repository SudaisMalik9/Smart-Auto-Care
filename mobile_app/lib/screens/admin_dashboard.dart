import 'package:flutter/material.dart';

const Color adminBlue = Color(0xFF1565C0);
const Color adminNavy = Color(0xFF102A43);
const Color adminBackground = Color(0xFFF5F7FB);

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int selectedIndex = 0;
  String userFilter = 'All';
  String bookingFilter = 'All';

  final List<Map<String, dynamic>> users = [
    {
      'name': 'Ali Ahmed',
      'email': 'ali@example.com',
      'role': 'Vehicle Owner',
      'phone': '0301-1234567',
      'status': 'Active',
    },
    {
      'name': 'Usman Khan',
      'email': 'usman@example.com',
      'role': 'Driver',
      'phone': '0302-1234567',
      'status': 'Active',
    },
    {
      'name': 'Ahmed Faisal',
      'email': 'ahmed@example.com',
      'role': 'Vehicle Owner',
      'phone': '0303-1234567',
      'status': 'Active',
    },
    {
      'name': 'Hassan Raza',
      'email': 'hassan@example.com',
      'role': 'Driver',
      'phone': '0304-1234567',
      'status': 'Inactive',
    },
    {
      'name': 'City Auto Workshop',
      'email': 'city@example.com',
      'role': 'Workshop',
      'phone': '0305-1234567',
      'status': 'Active',
    },
  ];

  final List<Map<String, dynamic>> workshops = [
    {
      'name': 'AutoCare Premium Workshop',
      'location': 'Saddar, Rawalpindi',
      'phone': '0300-1111111',
      'status': 'Verified',
    },
    {
      'name': 'Elite Motors Service Centre',
      'location': 'Commercial Market, Rawalpindi',
      'phone': '0300-2222222',
      'status': 'Pending',
    },
    {
      'name': 'QuickFix Auto Workshop',
      'location': 'Bahria Town, Rawalpindi',
      'phone': '0300-3333333',
      'status': 'Verified',
    },
    {
      'name': 'City Motors Garage',
      'location': 'Chaklala, Rawalpindi',
      'phone': '0300-4444444',
      'status': 'Pending',
    },
  ];

  final List<Map<String, dynamic>> bookings = [
    {
      'customer': 'Ali Ahmed',
      'workshop': 'AutoCare Premium Workshop',
      'vehicle': 'Honda Civic',
      'service': 'General Maintenance',
      'date': '02 Nov 2026',
      'status': 'Pending',
    },
    {
      'customer': 'Usman Khan',
      'workshop': 'Elite Motors Service Centre',
      'vehicle': 'Toyota Corolla',
      'service': 'Oil Change',
      'date': '02 Nov 2026',
      'status': 'Accepted',
    },
    {
      'customer': 'Hassan Raza',
      'workshop': 'QuickFix Auto Workshop',
      'vehicle': 'Suzuki Alto',
      'service': 'Brake Inspection',
      'date': '01 Nov 2026',
      'status': 'In Progress',
    },
    {
      'customer': 'Ahmed Faisal',
      'workshop': 'City Motors Garage',
      'vehicle': 'Honda City',
      'service': 'Car Wash',
      'date': '31 Oct 2026',
      'status': 'Completed',
    },
  ];

  final List<Map<String, String>> vehicles = [
    {
      'owner': 'Ali Ahmed',
      'name': 'Honda Civic',
      'registration': 'ABC-123',
      'year': '2022',
    },
    {
      'owner': 'Ahmed Faisal',
      'name': 'Toyota Corolla',
      'registration': 'XYZ-456',
      'year': '2023',
    },
    {
      'owner': 'Ali Ahmed',
      'name': 'Suzuki Alto',
      'registration': 'LEA-789',
      'year': '2021',
    },
  ];

  int get activeUsers => users.where((u) => u['status'] == 'Active').length;

  int get verifiedWorkshops =>
      workshops.where((w) => w['status'] == 'Verified').length;

  int get pendingWorkshops =>
      workshops.where((w) => w['status'] == 'Pending').length;

  int get completedBookings =>
      bookings.where((b) => b['status'] == 'Completed').length;

  void showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void updateUserStatus(Map<String, dynamic> user) {
    setState(() {
      user['status'] = user['status'] == 'Active' ? 'Inactive' : 'Active';
    });
    showMessage('${user['name']} status updated.');
  }

  void updateWorkshopStatus(Map<String, dynamic> workshop, String status) {
    setState(() {
      workshop['status'] = status;
    });
    showMessage('${workshop['name']} is now $status.');
  }

  void updateBookingStatus(Map<String, dynamic> booking, String status) {
    setState(() {
      booking['status'] = status;
    });
    showMessage('Booking status updated to $status.');
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      buildHome(),
      buildUsersPage(),
      buildWorkshopsPage(),
      buildBookingsPage(),
      buildVehiclesPage(),
      buildReportsPage(),
      buildSettingsPage(),
    ];

    return Scaffold(
      backgroundColor: adminBackground,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final desktop = constraints.maxWidth >= 850;

          return Row(
            children: [
              if (desktop) buildSidebar(),
              Expanded(
                child: Column(
                  children: [
                    buildTopBar(desktop),
                    Expanded(
                      child: IndexedStack(
                        index: selectedIndex,
                        children: pages,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      drawer: MediaQuery.of(context).size.width < 850
          ? Drawer(child: buildSidebarContent())
          : null,
    );
  }

  // SIDEBAR

  Widget buildSidebar() {
    return Container(
      width: 245,
      color: adminNavy,
      child: buildSidebarContent(),
    );
  }

  Widget buildSidebarContent() {
    final labels = [
      'Dashboard',
      'User Management',
      'Workshops',
      'Bookings',
      'Vehicles',
      'Reports & Analytics',
      'Settings',
    ];

    final icons = [
      Icons.dashboard_outlined,
      Icons.people_outline,
      Icons.store_outlined,
      Icons.calendar_month_outlined,
      Icons.directions_car_outlined,
      Icons.bar_chart_outlined,
      Icons.settings_outlined,
    ];

    return Container(
      color: adminNavy,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(22),
            child: Row(
              children: [
                Icon(
                  Icons.directions_car_filled,
                  color: Colors.white,
                  size: 32,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Smart Auto Care',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white24),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: labels.length,
              itemBuilder: (context, index) {
                final selected = selectedIndex == index;

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  child: ListTile(
                    leading: Icon(
                      icons[index],
                      color: selected ? Colors.white : Colors.white70,
                    ),
                    title: Text(
                      labels[index],
                      style: TextStyle(
                        color: selected ? Colors.white : Colors.white70,
                        fontWeight: selected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: 13,
                      ),
                    ),
                    selected: selected,
                    selectedTileColor: adminBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    onTap: () {
                      setState(() => selectedIndex = index);
                      if (MediaQuery.of(context).size.width < 850) {
                        Navigator.pop(context);
                      }
                    },
                  ),
                );
              },
            ),
          ),
          const Divider(color: Colors.white24),
          const ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.white24,
              child: Icon(Icons.admin_panel_settings, color: Colors.white),
            ),
            title: Text(
              'Administrator',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              'System Admin',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // TOP BAR

  Widget buildTopBar(bool desktop) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      color: Colors.white,
      child: Row(
        children: [
          if (!desktop)
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu, color: adminNavy),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
          Expanded(
            child: Text(
              [
                'Dashboard',
                'User Management',
                'Workshop Management',
                'Booking Management',
                'Vehicle Management',
                'Reports & Analytics',
                'System Settings',
              ][selectedIndex],
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: adminNavy,
              ),
            ),
          ),
          IconButton(
            onPressed: () => showMessage('No new notifications.'),
            icon: const Icon(Icons.notifications_none, color: adminNavy),
          ),
          const CircleAvatar(
            backgroundColor: Color(0xFFEAF3FF),
            child: Icon(Icons.admin_panel_settings, color: adminBlue),
          ),
        ],
      ),
    );
  }

  // HOME

  Widget buildHome() {
    return pageLayout(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome, Administrator! 👋',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: adminNavy,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Monitor and manage the Smart Auto Care platform.',
            style: TextStyle(color: Colors.blueGrey),
          ),
          const SizedBox(height: 25),

          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width > 900 ? 4 : 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 1.5,
            children: [
              statCard(
                'Total Users',
                '${users.length}',
                Icons.people_outline,
                adminBlue,
              ),
              statCard(
                'Active Users',
                '$activeUsers',
                Icons.verified_user_outlined,
                Colors.green,
              ),
              statCard(
                'Workshops',
                '${workshops.length}',
                Icons.store_outlined,
                Colors.deepPurple,
              ),
              statCard(
                'Vehicles',
                '${vehicles.length}',
                Icons.directions_car_outlined,
                Colors.orange,
              ),
              statCard(
                'Total Bookings',
                '${bookings.length}',
                Icons.calendar_month,
                adminBlue,
              ),
              statCard(
                'Pending Workshops',
                '$pendingWorkshops',
                Icons.pending_actions,
                Colors.orange,
              ),
              statCard(
                'Verified Workshops',
                '$verifiedWorkshops',
                Icons.verified,
                Colors.green,
              ),
              statCard(
                'Completed Services',
                '$completedBookings',
                Icons.check_circle_outline,
                Colors.teal,
              ),
            ],
          ),

          const SizedBox(height: 28),

          const Text('Recent Bookings', style: headingStyle),
          const SizedBox(height: 14),

          ...bookings.take(3).map(buildBookingCard),

          const SizedBox(height: 25),

          const Text('Workshop Verification Requests', style: headingStyle),
          const SizedBox(height: 14),

          ...workshops
              .where((w) => w['status'] == 'Pending')
              .map(buildWorkshopCard),
        ],
      ),
    );
  }

  // STAT CARD

  Widget statCard(String title, String value, IconData icon, Color color) {
    return card(
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
              color: adminNavy,
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

  // USERS PAGE

  Widget buildUsersPage() {
    final filtered = users.where((user) {
      return userFilter == 'All' || user['role'] == userFilter;
    }).toList();

    return pageLayout(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('User Management', style: headingStyle),
          const SizedBox(height: 8),
          const Text(
            'View and manage registered platform accounts.',
            style: TextStyle(color: Colors.blueGrey),
          ),
          const SizedBox(height: 18),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['All', 'Vehicle Owner', 'Driver', 'Workshop'].map((
              filter,
            ) {
              return ChoiceChip(
                label: Text(filter),
                selected: userFilter == filter,
                selectedColor: const Color(0xFFDCEBFF),
                onSelected: (_) {
                  setState(() => userFilter = filter);
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 18),

          ...filtered.map(buildUserCard),
        ],
      ),
    );
  }

  Widget buildUserCard(Map<String, dynamic> user) {
    return card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xFFEAF3FF),
            child: Icon(Icons.person_outline, color: adminBlue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['name'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: adminNavy,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user['email'],
                  style: const TextStyle(color: Colors.blueGrey, fontSize: 12),
                ),
                Text(
                  '${user['role']} • ${user['phone']}',
                  style: const TextStyle(color: Colors.blueGrey, fontSize: 11),
                ),
                const SizedBox(height: 6),
                statusBadge(user['status']),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'toggle') {
                updateUserStatus(user);
              } else {
                showUserDetails(user);
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'details', child: Text('View Details')),
              PopupMenuItem(
                value: 'toggle',
                child: Text('Change Account Status'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void showUserDetails(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('User Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${user['name']}'),
            Text('Email: ${user['email']}'),
            Text('Phone: ${user['phone']}'),
            Text('Role: ${user['role']}'),
            Text('Status: ${user['status']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // WORKSHOPS PAGE

  Widget buildWorkshopsPage() {
    return pageLayout(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Workshop Management', style: headingStyle),
          const SizedBox(height: 8),
          const Text(
            'Review workshop registration and verification.',
            style: TextStyle(color: Colors.blueGrey),
          ),
          const SizedBox(height: 20),

          ...workshops.map(buildWorkshopCard),
        ],
      ),
    );
  }

  Widget buildWorkshopCard(Map<String, dynamic> workshop) {
    return card(
      margin: const EdgeInsets.only(bottom: 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Color(0xFFEAF3FF),
                child: Icon(Icons.store, color: adminBlue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  workshop['name'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: adminNavy,
                  ),
                ),
              ),
              statusBadge(workshop['status']),
            ],
          ),
          const SizedBox(height: 13),
          detailRow(
            Icons.location_on_outlined,
            'Location',
            workshop['location'],
          ),
          detailRow(Icons.phone_outlined, 'Contact', workshop['phone']),
          const SizedBox(height: 12),

          if (workshop['status'] == 'Pending')
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => updateWorkshopStatus(workshop, 'Rejected'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                    child: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => updateWorkshopStatus(workshop, 'Verified'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: adminBlue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Verify Workshop'),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  // BOOKINGS PAGE

  Widget buildBookingsPage() {
    final filtered = bookings.where((booking) {
      return bookingFilter == 'All' || booking['status'] == bookingFilter;
    }).toList();

    return pageLayout(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Booking Management', style: headingStyle),
          const SizedBox(height: 8),
          const Text(
            'Monitor service bookings across the platform.',
            style: TextStyle(color: Colors.blueGrey),
          ),
          const SizedBox(height: 18),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['All', 'Pending', 'Accepted', 'In Progress', 'Completed']
                .map((filter) {
                  return ChoiceChip(
                    label: Text(filter),
                    selected: bookingFilter == filter,
                    selectedColor: const Color(0xFFDCEBFF),
                    onSelected: (_) {
                      setState(() => bookingFilter = filter);
                    },
                  );
                })
                .toList(),
          ),

          const SizedBox(height: 18),

          ...filtered.map(buildBookingCard),
        ],
      ),
    );
  }

  Widget buildBookingCard(Map<String, dynamic> booking) {
    return card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_month, color: adminBlue),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  booking['service'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: adminNavy,
                  ),
                ),
              ),
              statusBadge(booking['status']),
            ],
          ),
          const Divider(height: 23),
          detailRow(Icons.person_outline, 'Customer', booking['customer']),
          detailRow(Icons.store_outlined, 'Workshop', booking['workshop']),
          detailRow(Icons.directions_car, 'Vehicle', booking['vehicle']),
          detailRow(Icons.calendar_today, 'Date', booking['date']),
        ],
      ),
    );
  }

  // VEHICLES PAGE

  Widget buildVehiclesPage() {
    return pageLayout(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Vehicle Management', style: headingStyle),
          const SizedBox(height: 8),
          const Text(
            'View vehicles registered by platform users.',
            style: TextStyle(color: Colors.blueGrey),
          ),
          const SizedBox(height: 20),

          ...vehicles.map((vehicle) {
            return card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Color(0xFFEAF3FF),
                    child: Icon(Icons.directions_car, color: adminBlue),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vehicle['name']!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: adminNavy,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Registration: ${vehicle['registration']}',
                          style: const TextStyle(
                            color: Colors.blueGrey,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          'Owner: ${vehicle['owner']}',
                          style: const TextStyle(
                            color: Colors.blueGrey,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          'Model year: ${vehicle['year']}',
                          style: const TextStyle(
                            color: Colors.blueGrey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // REPORTS PAGE

  Widget buildReportsPage() {
    final total = bookings.length;
    final completed = completedBookings;
    final pending = bookings.where((b) => b['status'] == 'Pending').length;
    final inProgress = bookings
        .where((b) => b['status'] == 'In Progress')
        .length;

    return pageLayout(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Reports & Analytics', style: headingStyle),
          const SizedBox(height: 8),
          const Text(
            'Summary of Smart Auto Care platform activity.',
            style: TextStyle(color: Colors.blueGrey),
          ),
          const SizedBox(height: 22),

          card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Booking Statistics',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: adminNavy,
                  ),
                ),
                const SizedBox(height: 20),
                reportBar('Completed', completed, total, Colors.green),
                reportBar('Pending', pending, total, Colors.orange),
                reportBar('In Progress', inProgress, total, Colors.deepPurple),
                reportBar('Accepted', acceptedCount, total, adminBlue),
              ],
            ),
          ),

          const SizedBox(height: 18),

          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width > 650 ? 3 : 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              statCard(
                'Registered Users',
                '${users.length}',
                Icons.people,
                adminBlue,
              ),
              statCard(
                'Registered Vehicles',
                '${vehicles.length}',
                Icons.directions_car,
                Colors.orange,
              ),
              statCard(
                'Workshops',
                '${workshops.length}',
                Icons.store,
                Colors.deepPurple,
              ),
            ],
          ),

          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () =>
                  showMessage('Report export will be implemented later.'),
              icon: const Icon(Icons.download_outlined),
              label: const Text('Export Report'),
            ),
          ),
        ],
      ),
    );
  }

  int get acceptedCount =>
      bookings.where((b) => b['status'] == 'Accepted').length;

  Widget reportBar(String label, int value, int total, Color color) {
    final progress = total == 0 ? 0.0 : value / total;

    return Padding(
      padding: const EdgeInsets.only(bottom: 19),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label),
              Text(
                '$value',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              color: color,
              backgroundColor: const Color(0xFFE9EEF4),
            ),
          ),
        ],
      ),
    );
  }

  // SETTINGS PAGE

  Widget buildSettingsPage() {
    return pageLayout(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('System Settings', style: headingStyle),
          const SizedBox(height: 8),
          const Text(
            'Manage administrator account and platform settings.',
            style: TextStyle(color: Colors.blueGrey),
          ),
          const SizedBox(height: 22),

          card(
            child: const Column(
              children: [
                CircleAvatar(
                  radius: 38,
                  backgroundColor: Color(0xFFEAF3FF),
                  child: Icon(
                    Icons.admin_panel_settings,
                    color: adminBlue,
                    size: 42,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'System Administrator',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: adminNavy,
                  ),
                ),
                Text(
                  'admin@smartautocare.com',
                  style: TextStyle(color: Colors.blueGrey),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          settingTile(Icons.person_outline, 'Administrator Profile'),
          settingTile(Icons.security_outlined, 'Security & Password'),
          settingTile(Icons.notifications_outlined, 'Notification Settings'),
          settingTile(Icons.language_outlined, 'Language Settings'),
          settingTile(Icons.info_outline, 'About Smart Auto Care'),
          settingTile(Icons.help_outline, 'Help & Support'),
          settingTile(Icons.logout, 'Log Out'),
        ],
      ),
    );
  }

  Widget settingTile(IconData icon, String title) {
    return card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon, color: adminBlue),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => showMessage('$title will be implemented later.'),
      ),
    );
  }

  // REUSABLE COMPONENTS

  Widget pageLayout({required Widget child}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(22),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1150),
          child: child,
        ),
      ),
    );
  }

  Widget card({required Widget child, EdgeInsetsGeometry? margin}) {
    return Container(
      width: double.infinity,
      margin: margin,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5EAF0)),
      ),
      child: child,
    );
  }

  Widget detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: adminBlue),
          const SizedBox(width: 9),
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                color: adminNavy,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget statusBadge(String status) {
    Color color;

    switch (status) {
      case 'Active':
      case 'Verified':
      case 'Completed':
        color = Colors.green;
        break;
      case 'Inactive':
      case 'Rejected':
        color = Colors.red;
        break;
      case 'Pending':
        color = Colors.orange;
        break;
      case 'In Progress':
        color = Colors.deepPurple;
        break;
      default:
        color = adminBlue;
    }

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

  static const TextStyle headingStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: adminNavy,
  );
}
