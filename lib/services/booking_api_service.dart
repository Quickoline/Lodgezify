import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/booking_models.dart';
import '../constants/api_constants.dart';
import '../utils/hotel_id_utils.dart';

class BookingApiService {
  static const String baseUrl = '${ApiConstants.baseUrl}/api/v1';

  /// Fetch booking summary data
  static Future<BookingsData> getBookingSummary({
    int page = 1,
    int limit = 100,
    String? hotelId,
  }) async {
    try {
      final actualHotelId = hotelId ?? await HotelIdUtils.getHotelId();
      if (actualHotelId == null) {
        throw Exception('Missing hotelId. Please sign in again or select a property.');
      }

      final url = '$baseUrl/booking?hotelId=$actualHotelId&page=$page&limit=$limit';
      print('📊 Fetching booking data from: $url');
      print('🏨 Using hotel ID: $actualHotelId');

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout - server not responding');
        },
      );

      print('📡 Booking API Response: ${response.statusCode}');
      print('📝 Booking API Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return BookingsData.fromJson(data);
      } else {
        throw Exception('Failed to load booking data: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Booking API Error: $e');
      throw Exception('Failed to fetch booking data: $e');
    }
  }

  /// Fetch hotel information
  static Future<HotelInfo> getHotelInfo({String? hotelId}) async {
    try {
      final actualHotelId = hotelId ?? await HotelIdUtils.getHotelId();
      if (actualHotelId == null) {
        throw Exception('Missing hotelId. Please sign in again or select a property.');
      }

      final url = '$baseUrl/admin/hotels/by-id/$actualHotelId';
      print('🏨 Fetching hotel info from: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout - server not responding');
        },
      );

      print('📡 Hotel Info API Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final hotelData = data['data'] ?? {};
          final addressParts = [
            hotelData['addressLine1'],
            hotelData['addressLine2'],
            hotelData['city'],
            hotelData['state'],
            hotelData['country']
          ].where((part) => part != null && part.toString().isNotEmpty).toList();
          
          return HotelInfo(
            name: hotelData['name']?.toString() ?? 'Hotel',
            address: addressParts.join(', ') ?? hotelData['address']?.toString() ?? '',
            contact: hotelData['phone']?.toString() ?? hotelData['email']?.toString() ?? '',
            logo: hotelData['logoUrl']?.toString() ?? hotelData['logo']?.toString() ?? '/logo.png',
          );
        }
      }
      
      throw Exception('Failed to load hotel info');
    } catch (e) {
      print('❌ Hotel Info API Error: $e');
      throw Exception('Failed to fetch hotel info: $e');
    }
  }

  /// Update booking status
  static Future<bool> updateBookingStatus({
    required String bookingId,
    required String status,
    String? hotelId,
  }) async {
    try {
      final actualHotelId = hotelId ?? await HotelIdUtils.getHotelId();
      if (actualHotelId == null) {
        throw Exception('Missing hotelId. Please sign in again or select a property.');
      }

      final url = '$baseUrl/booking/$bookingId';
      print('📝 Updating booking status: $url');

      final response = await http.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'status': status,
          'hotelId': actualHotelId,
        }),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout - server not responding');
        },
      );

      print('📡 Update Booking API Response: ${response.statusCode}');

      return response.statusCode == 200;
    } catch (e) {
      print('❌ Update Booking API Error: $e');
      return false;
    }
  }

}
