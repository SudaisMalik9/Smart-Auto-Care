
import 'api_config.dart';
import 'api_service.dart';

class WorkshopService {
  static String get _base => '${ApiConfig.baseUrl}workshops/';

  // Convert either a normal list or a paginated DRF response into a list.
  static List<Map<String, dynamic>> _asList(dynamic response) {
    dynamic data = response;

    if (data is Map && data['results'] is List) {
      data = data['results'];
    }

    if (data is! List) {
      throw Exception('The server returned an unexpected list response.');
    }

    return data
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  static Map<String, dynamic> _asMap(dynamic response) {
    if (response is! Map) {
      throw Exception('The server returned an unexpected response.');
    }

    return Map<String, dynamic>.from(response);
  }

  // ------------------------------------------------------------
  // WORKSHOPS
  // ------------------------------------------------------------

  static Future<List<Map<String, dynamic>>> getWorkshops() async {
    final response = await ApiService.get(_base);
    return _asList(response);
  }

  static Future<Map<String, dynamic>> createWorkshop({
    required String name,
    String description = '',
    String email = '',
    String phone = '',
  }) async {
    final response = await ApiService.post(_base, {
      'name': name,
      'description': description,
      'email': email,
      'phone': phone,
    });

    return _asMap(response);
  }

  static Future<Map<String, dynamic>> updateWorkshop(
    int workshopId,
    Map<String, dynamic> data,
  ) async {
    final response = await ApiService.patch(
      '$_base$workshopId/',
      data,
    );

    return _asMap(response);
  }

  static Future<void> deleteWorkshop(int workshopId) async {
    await ApiService.delete('$_base$workshopId/');
  }

  // ------------------------------------------------------------
  // BRANCHES
  // ------------------------------------------------------------

  static Future<List<Map<String, dynamic>>> getBranches(
    int workshopId,
  ) async {
    final response = await ApiService.get(
      '$_base$workshopId/branches/',
    );

    return _asList(response);
  }

  static Future<Map<String, dynamic>> createBranch(
    int workshopId, {
    required String name,
    required String address,
    required String city,
    String phone = '',
    String email = '',
    bool isPrimary = false,
  }) async {
    final response = await ApiService.post(
      '$_base$workshopId/branches/',
      {
        'name': name,
        'address': address,
        'city': city,
        'phone': phone,
        'email': email,
        'is_primary': isPrimary,
      },
    );

    return _asMap(response);
  }

  static Future<Map<String, dynamic>> updateBranch(
    int branchId,
    Map<String, dynamic> data,
  ) async {
    final response = await ApiService.patch(
      '${_base}branches/$branchId/',
      data,
    );

    return _asMap(response);
  }

  static Future<void> deleteBranch(int branchId) async {
    await ApiService.delete('${_base}branches/$branchId/');
  }

  // ------------------------------------------------------------
  // OPERATING HOURS
  // weekday: 0 = Monday, 6 = Sunday
  // ------------------------------------------------------------

  static Future<List<Map<String, dynamic>>> getOperatingHours(
    int branchId,
  ) async {
    final response = await ApiService.get(
      '${_base}branches/$branchId/operating-hours/',
    );

    return _asList(response);
  }

  static Future<Map<String, dynamic>> createOperatingHours(
    int branchId, {
    required int weekday,
    required bool isClosed,
    String? openingTime,
    String? closingTime,
  }) async {
    final response = await ApiService.post(
      '${_base}branches/$branchId/operating-hours/',
      {
        'weekday': weekday,
        'is_closed': isClosed,
        'opening_time': isClosed ? null : openingTime,
        'closing_time': isClosed ? null : closingTime,
      },
    );

    return _asMap(response);
  }

  static Future<Map<String, dynamic>> updateOperatingHours(
    int hoursId,
    Map<String, dynamic> data,
  ) async {
    final response = await ApiService.patch(
      '${_base}operating-hours/$hoursId/',
      data,
    );

    return _asMap(response);
  }

  static Future<void> deleteOperatingHours(int hoursId) async {
    await ApiService.delete('${_base}operating-hours/$hoursId/');
  }

  // ------------------------------------------------------------
  // DEPARTMENTS
  // ------------------------------------------------------------

  static Future<List<Map<String, dynamic>>> getDepartments(
    int branchId,
  ) async {
    final response = await ApiService.get(
      '${_base}branches/$branchId/departments/',
    );

    return _asList(response);
  }

  static Future<Map<String, dynamic>> createDepartment(
    int branchId, {
    required String name,
    String description = '',
  }) async {
    final response = await ApiService.post(
      '${_base}branches/$branchId/departments/',
      {
        'name': name,
        'description': description,
      },
    );

    return _asMap(response);
  }

  static Future<Map<String, dynamic>> updateDepartment(
    int departmentId,
    Map<String, dynamic> data,
  ) async {
    final response = await ApiService.patch(
      '${_base}departments/$departmentId/',
      data,
    );

    return _asMap(response);
  }

  static Future<void> deleteDepartment(int departmentId) async {
    await ApiService.delete('${_base}departments/$departmentId/');
  }

  // ------------------------------------------------------------
  // SERVICES
  // ------------------------------------------------------------

  static Future<List<Map<String, dynamic>>> getServices(
    int branchId,
  ) async {
    final response = await ApiService.get(
      '${_base}branches/$branchId/services/',
    );

    return _asList(response);
  }

  static Future<Map<String, dynamic>> createService(
    int branchId, {
    required String name,
    String description = '',
    required num price,
    required int estimatedDurationMinutes,
    int? departmentId,
  }) async {
    final response = await ApiService.post(
      '${_base}branches/$branchId/services/',
      {
        'name': name,
        'description': description,
        'price': price,
        'estimated_duration_minutes': estimatedDurationMinutes,
        'department': departmentId,
      },
    );

    return _asMap(response);
  }

  static Future<Map<String, dynamic>> updateService(
    int serviceId,
    Map<String, dynamic> data,
  ) async {
    final response = await ApiService.patch(
      '${_base}services/$serviceId/',
      data,
    );

    return _asMap(response);
  }

  static Future<void> deleteService(int serviceId) async {
    await ApiService.delete('${_base}services/$serviceId/');
  }
}
