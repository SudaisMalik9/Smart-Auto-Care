
import 'package:material_ui/material_ui.dart';

import 'add_vehicle_screen.dart';
import 'find_workshop_screen.dart';
import 'book_service_screen.dart';
import '../services/customer_service.dart';
import '../services/auth_service.dart';

const Color dashboardBlue = Color(0xFF1565C0);
const Color dashboardNavy = Color(0xFF102A43);
const Color dashboardBackground = Color(0xFFF5F7FB);

class VehicleOwnerDashboard extends StatefulWidget {
  const VehicleOwnerDashboard({super.key});

  @override
  State<VehicleOwnerDashboard> createState() =>
      _VehicleOwnerDashboardState();
}

class _VehicleOwnerDashboardState extends State<VehicleOwnerDashboard> {
  int _selectedIndex = 0;

  String _ownerName = 'Vehicle Owner';
  String _ownerEmail = '';
  String _ownerPhone = '';
  String _ownerAddress = '';
  String _ownerCity = '';

  bool _isLoadingProfile = true;
  bool _isLoadingVehicles = true;
  bool _isLoggingOut = false;

  bool _bookingNotifications = true;
  bool _serviceReminders = true;
  bool _promotionalNotifications = false;

  List<Map<String, dynamic>> _vehicles = [];

  // Booking and service-history backend integration is not implemented yet.
  // Do not display fabricated records.
  final List<Map<String, String>> _bookings = [];
  final List<Map<String, String>> _activities = [];

  final Set<int> _deletingVehicleIds = {};

  @override
  void initState() {
    super.initState();
    _loadCustomerData();
  }

  Future<void> _loadCustomerData() async {
    await Future.wait([
      _loadCustomerProfile(),
      _loadCustomerVehicles(),
    ]);
  }

  Future<void> _loadCustomerProfile() async {
    try {
      final profile = await CustomerService.getCustomerProfile();

      final firstName = profile['first_name']?.toString() ?? '';
      final lastName = profile['last_name']?.toString() ?? '';
      final username = profile['username']?.toString() ?? '';
      final fullName = '$firstName $lastName'.trim();

      if (!mounted) return;

      setState(() {
        _ownerName = fullName.isNotEmpty ? fullName : username;
        _ownerEmail = profile['email']?.toString() ?? '';
        _ownerPhone = profile['phone']?.toString() ?? '';
        _ownerAddress = profile['address']?.toString() ?? '';
        _ownerCity = profile['city']?.toString() ?? '';
        _isLoadingProfile = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() => _isLoadingProfile = false);
      _showMessage('Could not load customer profile: $error');
    }
  }

  Future<void> _loadCustomerVehicles() async {
    try {
      final vehicles = await CustomerService.getVehicles();

      if (!mounted) return;

      setState(() {
        _vehicles = vehicles.map((vehicle) {
          return {
            'id': vehicle['id'],
            'registrationNumber':
                vehicle['registration_number'] ?? '',
            'make': vehicle['make'] ?? '',
            'model': vehicle['model'] ?? '',
            'year': vehicle['year'] ?? '',
            'color': vehicle['color'] ?? '',
            'fuelType': vehicle['fuel_type'] ?? '',
            'transmission': vehicle['transmission'] ?? '',
            'nickname': vehicle['nickname'] ?? '',
            'notes': vehicle['notes'] ?? '',
          };
        }).toList();

        _isLoadingVehicles = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() => _isLoadingVehicles = false);
      _showMessage('Could not load vehicles: $error');
    }
  }

  Future<void> _openAddVehicle() async {
    final vehicle = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddVehicleScreen(),
      ),
    );

    if (!mounted || vehicle == null) return;

    setState(() => _isLoadingVehicles = true);
    await _loadCustomerVehicles();

    if (!mounted) return;
    _showMessage('Vehicle list updated.');
  }

