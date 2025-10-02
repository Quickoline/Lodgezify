import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../models/profile_models.dart';
import '../utils/hotel_id_utils.dart';

class ProfileApiService {
  static const String baseUrl = '${ApiConstants.baseUrl}/api/v1/admin';

  // Get hotel profile by ID
  static Future<HotelProfile> getHotelProfile({String? hotelId}) async {
    try {
      final id = hotelId ?? await HotelIdUtils.getHotelId();
      print('🏨 Fetching hotel profile for ID: $id');
      
      final response = await http.get(
        Uri.parse('$baseUrl/hotels/by-id/$id'),
        headers: {
          'Content-Type': 'application/json',
          // Add authorization header if needed
        },
      );

      print('📡 Profile API Response Status: ${response.statusCode}');
      print('📡 Profile API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          print('✅ Hotel profile loaded successfully');
          return HotelProfile.fromJson(data['data']);
        } else {
          throw Exception('Failed to load hotel profile: ${data['message'] ?? 'Unknown error'}');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error fetching hotel profile: $e');
      throw Exception('Failed to fetch hotel profile: $e');
    }
  }

  // Update hotel profile
  static Future<HotelProfile> updateHotelProfile({
    required ProfileUpdateRequest request,
    String? hotelId,
  }) async {
    try {
      final id = hotelId ?? await HotelIdUtils.getHotelId();
      print('🏨 Updating hotel profile for ID: $id');
      
      final response = await http.put(
        Uri.parse('$baseUrl/hotels/$id/profile'),
        headers: {
          'Content-Type': 'application/json',
          // Add authorization header if needed
        },
        body: json.encode(request.toJson()),
      );

      print('📡 Update Profile API Response Status: ${response.statusCode}');
      print('📡 Update Profile API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          print('✅ Hotel profile updated successfully');
          return HotelProfile.fromJson(data['data']);
        } else {
          throw Exception('Failed to update hotel profile: ${data['message'] ?? 'Unknown error'}');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error updating hotel profile: $e');
      throw Exception('Failed to update hotel profile: $e');
    }
  }

  // Upload hotel image
  static Future<String> uploadHotelImage({
    required File imageFile,
    String? hotelId,
  }) async {
    try {
      final id = hotelId ?? await HotelIdUtils.getHotelId();
      print('📸 Uploading image for hotel ID: $id');
      
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/room/upload-image'),
      );

      // Add authorization header if needed
      // request.headers['Authorization'] = 'Bearer $token';

      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('📡 Image Upload Response Status: ${response.statusCode}');
      print('📡 Image Upload Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data']?['imageUrl'] != null) {
          print('✅ Image uploaded successfully');
          return data['data']['imageUrl'];
        } else {
          throw Exception('Failed to upload image: ${data['message'] ?? 'Unknown error'}');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error uploading image: $e');
      throw Exception('Failed to upload image: $e');
    }
  }

}
