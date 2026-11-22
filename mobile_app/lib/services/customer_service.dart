
import 'api_config.dart';
import 'api_service.dart';

class CustomerService {
  // Get the logged-in customer's profile.
  static Future<Map<String, dynamic>> getCustomerProfile() async {
    final response = await ApiService.get(
      ApiConfig.customerProfile,
    );

    return Map<String, dynamic>.from(response);
  }

  // Update editable customer profile information.
  static Future<Map<String, dynamic>> updateCustomerProfile({
    String? phone,
    String? address,
    String? city,
  }) async {
    final data = <String, dynamic>{};

    if (phone != null) data['phone'] = phone;
    if (address != null) data['address'] = address;
    if (city != null) data['city'] = city;

    final response = await ApiService.patch(
      ApiConfig.customerProfile,
      data,
    );

    return Map<String, dynamic>.from(response);
  }

  // Get vehicles belonging to the logged-in customer.
  static Future<List<Map<String, dynamic>>> getVehicles() async {
    final response = await ApiService.get(
      ApiConfig.customerVehicles,
    );

    if (response is! List) {
      throw Exception('Invalid vehicles response from server.');
    }

    return response
        .map((vehicle) => Map<String, dynamic>.from(vehicle))
        .toList();
  }

  // Add a vehicle to the logged-in customer's account.
  static Future<Map<String, dynamic>> addVehicle({
    required String make,
    required String model,
    required int year,
    required String registrationNumber,
    required String color,
    required String fuelType,
    required String transmission,
  }) async {
    final response = await ApiService.post(
      ApiConfig.customerVehicles,
      {
        'make': make,
        'model': model,
        'year': year,
        'registration_number': registrationNumber,
        'color': color,
        'fuel_type': fuelType.toUpperCase(),
        'transmission': transmission.toUpperCase(),
      },
    );

    return Map<String, dynamic>.from(response);
  }

  // Remove a vehicle from the logged-in customer's account.
  static Future<void> deleteVehicle(int vehicleId) async {
    await ApiService.delete(
      '${ApiConfig.customerVehicles}$vehicleId/delete/',
    );
  }
}