  Future<void> _openFindWorkshop() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => const FindWorkshopScreen(),
      ),
    );

    if (!mounted || result == null) return;

    // This is currently a local/session-only booking result.
    final booking = <String, String>{};
    result.forEach((key, value) {
      booking[key] = value?.toString() ?? '';
    });

    setState(() => _bookings.insert(0, booking));
    _showMessage(
      'Booking details received. Permanent booking storage is not connected yet.',
    );
  }

  Future<void> _openBookService() async {
    final result = await Navigator.push<dynamic>(
      context,
      MaterialPageRoute(
        builder: (context) => const BookServiceScreen(),
      ),
    );

    if (!mounted || result == null || result is! Map) return;

    // This is currently a local/session-only booking result.
    final booking = <String, String>{};
    result.forEach((key, value) {
      booking[key.toString()] = value?.toString() ?? '';
    });

    setState(() => _bookings.insert(0, booking));
    _showMessage(
      'Booking details received. Permanent booking storage is not connected yet.',
    );
  }

  void _openVehicles() {
    setState(() => _selectedIndex = 1);
  }

  void _openBookings() {
    setState(() => _selectedIndex = 2);
  }

  bool _isActiveBooking(Map<String, String> booking) {
    final status = (booking['status'] ?? '').toLowerCase();
    return status != 'cancelled' && status != 'completed';
  }

  int get _activeBookingCount =>
      _bookings.where(_isActiveBooking).length;

  void _openServiceHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _ServiceHistoryPage(
          activities: List<Map<String, String>>.from(_activities),
        ),
      ),
    );
  }

  void _showBookingDetails(Map<String, String> booking) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final status = booking['status'] ?? 'Upcoming';
        final canCancel = _isActiveBooking(booking);

        return AlertDialog(
          title: const Text('Booking Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow('Service', booking['service']),
              _detailRow('Workshop', booking['workshop']),
              _detailRow('Date', booking['date']),
              _detailRow('Time', booking['time']),
              _detailRow('Status', status),
              const SizedBox(height: 8),
              const Text(
                'This booking is not yet stored permanently on the server.',
                style: TextStyle(
                  color: Colors.blueGrey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Close'),
            ),
            if (canCancel)
              TextButton(
                onPressed: () {
                  setState(() => booking['status'] = 'Cancelled');
                  Navigator.pop(dialogContext);
                  _showMessage('Booking cancelled in this app session.');
                },
                child: const Text(
                  'Cancel Booking',
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _detailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 82,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value?.isNotEmpty == true ? value! : 'Not provided',
            ),
          ),
        ],
      ),
    );
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
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: dashboardNavy,
          ),
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
            onPressed: () => _showMessage('No new notifications.'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: pages,
        ),
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        selectedIndex: _selectedIndex,
        indicatorColor: const Color(0xFFE7F0FF),
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
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

  // HOME DASHBOARD

  Widget _buildHome() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 850;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 22,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1150),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, ${_ownerName == 'Vehicle Owner' ? 'Vehicle Owner' : _ownerName}!',
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: dashboardNavy,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Manage your vehicles and keep them running smoothly.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blueGrey,
                    ),
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
                        value: _isLoadingVehicles
                            ? '...'
                            : '${_vehicles.length}',
                        subtitle: 'Registered vehicles',
                        color: dashboardBlue,
                        onTap: _openVehicles,
                      ),
                      _StatCard(
                        icon: Icons.calendar_month_rounded,
                        label: 'Upcoming',
                        value: '$_activeBookingCount',
                        subtitle: 'Session bookings',
                        color: Colors.teal,
                        onTap: _openBookings,
                      ),
                      _StatCard(
                        icon: Icons.check_circle_outline_rounded,
                        label: 'Completed',
                        value: '${_activities.length}',
                        subtitle: 'Recorded services',
                        color: Colors.deepPurple,
                        onTap: _openServiceHistory,
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
                      _QuickAction(
                        icon: Icons.search_rounded,
                        title: 'Find Workshop',
                        onTap: _openFindWorkshop,
                      ),
                      _QuickAction(
                        icon: Icons.event_available_outlined,
                        title: 'Book Service',
                        onTap: _openBookService,
                      ),
                      _QuickAction(
                        icon: Icons.history_rounded,
                        title: 'Service History',
                        onTap: _openServiceHistory,
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
                      subtitle:
                          'Your future appointments will appear here.',
                    )
                  else
                    ..._bookings.take(2).map(
                      (booking) => _BookingTile(
                        booking: booking,
                        onTap: () => _showBookingDetails(booking),
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
                      subtitle:
                          'Your completed services will appear here.',
                    )
                  else
                    ..._activities.take(4).map(
                      (activity) => _ActivityTile(activity: activity),
                    ),
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
          colors: [
            Color(0xFF1565C0),
            Color(0xFF42A5F5),
          ],
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
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 15),
          Icon(
            Icons.car_repair_rounded,
            size: 60,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  // VEHICLES PAGE

  Widget _buildVehiclesPage() {
    return _pageContainer(
      title: 'My Vehicles',
      subtitle: 'Manage your registered vehicles.',
      action: ElevatedButton.icon(
        onPressed: _openAddVehicle,
        icon: const Icon(Icons.add),
        label: const Text('Add Vehicle'),
      ),
      child: _isLoadingVehicles
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(30),
                child: CircularProgressIndicator(),
              ),
            )
          : _vehicles.isEmpty
              ? _emptyCard(
                  icon: Icons.directions_car_outlined,
                  title: 'No vehicles registered',
                  subtitle:
                      'Add your first vehicle to get started.',
                )
              : Column(
                  children: _vehicles.map((vehicle) {
                    final year = vehicle['year']?.toString() ?? '';
                    final color = vehicle['color']?.toString() ?? '';
                    final fuel = vehicle['fuelType']?.toString() ?? '';
                    final transmission =
                        vehicle['transmission']?.toString() ?? '';
                    final id = int.tryParse(
                      vehicle['id']?.toString() ?? '',
                    );
                    final isDeleting =
                        id != null && _deletingVehicleIds.contains(id);

                    return Card(
                      color: Colors.white,
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                        side: const BorderSide(
                          color: Color(0xFFE5EAF0),
                        ),
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
                            '$year • $color\n'
                            '$fuel • $transmission',
                          ),
                        ),
                        isThreeLine: true,
                        trailing: isDeleting
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : IconButton(
                                tooltip: 'Delete vehicle',
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  color: Colors.redAccent,
                                ),
                                onPressed: id == null
                                    ? null
                                    : () => _confirmDeleteVehicle(vehicle),
                              ),
                      ),
                    );
                  }).toList(),
                ),
    );
  }

  void _confirmDeleteVehicle(Map<String, dynamic> vehicle) {
    final vehicleId = int.tryParse(
      vehicle['id']?.toString() ?? '',
    );

    if (vehicleId == null) {
      _showMessage('Invalid vehicle ID. Please refresh the vehicle list.');
      return;
    }

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Remove Vehicle?'),
          content: Text(
            'Do you want to remove '
            '${vehicle['make']} ${vehicle['model']}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await _deleteVehicle(vehicleId);
              },
              child: const Text(
                'Remove',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteVehicle(int vehicleId) async {
    if (_deletingVehicleIds.contains(vehicleId)) return;

    setState(() => _deletingVehicleIds.add(vehicleId));

    try {
      await CustomerService.deleteVehicle(vehicleId);

      if (!mounted) return;

      setState(() {
        _vehicles.removeWhere(
          (vehicle) => vehicle['id'].toString() == vehicleId.toString(),
        );
        _deletingVehicleIds.remove(vehicleId);
      });

      _showMessage('Vehicle removed successfully.');
    } catch (error) {
      if (!mounted) return;

      setState(() => _deletingVehicleIds.remove(vehicleId));
      _showMessage('Could not remove vehicle: $error');
    }
  }

  // BOOKINGS PAGE

  Widget _buildBookingsPage() {
    final activeBookings =
        _bookings.where(_isActiveBooking).toList();

    final pastBookings = _bookings
        .where((booking) => !_isActiveBooking(booking))
        .toList();

    return _pageContainer(
      title: 'My Bookings',
      subtitle: 'View and manage your service appointments.',
      action: ElevatedButton.icon(
        onPressed: _openBookService,
        icon: const Icon(Icons.add),
        label: const Text('Book Service'),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Upcoming Bookings',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: dashboardNavy,
            ),
          ),
          const SizedBox(height: 12),
          if (activeBookings.isEmpty)
            _emptyCard(
              icon: Icons.calendar_month_outlined,
              title: 'No upcoming bookings',
              subtitle:
                  'Your future appointments will appear here.',
            )
          else
            ...activeBookings.map(
              (booking) => _BookingTile(
                booking: booking,
                onTap: () => _showBookingDetails(booking),
              ),
            ),
          const SizedBox(height: 22),
          const Text(
            'Booking History',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: dashboardNavy,
            ),
          ),
          const SizedBox(height: 12),
          if (pastBookings.isEmpty)
            _emptyCard(
              icon: Icons.history_rounded,
              title: 'No past bookings',
              subtitle:
                  'Cancelled or completed bookings will appear here.',
            )
          else
            ...pastBookings.map(
              (booking) => _BookingTile(
                booking: booking,
                onTap: () => _showBookingDetails(booking),
              ),
            ),
          const SizedBox(height: 12),
          const Text(
            'Note: Booking records are currently held only in this app session. '
            'Permanent booking storage will be connected when the booking API is ready.',
            style: TextStyle(
              color: Colors.blueGrey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // PROFILE PAGE

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
              border: Border.all(
                color: const Color(0xFFE5EAF0),
              ),
            ),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 42,
                  backgroundColor: Color(0xFFEAF3FF),
                  child: Icon(
                    Icons.person_rounded,
                    size: 48,
                    color: dashboardBlue,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  _isLoadingProfile ? 'Loading...' : _ownerName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: dashboardNavy,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _ownerEmail.isEmpty
                      ? 'Email not provided'
                      : _ownerEmail,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.blueGrey),
                ),
                const SizedBox(height: 5),
                Text(
                  _ownerPhone.isEmpty
                      ? 'Phone not provided'
                      : _ownerPhone,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.blueGrey),
                ),
                if (_ownerAddress.isNotEmpty || _ownerCity.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    [_ownerAddress, _ownerCity]
                        .where((value) => value.isNotEmpty)
                        .join(', '),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.blueGrey),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 15),
          _profileOption(
            icon: Icons.person_outline_rounded,
            title: 'Personal Information',
            onTap: _openPersonalInformation,
          ),
          _profileOption(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            onTap: _openNotificationSettings,
          ),
          _profileOption(
            icon: Icons.help_outline_rounded,
            title: 'Help & Support',
            onTap: _openHelpSupport,
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

  Future<void> _openPersonalInformation() async {
    final result = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(
        builder: (context) => _PersonalInformationPage(
          name: _ownerName,
          email: _ownerEmail,
          phone: _ownerPhone,
          address: _ownerAddress,
          city: _ownerCity,
        ),
      ),
    );

    if (!mounted || result == null) return;

    try {
      await CustomerService.updateCustomerProfile(
        phone: result['phone'],
        address: result['address'],
        city: result['city'],
      );

      if (!mounted) return;

      setState(() {
        _ownerPhone = result['phone'] ?? _ownerPhone;
        _ownerAddress = result['address'] ?? _ownerAddress;
        _ownerCity = result['city'] ?? _ownerCity;
      });

      _showMessage('Personal information saved successfully.');
    } catch (error) {
      if (!mounted) return;
      _showMessage('Could not save profile information: $error');
    }
  }

  Future<void> _openNotificationSettings() async {
    final result = await Navigator.push<Map<String, bool>>(
      context,
      MaterialPageRoute(
        builder: (context) => _NotificationSettingsPage(
          bookingNotifications: _bookingNotifications,
          serviceReminders: _serviceReminders,
          promotionalNotifications: _promotionalNotifications,
        ),
      ),
    );

    if (!mounted || result == null) return;

    setState(() {
      _bookingNotifications =
          result['bookingNotifications'] ?? _bookingNotifications;
      _serviceReminders =
          result['serviceReminders'] ?? _serviceReminders;
      _promotionalNotifications =
          result['promotionalNotifications'] ??
              _promotionalNotifications;
    });

    _showMessage(
      'Notification preferences updated for this app session.',
    );
  }

  void _openHelpSupport() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const _HelpSupportPage(),
      ),
    );
  }

  void _confirmLogout() {
    if (_isLoggingOut) return;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Log Out'),
          content: const Text(
            'Do you want to log out of your account?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await _logout();
              },
              child: const Text('Log Out'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout() async {
    if (_isLoggingOut) return;

    setState(() => _isLoggingOut = true);

    try {
      await AuthService.logout();

      if (!mounted) return;

      // Return to the first route, normally the login screen.
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (error) {
      if (!mounted) return;

      setState(() => _isLoggingOut = false);
      _showMessage('Could not log out: $error');
    }
  }

  // REUSABLE COMPONENTS

  Widget _pageContainer({
    required String title,
    required String subtitle,
    required Widget child,
    Widget? action,
  }) {
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
              if (action != null) ...[
                const SizedBox(height: 18),
                action,
              ],
              const SizedBox(height: 22),
              child,
            ],
          ),
        ),
      ),
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
            style: const TextStyle(
              color: Colors.blueGrey,
              height: 1.4,
            ),
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
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

