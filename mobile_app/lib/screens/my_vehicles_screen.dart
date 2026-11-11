import 'package:flutter/material.dart';

const Color myVehiclesBlue = Color(0xFF1565C0);
const Color myVehiclesNavy = Color(0xFF102A43);
const Color myVehiclesBackground = Color(0xFFF5F7FB);

class MyVehiclesScreen extends StatefulWidget {
  const MyVehiclesScreen({
    super.key,
    this.initialVehicles = const [],
    this.onVehiclesChanged,
  });

  final List<Map<String, dynamic>> initialVehicles;
  final ValueChanged<List<Map<String, dynamic>>>? onVehiclesChanged;

  @override
  State<MyVehiclesScreen> createState() => _MyVehiclesScreenState();
}

class _MyVehiclesScreenState extends State<MyVehiclesScreen> {
  late List<Map<String, dynamic>> _vehicles;

  @override
  void initState() {
    super.initState();
    _vehicles = widget.initialVehicles
        .map((vehicle) => Map<String, dynamic>.from(vehicle))
        .toList();

    // Demo vehicles are shown when no vehicles are supplied.
    if (_vehicles.isEmpty) {
      _vehicles = [
        {
          'registrationNumber': 'ABC-123',
          'make': 'Honda',
          'model': 'Civic',
          'year': 2022,
          'type': 'Car',
          'fuelType': 'Petrol',
          'transmission': 'Automatic',
          'color': 'White',
          'mileage': 35000,
        },
        {
          'registrationNumber': 'XYZ-456',
          'make': 'Toyota',
          'model': 'Corolla',
          'year': 2021,
          'type': 'Car',
          'fuelType': 'Petrol',
          'transmission': 'Automatic',
          'color': 'Silver',
          'mileage': 48000,
        },
      ];
    }
  }

  void _notifyChanges() {
    widget.onVehiclesChanged?.call(
      _vehicles.map((vehicle) => Map<String, dynamic>.from(vehicle)).toList(),
    );
  }

