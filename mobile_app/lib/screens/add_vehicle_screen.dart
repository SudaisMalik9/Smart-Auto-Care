import 'package:material_ui/material_ui.dart';

import '../services/customer_service.dart';

const Color vehicleBlue = Color(0xFF1565C0);
const Color vehicleNavy = Color(0xFF102A43);
const Color vehicleBackground = Color(0xFFF5F7FB);

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();

  final _registrationController = TextEditingController();
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _mileageController = TextEditingController();
  final _colorController = TextEditingController();

  int? _selectedYear;
  String _vehicleType = 'Car';
  String _fuelType = 'Petrol';
  String _transmission = 'Automatic';

  bool _isSaving = false;

  final List<int> _years = List.generate(
    36,
    (index) => DateTime.now().year + 1 - index,
  );

  @override
  void dispose() {
    _registrationController.dispose();
    _makeController.dispose();
    _modelController.dispose();
    _mileageController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  Future<void> _saveVehicle() async {
    if (_isSaving) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedYear == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select the manufacturing year.')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Save the vehicle through the Django customer API.
      final vehicle = await CustomerService.addVehicle(
        make: _makeController.text.trim(),
        model: _modelController.text.trim(),
        year: _selectedYear!,
        registrationNumber: _registrationController.text.trim().toUpperCase(),
        color: _colorController.text.trim(),
        fuelType: _fuelType,
        transmission: _transmission,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vehicle saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Return the actual database record to the dashboard.
      Navigator.pop(context, vehicle);
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to save vehicle: $error'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: vehicleBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: vehicleNavy),
          onPressed: _isSaving ? null : () => Navigator.pop(context),
        ),
        title: const Text(
          'Add Vehicle',
          style: TextStyle(color: vehicleNavy, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // HEADER
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                        ),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: const Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Register Your Vehicle',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 23,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 9),
                                Text(
                                  'Add your vehicle details to manage '
                                  'maintenance and service bookings.',
                                  style: TextStyle(
                                    color: Colors.white,
                                    height: 1.5,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 10),
                          Icon(
                            Icons.directions_car_filled_rounded,
                            color: Colors.white,
                            size: 55,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    const Text(
                      'Vehicle Information',
                      style: TextStyle(
                        color: vehicleNavy,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),

                    _sectionCard(
                      child: Column(
                        children: [
                          _textField(
                            controller: _registrationController,
                            label: 'Registration Number',
                            hint: 'e.g. ABC-123',
                            icon: Icons.pin_outlined,
                            requiredField: true,
                            uppercase: true,
                          ),
                          const SizedBox(height: 18),
                          _textField(
                            controller: _makeController,
                            label: 'Vehicle Make / Brand',
                            hint: 'e.g. Toyota, Honda, Suzuki',
                            icon: Icons.directions_car_outlined,
                            requiredField: true,
                          ),
                          const SizedBox(height: 18),
                          _textField(
                            controller: _modelController,
                            label: 'Vehicle Model',
                            hint: 'e.g. Corolla, Civic, Alto',
                            icon: Icons.car_repair_rounded,
                            requiredField: true,
                          ),
                          const SizedBox(height: 18),

                          // YEAR
                          _dropdownField<int>(
                            label: 'Manufacturing Year',
                            icon: Icons.calendar_today_outlined,
                            value: _selectedYear,
                            items: _years,
                            itemLabel: (year) => year.toString(),
                            onChanged: (value) {
                              setState(() {
                                _selectedYear = value;
                              });
                            },
                          ),

                          const SizedBox(height: 18),

                          // VEHICLE TYPE
                          _dropdownField<String>(
                            label: 'Vehicle Type',
                            icon: Icons.commute_rounded,
                            value: _vehicleType,
                            items: const [
                              'Car',
                              'SUV',
                              'Pickup',
                              'Van',
                              'Motorcycle',
                              'Other',
                            ],
                            itemLabel: (value) => value,
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _vehicleType = value;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    const Text(
                      'Technical Details',
                      style: TextStyle(
                        color: vehicleNavy,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),

                    _sectionCard(
                      child: Column(
                        children: [
                          _dropdownField<String>(
                            label: 'Fuel Type',
                            icon: Icons.local_gas_station_outlined,
                            value: _fuelType,
                            items: const [
                              'Petrol',
                              'Diesel',
                              'Hybrid',
                              'Electric',
                              'CNG',
                              'LPG',
                              'Other',
                            ],
                            itemLabel: (value) => value,
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _fuelType = value;
                                });
                              }
                            },
                          ),

                          const SizedBox(height: 18),

                          _dropdownField<String>(
                            label: 'Transmission',
                            icon: Icons.settings_rounded,
                            value: _transmission,
                            items: const [
                              'Automatic',
                              'Manual',
                              'CVT',
                              'Other',
                            ],
                            itemLabel: (value) => value,
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _transmission = value;
                                });
                              }
                            },
                          ),

                          const SizedBox(height: 18),

                          _textField(
                            controller: _mileageController,
                            label: 'Current Mileage (km)',
                            hint: 'e.g. 45000',
                            icon: Icons.speed_rounded,
                            requiredField: true,
                            numberOnly: true,
                          ),

                          const SizedBox(height: 18),

                          _textField(
                            controller: _colorController,
                            label: 'Vehicle Color',
                            hint: 'e.g. White, Black, Silver',
                            icon: Icons.palette_outlined,
                            requiredField: true,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // SAVE BUTTON
                    SizedBox(
                      height: 55,
                      child: ElevatedButton.icon(
                        onPressed: _isSaving ? null : _saveVehicle,
                        icon: _isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.save_outlined),
                        label: Text(
                          _isSaving ? 'Saving Vehicle...' : 'Save Vehicle',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: vehicleBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    OutlinedButton(
                      onPressed: _isSaving
                          ? null
                          : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: vehicleBlue,
                        minimumSize: const Size.fromHeight(50),
                        side: const BorderSide(color: vehicleBlue),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'Vehicle details are saved to your customer account. '
                      'Vehicle type and mileage are not yet stored by '
                      'the current backend.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.blueGrey,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5EAF0)),
      ),
      child: child,
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool requiredField = false,
    bool uppercase = false,
    bool numberOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      textCapitalization: uppercase
          ? TextCapitalization.characters
          : TextCapitalization.words,
      keyboardType: numberOnly ? TextInputType.number : TextInputType.text,
      decoration: _decoration(label: label, hint: hint, icon: icon),
      validator: (value) {
        final text = value?.trim() ?? '';

        if (requiredField && text.isEmpty) {
          return '$label is required.';
        }

        if (numberOnly && text.isNotEmpty) {
          final mileage = int.tryParse(text);

          if (mileage == null || mileage < 0) {
            return 'Enter a valid mileage in kilometres.';
          }
        }

        return null;
      },
    );
  }

  Widget _dropdownField<T>({
    required String label,
    required IconData icon,
    required T? value,
    required List<T> items,
    required String Function(T) itemLabel,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: true,
      decoration: _decoration(label: label, hint: 'Select $label', icon: icon),
      items: items.map((item) {
        return DropdownMenuItem<T>(value: item, child: Text(itemLabel(item)));
      }).toList(),
      onChanged: onChanged,
      validator: (selected) {
        if (selected == null) {
          return 'Please select $label.';
        }
        return null;
      },
    );
  }

  InputDecoration _decoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: vehicleBlue),
      filled: true,
      fillColor: const Color(0xFFFAFBFD),
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 17),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: Color(0xFFD8E0E9)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: Color(0xFFD8E0E9)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: vehicleBlue, width: 1.5),
      ),
    );
  }
}
