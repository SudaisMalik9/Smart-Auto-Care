import 'package:material_ui/material_ui.dart';

import '../services/auth_service.dart';
import '../services/workshop_service.dart';
import 'website_qr_scanner_screen.dart';

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

  bool _isLoading = true;
  String? _error;

  List<Map<String, dynamic>> workshops = [];
  List<Map<String, dynamic>> branches = [];
  List<Map<String, dynamic>> services = [];
  List<Map<String, dynamic>> departments = [];

  Map<String, dynamic>? selectedWorkshop;
  Map<String, dynamic>? selectedBranch;

  int get workshopId => int.parse(selectedWorkshop!['id'].toString());
  int get branchId => int.parse(selectedBranch!['id'].toString());

  @override
  void initState() {
    super.initState();
    _loadWorkshopData();
  }

  void _message(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  int _id(Map<String, dynamic> item) => int.parse(item['id'].toString());

  Future<void> _loadWorkshopData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await WorkshopService.getWorkshops();
      if (!mounted) return;

      workshops = result;

      if (workshops.isEmpty) {
        setState(() {
          selectedWorkshop = null;
          selectedBranch = null;
          branches = [];
          services = [];
          departments = [];
        });
        return;
      }

      final previousWorkshopId = selectedWorkshop == null
          ? null
          : _id(selectedWorkshop!);

      selectedWorkshop = workshops.firstWhere(
        (item) => previousWorkshopId != null && _id(item) == previousWorkshopId,
        orElse: () => workshops.first,
      );

      await _loadBranches();
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceFirst('Exception: ', '');
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadBranches() async {
    if (selectedWorkshop == null) return;

    final result = await WorkshopService.getBranches(workshopId);
    if (!mounted) return;

    branches = result;

    if (branches.isEmpty) {
      setState(() {
        selectedBranch = null;
        services = [];
        departments = [];
      });
      return;
    }

    final previousBranchId = selectedBranch == null
        ? null
        : _id(selectedBranch!);

    selectedBranch = branches.firstWhere(
      (item) => previousBranchId != null && _id(item) == previousBranchId,
      orElse: () {
        return branches.firstWhere(
          (item) => item['is_primary'] == true,
          orElse: () => branches.first,
        );
      },
    );

    await _loadBranchData();
  }

  Future<void> _loadBranchData() async {
    if (selectedBranch == null) return;

    try {
      final results = await Future.wait([
        WorkshopService.getServices(branchId),
        WorkshopService.getDepartments(branchId),
      ]);

      if (!mounted) return;

      setState(() {
        services = results[0];
        departments = results[1];
      });
    } catch (e) {
      _message('Could not load branch information: $e');
    }
  }

  Future<void> _selectWorkshop(int id) async {
    final selected = workshops.firstWhere((item) => _id(item) == id);

    setState(() {
      selectedWorkshop = selected;
      selectedBranch = null;
      branches = [];
      services = [];
      departments = [];
      _isLoading = true;
    });

    try {
      await _loadBranches();
    } catch (e) {
      _message('Could not load branches: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _selectBranch(int id) async {
    final selected = branches.firstWhere((item) => _id(item) == id);

    setState(() {
      selectedBranch = selected;
      services = [];
      departments = [];
      _isLoading = true;
    });

    try {
      await _loadBranchData();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ------------------------------------------------------------
  // CREATE WORKSHOP
  // ------------------------------------------------------------

  Future<void> _createWorkshop() async {
    final name = TextEditingController();
    final description = TextEditingController();
    final email = TextEditingController();
    final phone = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Create Workshop'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Workshop Name *'),
              ),
              TextField(
                controller: description,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: email,
                decoration: const InputDecoration(labelText: 'Business Email'),
              ),
              TextField(
                controller: phone,
                decoration: const InputDecoration(labelText: 'Phone'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      name.dispose();
      description.dispose();
      email.dispose();
      phone.dispose();
      return;
    }

    if (name.text.trim().isEmpty) {
      _message('Workshop name is required.');
      name.dispose();
      description.dispose();
      email.dispose();
      phone.dispose();
      return;
    }

    try {
      await WorkshopService.createWorkshop(
        name: name.text.trim(),
        description: description.text.trim(),
        email: email.text.trim(),
        phone: phone.text.trim(),
      );

      _message('Workshop created successfully.');
      await _loadWorkshopData();
    } catch (e) {
      _message('Could not create workshop: $e');
    } finally {
      name.dispose();
      description.dispose();
      email.dispose();
      phone.dispose();
    }
  }

  // ------------------------------------------------------------
  // CREATE BRANCH
  // ------------------------------------------------------------

  Future<void> _createBranch() async {
    if (selectedWorkshop == null) return;

    final name = TextEditingController();
    final address = TextEditingController();
    final city = TextEditingController();
    final phone = TextEditingController();
    final email = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add Workshop Branch'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Branch Name *'),
              ),
              TextField(
                controller: address,
                decoration: const InputDecoration(labelText: 'Address *'),
              ),
              TextField(
                controller: city,
                decoration: const InputDecoration(labelText: 'City *'),
              ),
              TextField(
                controller: phone,
                decoration: const InputDecoration(labelText: 'Phone'),
              ),
              TextField(
                controller: email,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Create Branch'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      name.dispose();
      address.dispose();
      city.dispose();
      phone.dispose();
      email.dispose();
      return;
    }

    if (name.text.trim().isEmpty ||
        address.text.trim().isEmpty ||
        city.text.trim().isEmpty) {
      _message('Branch name, address and city are required.');
      name.dispose();
      address.dispose();
      city.dispose();
      phone.dispose();
      email.dispose();
      return;
    }

    try {
      await WorkshopService.createBranch(
        workshopId,
        name: name.text.trim(),
        address: address.text.trim(),
        city: city.text.trim(),
        phone: phone.text.trim(),
        email: email.text.trim(),
      );

      _message('Branch created successfully.');
      await _loadWorkshopData();
    } catch (e) {
      _message('Could not create branch: $e');
    } finally {
      name.dispose();
      address.dispose();
      city.dispose();
      phone.dispose();
      email.dispose();
    }
  }

  // ------------------------------------------------------------
  // SERVICE MANAGEMENT
  // ------------------------------------------------------------

  Future<void> _showServiceEditor({Map<String, dynamic>? service}) async {
    if (selectedBranch == null) {
      _message('Create or select a branch first.');
      return;
    }

    final name = TextEditingController(
      text: service?['name']?.toString() ?? '',
    );
    final price = TextEditingController(
      text: service?['price']?.toString() ?? '',
    );
    final description = TextEditingController(
      text: service?['description']?.toString() ?? '',
    );
    final duration = TextEditingController(
      text: service?['estimated_duration_minutes']?.toString() ?? '60',
    );

    int? departmentId = service?['department'] is int
        ? service!['department'] as int
        : int.tryParse(service?['department']?.toString() ?? '');

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, refreshDialog) => AlertDialog(
          title: Text(service == null ? 'Add Service' : 'Edit Service'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: name,
                  decoration: const InputDecoration(
                    labelText: 'Service Name *',
                  ),
                ),
                TextField(
                  controller: price,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(labelText: 'Price (PKR) *'),
                ),
                TextField(
                  controller: duration,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Estimated Duration (minutes) *',
                  ),
                ),
                TextField(
                  controller: description,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  initialValue: departmentId,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Department (Optional)',
                  ),
                  items: [
                    const DropdownMenuItem<int>(
                      value: null,
                      child: Text('No Department'),
                    ),
                    ...departments.map(
                      (department) => DropdownMenuItem<int>(
                        value: _id(department),
                        child: Text(department['name'].toString()),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    refreshDialog(() => departmentId = value);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if (confirmed != true) {
      name.dispose();
      price.dispose();
      duration.dispose();
      description.dispose();
      return;
    }

    final amount = double.tryParse(price.text.trim());
    final minutes = int.tryParse(duration.text.trim());

    if (name.text.trim().isEmpty ||
        amount == null ||
        amount < 0 ||
        minutes == null ||
        minutes <= 0) {
      _message('Enter a valid name, price and duration.');
      name.dispose();
      price.dispose();
      duration.dispose();
      description.dispose();
      return;
    }

    try {
      if (service == null) {
        await WorkshopService.createService(
          branchId,
          name: name.text.trim(),
          description: description.text.trim(),
          price: amount,
          estimatedDurationMinutes: minutes,
          departmentId: departmentId,
        );
        _message('Service added successfully.');
      } else {
        await WorkshopService.updateService(_id(service), {
          'name': name.text.trim(),
          'description': description.text.trim(),
          'price': amount,
          'estimated_duration_minutes': minutes,
          'department': departmentId,
        });
        _message('Service updated successfully.');
      }

      await _loadBranchData();
    } catch (e) {
      _message('Could not save service: $e');
    } finally {
      name.dispose();
      price.dispose();
      duration.dispose();
      description.dispose();
    }
  }

  Future<void> _toggleService(Map<String, dynamic> service, bool active) async {
    try {
      await WorkshopService.updateService(_id(service), {'is_active': active});

      await _loadBranchData();
      _message(active ? 'Service activated.' : 'Service deactivated.');
    } catch (e) {
      _message('Could not update service: $e');
    }
  }

  Future<void> _deleteService(Map<String, dynamic> service) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Service'),
        content: Text('Are you sure you want to remove ${service['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await WorkshopService.deleteService(_id(service));
      await _loadBranchData();
      _message('Service removed.');
    } catch (e) {
      _message('Could not delete service: $e');
    }
  }

  // ------------------------------------------------------------
  // WORKSHOP PROFILE EDITING
  // ------------------------------------------------------------

  Future<void> _editWorkshop() async {
    if (selectedWorkshop == null) return;

    final name = TextEditingController(
      text: selectedWorkshop!['name']?.toString() ?? '',
    );
    final email = TextEditingController(
      text: selectedWorkshop!['email']?.toString() ?? '',
    );
    final phone = TextEditingController(
      text: selectedWorkshop!['phone']?.toString() ?? '',
    );
    final description = TextEditingController(
      text: selectedWorkshop!['description']?.toString() ?? '',
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Workshop Information'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: email,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: phone,
                decoration: const InputDecoration(labelText: 'Phone'),
              ),
              TextField(
                controller: description,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (confirmed == true && name.text.trim().isNotEmpty) {
      try {
        await WorkshopService.updateWorkshop(workshopId, {
          'name': name.text.trim(),
          'email': email.text.trim(),
          'phone': phone.text.trim(),
          'description': description.text.trim(),
        });
        await _loadWorkshopData();
        _message('Workshop information updated.');
      } catch (e) {
        _message('Could not update workshop: $e');
      }
    }

    name.dispose();
    email.dispose();
    phone.dispose();
    description.dispose();
  }

  Future<void> _editBranch() async {
    if (selectedBranch == null) return;

    final name = TextEditingController(
      text: selectedBranch!['name']?.toString() ?? '',
    );
    final address = TextEditingController(
      text: selectedBranch!['address']?.toString() ?? '',
    );
    final city = TextEditingController(
      text: selectedBranch!['city']?.toString() ?? '',
    );
    final phone = TextEditingController(
      text: selectedBranch!['phone']?.toString() ?? '',
    );
    final email = TextEditingController(
      text: selectedBranch!['email']?.toString() ?? '',
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Branch Information'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Branch Name'),
              ),
              TextField(
                controller: address,
                decoration: const InputDecoration(labelText: 'Address'),
              ),
              TextField(
                controller: city,
                decoration: const InputDecoration(labelText: 'City'),
              ),
              TextField(
                controller: phone,
                decoration: const InputDecoration(labelText: 'Phone'),
              ),
              TextField(
                controller: email,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (confirmed == true &&
        name.text.trim().isNotEmpty &&
        address.text.trim().isNotEmpty &&
        city.text.trim().isNotEmpty) {
      try {
        await WorkshopService.updateBranch(branchId, {
          'name': name.text.trim(),
          'address': address.text.trim(),
          'city': city.text.trim(),
          'phone': phone.text.trim(),
          'email': email.text.trim(),
        });
        await _loadWorkshopData();
        _message('Branch information updated.');
      } catch (e) {
        _message('Could not update branch: $e');
      }
    }

    name.dispose();
    address.dispose();
    city.dispose();
    phone.dispose();
    email.dispose();
  }

  // ------------------------------------------------------------
  // LOGOUT
  // ------------------------------------------------------------

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text(
          'Are you sure you want to log out of your workshop account?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Log Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await AuthService.logout();
      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      _message('Logout failed: $e');
    }
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

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
          onPressed: _confirmLogout,
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
            icon: const Icon(Icons.qr_code_scanner, color: workshopBlue),
            tooltip: 'Website QR Login',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WebsiteQrScannerScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: workshopNavy),
            onPressed: _loadWorkshopData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? _errorView()
            : IndexedStack(index: _selectedIndex, children: pages),
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

  Widget _errorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 50, color: Colors.red),
            const SizedBox(height: 15),
            const Text(
              'Could not load workshop data',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: workshopNavy,
              ),
            ),
            const SizedBox(height: 10),
            Text(_error ?? '', textAlign: TextAlign.center),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: _loadWorkshopData,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // HOME
  // ------------------------------------------------------------

  Widget _buildHome() {
    if (selectedWorkshop == null) {
      return _pageLayout(
        child: Column(
          children: [
            const SizedBox(height: 50),
            const Icon(Icons.storefront, size: 75, color: workshopBlue),
            const SizedBox(height: 18),
            const Text(
              'Welcome, Workshop Owner!',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: workshopNavy,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              'You have not created a workshop yet. Create your workshop to get started.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.blueGrey),
            ),
            const SizedBox(height: 22),
            ElevatedButton.icon(
              onPressed: _createWorkshop,
              icon: const Icon(Icons.add),
              label: const Text('Create Workshop'),
              style: _primaryButtonStyle,
            ),
          ],
        ),
      );
    }

    return _pageLayout(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome, Workshop Owner!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: workshopNavy,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Manage your workshop and services.',
            style: TextStyle(color: Colors.blueGrey),
          ),
          const SizedBox(height: 22),
          _selectionCard(),
          const SizedBox(height: 22),
          const Text('Workshop Overview', style: _headingStyle),
          const SizedBox(height: 13),
          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width > 650 ? 3 : 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.45,
            children: [
              _statCard(
                'Workshops',
                workshops.length.toString(),
                Icons.storefront,
              ),
              _statCard(
                'Branches',
                branches.length.toString(),
                Icons.location_on_outlined,
              ),
              _statCard(
                'Active Services',
                services.where((s) => s['is_active'] == true).length.toString(),
                Icons.build_outlined,
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Branch Services', style: _headingStyle),
          const SizedBox(height: 12),
          if (selectedBranch == null)
            _emptyCard(
              Icons.add_business,
              'No branch created',
              'Add a branch to start managing services.',
            )
          else if (services.isEmpty)
            _emptyCard(
              Icons.build_outlined,
              'No services yet',
              'Add services from the Services tab.',
            )
          else
            ...services.take(3).map(_serviceSummaryCard),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => setState(() => _selectedIndex = 3),
            icon: const Icon(Icons.build),
            label: const Text('Manage Services'),
          ),
        ],
      ),
    );
  }

  Widget _selectionCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Select Workshop', style: _headingStyle),
          const SizedBox(height: 10),
          DropdownButtonFormField<int>(
            initialValue: _id(selectedWorkshop!),
            isExpanded: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Workshop',
            ),
            items: workshops.map((item) {
              return DropdownMenuItem<int>(
                value: _id(item),
                child: Text(item['name'].toString()),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) _selectWorkshop(value);
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(
                child: Text('Select Branch', style: _headingStyle),
              ),
              TextButton.icon(
                onPressed: _createBranch,
                icon: const Icon(Icons.add),
                label: const Text('Add Branch'),
              ),
            ],
          ),
          if (branches.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'No branches available. Add your first branch.',
                style: TextStyle(color: Colors.blueGrey),
              ),
            )
          else
            DropdownButtonFormField<int>(
              initialValue: _id(selectedBranch!),
              isExpanded: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Branch',
              ),
              items: branches.map((item) {
                return DropdownMenuItem<int>(
                  value: _id(item),
                  child: Text(item['name'].toString()),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) _selectBranch(value);
              },
            ),
          if (selectedBranch != null) ...[
            const SizedBox(height: 10),
            Text(
              '${selectedBranch!['address'] ?? ''}, ${selectedBranch!['city'] ?? ''}',
              style: const TextStyle(color: Colors.blueGrey),
            ),
          ],
        ],
      ),
    );
  }

  Widget _serviceSummaryCard(Map<String, dynamic> service) {
    return _card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFEAF3FF),
          child: Icon(Icons.build, color: workshopBlue),
        ),
        title: Text(
          service['name'].toString(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: workshopNavy,
          ),
        ),
        subtitle: Text('PKR ${service['price']}'),
        trailing: _statusBadge(
          service['is_active'] == true ? 'Active' : 'Inactive',
        ),
      ),
    );
  }

  Widget _statCard(String title, String value, IconData icon) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: workshopBlue, size: 25),
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

  // ------------------------------------------------------------
  // BOOKINGS AND JOBS
  // ------------------------------------------------------------

  Widget _buildBookingsPage() {
    return _pageLayout(
      child: _emptyCard(
        Icons.calendar_month,
        'Bookings API integration pending',
        'Real customer bookings will appear here after the booking endpoints are connected.',
      ),
    );
  }

  Widget _buildJobsPage() {
    return _pageLayout(
      child: _emptyCard(
        Icons.work_outline,
        'Jobs API integration pending',
        'Workshop job management will be connected after the booking workflow is implemented.',
      ),
    );
  }

  // ------------------------------------------------------------
  // SERVICES PAGE
  // ------------------------------------------------------------

  Widget _buildServicesPage() {
    return _pageLayout(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Workshop Services', style: _headingStyle),
              ),
              ElevatedButton.icon(
                onPressed: selectedBranch == null
                    ? null
                    : () => _showServiceEditor(),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add'),
                style: _primaryButtonStyle,
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Manage the services and prices offered by your selected branch.',
            style: TextStyle(color: Colors.blueGrey),
          ),
          const SizedBox(height: 16),
          if (selectedBranch == null)
            _emptyCard(
              Icons.location_on_outlined,
              'Select a branch first',
              'Open Home and create or select a branch before managing services.',
            )
          else if (services.isEmpty)
            _emptyCard(
              Icons.build_outlined,
              'No services available',
              'Use Add to create your first service.',
            )
          else
            ...services.map(_buildServiceCard),
        ],
      ),
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service) {
    final active = service['is_active'] == true;
    final departmentId = service['department'];

    String departmentName = 'No department';

    for (final department in departments) {
      if (_id(department) == int.tryParse(departmentId?.toString() ?? '')) {
        departmentName = department['name'].toString();
        break;
      }
    }

    return _card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF3FF),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(Icons.build, color: workshopBlue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service['name'].toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: workshopNavy,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  service['description']?.toString() ?? '',
                  style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
                ),
                const SizedBox(height: 5),
                Text(
                  'PKR ${service['price']}',
                  style: const TextStyle(
                    color: workshopBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${service['estimated_duration_minutes'] ?? '-'} minutes â€¢ $departmentName',
                  style: const TextStyle(fontSize: 11, color: Colors.blueGrey),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Switch(
                value: active,
                activeThumbColor: workshopBlue,
                onChanged: (value) => _toggleService(service, value),
              ),
              PopupMenuButton<String>(
                onSelected: (choice) {
                  if (choice == 'edit') {
                    _showServiceEditor(service: service);
                  } else if (choice == 'delete') {
                    _deleteService(service);
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // PROFILE
  // ------------------------------------------------------------

  Widget _buildProfilePage() {
    if (selectedWorkshop == null) {
      return _pageLayout(
        child: _emptyCard(
          Icons.storefront,
          'No workshop profile',
          'Create your workshop to manage its profile.',
        ),
      );
    }

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
            selectedWorkshop!['name'].toString(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: workshopNavy,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            selectedWorkshop!['email']?.toString() ?? '',
            style: const TextStyle(color: Colors.blueGrey),
          ),
          const SizedBox(height: 25),
          _profileOption(
            Icons.store_outlined,
            'Edit Workshop Information',
            _editWorkshop,
          ),
          _profileOption(
            Icons.location_on_outlined,
            'Edit Selected Branch',
            selectedBranch == null ? null : _editBranch,
          ),
          _profileOption(
            Icons.add_business_outlined,
            'Add Another Branch',
            _createBranch,
          ),
          _profileOption(
            Icons.refresh,
            'Refresh Workshop Data',
            _loadWorkshopData,
          ),
          _profileOption(Icons.help_outline, 'Help & Support', _showHelp),
          _profileOption(Icons.logout, 'Log Out', _confirmLogout),
        ],
      ),
    );
  }

  Widget _profileOption(IconData icon, String title, VoidCallback? onTap) {
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
        onTap: onTap,
      ),
    );
  }

  void _showHelp() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Workshop Help'),
        content: const Text(
          'Create your workshop, add one or more branches, and manage each branch service catalogue from the Services tab. Booking, job and invoice features will be connected when their backend APIs are ready.',
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

  // ------------------------------------------------------------
  // REUSABLE WIDGETS
  // ------------------------------------------------------------

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

  Widget _emptyCard(IconData icon, String title, String subtitle) {
    return _card(
      child: Column(
        children: [
          Icon(icon, size: 42, color: workshopBlue),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
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

  Widget _statusBadge(String status) {
    final active = status == 'Active';

    final color = active ? Colors.green : Colors.grey;

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

  static const TextStyle _headingStyle = TextStyle(
    fontSize: 19,
    fontWeight: FontWeight.bold,
    color: workshopNavy,
  );

  static final ButtonStyle _primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: workshopBlue,
    foregroundColor: Colors.white,
  );
}