// STAT CARD

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
              style: const TextStyle(
                color: Colors.blueGrey,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// QUICK ACTION

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

// SERVICE HISTORY PAGE

class _ServiceHistoryPage extends StatelessWidget {
  final List<Map<String, String>> activities;

  const _ServiceHistoryPage({
    required this.activities,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: dashboardBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: dashboardNavy,
        elevation: 0,
        title: const Text('Service History'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Completed Services',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: dashboardNavy,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Review the maintenance and services recorded for your vehicles.',
            style: TextStyle(color: Colors.blueGrey),
          ),
          const SizedBox(height: 20),
          if (activities.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(22),
                child: Text(
                  'No completed services have been recorded yet.',
                ),
              ),
            )
          else
            ...activities.map(
              (activity) => _ActivityTile(activity: activity),
            ),
        ],
      ),
    );
  }
}

// UPCOMING BOOKING TILE

class _BookingTile extends StatelessWidget {
  final Map<String, String> booking;
  final VoidCallback onTap;

  const _BookingTile({
    required this.booking,
    required this.onTap,
  });

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

// RECENT ACTIVITY TILE

class _ActivityTile extends StatelessWidget {
  final Map<String, String> activity;

  const _ActivityTile({
    required this.activity,
  });

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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 5,
        ),
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFE3F4F1),
          child: Icon(
            Icons.check_circle_rounded,
            color: Colors.teal,
          ),
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
            '${activity['vehicle'] ?? ''} • ${activity['status'] ?? ''}',
          ),
        ),
        trailing: Text(
          activity['date'] ?? '',
          style: const TextStyle(
            fontSize: 10,
            color: Colors.blueGrey,
          ),
        ),
      ),
    );
  }
}

