import 'package:flutter/material.dart';

class BookServiceScreen extends StatefulWidget {
  final String workshopName;
  final String workshopLocation;

  const BookServiceScreen({
    super.key,
    this.workshopName = 'Selected Workshop',
    this.workshopLocation = 'Workshop Location',
  });

  @override
  State<BookServiceScreen> createState() => _BookServiceScreenState();
}

class _BookServiceScreenState extends State<BookServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _remarksController = TextEditingController();

  String? _selectedWorkshop;
  String? _selectedVehicle;
  String? _selectedService;
  String? _selectedTime;

  String _selectedWorkshopLocation = 'Workshop Location';

  DateTime? _selectedDate;

  final List<Map<String, String>> _workshops = [
    {'name': 'AutoCare Premium Workshop', 'location': 'Saddar, Rawalpindi'},
    {
      'name': 'Elite Motors Service Centre',
      'location': 'Commercial Market, Rawalpindi',
    },
    {'name': 'QuickFix Auto Workshop', 'location': 'Bahria Town, Rawalpindi'},
    {'name': 'City Motors Garage', 'location': 'Chaklala, Rawalpindi'},
  ];

  final List<String> _vehicles = [
    'Honda Civic - ABC-123',
    'Toyota Corolla - XYZ-456',
  ];

  final List<String> _services = [
    'General Service',
    'Oil Change',
    'Engine Repair',
    'Car Wash',
    'Electrical Repair',
    'Brake Service',
    'AC Service',
    'Tyre Service',
  ];

  final List<String> _timeSlots = [
    '09:00 AM',
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
    '02:00 PM',
    '03:00 PM',
    '04:00 PM',
  ];

  @override
  void initState() {
    super.initState();

    // Retain the workshop if this screen was opened from Find Workshop.
    if (widget.workshopName != 'Selected Workshop') {
      _selectedWorkshop = widget.workshopName;
      _selectedWorkshopLocation = widget.workshopLocation;
    }
  }

  @override
  void dispose() {
    _remarksController.dispose();
    super.dispose();
  }

  void _onWorkshopChanged(String? value) {
    if (value == null) return;

    final workshop = _workshops.firstWhere((item) => item['name'] == value);

    setState(() {
      _selectedWorkshop = value;
      _selectedWorkshopLocation = workshop['location']!;
    });
  }

  Future<void> _pickDate() async {
    final today = DateTime.now();

    final date = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: today,
      lastDate: today.add(const Duration(days: 90)),
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  void _confirmBooking() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an appointment date and time.'),
        ),
      );
      return;
    }

    final booking = {
      'workshop': _selectedWorkshop,
      'location': _selectedWorkshopLocation,
      'vehicle': _selectedVehicle,
      'service': _selectedService,
      'date':
          '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
      'time': _selectedTime,
      'remarks': _remarksController.text.trim(),
      'status': 'Pending',
    };

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.green,
                size: 65,
              ),
              const SizedBox(height: 15),
              const Text(
                'Booking Submitted!',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Your service booking request has been recorded in this demo.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              Text(
                '${booking['workshop']}\n'
                '${booking['service']}\n'
                '${booking['date']} at ${booking['time']}',
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.pop(context, booking);
              },
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text(
          'Book a Service',
          style: TextStyle(
            color: Color(0xFF102A43),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF102A43),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 650),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _workshopCard(),
                  const SizedBox(height: 25),

                  // Workshop Selection
                  _heading('Select Workshop'),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _selectedWorkshop,
                    isExpanded: true,
                    decoration: _decoration(
                      'Choose workshop',
                      Icons.store_rounded,
                    ),
                    items: _workshops.map((workshop) {
                      return DropdownMenuItem<String>(
                        value: workshop['name'],
                        child: Text(
                          workshop['name']!,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: _onWorkshopChanged,
                    validator: (value) =>
                        value == null ? 'Please select a workshop' : null,
                  ),

                  const SizedBox(height: 22),

                  _heading('Select Your Vehicle'),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _selectedVehicle,
                    isExpanded: true,
                    decoration: _decoration(
                      'Choose vehicle',
                      Icons.directions_car_rounded,
                    ),
                    items: _vehicles.map((vehicle) {
                      return DropdownMenuItem(
                        value: vehicle,
                        child: Text(vehicle),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedVehicle = value);
                    },
                    validator: (value) =>
                        value == null ? 'Please select a vehicle' : null,
                  ),

                  const SizedBox(height: 22),

                  _heading('Select Service'),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _selectedService,
                    isExpanded: true,
                    decoration: _decoration(
                      'Choose service',
                      Icons.build_rounded,
                    ),
                    items: _services.map((service) {
                      return DropdownMenuItem(
                        value: service,
                        child: Text(service),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedService = value);
                    },
                    validator: (value) =>
                        value == null ? 'Please select a service' : null,
                  ),

                  const SizedBox(height: 22),

                  _heading('Appointment Date'),
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: _pickDate,
                    child: InputDecorator(
                      decoration: _decoration(
                        'Select appointment date',
                        Icons.calendar_month_rounded,
                      ),
                      child: Text(
                        _selectedDate == null
                            ? 'Choose a date'
                            : '${_selectedDate!.day}/'
                                  '${_selectedDate!.month}/'
                                  '${_selectedDate!.year}',
                        style: TextStyle(
                          color: _selectedDate == null
                              ? Colors.grey
                              : const Color(0xFF102A43),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  _heading('Available Time Slots'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _timeSlots.map((time) {
                      final selected = _selectedTime == time;

                      return ChoiceChip(
                        label: Text(time),
                        selected: selected,
                        selectedColor: const Color(0xFFDCEBFF),
                        onSelected: (_) {
                          setState(() => _selectedTime = time);
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 22),

                  _heading('Additional Remarks'),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _remarksController,
                    maxLines: 4,
                    decoration: _decoration(
                      'Describe any issue or special request',
                      Icons.notes_rounded,
                    ),
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: _confirmBooking,
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text(
                        'Confirm Booking',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1565C0),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _workshopCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5EAF0)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 27,
            backgroundColor: Color(0xFFEAF3FF),
            child: Icon(
              Icons.car_repair_rounded,
              color: Color(0xFF1565C0),
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selected Workshop',
                  style: TextStyle(color: Colors.blueGrey, fontSize: 12),
                ),
                const SizedBox(height: 5),
                Text(
                  _selectedWorkshop ?? 'No workshop selected',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF102A43),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _selectedWorkshop == null
                      ? 'Please choose a workshop below'
                      : _selectedWorkshopLocation,
                  style: const TextStyle(color: Colors.blueGrey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _heading(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF102A43),
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  InputDecoration _decoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: const Color(0xFF1565C0)),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: Color(0xFFE5EAF0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: Color(0xFFE5EAF0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: Color(0xFF1565C0), width: 1.5),
      ),
    );
  }
}
