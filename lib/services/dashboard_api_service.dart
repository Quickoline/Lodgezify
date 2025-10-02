import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/dashboard_models.dart';
import '../constants/api_constants.dart';
import '../utils/hotel_id_utils.dart';
import 'auth_service.dart';

class DashboardApiService {
  static const String baseUrl = '${ApiConstants.baseUrl}/api/v1/analytics'; // Server analytics API base URL
  
  // Get comprehensive dashboard data
  static Future<DashboardData> getDashboardData({String? hotelId}) async {
    print('🔄 Starting dashboard data fetch...');
    
    // Fetch core data in parallel
    final coreResults = await Future.wait([
      getTodayRevenue(hotelId: hotelId),
      getOccupancyRate(hotelId: hotelId),
      getActiveReservations(hotelId: hotelId),
      getRoomServiceOrders(hotelId: hotelId),
      getGuestSatisfaction(hotelId: hotelId),
      getMonthlyRevenue(hotelId: hotelId),
      getMonthlyOccupancy(hotelId: hotelId),
      getTodaysTimeline(hotelId: hotelId),
    ]);
    
    // Try to fetch payment data separately (optional)
    Map<String, dynamic> paymentData = {};
    try {
      paymentData = await getPaymentOverview(hotelId: hotelId);
      print('✅ Payment data loaded successfully');
    } catch (e) {
      print('⚠️ Payment data unavailable: $e');
      print('📊 Continuing with core dashboard data only');
      // Provide empty payment data structure
      paymentData = {
        'transactions': [],
        'paymentMethods': [],
        'revenueBySource': []
      };
    }

    final revenueToday = coreResults[0] as DashboardMetrics;
    final occupancyRate = coreResults[1] as DashboardMetrics;
    final activeReservations = coreResults[2] as DashboardMetrics;
    final roomServiceOrders = coreResults[3] as DashboardMetrics;
    final guestSatisfaction = coreResults[4] as GuestSatisfaction;
    final revenueTrend = coreResults[5] as List<MonthlyData>;
    final occupancyTrend = coreResults[6] as List<MonthlyData>;
    final timeline = coreResults[7] as List<TimelineEvent>;

    // Parse payment data (if available)
    final transactions = (paymentData['transactions'] as List<dynamic>?)
        ?.map((item) => Transaction.fromJson(item))
        .toList() ?? [];
    
    final paymentMethods = (paymentData['paymentMethods'] as List<dynamic>?)
        ?.map((item) => PaymentMethod.fromJson(item))
        .toList() ?? [];
    
    final revenueBySource = (paymentData['revenueBySource'] as List<dynamic>?)
        ?.map((item) => RevenueSource.fromJson(item))
        .toList() ?? [];

    print('✅ Dashboard data assembled successfully');
    
    return DashboardData(
      revenueToday: revenueToday,
      occupancyRate: occupancyRate,
      activeReservations: activeReservations,
      roomServiceOrders: roomServiceOrders,
      guestSatisfaction: guestSatisfaction,
      revenueTrend: revenueTrend,
      occupancyTrend: occupancyTrend,
      timeline: timeline,
      recentTransactions: transactions,
      paymentMethods: paymentMethods,
      revenueBySource: revenueBySource,
    );
  }

  // Get today's revenue data
  static Future<DashboardMetrics> getTodayRevenue({String? hotelId}) async {
    try {
      // Get hotel ID from utility if not provided
      final actualHotelId = hotelId ?? await HotelIdUtils.getHotelId();
      final url = '$baseUrl/revenue/today${actualHotelId != null ? '?hotelId=$actualHotelId' : ''}';
      print('📊 Fetching revenue data from: $url');
      print('🏨 Using hotel ID: $actualHotelId');
      
      final token = await AuthService.getCurrentToken();
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout - server not responding');
        },
      );
      
      print('📡 Revenue API Response: ${response.statusCode}');
      print('📝 Revenue API Body: ${response.body}');
      