// PERSONAL INFORMATION PAGE

class _PersonalInformationPage extends StatefulWidget {
  final String name;
  final String email;
  final String phone;
  final String address;
  final String city;

  const _PersonalInformationPage({
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.city,
  });

  @override
  State<_PersonalInformationPage> createState() =>
      _PersonalInformationPageState();
}

class _PersonalInformationPageState
    extends State<_PersonalInformationPage> {
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _cityController;

  @override
  void initState() {
    super.initState();

    _phoneController = TextEditingController(text: widget.phone);
    _addressController = TextEditingController(text: widget.address);
    _cityController = TextEditingController(text: widget.city);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _save() {
    Navigator.pop(
      context,
      <String, String>{
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'city': _cityController.text.trim(),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: dashboardBackground,
      appBar: AppBar(
        title: const Text('Personal Information'),
        backgroundColor: Colors.white,
        foregroundColor: dashboardNavy,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Your account information',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: dashboardNavy,
            ),
          ),
          const SizedBox(height: 18),
          _readOnlyField('Full Name', widget.name),
          _readOnlyField('Email Address', widget.email),
          _buildField(
            'Phone Number',
            _phoneController,
            Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
          _buildField(
            'Address',
            _addressController,
            Icons.location_on_outlined,
            maxLines: 2,
          ),
          _buildField(
            'City',
            _cityController,
            Icons.location_city_outlined,
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: dashboardBlue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Save Changes'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _readOnlyField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        initialValue: value,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: const Color(0xFFEFF2F6),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: dashboardBlue),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: const BorderSide(
              color: Color(0xFFE5EAF0),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: const BorderSide(
              color: Color(0xFFE5EAF0),
            ),
          ),
        ),
      ),
    );
  }
}

