import 'package:material_ui/material_ui.dart';

const Color _primaryBlue = Color(0xFF1565C0);
const Color _backgroundColor = Color(0xFFF5F7FB);
const Color _navyColor = Color(0xFF102A43);

class ServiceTrackingScreen extends StatefulWidget {
  const ServiceTrackingScreen({
    super.key,
    this.bookingId,
    this.vehicle,
    this.workshop,
    this.service,
    this.mechanic,
    this.currentStatus,
  });

  final String? bookingId;
  final String? vehicle;
  final String? workshop;
  final String? service;
  final String? mechanic;
  final String? currentStatus;

  @override
  State<ServiceTrackingScreen> createState() => _ServiceTrackingScreenState();
}

class _ServiceTrackingScreenState extends State<ServiceTrackingScreen> {
  // Temporary demonstration values.
  // Replace with actual booking data from the Django API.
  late final String _bookingId;
  late final String _vehicle;
  late final String _workshop;
  late final String _service;
  late final String _mechanic;
  late final String _currentStatus;

  final List<String> _statuses = [
    'Booking Confirmed',
    'Vehicle Received',
    'Service In Progress',
    'Quality Inspection',
    'Service Completed',
  ];

  int get _currentStep {
    switch (_currentStatus) {
      case 'Booking Confirmed':
        return 0;
      case 'Vehicle Received':
        return 1;
      case 'Service In Progress':
        return 2;
      case 'Quality Inspection':
        return 3;
      case 'Service Completed':
        return 4;
      default:
        return -1;
    }
  }

  @override
  void initState() {
    super.initState();

    _bookingId = widget.bookingId ?? 'DEMO-001';
    _vehicle = widget.vehicle ?? 'Honda Civic';
    _workshop = widget.workshop ?? 'City Auto Workshop';
    _service = widget.service ?? 'General Maintenance';
    _mechanic = widget.mechanic ?? 'Not assigned';
    _currentStatus = widget.currentStatus ?? 'Service In Progress';
  }

  Color _statusColor() {
    if (_currentStatus == 'Service Completed') {
      return Colors.green;
    }

    if (_currentStatus == 'Cancelled') {
      return Colors.red;
    }

    return Colors.orange;
  }

  Widget _informationCard() {
    return Card(
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE5EAF1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Booking Information',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: _navyColor,
              ),
            ),

            const SizedBox(height: 18),

            _detailRow(
              Icons.confirmation_number_outlined,
              'Booking ID',
              _bookingId,
            ),

            _detailRow(Icons.directions_car_outlined, 'Vehicle', _vehicle),

            _detailRow(Icons.build_outlined, 'Service', _service),

            _detailRow(
              Icons.home_repair_service_outlined,
              'Workshop',
              _workshop,
            ),

            _detailRow(Icons.engineering_outlined, 'Mechanic', _mechanic),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Icon(icon, color: _primaryBlue, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.blueGrey, fontSize: 13),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: _navyColor,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    if (_currentStatus == 'Cancelled') {
      return _buildCancelledMessage();
    }

    if (_currentStep == -1) {
      return const Text(
        'The current booking status is not available.',
        style: TextStyle(color: Colors.blueGrey),
      );
    }

    return Column(
      children: List.generate(_statuses.length, (index) {
        final isCompleted = index < _currentStep;
        final isCurrent = index == _currentStep;
        final isLast = index == _statuses.length - 1;

        final color = isCompleted || isCurrent
            ? _primaryBlue
            : Colors.grey.shade300;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 34,
                child: Column(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCompleted || isCurrent
                            ? _primaryBlue
                            : Colors.grey.shade200,
                      ),
                      child: Icon(
                        isCompleted
                            ? Icons.check
                            : isCurrent
                            ? Icons.radio_button_checked
                            : Icons.circle_outlined,
                        color: isCompleted || isCurrent
                            ? Colors.white
                            : Colors.grey,
                        size: 17,
                      ),
                    ),

                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          color: isCompleted
                              ? _primaryBlue
                              : Colors.grey.shade300,
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 3, bottom: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _statuses[index],
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isCurrent
                              ? FontWeight.bold
                              : FontWeight.w600,
                          color: isCompleted || isCurrent
                              ? _navyColor
                              : Colors.blueGrey,
                        ),
                      ),

                      if (isCurrent) ...[
                        const SizedBox(height: 5),
                        Text(
                          'Current booking status',
                          style: TextStyle(
                            fontSize: 12,
                            color: color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],

                      if (isCompleted) ...[
                        const SizedBox(height: 5),
                        const Text(
                          'Completed',
                          style: TextStyle(fontSize: 12, color: Colors.green),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildCancelledMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.cancel_outlined, color: Colors.red),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'This booking has been cancelled.',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusHeader() {
    final color = _statusColor();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(
            _currentStatus == 'Service Completed'
                ? Icons.check_circle_outline
                : _currentStatus == 'Cancelled'
                ? Icons.cancel_outlined
                : Icons.pending_actions,
            color: color,
            size: 30,
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Current Status',
                  style: TextStyle(fontSize: 12, color: Colors.blueGrey),
                ),
                const SizedBox(height: 4),
                Text(
                  _currentStatus,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Service Tracking',
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
              'Track Your Service',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: _navyColor,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'Check the latest status of your vehicle service booking.',
              style: TextStyle(fontSize: 13, color: Colors.blueGrey),
            ),

            const SizedBox(height: 20),

            _statusHeader(),

            const SizedBox(height: 20),

            _informationCard(),

            const SizedBox(height: 22),

            Card(
              color: Colors.white,
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFFE5EAF1)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Service Progress',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: _navyColor,
                      ),
                    ),

                    const SizedBox(height: 22),

                    _buildTimeline(),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Note: Tracking information will be updated from the backend once API integration is completed.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.blueGrey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
