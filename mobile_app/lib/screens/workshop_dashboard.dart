import 'package:material_ui/material_ui.dart';

const Color workshopBlue = Color(0xFF1565C0);
const Color workshopNavy = Color(0xFF102A43);
const Color workshopBackground = Color(0xFFF5F7FB);

class WorkshopDashboard extends StatefulWidget {
  const WorkshopDashboard({super.key});

  @override
  State<WorkshopDashboard> createState() => _WorkshopDashboardState();
}

class _WorkshopDashboardState extends State<WorkshopDashboard> {
  int _selectedIndex = 0;

  final bool _bookingNotifications = true;
  final bool _jobNotifications = true;
  final bool _invoiceNotifications = true;

  final Map<String, String> workshop = {
    'name': 'AutoCare Premium Workshop',
    'location': 'Saddar, Rawalpindi',
    'phone': '0300-1234567',
    'email': 'workshop@example.com',
    'status': 'Verified',
  };

  final List<Map<String, dynamic>> bookings = [
    {
      'customer': 'Ali Ahmed',
      'phone': '0301-1234567',
      'vehicle': 'Honda Civic',
      'registration': 'ABC-123',
      'service': 'General Maintenance',
      'date': '02 Nov 2026',
      'time': '10:00 AM',
      'status': 'Pending',
      'remarks': 'Please inspect engine oil and filters.',
      'amount': 3500,
      'invoiceStatus': 'Not Generated',
    },
    {
      'customer': 'Usman Khan',
      'phone': '0302-1234567',
      'vehicle': 'Toyota Corolla',
      'registration': 'XYZ-456',
      'service': 'Oil Change',
      'date': '02 Nov 2026',
      'time': '12:00 PM',
      'status': 'Accepted',
      'remarks': 'Use recommended engine oil.',
      'amount': 2500,
      'invoiceStatus': 'Not Generated',
    },
    {
      'customer': 'Hassan Raza',
      'phone': '0303-1234567',
      'vehicle': 'Suzuki Alto',
      'registration': 'LEA-789',
      'service': 'Brake Inspection',
      'date': '01 Nov 2026',
      'time': '09:00 AM',
      'status': 'In Progress',
      'remarks': 'Check brake pads and brake fluid.',
      'amount': 4200,
      'invoiceStatus': 'Not Generated',
    },
    {
      'customer': 'Ahmed Faisal',
      'phone': '0304-1234567',
      'vehicle': 'Honda City',
      'registration': 'ABC-789',
      'service': 'Car Wash',
      'date': '31 Oct 2026',
      'time': '11:00 AM',
      'status': 'Completed',
      'remarks': 'Interior and exterior cleaning.',
      'amount': 1000,
      'invoiceStatus': 'Not Generated',
    },
  ];

  final List<Map<String, dynamic>> services = [
    {
      'name': 'General Maintenance',
      'price': 'Rs. 2,000',
      'description': 'Routine vehicle inspection and maintenance.',
      'active': true,
    },
    {
      'name': 'Oil Change',
      'price': 'Rs. 1,500',
      'description': 'Engine oil and filter replacement.',
      'active': true,
    },
    {
      'name': 'Engine Repair',
      'price': 'Rs. 5,000',
      'description': 'Engine inspection and repair services.',
      'active': true,
    },
    {
      'name': 'Car Wash',
      'price': 'Rs. 1,000',
      'description': 'Interior and exterior vehicle cleaning.',
      'active': true,
    },
    {
      'name': 'Brake Inspection',
      'price': 'Rs. 1,200',
      'description': 'Brake system inspection and checking.',
      'active': true,
    },
  ];

  final List<Map<String, String>> customers = [
    {
      'name': 'Ali Ahmed',
      'phone': '0301-1234567',
      'vehicle': 'Honda Civic',
      'registration': 'ABC-123',
    },
    {
      'name': 'Usman Khan',
      'phone': '0302-1234567',
      'vehicle': 'Toyota Corolla',
      'registration': 'XYZ-456',
    },
    {
      'name': 'Hassan Raza',
      'phone': '0303-1234567',
      'vehicle': 'Suzuki Alto',
      'registration': 'LEA-789',
    },
  ];

  List<Map<String, dynamic>> get pendingBookings =>
      bookings.where((b) => b['status'] == 'Pending').toList();