// NOTIFICATION SETTINGS PAGE

class _NotificationSettingsPage extends StatefulWidget {
  final bool bookingNotifications;
  final bool serviceReminders;
  final bool promotionalNotifications;

  const _NotificationSettingsPage({
    required this.bookingNotifications,
    required this.serviceReminders,
    required this.promotionalNotifications,
  });

  @override
  State<_NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState
    extends State<_NotificationSettingsPage> {
  late bool _bookingNotifications;
  late bool _serviceReminders;
  late bool _promotionalNotifications;

  @override
  void initState() {
    super.initState();

    _bookingNotifications = widget.bookingNotifications;
    _serviceReminders = widget.serviceReminders;
    _promotionalNotifications = widget.promotionalNotifications;
  }

  void _save() {
    Navigator.pop(
      context,
      <String, bool>{
        'bookingNotifications': _bookingNotifications,
        'serviceReminders': _serviceReminders,
        'promotionalNotifications': _promotionalNotifications,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: dashboardBackground,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.white,
        foregroundColor: dashboardNavy,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Notification Preferences',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: dashboardNavy,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Choose which updates you want to receive.',
            style: TextStyle(color: Colors.blueGrey),
          ),
          const SizedBox(height: 18),
          _switchTile(
            'Booking Updates',
            'Confirmation, changes and cancellation updates.',
            Icons.calendar_month_outlined,
            _bookingNotifications,
            (value) => setState(() => _bookingNotifications = value),
          ),
          _switchTile(
            'Service Reminders',
            'Reminders for upcoming vehicle maintenance.',
            Icons.build_circle_outlined,
            _serviceReminders,
            (value) => setState(() => _serviceReminders = value),
          ),
          _switchTile(
            'Promotions and Offers',
            'Special offers and promotional announcements.',
            Icons.local_offer_outlined,
            _promotionalNotifications,
            (value) => setState(() => _promotionalNotifications = value),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: dashboardBlue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Save Preferences'),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'These preferences are currently stored only during this app session.',
            style: TextStyle(
              color: Colors.blueGrey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _switchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE5EAF0)),
      ),
      child: SwitchListTile(
        secondary: Icon(icon, color: dashboardBlue),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle),
        value: value,
        activeThumbColor: dashboardBlue,
        onChanged: onChanged,
      ),
    );
  }
}

