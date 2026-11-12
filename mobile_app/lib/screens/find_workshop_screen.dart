import 'package:material_ui/material_ui.dart';

import 'book_service_screen.dart';

const Color workshopBlue = Color(0xFF1565C0);
const Color workshopNavy = Color(0xFF102A43);
const Color workshopBackground = Color(0xFFF5F7FB);

class FindWorkshopScreen extends StatefulWidget {
  const FindWorkshopScreen({super.key});

  @override
  State<FindWorkshopScreen> createState() => _FindWorkshopScreenState();
}

class _FindWorkshopScreenState extends State<FindWorkshopScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _selectedFilter = 'All';

  final List<String> _filters = [
    'All',
    'General Service',
    'Oil Change',
    'Engine Repair',
    'Car Wash',
    'Electrical',
  ];

  final List<Map<String, dynamic>> _workshops = [
    {
      'name': 'AutoCare Premium Workshop',
      'location': 'Saddar, Rawalpindi',
      'rating': 4.8,
      'reviews': 125,
      'distance': '2.5 km',
      'services': ['General Service', 'Oil Change', 'Engine Repair'],
      'price': 'From Rs. 2,000',
      'open': true,
      'icon': Icons.car_repair,
    },
    {
      'name': 'Elite Motors Service Centre',
      'location': 'Commercial Market, Rawalpindi',
      'rating': 4.6,
      'reviews': 98,
      'distance': '4.0 km',
      'services': ['General Service', 'Electrical', 'Oil Change'],
      'price': 'From Rs. 1,500',
      'open': true,
      'icon': Icons.build_circle_outlined,
    },
    {
      'name': 'QuickFix Auto Workshop',
      'location': 'Bahria Town, Rawalpindi',
      'rating': 4.5,
      'reviews': 76,
      'distance': '6.2 km',
      'services': ['Engine Repair', 'Car Wash', 'Electrical'],
      'price': 'From Rs. 1,000',
      'open': false,
      'icon': Icons.handyman_outlined,
    },
    {
      'name': 'City Motors Garage',
      'location': 'Chaklala, Rawalpindi',
      'rating': 4.7,
      'reviews': 110,
      'distance': '5.1 km',
      'services': ['Oil Change', 'General Service', 'Car Wash'],
      'price': 'From Rs. 1,200',
      'open': true,
      'icon': Icons.garage_outlined,
    },
  ];

  List<Map<String, dynamic>> get _filteredWorkshops {
    final query = _searchController.text.toLowerCase().trim();

    return _workshops.where((workshop) {
      final name = workshop['name'].toString().toLowerCase();
      final location = workshop['location'].toString().toLowerCase();

      final services = List<String>.from(workshop['services']);

      final matchesSearch =
          query.isEmpty ||
          name.contains(query) ||
          location.contains(query) ||
          services.any((service) => service.toLowerCase().contains(query));

      final matchesFilter =
          _selectedFilter == 'All' || services.contains(_selectedFilter);

      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // BOOK SERVICE NAVIGATION
  // Returns the confirmed booking to the dashboard.

  Future<void> _openBookingScreen(
    Map<String, dynamic> workshop,
    BuildContext sheetContext,
  ) async {
    debugPrint('BOOK SERVICE BUTTON PRESSED');

    // Close workshop details bottom sheet.
    Navigator.pop(sheetContext);

    // Open booking screen and wait for the result.
    final booking = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => BookServiceScreen(
          workshopName: workshop['name'].toString(),
          workshopLocation: workshop['location'].toString(),
        ),
      ),
    );

    // Return the confirmed booking to the dashboard.
    if (!mounted || booking == null) return;

    Navigator.pop(context, booking);
  }

  // WORKSHOP DETAILS

  void _showWorkshopDetails(Map<String, dynamic> workshop) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (sheetContext) {
        final services = List<String>.from(workshop['services']);

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 10, 22, 25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _workshopIcon(workshop['icon']),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        workshop['name'],
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: workshopNavy,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                _detailRow(Icons.location_on_outlined, workshop['location']),

                _detailRow(
                  Icons.star_rounded,
                  '${workshop['rating']} rating '
                  '(${workshop['reviews']} reviews)',
                ),

                _detailRow(Icons.near_me_outlined, workshop['distance']),

                const SizedBox(height: 18),

                const Text(
                  'Available Services',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: workshopNavy,
                  ),
                ),

                const SizedBox(height: 12),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: services.map((service) {
                    return Chip(
                      label: Text(service),
                      backgroundColor: const Color(0xFFEAF3FF),
                      side: BorderSide.none,
                    );
                  }).toList(),
                ),

                const SizedBox(height: 16),

                Text(
                  workshop['price'],
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: workshopBlue,
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _openBookingScreen(workshop, sheetContext);
                    },
                    icon: const Icon(Icons.calendar_month),
                    label: const Text('Book Service'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: workshopBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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

  // DETAIL ROW

  Widget _detailRow(IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Icon(icon, color: workshopBlue, size: 21),
          const SizedBox(width: 10),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.blueGrey)),
          ),
        ],
      ),
    );
  }

  // WORKSHOP ICON

  Widget _workshopIcon(IconData icon) {
    return Container(
      height: 58,
      width: 58,
      decoration: BoxDecoration(
        color: const Color(0xFFEAF3FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, color: workshopBlue, size: 32),
    );
  }

  // FILTER CHIPS

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _filters.map((filter) {
          final selected = _selectedFilter == filter;

          return Padding(
            padding: const EdgeInsets.only(right: 9),
            child: ChoiceChip(
              label: Text(filter),
              selected: selected,
              onSelected: (_) {
                setState(() {
                  _selectedFilter = filter;
                });
              },
              selectedColor: workshopBlue,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: selected ? Colors.white : workshopNavy,
                fontWeight: FontWeight.w600,
              ),
              side: BorderSide(
                color: selected ? workshopBlue : const Color(0xFFE0E6EF),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // WORKSHOP CARD

  Widget _buildWorkshopCard(Map<String, dynamic> workshop) {
    final services = List<String>.from(workshop['services']);

    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(17),
        side: const BorderSide(color: Color(0xFFE3EAF3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _workshopIcon(workshop['icon']),
                const SizedBox(width: 13),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        workshop['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: workshopNavy,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        workshop['location'],
                        style: const TextStyle(
                          color: Colors.blueGrey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'details') {
                      _showWorkshopDetails(workshop);
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'details',
                      child: Text('View Details'),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 15),

            Row(
              children: [
                const Icon(Icons.star_rounded, color: Colors.amber, size: 21),
                const SizedBox(width: 4),

                Text(
                  '${workshop['rating']}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),

                Text(
                  ' (${workshop['reviews']} reviews)',
                  style: const TextStyle(color: Colors.blueGrey, fontSize: 12),
                ),

                const Spacer(),

                const Icon(
                  Icons.near_me_outlined,
                  color: workshopBlue,
                  size: 17,
                ),

                const SizedBox(width: 4),

                Text(
                  workshop['distance'],
                  style: const TextStyle(color: Colors.blueGrey, fontSize: 12),
                ),
              ],
            ),

            const SizedBox(height: 13),

            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: services.take(3).map((service) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF3FF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    service,
                    style: const TextStyle(
                      fontSize: 11,
                      color: workshopBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: Text(
                    workshop['price'],
                    style: const TextStyle(
                      color: workshopNavy,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                Text(
                  workshop['open'] ? 'Open Now' : 'Closed',
                  style: TextStyle(
                    color: workshop['open'] ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 13),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  _showWorkshopDetails(workshop);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: workshopBlue,
                  side: const BorderSide(color: workshopBlue),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                ),
                child: const Text('View Workshop & Services'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // MAIN SCREEN

  @override
  Widget build(BuildContext context) {
    final workshops = _filteredWorkshops;

    return Scaffold(
      backgroundColor: workshopBackground,

      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Row(
          children: [
            Icon(Icons.directions_car_filled_rounded, color: workshopBlue),
            SizedBox(width: 10),
            Text(
              'Find Workshops',
              style: TextStyle(
                color: workshopNavy,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),

      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 850),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // BANNER

                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                    ),
                    borderRadius: BorderRadius.circular(19),
                  ),
                  child: const Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Find Trusted Workshops',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 21,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Discover workshops and services '
                              'for your vehicle.',
                              style: TextStyle(
                                color: Colors.white,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 10),
                      Icon(
                        Icons.car_repair_rounded,
                        color: Colors.white,
                        size: 48,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // SEARCH FIELD
                TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search workshop, location or service',
                    prefixIcon: const Icon(Icons.search, color: workshopBlue),
                    suffixIcon: IconButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                      icon: const Icon(Icons.close),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  'Filter by Service',
                  style: TextStyle(
                    color: workshopNavy,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                _buildFilterChips(),

                const SizedBox(height: 22),

                // WORKSHOP LIST HEADING
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Available Workshops',
                        style: TextStyle(
                          color: workshopNavy,
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    Text(
                      '${workshops.length} found',
                      style: const TextStyle(color: Colors.blueGrey),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // WORKSHOP RESULTS
                if (workshops.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(35),
                    child: Column(
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 55,
                          color: Colors.blueGrey,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'No workshops found',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: workshopNavy,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Try another search or service filter.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.blueGrey),
                        ),
                      ],
                    ),
                  )
                else
                  ...workshops.map(_buildWorkshopCard),

                const SizedBox(height: 20),

                const Center(
                  child: Text(
                    'Smart Auto Care • Your car, our responsibility',
                    style: TextStyle(color: Colors.blueGrey, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
