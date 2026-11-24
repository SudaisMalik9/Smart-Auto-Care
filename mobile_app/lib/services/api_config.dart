class ApiConfig {
  // USB debugging: adb reverse tcp:8000 tcp:8000
  static const String baseUrl = 'http://127.0.0.1:8000/api/';

  static const String register = '${baseUrl}auth/register/';
  static const String login = '${baseUrl}auth/login/';
  static const String logout = '${baseUrl}auth/logout/';
  static const String profile = '${baseUrl}auth/profile/';

  static const String customerProfile = '${baseUrl}customers/profile/';
  static const String customerVehicles = '${baseUrl}customers/vehicles/';
}
