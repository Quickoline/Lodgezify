import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../models/staff_models.dart';
import '../utils/hotel_id_utils.dart';
import 'auth_service.dart';

class StaffApiService {
  static const String baseUrl = '${ApiConstants.baseUrl}/api/v1/staff/hotel';
  static const String adminBaseUrl = '${ApiConstants.baseUrl}/api/v1/admin/hotels';

  // Get all staff members for a hotel
  static Future<StaffData> getStaffData() async {
    final hotelId = await HotelIdUtils.getHotelId();
    final token = await AuthService.getCurrentToken();
    print('🏨 Fetching staff data for hotel: $hotelId');
    print('🔑 Using token: ${token != null ? 'Found' : 'Not found'}');

    if (token == null) {
      throw Exception('Authentication token not found. Please login again.');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/$hotelId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('📡 Staff API Response Status: ${response.statusCode}');
    print('📡 Staff API Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return StaffData.fromJson(data);
    } else if (response.statusCode == 401) {
      throw Exception('Authentication failed. Please login again.');
    } else {
      throw Exception('Failed to load staff data: ${response.statusCode}');
    }
  }

  // Create a new staff member
  static Future<bool> createStaff(StaffCreateRequest request) async {
    final hotelId = await HotelIdUtils.getHotelId();
    final token = await AuthService.getCurrentToken();
    print('🏨 Creating staff for hotel: $hotelId');
    print('🔑 Using token: ${token != null ? 'Found' : 'Not found'}');

    if (token == null) {
      throw Exception('Authentication token not found. Please login again.');
    }

    // Debug: Print request data
    final requestData = request.toJson();
    requestData['hotelId'] = hotelId; // Add hotelId to request
    print('📤 Request Data: $requestData');
    print('📤 Request URL: $baseUrl/$hotelId/staff');

    // Use the correct admin endpoint for staff creation
    final endpoint = '$adminBaseUrl/$hotelId/roles';
    print('🔄 Using endpoint: $endpoint');
    
    final response = await http.post(
      Uri.parse(endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(requestData),
    );

    print('📡 Response Status: ${response.statusCode}');
    print('📡 Response Headers: ${response.headers}');
    print('📡 Response Body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('✅ Staff created successfully!');
      return true;
    } else if (response.statusCode == 401) {
      throw Exception('Authentication failed. Please login again.');
    } else {
      throw Exception('Failed to create staff: ${response.statusCode} - ${response.body}');
    }
  }

  // Update staff member status
  static Future<bool> updateStaffStatus(String staffId, String status) async {
    final hotelId = await HotelIdUtils.getHotelId();
    final token = await AuthService.getCurrentToken();
    print('🏨 Updating staff status for hotel: $hotelId, staff: $staffId');
    print('🔑 Using token: ${token != null ? 'Found' : 'Not found'}');

    if (token == null) {
      throw Exception('Authentication token not found. Please login again.');
    }

    final response = await http.put(
      Uri.parse('$baseUrl/$staffId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'status': status}),
    );

    print('📡 Update Staff Status API Response Status: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      return true;
    } else if (response.statusCode == 401) {
      throw Exception('Authentication failed. Please login again.');
    } else {
      throw Exception('Failed to update staff status: ${response.statusCode}');
    }
  }

  // Delete staff member
  static Future<bool> deleteStaff(String staffId) async {
    final hotelId = await HotelIdUtils.getHotelId();
    final token = await AuthService.getCurrentToken();
    print('🏨 Deleting staff for hotel: $hotelId, staff: $staffId');
    print('🔑 Using token: ${token != null ? 'Found' : 'Not found'}');

    if (token == null) {
      throw Exception('Authentication token not found. Please login again.');
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/$staffId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('📡 Delete Staff API Response Status: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      return true;
    } else if (response.statusCode == 401) {
      throw Exception('Authentication failed. Please login again.');
    } else {
      throw Exception('Failed to delete staff: ${response.statusCode}');
    }
  }

}
