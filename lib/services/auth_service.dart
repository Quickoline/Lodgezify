import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/enhanced_auth_models.dart';
import '../constants/api_constants.dart';

class AuthResponse {
  final bool success;
  final String message;
  final EnhancedUser? user;
  final String? token;

  const AuthResponse({
    required this.success,
    required this.message,
    this.user,
    this.token,
  });
}

class AuthService {
  static const String staffBaseUrl = '${ApiConstants.baseUrl}/api/v1/staff/hotel'; // Server staff API base URL
  static const String adminBaseUrl = '${ApiConstants.baseUrl}/api/v1.0/admin'; // Server admin API base URL
  

  // Login method using real API
  static Future<AuthResponse> login(String email, String password, String loginType, String recaptchaToken, {String? staffRole}) async {
    try {
      // Determine which endpoint to use based on login type and role
      final isPMS = loginType == 'pms';
      final isHotelAdmin = staffRole == 'hotel_admin';
      final baseUrl = (isPMS || isHotelAdmin) ? adminBaseUrl : staffBaseUrl;
      
      print('🔐 Attempting login to: $baseUrl/login');
      print('📧 Email: $email');
      print('🔑 Role: $staffRole');
      print('🏨 Login Type: $loginType');
      print('🏨 Is PMS: $isPMS');
      print('🏨 Is Hotel Admin: $isHotelAdmin');
      
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'email': email,
          'password': password,
        }),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout - server not responding');
        },
      );
      
      print('📡 Response Status: ${response.statusCode}');
      print('📄 Response Headers: ${response.headers}');
      print('📝 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        // Check if response is JSON
        if (response.headers['content-type']?.contains('application/json') != true) {
          return const AuthResponse(
            success: false,
            message: 'Server returned non-JSON response. Please check the API endpoint.',
            user: null,
            token: null,
          );
        }
        
        try {
          final data = json.decode(response.body);
          
          if (data['success'] == true) {
            final userData = data['data'];
            
            // Create user object from API response with safe defaults
          final userRole = _parseUserRole(userData['role'] ?? 'front_desk');
          print('🔧 AuthService: Parsed user role: $userRole');
          print('🔧 AuthService: Raw role from server: ${userData['role']}');
          
          final user = EnhancedUser(
            id: userData['_id'] ?? '',
            email: userData['email'] ?? '',
            name: userData['name'] ?? '',
            phone: userData['phone'] ?? '+1234567890',
            role: userRole,
            accessToken: userData['accessToken'] ?? '',
            hotelId: userData['hotelId'] ?? '',
            restaurantId: userData['restaurantId'] ?? '',
            hasHotel: userData['hasHotel'] ?? false,
            planType: _parsePlanType(userData['planType'] ?? 'pms'),
            subscriptionStatus: _parseSubscriptionStatus(userData['subscriptionStatus'] ?? 'none'),
            subscriptionId: userData['subscriptionId'] ?? '',
            subscriptionDate: userData['subscriptionDate'] ?? '',
            subscriptionEndDate: userData['subscriptionEndDate'] ?? '',
            trialEndDate: userData['trialEndDate'],
            isTrialActive: userData['isTrialActive'] ?? false,
            daysLeftInTrial: userData['daysLeftInTrial'] ?? 0,
            isFreeTrial: userData['isFreeTrial'] ?? false,
            hasUsedFreeTrial: userData['hasUsedFreeTrial'] ?? false,
            hasUsedTrial: userData['hasUsedTrial'] ?? false,
            hasActivePlan: userData['hasActivePlan'] ?? false,
            currentPlan: userData['currentPlan'] != null ? _parseCurrentPlan(userData['currentPlan']) : null,
            isSystemAdmin: userData['isSystemAdmin'] ?? false,
            canAccessPMS: userData['canAccessPMS'] ?? true, // Default to true for staff
            canAccessPOS: userData['canAccessPOS'] ?? true, // Default to true for staff
          );

          // Store authenticated user data for hotel ID retrieval
          await _storeAuthenticatedUserData(user, userData);

          return AuthResponse(
            success: true,
            message: 'Login successful',
            user: user,
            token: userData['accessToken'],
          );
        } else {
          return AuthResponse(
            success: false,
            message: data['message'] ?? 'Login failed',
            user: null,
            token: null,
          );
        }
        } catch (e) {
          return AuthResponse(
            success: false,
            message: 'Failed to parse server response: $e',
            user: null,
            token: null,
          );
        }
      } else {
        try {
          final errorData = json.decode(response.body);
          return AuthResponse(
            success: false,
            message: errorData['message'] ?? 'Login failed',
            user: null,
            token: null,
          );
        } catch (e) {
          return AuthResponse(
            success: false,
            message: 'Server error (${response.statusCode}): ${response.body}',
            user: null,
            token: null,
          );
        }
      }
    } catch (e) {
      print('❌ API Error: $e');
      return AuthResponse(
        success: false,
        message: 'Login failed: $e',
        user: null,
        token: null,
      );
    }
  }


  // Helper method to parse current plan from API response
  static EnhancedPlan? _parseCurrentPlan(Map<String, dynamic> planData) {
    try {
      return EnhancedPlan(
        id: planData['_id'] as String? ?? '',
        type: _parsePlanType(planData['planType'] as String? ?? 'bundle'),
        tier: planData['tier'] as String? ?? 'starter',
        name: planData['name'] as String? ?? 'Unknown Plan',
        marketingName: planData['marketingName'] as String? ?? planData['name'] as String? ?? 'Unknown Plan',
        monthlyPriceCents: planData['monthlyPriceCents'] as int?,
        currency: planData['currency'] as String? ?? 'USD',
        features: planData['features'] as Map<String, dynamic>? ?? {},
        supportLevel: planData['supportLevel'] as String? ?? 'standard',
        subscriptionDate: planData['subscriptionDate'] as String?,
        subscriptionEndDate: planData['subscriptionEndDate'] as String?,
        subscriptionId: planData['subscriptionId'] as String?,
        transactionId: planData['transactionId'] as String?,
        trialEndDate: planData['trialEndDate'] as String?,
        isTrialActive: planData['isTrialActive'] as bool? ?? false,
        daysLeftInTrial: planData['daysLeftInTrial'] as int? ?? 0,
        isFreeTrial: planData['isFreeTrial'] as bool? ?? false,
        paymentMethod: planData['paymentMethod'] as String?,
        status: planData['status'] as String? ?? 'active',
      );
    } catch (e) {
      print('❌ Error parsing current plan: $e');
      return null;
    }
  }

  // Store authenticated user data for hotel ID retrieval
  static Future<void> _storeAuthenticatedUserData(EnhancedUser user, Map<String, dynamic> userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Store the complete user data as JSON
      final userDataJson = json.encode(userData);
      await prefs.setString('auth_user_data', userDataJson);
      
      // Store current user session
      final currentUserJson = json.encode({
        'id': user.id,
        'email': user.email,
        'name': user.name,
        'hotelId': user.hotelId,
        'restaurantId': user.restaurantId,
        'planType': user.planType.toString(),
        'accessToken': user.accessToken,
      });
      await prefs.setString('current_user', currentUserJson);
      
      // Store login response for debugging
      final loginResponseJson = json.encode({
        'success': true,
        'data': userData,
        'timestamp': DateTime.now().toIso8601String(),
      });
      await prefs.setString('login_response', loginResponseJson);
      
      // Also store hotel ID directly for quick access
      if (user.hotelId != null) {
        await prefs.setString('hotelId', user.hotelId!);
        await prefs.setString('pms_hotel_id', user.hotelId!);
      }
      
      print('✅ Stored authenticated user data with hotel ID: ${user.hotelId}');
    } catch (e) {
      print('❌ Error storing authenticated user data: $e');
    }
  }

  // Logout method using real API
  static Future<bool> logout(String accessToken) async {
    try {
      final response = await http.post(
        Uri.parse('$staffBaseUrl/logout'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      // Clear stored user data on logout
      await _clearAuthenticatedUserData();
      
      return response.statusCode == 200;
    } catch (e) {
      // Even if API call fails, clear local data
      await _clearAuthenticatedUserData();
      return false;
    }
  }

  // Get current authentication token
  static Future<String?> getCurrentToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // First try to get from current user data
      final currentUserJson = prefs.getString('current_user');
      if (currentUserJson != null) {
        final currentUser = json.decode(currentUserJson);
        final token = currentUser['accessToken'] as String?;
        if (token != null && token.isNotEmpty) {
          print('🔑 Retrieved token from current user data');
          return token;
        }
      }
      
      // Fallback to auth user data
      final authUserDataJson = prefs.getString('auth_user_data');
      if (authUserDataJson != null) {
        final authUserData = json.decode(authUserDataJson);
        final token = authUserData['accessToken'] as String?;
        if (token != null && token.isNotEmpty) {
          print('🔑 Retrieved token from auth user data');
          return token;
        }
      }
      
      print('❌ No valid token found');
      return null;
    } catch (e) {
      print('❌ Error getting current token: $e');
      return null;
    }
  }

  // Clear authenticated user data on logout
  static Future<void> _clearAuthenticatedUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Clear all auth-related data
      await prefs.remove('auth_user_data');
      await prefs.remove('current_user');
      await prefs.remove('login_response');
      await prefs.remove('hotelId');
      await prefs.remove('pms_hotel_id');
      await prefs.remove('pms_user_data');
      
      print('✅ Cleared authenticated user data');
    } catch (e) {
      print('❌ Error clearing authenticated user data: $e');
    }
  }

  // Validate token method using real API
  static Future<AuthResponse> validateToken(String token) async {
    try {
      final response = await http.post(
        Uri.parse('$staffBaseUrl/refresh-token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true) {
          // Token is valid, return success
          return AuthResponse(
            success: true,
            message: 'Token valid',
            user: null, // User data would need to be fetched separately
            token: data['accessToken'],
          );
        }
      }

      return const AuthResponse(
        success: false,
        message: 'Invalid token',
        user: null,
        token: null,
      );
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'Token validation failed: $e',
        user: null,
        token: null,
      );
    }
  }

  // Helper methods
  static UserRole _parseUserRole(String role) {
    print('🔧 AuthService: Parsing role: $role');
    switch (role) {
      case 'system_admin':
        print('🔧 AuthService: Parsed as systemAdmin');
        return UserRole.systemAdmin;
      case 'hotel_admin':
        print('🔧 AuthService: Parsed as hotelAdmin');
        return UserRole.hotelAdmin;
      case 'front_desk':
        print('🔧 AuthService: Parsed as frontDesk');
        return UserRole.frontDesk;
      case 'restaurant_manager':
        print('🔧 AuthService: Parsed as restaurantManager');
        return UserRole.restaurantManager;
      case 'housekeeper':
        print('🔧 AuthService: Parsed as housekeeper');
        return UserRole.housekeeper;
      case 'spa_manager':
        print('🔧 AuthService: Parsed spa_manager as housekeeper');
        return UserRole.housekeeper; // Map spa manager to housekeeper
      default:
        print('🔧 AuthService: Default to frontDesk for role: $role');
        return UserRole.frontDesk;
    }
  }

  static PlanType _parsePlanType(String planType) {
    switch (planType) {
      case 'pms':
        return PlanType.pms;
      case 'pos':
        return PlanType.pos;
      case 'bundle':
        return PlanType.bundle;
      default:
        return PlanType.pms;
    }
  }

  static SubscriptionStatus _parseSubscriptionStatus(String status) {
    switch (status) {
      case 'none':
        return SubscriptionStatus.none;
      case 'active':
        return SubscriptionStatus.active;
      case 'trial':
        return SubscriptionStatus.trial;
      case 'past_due':
        return SubscriptionStatus.pastDue;
      case 'canceled':
        return SubscriptionStatus.canceled;
      case 'incomplete':
        return SubscriptionStatus.incomplete;
      case 'incomplete_expired':
        return SubscriptionStatus.incompleteExpired;
      default:
        return SubscriptionStatus.none;
    }
  }
}