// HELP AND SUPPORT PAGE

class _HelpSupportPage extends StatelessWidget {
  const _HelpSupportPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: dashboardBackground,
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: Colors.white,
        foregroundColor: dashboardNavy,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'How can we help?',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: dashboardNavy,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Find answers to common questions about Smart Auto Care.',
            style: TextStyle(color: Colors.blueGrey),
          ),
          const SizedBox(height: 18),
          _faq(
            'How do I add a vehicle?',
            'Open the Vehicles tab and select Add Vehicle. '
                'Enter your vehicle details and save.',
          ),
          _faq(
            'How do I book a service?',
            'Open Book Service or Find Workshop, select the '
                'required service and follow the booking steps.',
          ),
          _faq(
            'Where can I see my appointments?',
            'Open the Bookings tab to view your current session bookings. '
                'Permanent booking records will appear when backend integration is ready.',
          ),
          _faq(
            'Can I change my profile details?',
            'Open Profile, select Personal Information, update '
                'your phone, address or city and tap Save Changes.',
          ),
          _faq(
            'Are my settings saved permanently?',
            'Notification preferences are currently saved only '
                'during the running app session.',
          ),
          const SizedBox(height: 14),
          Card(
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(color: Color(0xFFE5EAF0)),
            ),
            child: const Padding(
              padding: EdgeInsets.all(18),
              child: Row(
                children: [
                  Icon(
                    Icons.support_agent,
                    color: dashboardBlue,
                    size: 30,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Need more help?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: dashboardNavy,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Support contact details can be added when '
                          'the official support channel is configured.',
                          style: TextStyle(color: Colors.blueGrey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE5EAF0)),
      ),
      child: ExpansionTile(
        iconColor: dashboardBlue,
        collapsedIconColor: Colors.blueGrey,
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
              style: const TextStyle(
                color: Colors.blueGrey,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
