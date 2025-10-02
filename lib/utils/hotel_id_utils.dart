import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

/// Hotel ID Utility - Exact mapping to Next.js getHotelId.ts
class HotelIdUtils {
  static Future<String?> getHotelId() async {
    // 1) Authenticated user data (highest priority)
    final authHotelId = await _getHotelIdFromAuth();
    if (authHotelId != null) return authHotelId;
    
    // 2) PMS auth system (new)
    final pmsHotelId = await _getHotelIdFromPmsAuth();
    if (pmsHotelId != null) return pmsHotelId;
    
    // 3) Legacy userData JSON from SharedPreferences
    final userDataHotelId = await _getHotelIdFromUserData();
    if (userDataHotelId != null) return userDataHotelId;
    
    // 4) Direct storage keys
    return await _getHotelIdFromStorage();
  }

  /// Get hotel ID from authenticated user data (highest priority)
  static Future<String?> _getHotelIdFromAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Check for authenticated user data
      final authUserData = prefs.getString('auth_user_data');
      if (authUserData != null) {
        final hotelId = _extractHotelIdFromJson(authUserData);
        if (hotelId != null) {
          if (kDebugMode) {
            print('🏨 Found hotel ID from authenticated user data: $hotelId');
          }
          return hotelId;
        }
      }
      
      // Check for current user session
      final currentUser = prefs.getString('current_user');
      if (currentUser != null) {
        final hotelId = _extractHotelIdFromJson(currentUser);
        if (hotelId != null) {
          if (kDebugMode) {
            print('🏨 Found hotel ID from current user session: $hotelId');
          }
          return hotelId;
        }
      }
      
      // Check for login response data
      final loginResponse = prefs.getString('login_response');
      if (loginResponse != null) {
        final hotelId = _extractHotelIdFromJson(loginResponse);
        if (hotelId != null) {
          if (kDebugMode) {
            print('🏨 Found hotel ID from login response: $hotelId');
          }
          return hotelId;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting hotelId from auth: $e');
      }
    }
    return null;
  }

  /// Get hotel ID from PMS auth system (new)
  static Future<String?> _getHotelIdFromPmsAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Check PMS hotel ID directly
      final pmsHotelId = prefs.getString('pms_hotel_id');
      if (pmsHotelId != null && pmsHotelId.isNotEmpty) {
        return pmsHotelId;
      }
      
      // Check PMS user data JSON
      final pmsUserData = prefs.getString('pms_user_data');
      if (pmsUserData != null) {
        final hotelId = _extractHotelIdFromJson(pmsUserData);
        if (hotelId != null) return hotelId;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting hotelId from PMS auth: $e');
      }
    }
    return null;
  }

  /// Get hotel ID from userData JSON (equivalent to localStorage.getItem('userData'))
  static Future<String?> _getHotelIdFromUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString('userData');
      
      if (userData != null) {
        // Parse JSON manually to avoid dependency on dart:convert
        final hotelId = _extractHotelIdFromJson(userData);
        if (hotelId != null) return hotelId;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing userData: $e');
      }
    }
    return null;
  }

  /// Extract hotel ID from JSON string
  static String? _extractHotelIdFromJson(String jsonString) {
    try {
      // Simple JSON parsing for hotelId extraction
      if (jsonString.contains('"hotelId"')) {
        final regex = RegExp(r'"hotelId"\s*:\s*"([^"]+)"');
        final match = regex.firstMatch(jsonString);
        if (match != null) return match.group(1);
      }
      
      if (jsonString.contains('"hotel"')) {
        // Check for nested hotel object
        final hotelRegex = RegExp(r'"hotel"\s*:\s*\{[^}]*"id"\s*:\s*"([^"]+)"');
        final hotelMatch = hotelRegex.firstMatch(jsonString);
        if (hotelMatch != null) return hotelMatch.group(1);
        
        final hotelIdRegex = RegExp(r'"hotel"\s*:\s*\{[^}]*"hotelId"\s*:\s*"([^"]+)"');
        final hotelIdMatch = hotelIdRegex.firstMatch(jsonString);
        if (hotelIdMatch != null) return hotelIdMatch.group(1);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error extracting hotelId from JSON: $e');
      }
    }
    return null;
  }

  /// Get hotel ID from dedicated storage keys (equivalent to localStorage.getItem('hotelId'))
  static Future<String?> _getHotelIdFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Check dedicated hotelId key
      final hotelId = prefs.getString('hotelId');
      if (hotelId != null && hotelId.isNotEmpty) {
        return hotelId;
      }
      
      // Check session storage equivalent
      final sessionHotelId = prefs.getString('sessionHotelId');
      if (sessionHotelId != null && sessionHotelId.isNotEmpty) {
        return sessionHotelId;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting hotelId from storage: $e');
      }
    }
    return null;
  }

  /// Set hotel ID in storage
  static Future<void> setHotelId(String hotelId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Set in both legacy and PMS auth systems
      await prefs.setString('hotelId', hotelId);
      await prefs.setString('pms_hotel_id', hotelId);
    } catch (e) {
      if (kDebugMode) {
        print('Error setting hotelId: $e');
      }
    }
  }

  /// Clear hotel ID from storage
  static Future<void> clearHotelId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Clear legacy storage
      await prefs.remove('hotelId');
      await prefs.remove('sessionHotelId');
      
      // Clear PMS auth storage
      await prefs.remove('pms_hotel_id');
      await prefs.remove('pms_user_data');
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing hotelId: $e');
      }
    }
  }

  /// Check if hotel ID is available
  static Future<bool> hasHotelId() async {
    final hotelId = await getHotelId();
    return hotelId != null && hotelId.isNotEmpty;
  }

  /// Get hotel ID with fallback message
  static Future<String> getHotelIdWithFallback() async {
    final hotelId = await getHotelId();
    if (hotelId == null || hotelId.isEmpty) {
      throw Exception('Missing hotelId. Please sign in again or select a property.');
    }
    return hotelId;
  }

  /// Get PMS hotel ID specifically (for debugging)
  static Future<String?> getPmsHotelId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('pms_hotel_id');
    } catch (e) {
      if (kDebugMode) {
        print('Error getting PMS hotelId: $e');
      }
      return null;
    }
  }

  /// Debug method to show all hotel ID sources
  static Future<Map<String, String?>> debugHotelIdSources() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return {
        'auth_user_data': prefs.getString('auth_user_data'),
        'current_user': prefs.getString('current_user'),
        'login_response': prefs.getString('login_response'),
        'pms_hotel_id': prefs.getString('pms_hotel_id'),
        'pms_user_data': prefs.getString('pms_user_data'),
        'hotelId': prefs.getString('hotelId'),
        'sessionHotelId': prefs.getString('sessionHotelId'),
        'userData': prefs.getString('userData'),
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error debugging hotelId sources: $e');
      }
      return {};
    }
  }
}
