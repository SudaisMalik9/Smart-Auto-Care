import 'package:material_ui/material_ui.dart';

const Color _primaryBlue = Color(0xFF1565C0);
const Color _backgroundColor = Color(0xFFF5F7FB);
const Color _navyColor = Color(0xFF102A43);

class MechanicJobDetailsScreen extends StatefulWidget {
  const MechanicJobDetailsScreen({
    super.key,
    this.jobId,
    this.customerName,
    this.vehicle,
    this.registrationNumber,
    this.serviceName,
    this.description,
    this.bookingDate,
    this.workshopName,
    this.status,
  });

  final String? jobId;
  final String? customerName;
  final String? vehicle;
  final String? registrationNumber;
  final String? serviceName;
  final String? description;
  final String? bookingDate;
  final String? workshopName;
  final String? status;

  @override
  State<MechanicJobDetailsScreen> createState() =>
      _MechanicJobDetailsScreenState();
}

class _MechanicJobDetailsScreenState extends State<MechanicJobDetailsScreen> {
  late String _status;

  late final String _jobId;
  late final String _customerName;
  late final String _vehicle;
  late final String _registrationNumber;
  late final String _serviceName;
  late final String _description;
  late final String _bookingDate;
  late final String _workshopName;

  bool _isUpdating = false;

  final List<String> _availableStatuses = [
    'Assigned',
    'In Progress',
    'Completed',
  ];

  @override
  void initState() {
    super.initState();

    // Demonstration data only.
    // Actual job details must come from the authenticated backend.
    _jobId = widget.jobId ?? 'JOB-DEMO-001';
    _customerName = widget.customerName ?? 'Sample Customer';
    _vehicle = widget.vehicle ?? 'Honda Civic';
    _registrationNumber = widget.registrationNumber ?? 'ABC-123';
    _serviceName = widget.serviceName ?? 'General Maintenance';
    _description =
        widget.description ??
        'Perform general vehicle inspection and maintenance.';
    _bookingDate = widget.bookingDate ?? '18 Nov 2026';
    _workshopName = widget.workshopName ?? 'City Auto Workshop';
    _status = widget.status ?? 'Assigned';
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Completed':
        return Colors.green;
      case 'In Progress':
        return Colors.orange;
      case 'Assigned':
        return Colors.blue;
      default:
        return Colors.blueGrey;
    }
  }

  Future<void> _updateStatus(String newStatus) async {
    if (!_availableStatuses.contains(newStatus) ||
        newStatus == _status ||
        _isUpdating) {
      return;
    }

    // No local status update is performed.
    // Connect this action to the authenticated Django API later.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Job status updates are not connected to the backend yet.',
        ),
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
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
                Icon(icon, color: _primaryBlue, size: 22),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    color: _navyColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            ...children,
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, color: Colors.blueGrey, size: 18),
            const SizedBox(width: 10),
          ],

          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: Colors.blueGrey),
            ),
          ),

          const SizedBox(width: 12),

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
      ),
    );
  }

  Widget _buildStatusCard() {
    final color = _statusColor(_status);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.assignment_turned_in_outlined, color: color, size: 30),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Current Job Status',
                  style: TextStyle(color: Colors.blueGrey, fontSize: 12),
                ),

                const SizedBox(height: 5),

                Text(
                  _status,
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusActions() {
    return _sectionCard(
      title: 'Job Actions',
      icon: Icons.engineering_outlined,
      children: [
        const Text(
          'Select an action to update the job status.',
          style: TextStyle(fontSize: 13, color: Colors.blueGrey),
        ),

        const SizedBox(height: 16),

        ..._availableStatuses.map((status) {
          final isCurrent = _status == status;

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: isCurrent || _isUpdating
                    ? null
                    : () => _updateStatus(status),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _primaryBlue,
                  side: BorderSide(
                    color: isCurrent ? Colors.green : _primaryBlue,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isCurrent) ...[
                      const Icon(
                        Icons.check_circle,
                        size: 18,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 8),
                    ],

                    Text(
                      isCurrent ? '$status (Current)' : status,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,

      appBar: AppBar(
        title: const Text(
          'Job Details',
          style: TextStyle(color: _navyColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: _backgroundColor,
        foregroundColor: _navyColor,
        elevation: 0,
      ),

      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            const Text(
              'Assigned Job',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: _navyColor,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'Job ID: $_jobId',
              style: const TextStyle(fontSize: 13, color: Colors.blueGrey),
            ),

            const SizedBox(height: 18),

            _buildStatusCard(),

            const SizedBox(height: 20),

            // CUSTOMER DETAILS
            _sectionCard(
              title: 'Customer Information',
              icon: Icons.person_outline,
              children: [_detailRow('Customer Name', _customerName)],
            ),

            // VEHICLE DETAILS
            _sectionCard(
              title: 'Vehicle Information',
              icon: Icons.directions_car_outlined,
              children: [
                _detailRow('Vehicle', _vehicle),
                _detailRow('Registration Number', _registrationNumber),
              ],
            ),

            // SERVICE DETAILS
            _sectionCard(
              title: 'Service Requirements',
              icon: Icons.build_outlined,
              children: [
                _detailRow('Service', _serviceName),

                const SizedBox(height: 4),

                const Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.blueGrey,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  _description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: _navyColor,
                    height: 1.5,
                  ),
                ),
              ],
            ),

            // BOOKING DETAILS
            _sectionCard(
              title: 'Booking Information',
              icon: Icons.calendar_month_outlined,
              children: [
                _detailRow('Booking Date', _bookingDate),
                _detailRow('Workshop', _workshopName),
              ],
            ),

            // JOB STATUS ACTIONS
            _buildStatusActions(),

            const SizedBox(height: 10),

            const Text(
              'Only jobs assigned to the authenticated mechanic '
              'should be accessible. Backend authorization is '
              'required before displaying real customer information '
              'or submitting job status updates.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.blueGrey,
                fontSize: 12,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
