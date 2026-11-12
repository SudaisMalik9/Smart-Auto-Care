import 'package:material_ui/material_ui.dart';

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
  String userSearch = '';
  String adminName = 'System Administrator';
  String adminEmail = 'admin@smartautocare.com';
  bool bookingNotifications = true;
  bool securityNotifications = true;
  bool systemNotifications = true;
  String selectedLanguage = 'English';

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
            onPressed: showAdminNotifications,
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
      final matchesRole = userFilter == 'All' || user['role'] == userFilter;
      final query = userSearch.trim().toLowerCase();
      final matchesSearch =
          query.isEmpty ||
          user['name'].toString().toLowerCase().contains(query) ||
          user['email'].toString().toLowerCase().contains(query) ||
          user['phone'].toString().toLowerCase().contains(query);
      return matchesRole && matchesSearch;
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
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search by name, email or phone',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) => setState(() => userSearch = value),
                ),
              ),
              const SizedBox(width: 10),
              IconButton.filled(
                tooltip: 'Add user',
                onPressed: showAddUserDialog,
                icon: const Icon(Icons.person_add_alt_1),
              ),
            ],
          ),
          const SizedBox(height: 16),

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
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search by name, email or phone',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) => setState(() => userSearch = value),
                ),
              ),
              const SizedBox(width: 10),
              IconButton.filled(
                tooltip: 'Add user',
                onPressed: showAddUserDialog,
                icon: const Icon(Icons.person_add_alt_1),
              ),
            ],
          ),
          const SizedBox(height: 16),

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
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Wrap(
              spacing: 8,
              children: [
                TextButton.icon(
                  onPressed: () => showBookingDetails(booking),
                  icon: const Icon(Icons.visibility_outlined, size: 17),
                  label: const Text('Details'),
                ),
                PopupMenuButton<String>(
                  tooltip: 'Update booking status',
                  onSelected: (status) => updateBookingStatus(booking, status),
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'Pending',
                      child: Text('Mark Pending'),
                    ),
                    PopupMenuItem(
                      value: 'Accepted',
                      child: Text('Mark Accepted'),
                    ),
                    PopupMenuItem(
                      value: 'In Progress',
                      child: Text('Mark In Progress'),
                    ),
                    PopupMenuItem(
                      value: 'Completed',
                      child: Text('Mark Completed'),
                    ),
                    PopupMenuItem(
                      value: 'Cancelled',
                      child: Text('Mark Cancelled'),
                    ),
                  ],
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.edit_outlined, size: 17, color: adminBlue),
                        SizedBox(width: 5),
                        Text(
                          'Update status',
                          style: TextStyle(color: adminBlue),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void showBookingDetails(Map<String, dynamic> booking) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Booking Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Service: ${booking['service']}'),
            Text('Customer: ${booking['customer']}'),
            Text('Workshop: ${booking['workshop']}'),
            Text('Vehicle: ${booking['vehicle']}'),
            Text('Date: ${booking['date']}'),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Status: '),
                statusBadge(booking['status']),
              ],
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
            return InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => showVehicleDetails(vehicle),
              child: card(
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
              ),
            );
          }),
        ],
      ),
    );
  }

  void showVehicleDetails(Map<String, String> vehicle) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(vehicle['name'] ?? 'Vehicle Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Owner: ${vehicle['owner']}'),
            Text('Registration: ${vehicle['registration']}'),
            Text('Model year: ${vehicle['year']}'),
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
              onPressed: showReportPreview,
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
            child: Column(
              children: [
                const CircleAvatar(
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
                  adminName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: adminNavy,
                  ),
                ),
                Text(adminEmail, style: TextStyle(color: Colors.blueGrey)),
              ],
            ),
          ),

          const SizedBox(height: 20),

          settingTile(
            Icons.person_outline,
            'Administrator Profile',
            editAdminProfile,
          ),
          settingTile(
            Icons.security_outlined,
            'Security & Password',
            showSecuritySettings,
          ),
          settingTile(
            Icons.notifications_outlined,
            'Notification Settings',
            showNotificationSettings,
          ),
          settingTile(
            Icons.language_outlined,
            'Language Settings',
            showLanguageSettings,
          ),
          settingTile(Icons.info_outline, 'About Smart Auto Care', showAbout),
          settingTile(Icons.help_outline, 'Help & Support', showHelp),
          settingTile(Icons.logout, 'Log Out', confirmLogout),
        ],
      ),
    );
  }

  Widget settingTile(IconData icon, String title, VoidCallback onTap) {
    return card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon, color: adminBlue),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  // ADMIN ACTIONS

  void showAddUserDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    String role = 'Vehicle Owner';

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, dialogSetState) => AlertDialog(
          title: const Text('Add Platform User'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Full name'),
                ),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email address'),
                ),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Phone number'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: role,
                  decoration: const InputDecoration(labelText: 'User role'),
                  items: const [
                    DropdownMenuItem(
                      value: 'Vehicle Owner',
                      child: Text('Vehicle Owner'),
                    ),
                    DropdownMenuItem(value: 'Driver', child: Text('Driver')),
                    DropdownMenuItem(
                      value: 'Workshop',
                      child: Text('Workshop'),
                    ),
                  ],
                  onChanged: (value) =>
                      dialogSetState(() => role = value ?? role),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                final email = emailController.text.trim();
                final phone = phoneController.text.trim();
                if (name.isEmpty ||
                    email.isEmpty ||
                    phone.isEmpty ||
                    !email.contains('@')) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Enter a name, valid email and phone number.',
                      ),
                    ),
                  );
                  return;
                }
                setState(() {
                  users.add({
                    'name': name,
                    'email': email,
                    'role': role,
                    'phone': phone,
                    'status': 'Active',
                  });
                });
                Navigator.pop(dialogContext);
                showMessage('$name added as $role.');
              },
              child: const Text('Add User'),
            ),
          ],
        ),
      ),
    );
  }

  void editAdminProfile() {
    final nameController = TextEditingController(text: adminName);
    final emailController = TextEditingController(text: adminEmail);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Administrator Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Display name'),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email address'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isEmpty ||
                  !emailController.text.trim().contains('@')) {
                showMessage('Enter a name and valid email address.');
                return;
              }
              setState(() {
                adminName = nameController.text.trim();
                adminEmail = emailController.text.trim();
              });
              Navigator.pop(dialogContext);
              showMessage('Administrator profile updated.');
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void showSecuritySettings() {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Security & Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Current password'),
            ),
            TextField(
              controller: newController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'New password'),
            ),
            const SizedBox(height: 8),
            const Text(
              'Demo interface only. Password changes require authentication backend integration.',
              style: TextStyle(color: Colors.blueGrey, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              showMessage(
                'Password update requires Firebase Authentication integration.',
              );
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void showNotificationSettings() {
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, dialogSetState) => AlertDialog(
          title: const Text('Notification Settings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: const Text('Booking updates'),
                value: bookingNotifications,
                onChanged: (v) {
                  dialogSetState(() => bookingNotifications = v);
                  setState(() {});
                },
              ),
              SwitchListTile(
                title: const Text('Security alerts'),
                value: securityNotifications,
                onChanged: (v) {
                  dialogSetState(() => securityNotifications = v);
                  setState(() {});
                },
              ),
              SwitchListTile(
                title: const Text('System announcements'),
                value: systemNotifications,
                onChanged: (v) {
                  dialogSetState(() => systemNotifications = v);
                  setState(() {});
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }

  void showLanguageSettings() {
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, dialogSetState) => AlertDialog(
          title: const Text('Language Settings'),
          content: DropdownButtonFormField<String>(
            initialValue: selectedLanguage,
            items: const [
              DropdownMenuItem(value: 'English', child: Text('English')),
              DropdownMenuItem(value: 'اردو', child: Text('اردو')),
            ],
            onChanged: (value) => dialogSetState(
              () => selectedLanguage = value ?? selectedLanguage,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                showMessage(
                  'Language preference set to $selectedLanguage. Full localization requires app-wide translation support.',
                );
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void showAbout() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('About Smart Auto Care'),
        content: const Text(
          'Smart Auto Care is a vehicle maintenance platform connecting vehicle owners, assigned drivers and workshops. This administrator area provides platform oversight and management tools.',
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

  void showHelp() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Administrator Help'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'User Management',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Search accounts, add demo users, view details and activate or deactivate accounts.',
              ),
              SizedBox(height: 10),
              Text(
                'Workshop Management',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Review pending workshop registrations and verify or reject them.',
              ),
              SizedBox(height: 10),
              Text(
                'Booking Management',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Filter bookings, review details and update their administrative status.',
              ),
              SizedBox(height: 10),
              Text('Reports', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                'Review booking counts and platform registration summaries.',
              ),
            ],
          ),
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

  void showAdminNotifications() {
    final notices = <String>[
      if (pendingWorkshops > 0)
        '$pendingWorkshops workshop verification request(s) are pending.',
      if (bookings.any((b) => b['status'] == 'Pending'))
        '${bookings.where((b) => b['status'] == 'Pending').length} booking(s) need review.',
      if (users.any((u) => u['status'] == 'Inactive'))
        '${users.where((u) => u['status'] == 'Inactive').length} user account(s) are inactive.',
    ];
    if (!bookingNotifications) {
      notices.removeWhere((n) => n.contains('booking'));
    }
    if (!systemNotifications) {
      notices.removeWhere((n) => n.contains('workshop'));
    }
    if (!securityNotifications) {
      notices.removeWhere((n) => n.contains('inactive'));
    }
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Administrator Notifications'),
        content: notices.isEmpty
            ? const Text('No new notifications.')
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: notices
                    .map(
                      (n) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text('• $n'),
                      ),
                    )
                    .toList(),
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

  void showReportPreview() {
    final rows = [
      'Total users: ${users.length}',
      'Active users: $activeUsers',
      'Total workshops: ${workshops.length}',
      'Verified workshops: $verifiedWorkshops',
      'Pending workshops: $pendingWorkshops',
      'Total vehicles: ${vehicles.length}',
      'Total bookings: ${bookings.length}',
      'Completed bookings: $completedBookings',
      'Accepted bookings: $acceptedCount',
      'Pending bookings: ${bookings.where((b) => b['status'] == 'Pending').length}',
      'In-progress bookings: ${bookings.where((b) => b['status'] == 'In Progress').length}',
    ];
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Platform Report Preview'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: rows
              .map(
                (row) => Padding(
                  padding: const EdgeInsets.only(bottom: 7),
                  child: Text(row),
                ),
              )
              .toList(),
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

  void confirmLogout() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text(
          'Are you sure you want to log out of the administrator account?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('Log Out'),
          ),
        ],
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
      case 'Cancelled':
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

  static const TextStyle headingStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: adminNavy,
  );
}
