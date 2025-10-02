import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/enhanced_auth_models.dart';

/// Enhanced authentication provider with relationshipful authentication
/// Integrates with POS/PMS backend plan-based access control

class EnhancedAuthNotifier extends StateNotifier<EnhancedAuthState> {
  EnhancedAuthNotifier() : super(const EnhancedAuthState()) {
    _checkAuthStatus();
  }

  /// Check authentication status on app start
  Future<void> _checkAuthStatus() async {
    state = state.copyWith(isLoading: true);
    
    try {
      // Simplified auth check - always return false for now
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        user: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        user: null,
        error: e.toString(),
      );
    }
  }

  /// Login with plan type selection
  Future<void> login({
    required String email,
    required String password,
    required PlanType planType,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // Simplified login - create dummy user for now
      final user = EnhancedUser(
        id: '1',
        name: 'Test User',
        email: email,
        phone: '+1234567890',
        role: UserRole.hotelAdmin,
        accessToken: 'dummy_token',
        hotelId: 'hotel_123',
        hasHotel: true,
        planType: planType,
        subscriptionStatus: SubscriptionStatus.active,
        subscriptionId: 'sub_123',
        subscriptionDate: DateTime.now().toIso8601String(),
        subscriptionEndDate: DateTime.now().add(const Duration(days: 30)).toIso8601String(),
        trialEndDate: null,
        isTrialActive: false,
        daysLeftInTrial: 0,
        isFreeTrial: false,
        hasUsedFreeTrial: false,
        hasUsedTrial: false,
        isSystemAdmin: false,
        canAccessPMS: planType == PlanType.pms || planType == PlanType.bundle,
        canAccessPOS: planType == PlanType.pos || planType == PlanType.bundle,
        hasActivePlan: true,
        // isTrial: false, // Removed - parameter not defined
      );
      
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: user,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        user: null,
        error: e.toString(),
      );
    }
  }

  /// Logout user
  Future<void> logout() async {
    state = state.copyWith(
      isAuthenticated: false,
      user: null,
      error: null,
    );
  }

  /// Check if user can access PMS
  bool canAccessPMS() {
    final user = state.user;
    if (user == null) return false;
    
    return user.planType == PlanType.pms || 
           user.planType == PlanType.bundle ||
           user.role == UserRole.systemAdmin;
  }

  /// Check if user can access POS
  bool canAccessPOS() {
    final user = state.user;
    if (user == null) return false;
    
    return user.planType == PlanType.pos || 
           user.planType == PlanType.bundle ||
           user.role == UserRole.systemAdmin;
  }
}

/// Enhanced authentication state
class EnhancedAuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final EnhancedUser? user;
  final String? error;

  const EnhancedAuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.user,
    this.error,
  });

  EnhancedAuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    EnhancedUser? user,
    String? error,
  }) {
    return EnhancedAuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      error: error ?? this.error,
    );
  }
}

/// Enhanced authentication provider
final enhancedAuthProvider = StateNotifierProvider<EnhancedAuthNotifier, EnhancedAuthState>(
  (ref) => EnhancedAuthNotifier(),
);