  void _addVehicle() {
    Navigator.pushNamed(context, '/add-vehicle').then((result) {
      if (!mounted || result is! Map) return;

      final vehicle = Map<String, dynamic>.from(result);

      setState(() {
        _vehicles.add(vehicle);
      });

      _notifyChanges();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vehicle added successfully.'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  void _removeVehicle(int index) {
    final vehicle = _vehicles[index];
    final name = '${vehicle['make'] ?? ''} ${vehicle['model'] ?? ''}'.trim();

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Remove Vehicle?'),
          content: Text('Do you want to remove $name from your vehicles?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                setState(() {
                  _vehicles.removeAt(index);
                });

                _notifyChanges();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Vehicle removed.'),
                  ),
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );
  }

  void _showVehicleDetails(Map<String, dynamic> vehicle) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (context) {
        final details = <MapEntry<String, String>>[
          MapEntry('Registration', '${vehicle['registrationNumber'] ?? '—'}'),
          MapEntry('Make', '${vehicle['make'] ?? '—'}'),
          MapEntry('Model', '${vehicle['model'] ?? '—'}'),
          MapEntry('Year', '${vehicle['year'] ?? '—'}'),
          MapEntry('Type', '${vehicle['type'] ?? '—'}'),
          MapEntry('Fuel Type', '${vehicle['fuelType'] ?? '—'}'),
          MapEntry('Transmission', '${vehicle['transmission'] ?? '—'}'),
          MapEntry('Color', '${vehicle['color'] ?? '—'}'),
          MapEntry('Mileage', '${vehicle['mileage'] ?? '—'} km'),
        ];

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 8, 22, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Vehicle Details',
                  style: TextStyle(
                    color: myVehiclesNavy,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 18),
                ...details.map(
                      (detail) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            detail.key,
                            style: const TextStyle(color: Colors.blueGrey),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            detail.value,
                            textAlign: TextAlign.end,
                            style: const TextStyle(
                              color: myVehiclesNavy,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: myVehiclesBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: myVehiclesNavy),
        title: const Text(
          'My Vehicles',
          style: TextStyle(
            color: myVehiclesNavy,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Add Vehicle',
            onPressed: _addVehicle,
            icon: const Icon(Icons.add_circle_outline),
            color: myVehiclesBlue,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: _vehicles.isEmpty
                ? _buildEmptyState()
                : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Registered Vehicles',
                        style: TextStyle(
                          color: myVehiclesNavy,
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      '${_vehicles.length} vehicle${_vehicles.length == 1 ? '' : 's'}',
                      style: const TextStyle(
                        color: Colors.blueGrey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                ...List.generate(
                  _vehicles.length,
                      (index) => _buildVehicleCard(_vehicles[index], index),
                ),
                const SizedBox(height: 18),
                OutlinedButton.icon(
                  onPressed: _addVehicle,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Another Vehicle'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: myVehiclesBlue,
                    padding: const EdgeInsets.all(16),
                    side: const BorderSide(color: myVehiclesBlue),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Center(
                  child: Text(
                    'Smart Auto Care • Your car, our responsibility',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.blueGrey,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(23),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1565C0),
            Color(0xFF42A5F5),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Vehicles,',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Your Responsibility',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Keep your vehicle information organized in one place.',
                  style: TextStyle(
                    color: Colors.white,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12),
          Icon(
            Icons.directions_car_filled_rounded,
            size: 55,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleCard(Map<String, dynamic> vehicle, int index) {
    final make = '${vehicle['make'] ?? ''}';
    final model = '${vehicle['model'] ?? ''}';
    final year = '${vehicle['year'] ?? ''}';
    final registration = '${vehicle['registrationNumber'] ?? 'Not provided'}';
    final fuel = '${vehicle['fuelType'] ?? 'Not specified'}';
    final mileage = '${vehicle['mileage'] ?? '—'}';

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 15),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFFE3EAF3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  height: 58,
                  width: 58,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF3FF),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.directions_car_filled_rounded,
                    size: 31,
                    color: myVehiclesBlue,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$make $model'.trim(),
                        style: const TextStyle(
                          color: myVehiclesNavy,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '$year • $registration',
                        style: const TextStyle(
                          color: Colors.blueGrey,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  tooltip: 'Vehicle options',
                  onSelected: (value) {
                    if (value == 'details') {
                      _showVehicleDetails(vehicle);
                    } else if (value == 'remove') {
                      _removeVehicle(index);
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'details',
                      child: Row(
                        children: [
                          Icon(Icons.info_outline),
                          SizedBox(width: 10),
                          Text('View Details'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'remove',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, color: Colors.red),
                          SizedBox(width: 10),
                          Text('Remove Vehicle'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 28),
            Row(
              children: [
                Expanded(
                  child: _detailTile(
                    icon: Icons.local_gas_station_outlined,
                    label: 'Fuel Type',
                    value: fuel,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _detailTile(
                    icon: Icons.speed_rounded,
                    label: 'Mileage',
                    value: '$mileage km',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showVehicleDetails(vehicle),
                icon: const Icon(Icons.visibility_outlined),
                label: const Text('View Vehicle Details'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: myVehiclesBlue,
                  side: const BorderSide(color: Color(0xFFD5E3F5)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: myVehiclesBlue),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: myVehiclesNavy,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFFEAF3FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.directions_car_outlined,
                size: 65,
                color: myVehiclesBlue,
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'No Vehicles Yet',
              style: TextStyle(
                color: myVehiclesNavy,
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Add your first vehicle to manage its details and service history.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.blueGrey,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 23),
            FilledButton.icon(
              onPressed: _addVehicle,
              icon: const Icon(Icons.add),
              label: const Text('Add Vehicle'),
              style: FilledButton.styleFrom(
                backgroundColor: myVehiclesBlue,
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}