  List<Map<String, dynamic>> get acceptedBookings =>
      bookings.where((b) => b['status'] == 'Accepted').toList();

  List<Map<String, dynamic>> get activeJobs =>
      bookings.where((b) => b['status'] == 'In Progress').toList();

  List<Map<String, dynamic>> get completedBookings =>
      bookings.where((b) => b['status'] == 'Completed').toList();

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _updateStatus(Map<String, dynamic> booking, String status) {
    setState(() {
      booking['status'] = status;
    });

    _showMessage('Booking status updated to $status.');
  }

  void _acceptBooking(Map<String, dynamic> booking) {
    _updateStatus(booking, 'Accepted');
  }

  void _rejectBooking(Map<String, dynamic> booking) {
    setState(() {
      booking['status'] = 'Rejected';
    });

    _showMessage('Service request rejected.');
  }

  void _completeBooking(Map<String, dynamic> booking) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Complete Job'),
        content: const Text(
          'Confirm that this service job has been completed?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Not Yet'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _updateStatus(booking, 'Completed');
              setState(() => booking['invoiceStatus'] = 'Ready to Generate');
            },
            child: const Text('Confirm Completion'),
          ),
        ],
      ),
    );
  }

  void _showBookingDetails(Map<String, dynamic> booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.all(22),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Booking Details',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: workshopNavy,
                  ),
                ),
                const SizedBox(height: 20),
                _detailRow(
                  Icons.person_outline,
                  'Customer',
                  booking['customer'].toString(),
                ),
                _detailRow(
                  Icons.phone_outlined,
                  'Phone',
                  booking['phone'].toString(),
                ),
                _detailRow(
                  Icons.directions_car,
                  'Vehicle',
                  booking['vehicle'].toString(),
                ),
                _detailRow(
                  Icons.confirmation_number_outlined,
                  'Registration',
                  booking['registration'].toString(),
                ),
                _detailRow(
                  Icons.build_outlined,
                  'Service',
                  booking['service'].toString(),
                ),
                _detailRow(
                  Icons.calendar_today,
                  'Date',
                  booking['date'].toString(),
                ),
                _detailRow(
                  Icons.access_time,
                  'Time',
                  booking['time'].toString(),
                ),
                _detailRow(
                  Icons.info_outline,
                  'Status',
                  booking['status'].toString(),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Customer Remarks',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: workshopNavy,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  booking['remarks'].toString(),
                  style: const TextStyle(color: Colors.blueGrey),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(sheetContext),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: workshopBlue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openNotifications() {
    final messages = <String>[];
    if (_bookingNotifications && pendingBookings.isNotEmpty) {
      messages.add(
        '${pendingBookings.length} new booking request(s) need your review.',
      );
    }
    if (_jobNotifications && activeJobs.isNotEmpty) {
      messages.add('${activeJobs.length} job(s) are currently in progress.');
    }
    if (_invoiceNotifications && completedBookings.isNotEmpty) {
      messages.add(
        '${completedBookings.length} completed service(s) can be invoiced.',
      );
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _WorkshopNotificationsPage(messages: messages),
      ),
    );
  }

  void _openInvoices() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _WorkshopInvoicesPage(
          bookings: completedBookings,
          onGenerate: (booking) {
            setState(() {
              booking['invoiceStatus'] = 'Generated';
            });
          },
        ),
      ),
    );
  }

  void _openCustomerDetails(Map<String, String> customer) {
    final related = bookings
        .where(
          (b) =>
              b['customer'] == customer['name'] ||
              b['registration'] == customer['registration'],
        )
        .toList();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.all(22),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                customer['name'] ?? 'Customer',
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: workshopNavy,
                ),
              ),
              const SizedBox(height: 16),
              _detailRow(
                Icons.phone_outlined,
                'Phone',
                customer['phone'] ?? '',
              ),
              _detailRow(
                Icons.directions_car,
                'Vehicle',
                customer['vehicle'] ?? '',
              ),
              _detailRow(
                Icons.confirmation_number_outlined,
                'Registration',
                customer['registration'] ?? '',
              ),
              const Divider(height: 24),
              const Text(
                'Service Records',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: workshopNavy,
                ),
              ),
              const SizedBox(height: 8),
              if (related.isEmpty)
                const Text('No service records found for this customer.')
              else
                ...related.map(
                  (b) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(b['service'].toString()),
                    subtitle: Text('${b['date']} • ${b['status']}'),
                    trailing: _statusBadge(b['status'].toString()),
                  ),
                ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(sheetContext),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showServiceEditor({Map<String, dynamic>? service}) {
    final name = TextEditingController(
      text: service?['name']?.toString() ?? '',
    );
    final price = TextEditingController(
      text: service == null
          ? ''
          : service['price'].toString().replaceAll('Rs. ', ''),
    );
    final description = TextEditingController(
      text: service?['description']?.toString() ?? '',
    );
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(service == null ? 'Add Service' : 'Edit Service'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Service Name'),
              ),
              TextField(
                controller: price,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Price (PKR)'),
              ),
              TextField(
                controller: description,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Description'),
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
              final amount = double.tryParse(price.text.trim());
              if (name.text.trim().isEmpty || amount == null || amount < 0) {
                _showMessage('Enter a service name and a valid price.');
                return;
              }
              setState(() {
                if (service == null) {
                  services.add({
                    'name': name.text.trim(),
                    'price': 'Rs. ${amount.toStringAsFixed(0)}',
                    'description': description.text.trim(),
                    'active': true,
                  });
                } else {
                  service['name'] = name.text.trim();
                  service['price'] = 'Rs. ${amount.toStringAsFixed(0)}';
                  service['description'] = description.text.trim();
                }
              });
              Navigator.pop(dialogContext);
              _showMessage(
                service == null ? 'Service added.' : 'Service updated.',
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _editWorkshopField(String title, String key) {
    final controller = TextEditingController(text: workshop[key] ?? '');
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Edit $title'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: title),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isEmpty) {
                _showMessage('$title cannot be empty.');
                return;
              }
              setState(() => workshop[key] = controller.text.trim());
              Navigator.pop(dialogContext);
              _showMessage('$title updated.');
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showHelpSupport() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const _WorkshopHelpPage()),
    );
  }

  void _confirmLogout() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text(
          'Are you sure you want to log out of the workshop account?',
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
      _buildBookingsPage(),
      _buildJobsPage(),
      _buildServicesPage(),
      _buildProfilePage(),
    ];

    return Scaffold(
      backgroundColor: workshopBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: workshopNavy),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Row(
          children: [
            Icon(Icons.storefront, color: workshopBlue),
            SizedBox(width: 10),
            Text(
              'Smart Auto Care',
              style: TextStyle(
                color: workshopNavy,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: workshopNavy),
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
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            label: 'Bookings',
          ),
          NavigationDestination(icon: Icon(Icons.work_outline), label: 'Jobs'),
          NavigationDestination(
            icon: Icon(Icons.build_outlined),
            label: 'Services',
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
            'Welcome, Workshop! 👋',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: workshopNavy,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Manage your workshop and customer services.',
            style: TextStyle(color: Colors.blueGrey),
          ),
          const SizedBox(height: 22),

          _buildWorkshopCard(),

          const SizedBox(height: 25),

          const Text('Workshop Overview', style: _headingStyle),
          const SizedBox(height: 14),

          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width > 650 ? 4 : 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: [
              _statCard(
                'New Requests',
                '${pendingBookings.length}',
                Icons.notifications_active_outlined,
                Colors.orange,
              ),
              _statCard(
                'Accepted',
                '${acceptedBookings.length}',
                Icons.event_available,
                workshopBlue,
              ),
              _statCard(
                'Active Jobs',
                '${activeJobs.length}',
                Icons.build_circle_outlined,
                Colors.deepPurple,
              ),
              _statCard(
                'Completed',
                '${completedBookings.length}',
                Icons.check_circle_outline,
                Colors.green,
              ),
            ],
          ),

          const SizedBox(height: 25),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('New Service Requests', style: _headingStyle),
              TextButton(
                onPressed: () {
                  setState(() => _selectedIndex = 1);
                },
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 10),

          if (pendingBookings.isEmpty)
            _emptyCard(
              Icons.inbox_outlined,
              'No new requests',
              'New customer bookings will appear here.',
            )
          else
            ...pendingBookings.map(_buildBookingCard),

          const SizedBox(height: 25),

          const Text('Active Jobs', style: _headingStyle),
          const SizedBox(height: 12),

          if (activeJobs.isEmpty)
            _emptyCard(
              Icons.build_outlined,
              'No active jobs',
              'Accepted jobs can be started from the Jobs tab.',
            )
          else
            ...activeJobs.map(_buildJobCard),
        ],
      ),
    );
  }

  // WORKSHOP PROFILE CARD

  Widget _buildWorkshopCard() {
    return _card(
      child: Row(
        children: [
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF3FF),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(Icons.storefront, color: workshopBlue, size: 34),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workshop['name']!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: workshopNavy,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  workshop['location']!,
                  style: const TextStyle(color: Colors.blueGrey, fontSize: 12),
                ),
                const SizedBox(height: 7),
                Row(
                  children: const [
                    Icon(Icons.verified, color: Colors.green, size: 15),
                    SizedBox(width: 5),
                    Text(
                      'Verified Workshop',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // STATISTICS CARD

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 25),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: workshopNavy,
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

  // BOOKING CARD

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    return _card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person_outline, color: workshopBlue),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  booking['customer'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: workshopNavy,
                  ),
                ),
              ),
              _statusBadge(booking['status']),
            ],
          ),
          const Divider(height: 24),
          _detailRow(Icons.directions_car, 'Vehicle', booking['vehicle']),
          _detailRow(
            Icons.confirmation_number_outlined,
            'Registration',
            booking['registration'],
          ),
          _detailRow(Icons.build_outlined, 'Service', booking['service']),
          _detailRow(
            Icons.calendar_today,
            'Date & Time',
            '${booking['date']} • ${booking['time']}',
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showBookingDetails(booking),
                  child: const Text('Details'),
                ),
              ),
              if (booking['status'] == 'Pending') ...[
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _rejectBooking(booking),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                    child: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _acceptBooking(booking),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: workshopBlue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Accept'),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // JOB CARD

  Widget _buildJobCard(Map<String, dynamic> booking) {
    return _card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.build_circle_outlined, color: workshopBlue),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  booking['service'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: workshopNavy,
                  ),
                ),
              ),
              _statusBadge(booking['status']),
            ],
          ),
          const SizedBox(height: 15),
          _detailRow(Icons.person_outline, 'Customer', booking['customer']),
          _detailRow(Icons.directions_car, 'Vehicle', booking['vehicle']),
          _detailRow(
            Icons.confirmation_number_outlined,
            'Registration',
            booking['registration'],
          ),
          _detailRow(Icons.calendar_today, 'Date', booking['date']),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _completeBooking(booking),
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Mark as Completed'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // BOOKINGS PAGE

  String _bookingFilter = 'All';

  Widget _buildBookingsPage() {
    final visibleBookings = bookings.where((booking) {
      if (_bookingFilter == 'All') return booking['status'] != 'Rejected';
      return booking['status'] == _bookingFilter;
    }).toList();
    return _pageLayout(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Service Bookings', style: _headingStyle),
          const SizedBox(height: 7),
          const Text(
            'Manage incoming customer service requests.',
            style: TextStyle(color: Colors.blueGrey),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['All', 'Pending', 'Accepted', 'In Progress', 'Completed']
                .map((filter) {
                  return ChoiceChip(
                    label: Text(filter),
                    selected: _bookingFilter == filter,
                    selectedColor: const Color(0xFFE7F0FF),
                    onSelected: (_) => setState(() => _bookingFilter = filter),
                  );
                })
                .toList(),
          ),
          const SizedBox(height: 16),
          if (visibleBookings.isEmpty)
            _emptyCard(
              Icons.calendar_month,
              'No bookings',
              'No bookings match this filter.',
            )
          else
            ...visibleBookings.map(_buildBookingCard),
        ],
      ),
    );
  }

  // JOBS PAGE

  Widget _buildJobsPage() {
    final jobs = bookings
        .where((b) => b['status'] == 'Accepted' || b['status'] == 'In Progress')
        .toList();

    return _pageLayout(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Workshop Jobs', style: _headingStyle),
          const SizedBox(height: 7),
          const Text(
            'Track accepted jobs and service progress.',
            style: TextStyle(color: Colors.blueGrey),
          ),
          const SizedBox(height: 20),

          if (jobs.isEmpty)
            _emptyCard(
              Icons.work_outline,
              'No active jobs',
              'Accepted bookings will appear here.',
            )
          else
            ...jobs.map((booking) {
              if (booking['status'] == 'Accepted') {
                return _card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking['service'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: workshopNavy,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${booking['customer']} • ${booking['vehicle']}',
                        style: const TextStyle(color: Colors.blueGrey),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () =>
                              _updateStatus(booking, 'In Progress'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: workshopBlue,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Start Job'),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return _buildJobCard(booking);
            }),
        ],
      ),
    );
  }

  // SERVICES PAGE

  Widget _buildServicesPage() {
    return _pageLayout(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text('Workshop Services', style: _headingStyle),
              ),
              ElevatedButton.icon(
                onPressed: () => _showServiceEditor(),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: workshopBlue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          const Text(
            'View the services offered by your workshop.',
            style: TextStyle(color: Colors.blueGrey),
          ),
          const SizedBox(height: 20),

          ...services.map((service) {
            return _card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF3FF),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(Icons.build, color: workshopBlue),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: workshopNavy,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          service['description'],
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.blueGrey,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          service['price'],
                          style: const TextStyle(
                            color: workshopBlue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        value: service['active'],
                        activeThumbColor: workshopBlue,
                        onChanged: (value) =>
                            setState(() => service['active'] = value),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (choice) {
                          if (choice == 'edit') {
                            _showServiceEditor(service: service);
                          } else if (choice == 'delete') {
                            setState(() => services.remove(service));
                            _showMessage('Service removed.');
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: 'edit', child: Text('Edit')),
                          PopupMenuItem(value: 'delete', child: Text('Delete')),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // CUSTOMERS PAGE CONTENT

  Widget _buildCustomersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Customer Records', style: _headingStyle),
        const SizedBox(height: 12),
        ...customers.map((customer) {
          return _card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFEAF3FF),
                child: Icon(Icons.person, color: workshopBlue),
              ),
              title: Text(
                customer['name']!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: workshopNavy,
                ),
              ),
              subtitle: Text(
                '${customer['phone']}\n'
                '${customer['vehicle']} • ${customer['registration']}',
              ),
              isThreeLine: true,
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _openCustomerDetails(customer),
            ),
          );
        }),
      ],
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
            child: Icon(Icons.storefront, color: workshopBlue, size: 52),
          ),
          const SizedBox(height: 15),
          Text(
            workshop['name']!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: workshopNavy,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            workshop['email']!,
            style: const TextStyle(color: Colors.blueGrey),
          ),
          const SizedBox(height: 25),

          _profileOption(
            Icons.store_outlined,
            'Workshop Information',
            onTap: () => _editWorkshopField('Workshop Name', 'name'),
          ),
          _profileOption(
            Icons.location_on_outlined,
            'Workshop Address',
            onTap: () => _editWorkshopField('Workshop Address', 'location'),
          ),
          _profileOption(
            Icons.phone_outlined,
            'Contact Information',
            onTap: () => _editWorkshopField('Phone Number', 'phone'),
          ),
          _profileOption(
            Icons.verified_user_outlined,
            'Verification Status',
            onTap: () => showDialog<void>(
              context: context,
              builder: (dialogContext) => AlertDialog(
                title: const Text('Verification Status'),
                content: Text(
                  'Workshop status: ${workshop['status']}. This is demo status; live verification will be connected later.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ),
          ),
          _profileOption(
            Icons.people_outline,
            'Customer Records',
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => Padding(
                  padding: const EdgeInsets.all(20),
                  child: SingleChildScrollView(child: _buildCustomersSection()),
                ),
              );
            },
          ),
          _profileOption(
            Icons.receipt_long_outlined,
            'Invoices',
            onTap: _openInvoices,
          ),
          _profileOption(
            Icons.notifications_outlined,
            'Notifications',
            onTap: _openNotifications,
          ),
          _profileOption(
            Icons.help_outline,
            'Help & Support',
            onTap: _showHelpSupport,
          ),
          _profileOption(Icons.logout, 'Log Out', onTap: _confirmLogout),
        ],
      ),
    );
  }

  Widget _profileOption(IconData icon, String title, {VoidCallback? onTap}) {
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE5EAF0)),
      ),
      child: ListTile(
        leading: Icon(icon, color: workshopBlue),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap ?? () => _showMessage('$title will be implemented later.'),
      ),
    );
  }

  // REUSABLE LAYOUT

  Widget _pageLayout({required Widget child}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1050),
          child: child,
        ),
      ),
    );
  }

  Widget _card({required Widget child, EdgeInsetsGeometry? margin}) {
    return Container(
      width: double.infinity,
      margin: margin,
      padding: const EdgeInsets.all(17),
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
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 19, color: workshopBlue),
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
                color: workshopNavy,
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
    Color color;

    switch (status) {
      case 'Completed':
        color = Colors.green;
        break;
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
        color = workshopBlue;
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

  Widget _emptyCard(IconData icon, String title, String subtitle) {
    return _card(
      child: Column(
        children: [
          Icon(icon, size: 40, color: workshopBlue),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: workshopNavy,
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
    color: workshopNavy,
  );
}

// =========================================================
// WORKSHOP SUPPORT SCREENS
// =========================================================

class _WorkshopInvoicesPage extends StatelessWidget {
  final List<Map<String, dynamic>> bookings;
  final ValueChanged<Map<String, dynamic>> onGenerate;

  const _WorkshopInvoicesPage({
    required this.bookings,
    required this.onGenerate,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: workshopBackground,
      appBar: AppBar(
        title: const Text('Service Invoices'),
        backgroundColor: Colors.white,
        foregroundColor: workshopNavy,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Completed Services',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: workshopNavy,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Generate a demo invoice for a completed service.',
            style: TextStyle(color: Colors.blueGrey),
          ),
          const SizedBox(height: 16),
          if (bookings.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text('No completed services are ready for invoicing.'),
              ),
            )
          else
            ...bookings.map(
              (booking) => Card(
                color: Colors.white,
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking['service'].toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: workshopNavy,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text('${booking['customer']} • ${booking['vehicle']}'),
                      Text('Amount: Rs. ${booking['amount'] ?? 0}'),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Invoice: ${booking['invoiceStatus'] ?? 'Not Generated'}',
                            ),
                          ),
                          ElevatedButton(
                            onPressed: booking['invoiceStatus'] == 'Generated'
                                ? null
                                : () {
                                    onGenerate(booking);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Demo invoice generated.',
                                        ),
                                      ),
                                    );
                                  },
                            child: Text(
                              booking['invoiceStatus'] == 'Generated'
                                  ? 'Generated'
                                  : 'Generate',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _WorkshopNotificationsPage extends StatelessWidget {
  final List<String> messages;

  const _WorkshopNotificationsPage({required this.messages});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: workshopBackground,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.white,
        foregroundColor: workshopNavy,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Workshop Updates',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: workshopNavy,
            ),
          ),
          const SizedBox(height: 14),
          if (messages.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text('No current workshop notifications.'),
              ),
            )
          else
            ...messages.map(
              (message) => Card(
                color: Colors.white,
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFEAF3FF),
                    child: Icon(
                      Icons.notifications_active_outlined,
                      color: workshopBlue,
                    ),
                  ),
                  title: Text(message),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _WorkshopHelpPage extends StatelessWidget {
  const _WorkshopHelpPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: workshopBackground,
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: Colors.white,
        foregroundColor: workshopNavy,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Workshop Help',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: workshopNavy,
            ),
          ),
          const SizedBox(height: 14),
          _faq(
            'How do I handle a new booking?',
            'Open Bookings, review the customer and vehicle details, then accept or reject the request.',
          ),
          _faq(
            'How do I start a service job?',
            'Accept a booking first. It will appear in Jobs, where you can select Start Job.',
          ),
          _faq(
            'How do I complete a job?',
            'Open the active job and select Mark as Completed after the work is finished.',
          ),
          _faq(
            'How do I manage workshop services?',
            'Open Services to add, edit, delete, or temporarily deactivate a service.',
          ),
          _faq(
            'How do I generate an invoice?',
            'After completing a job, open Profile > Invoices and generate a demo invoice for that service.',
          ),
          _faq(
            'Are changes saved permanently?',
            'This version stores demo data in memory. Firebase/database integration is required for permanent storage and owner-side synchronization.',
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