      if (response.statusCode == 200) {
        return DashboardMetrics.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load revenue data: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Revenue API Error: $e');
      throw Exception('Failed to fetch revenue data: $e');
    }
  }

  // Get today's occupancy rate
  static Future<DashboardMetrics> getOccupancyRate({String? hotelId}) async {
    try {
      // Get hotel ID from utility if not provided
      final actualHotelId = hotelId ?? await HotelIdUtils.getHotelId();
      final url = '$baseUrl/occupancy-rate/today${actualHotelId != null ? '?hotelId=$actualHotelId' : ''}';
      print('📊 Fetching occupancy data from: $url');
      print('🏨 Using hotel ID: $actualHotelId');
      
      final token = await AuthService.getCurrentToken();
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        return DashboardMetrics.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load occupancy data');
      }
    } catch (e) {
      throw Exception('Error fetching occupancy: $e');
    }
  }

  // Get active reservations
  static Future<DashboardMetrics> getActiveReservations({String? hotelId}) async {
    try {
      // Get hotel ID from utility if not provided
      final actualHotelId = hotelId ?? await HotelIdUtils.getHotelId();
      final url = '$baseUrl/active-reservations${actualHotelId != null ? '?hotelId=$actualHotelId' : ''}';
      print('📊 Fetching reservations data from: $url');
      print('🏨 Using hotel ID: $actualHotelId');
      
      final token = await AuthService.getCurrentToken();
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        return DashboardMetrics.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load reservations data');
      }
    } catch (e) {
      throw Exception('Error fetching reservations: $e');
    }
  }

  // Get room service orders
  static Future<DashboardMetrics> getRoomServiceOrders({String? hotelId}) async {
    try {
      // Get hotel ID from utility if not provided
      final actualHotelId = hotelId ?? await HotelIdUtils.getHotelId();
      final url = '$baseUrl/room-service-orders${actualHotelId != null ? '?hotelId=$actualHotelId' : ''}';
      print('📊 Fetching room service data from: $url');
      print('🏨 Using hotel ID: $actualHotelId');
      
      final token = await AuthService.getCurrentToken();
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        return DashboardMetrics.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load room service data');
      }
    } catch (e) {
      throw Exception('Error fetching room service: $e');
    }
  }

  // Get guest satisfaction
  static Future<GuestSatisfaction> getGuestSatisfaction({String? hotelId}) async {
    try {
      // Get hotel ID from utility if not provided
      final actualHotelId = hotelId ?? await HotelIdUtils.getHotelId();
      final url = '$baseUrl/guest-satisfaction${actualHotelId != null ? '?hotelId=$actualHotelId' : ''}';
      print('📊 Fetching guest satisfaction data from: $url');
      print('🏨 Using hotel ID: $actualHotelId');
      
      final token = await AuthService.getCurrentToken();
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        return GuestSatisfaction.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load satisfaction data');
      }
    } catch (e) {
      throw Exception('Error fetching satisfaction: $e');
    }
  }

  // Get monthly revenue trend
  static Future<List<MonthlyData>> getMonthlyRevenue({String? hotelId, int? year}) async {
    try {
      // Get hotel ID from utility if not provided
      final actualHotelId = hotelId ?? await HotelIdUtils.getHotelId();
      String url = '$baseUrl/revenue/monthly';
      List<String> params = [];
      if (actualHotelId != null) params.add('hotelId=$actualHotelId');
      if (year != null) params.add('year=$year');
      if (params.isNotEmpty) url += '?${params.join('&')}';
      
      print('📊 Fetching monthly revenue data from: $url');
      print('🏨 Using hotel ID: $actualHotelId');
      
      final token = await AuthService.getCurrentToken();
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((item) => MonthlyData.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load revenue trend');
      }
    } catch (e) {
      throw Exception('Error fetching revenue trend: $e');
    }
  }

  // Get monthly occupancy trend
  static Future<List<MonthlyData>> getMonthlyOccupancy({String? hotelId, int? year}) async {
    try {
      // Get hotel ID from utility if not provided
      final actualHotelId = hotelId ?? await HotelIdUtils.getHotelId();
      String url = '$baseUrl/occupancy/monthly';
      List<String> params = [];
      if (actualHotelId != null) params.add('hotelId=$actualHotelId');
      if (year != null) params.add('year=$year');
      if (params.isNotEmpty) url += '?${params.join('&')}';
      
      print('📊 Fetching monthly occupancy data from: $url');
      print('🏨 Using hotel ID: $actualHotelId');
      
      final token = await AuthService.getCurrentToken();
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((item) => MonthlyData.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load occupancy trend');
      }
    } catch (e) {
      throw Exception('Error fetching occupancy trend: $e');
    }
  }

  // Get today's timeline
  static Future<List<TimelineEvent>> getTodaysTimeline({String? hotelId}) async {
    try {
      // Get hotel ID from utility if not provided
      final actualHotelId = hotelId ?? await HotelIdUtils.getHotelId();
      final url = '$baseUrl/timeline/today${actualHotelId != null ? '?hotelId=$actualHotelId' : ''}';
      print('📊 Fetching timeline data from: $url');
      print('🏨 Using hotel ID: $actualHotelId');
      
      final token = await AuthService.getCurrentToken();
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((item) => TimelineEvent.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load timeline data');
      }
    } catch (e) {
      throw Exception('Error fetching timeline: $e');
    }
  }

  // Get payment overview data
  static Future<Map<String, dynamic>> getPaymentOverview({String? hotelId}) async {
    try {
      // Get hotel ID from utility if not provided
      final actualHotelId = hotelId ?? await HotelIdUtils.getHotelId();
      final token = await AuthService.getCurrentToken();
      // Use the correct payment overview endpoint from the server routes
      final url = '${ApiConstants.baseUrl}/api/v1/overview/payments/dashboard/payments-data${actualHotelId != null ? '?hotelId=$actualHotelId' : ''}';
      print('📊 Fetching payment overview data from: $url');
      print('🏨 Using hotel ID: $actualHotelId');
      print('🔑 Using token: ${token != null ? 'Found' : 'Not found'}');
      
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Payment API request timeout');
        },
      );
      
      print('📡 Payment API Response Status: ${response.statusCode}');
      print('📡 Payment API Response Body: ${response.body}');
      print('📡 Payment API Response Headers: ${response.headers}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Payment data parsed successfully');
        return data;
      } else if (response.statusCode == 404) {
        throw Exception('Payment overview endpoint not found (404)');
      } else if (response.statusCode == 500) {
        throw Exception('Payment service internal error (500)');
      } else {
        throw Exception('Payment API failed with status ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Payment API Error: $e');
      throw Exception('Error fetching payment data: $e');
    }
  }

}
