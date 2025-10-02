import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../models/direct_booking_models.dart';
import '../utils/hotel_id_utils.dart';

class DirectBookingApiService {
  static const String baseUrl = '${ApiConstants.baseUrl}/api/v1/admin';

  // Get direct booking configuration
  static Future<DirectBookingConfig> getDirectBookingConfig({String? hotelId}) async {
    try {
      final id = hotelId ?? await HotelIdUtils.getHotelId();
      print('🔧 Fetching direct booking config for hotel: $id');
      
      final response = await http.get(
        Uri.parse('$baseUrl/hotels/$id/direct-booking/config'),
        headers: {
          'Content-Type': 'application/json',
          // Add authorization header if needed
        },
      );

      print('📡 Direct Booking Config API Response Status: ${response.statusCode}');
      print('📡 Direct Booking Config API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          print('✅ Direct booking config loaded successfully');
          return DirectBookingConfig.fromJson(data['data']);
        } else {
          throw Exception('Failed to load direct booking config: ${data['message'] ?? 'Unknown error'}');
        }
      } else if (response.statusCode == 404) {
        // Endpoint doesn't exist, return default configuration
        print('⚠️ Direct booking config endpoint not found, using default configuration');
        return DirectBookingConfig(
          versionNumber: '',
          developerId: '',
          deviceIp: '',
          secretApiKey: '',
          isConfigured: false,
        );
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error fetching direct booking config: $e');
      throw Exception('Failed to fetch direct booking config: $e');
    }
  }

  // Update direct booking configuration
  static Future<DirectBookingConfig> updateDirectBookingConfig({
    required DirectBookingUpdateRequest request,
    String? hotelId,
  }) async {
    try {
      final id = hotelId ?? await HotelIdUtils.getHotelId();
      print('🔧 Updating direct booking config for hotel: $id');
      
      final response = await http.put(
        Uri.parse('$baseUrl/hotels/$id/direct-booking/config'),
        headers: {
          'Content-Type': 'application/json',
          // Add authorization header if needed
        },
        body: json.encode(request.toJson()),
      );

      print('📡 Update Direct Booking Config API Response Status: ${response.statusCode}');
      print('📡 Update Direct Booking Config API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          print('✅ Direct booking config updated successfully');
          return DirectBookingConfig.fromJson(data['data']);
        } else {
          throw Exception('Failed to update direct booking config: ${data['message'] ?? 'Unknown error'}');
        }
      } else if (response.statusCode == 404) {
        // Endpoint doesn't exist, return the updated config locally
        print('⚠️ Direct booking config endpoint not found, returning local configuration');
        return DirectBookingConfig(
          versionNumber: request.versionNumber,
          developerId: request.developerId,
          deviceIp: request.deviceIp,
          secretApiKey: request.secretApiKey,
          isConfigured: true,
        );
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error updating direct booking config: $e');
      throw Exception('Failed to update direct booking config: $e');
    }
  }

  // Test direct booking configuration
  static Future<DirectBookingStatus> testDirectBookingConfig({
    required DirectBookingUpdateRequest request,
    String? hotelId,
  }) async {
    try {
      final id = hotelId ?? await HotelIdUtils.getHotelId();
      print('🧪 Testing direct booking config for hotel: $id');
      
      final response = await http.post(
        Uri.parse('$baseUrl/hotels/$id/direct-booking/test'),
        headers: {
          'Content-Type': 'application/json',
          // Add authorization header if needed
        },
        body: json.encode(request.toJson()),
      );

      print('📡 Test Direct Booking API Response Status: ${response.statusCode}');
      print('📡 Test Direct Booking API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          print('✅ Direct booking test completed successfully');
          return DirectBookingStatus.fromJson(data['data']);
        } else {
          throw Exception('Failed to test direct booking config: ${data['message'] ?? 'Unknown error'}');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error testing direct booking config: $e');
      throw Exception('Failed to test direct booking config: $e');
    }
  }

  // Get direct booking status
  static Future<DirectBookingStatus> getDirectBookingStatus({String? hotelId}) async {
    try {
      final id = hotelId ?? await HotelIdUtils.getHotelId();
      print('📊 Fetching direct booking status for hotel: $id');
      
      final response = await http.get(
        Uri.parse('$baseUrl/hotels/$id/direct-booking/status'),
        headers: {
          'Content-Type': 'application/json',
          // Add authorization header if needed
        },
      );

      print('📡 Direct Booking Status API Response Status: ${response.statusCode}');
      print('📡 Direct Booking Status API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          print('✅ Direct booking status loaded successfully');
          return DirectBookingStatus.fromJson(data['data']);
        } else {
          throw Exception('Failed to load direct booking status: ${data['message'] ?? 'Unknown error'}');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error fetching direct booking status: $e');
      throw Exception('Failed to fetch direct booking status: $e');
    }
  }

}
