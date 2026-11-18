import 'package:material_ui/material_ui.dart';

const Color _primaryBlue = Color(0xFF1565C0);
const Color _backgroundColor = Color(0xFFF5F7FB);
const Color _navyColor = Color(0xFF102A43);

class ServiceHistoryScreen extends StatefulWidget {
  const ServiceHistoryScreen({super.key});

  @override
  State<ServiceHistoryScreen> createState() => _ServiceHistoryScreenState();
}

class _ServiceHistoryScreenState extends State<ServiceHistoryScreen> {
  String _selectedFilter = 'All';

  // Temporary demonstration data.
  // Replace with records retrieved from the Django API later.
  final List<Map<String, String>> _serviceRecords = [
    {
      'service': 'Oil Change',
      'vehicle': 'Honda Civic',
      'workshop': 'City Auto Workshop',
      'bookingDate': '15 Oct 2026',
      'completionDate': '15 Oct 2026',
      'status': 'Completed',
    },
    {
      'service': 'General Inspection',
      'vehicle': 'Toyota Corolla',
      'workshop': 'Auto Care Centre',
      'bookingDate': '02 Oct 2026',
      'completionDate': '02 Oct 2026',
      'status': 'Completed',
    },
    {
      'service': 'Brake Inspection',
      'vehicle': 'Honda Civic',
      'workshop': 'City Auto Workshop',
      'bookingDate': '18 Nov 2026',
      'completionDate': 'Pending',
      'status': 'In Progress',
    },
  ];

  List<Map<String, String>> get _filteredRecords {
    if (_selectedFilter == 'All') {
      return _serviceRecords;
    }

    return _serviceRecords
        .where((record) => record['status'] == _selectedFilter)
        .toList();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Completed':
        return Colors.green;
      case 'In Progress':
        return Colors.orange;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'Completed':
        return Icons.check_circle_outline;
      case 'In Progress':
        return Icons.pending_actions;
      case 'Cancelled':
        return Icons.cancel_outlined;
      default:
        return Icons.info_outline;
    }
  }

  Widget _buildServiceCard(Map<String, String> record) {
    final status = record['status'] ?? 'Unknown';
    final statusColor = _statusColor(status);

    return Card(
      color: Colors.white,
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE5EAF1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _primaryBlue.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.build_circle_outlined,
                    color: _primaryBlue,
                    size: 27,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record['service'] ?? 'Service',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _navyColor,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        record['vehicle'] ?? 'Vehicle not specified',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.blueGrey,
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_statusIcon(status), size: 14, color: statusColor),
                      const SizedBox(width: 5),
                      Text(
                        status,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),
            const Divider(),
            const SizedBox(height: 10),

            _detailRow(
              Icons.home_repair_service_outlined,
              'Workshop',
              record['workshop'] ?? 'Not available',
            ),

            const SizedBox(height: 12),

            _detailRow(
              Icons.calendar_today_outlined,
              'Booking Date',
              record['bookingDate'] ?? 'Not available',
            ),

            const SizedBox(height: 12),

            _detailRow(
              Icons.event_available_outlined,
              'Completion Date',
              record['completionDate'] ?? 'Not available',
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.blueGrey),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: Colors.blueGrey),
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _navyColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history, size: 65, color: Colors.blueGrey.shade300),
            const SizedBox(height: 16),
            const Text(
              'No Service Records Found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _navyColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your service records will appear here once available.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.blueGrey, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final records = _filteredRecords;

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Service History',
          style: TextStyle(color: _navyColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: _backgroundColor,
        foregroundColor: _navyColor,
        elevation: 0,
      ),

      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Service Records',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: _navyColor,
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    'View your vehicle maintenance and service details.',
                    style: TextStyle(fontSize: 13, color: Colors.blueGrey),
                  ),

                  const SizedBox(height: 20),

                  // FILTER OPTIONS
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _filterButton('All'),
                        const SizedBox(width: 8),
                        _filterButton('Completed'),
                        const SizedBox(width: 8),
                        _filterButton('In Progress'),
                        const SizedBox(width: 8),
                        _filterButton('Cancelled'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: records.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                      itemCount: records.length,
                      itemBuilder: (context, index) {
                        return _buildServiceCard(records[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterButton(String filter) {
    final isSelected = _selectedFilter == filter;

    return ChoiceChip(
      label: Text(filter),
      selected: isSelected,
      selectedColor: _primaryBlue,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : _navyColor,
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
      side: BorderSide(
        color: isSelected ? _primaryBlue : const Color(0xFFD8DEE8),
      ),
      onSelected: (_) {
        setState(() {
          _selectedFilter = filter;
        });
      },
    );
  }
}
