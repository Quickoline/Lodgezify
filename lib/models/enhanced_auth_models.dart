import 'package:equatable/equatable.dart';

/// Enhanced authentication models that mirror the backend POS/PMS system
/// This provides a relationshipful authentication system

enum PlanType {
  pms('pms'),
  pos('pos'),
  bundle('bundle');

  const PlanType(this.value);
  final String value;

  static PlanType fromString(String value) {
    switch (value.toLowerCase()) {
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
}

enum LoginContext {
  pms,
  pos,
  direct, // For direct navigation without login screen
}

enum UserRole {
  systemAdmin('system_admin'),
  hotelAdmin('hotel_admin'),
  frontDesk('front_desk'),
  restaurantManager('restaurant_manager'),
  housekeeper('housekeeper');

  const UserRole(this.value);
  final String value;

  static UserRole fromString(String value) {
    switch (value.toLowerCase()) {
      case 'system_admin':
        return UserRole.systemAdmin;
      case 'hotel_admin':
        return UserRole.hotelAdmin;
      case 'front_desk':
        return UserRole.frontDesk;
      case 'restaurant_manager':
        return UserRole.restaurantManager;
      case 'housekeeper':
        return UserRole.housekeeper;
      default:
        return UserRole.hotelAdmin;
    }
  }
}

enum SubscriptionStatus {
  none('none'),
  active('active'),
  trial('trial'),
  pastDue('past_due'),
  canceled('canceled'),
  incomplete('incomplete'),
  incompleteExpired('incomplete_expired');

  const SubscriptionStatus(this.value);
  final String value;

  static SubscriptionStatus fromString(String value) {
    switch (value.toLowerCase()) {
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

/// Enhanced user model with plan access control
class EnhancedUser extends Equatable {
  final String id;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final String accessToken;
  final String? hotelId;
  final String? restaurantId;
  final bool hasHotel;
  final PlanType? planType;
  final SubscriptionStatus subscriptionStatus;
  final String? subscriptionId;
  final String? subscriptionDate;
  final String? subscriptionEndDate;
  final String? trialEndDate;
  final bool isTrialActive;
  final int daysLeftInTrial;
  final bool isFreeTrial;
  final bool hasUsedFreeTrial;
  final bool hasUsedTrial;
  final bool hasActivePlan;
  final EnhancedPlan? currentPlan;
  final bool isSystemAdmin;
  final bool canAccessPMS;
  final bool canAccessPOS;

  const EnhancedUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.accessToken,
    this.hotelId,
    this.restaurantId,
    required this.hasHotel,
    this.planType,
    required this.subscriptionStatus,
    this.subscriptionId,
    this.subscriptionDate,
    this.subscriptionEndDate,
    this.trialEndDate,
    required this.isTrialActive,
    required this.daysLeftInTrial,
    required this.isFreeTrial,
    required this.hasUsedFreeTrial,
    required this.hasUsedTrial,
    required this.hasActivePlan,
    this.currentPlan,
    required this.isSystemAdmin,
    required this.canAccessPMS,
    required this.canAccessPOS,
  });

  factory EnhancedUser.fromJson(Map<String, dynamic> json) {
    return EnhancedUser(
      id: json['_id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      role: UserRole.fromString(json['role'] as String),
      accessToken: json['accessToken'] as String,
      hotelId: json['hotelId'] as String?,
      restaurantId: json['restaurantId'] as String?,
      hasHotel: json['hasHotel'] as bool? ?? false,
      planType: json['planType'] != null 
          ? PlanType.fromString(json['planType'] as String)
          : null,
      subscriptionStatus: SubscriptionStatus.fromString(
          json['subscriptionStatus'] as String? ?? 'none'),
      subscriptionId: json['subscriptionId'] as String?,
      subscriptionDate: json['subscriptionDate'] as String?,
      subscriptionEndDate: json['subscriptionEndDate'] as String?,
      trialEndDate: json['trialEndDate'] as String?,
      isTrialActive: json['isTrialActive'] as bool? ?? false,
      daysLeftInTrial: json['daysLeftInTrial'] as int? ?? 0,
      isFreeTrial: json['isFreeTrial'] as bool? ?? false,
      hasUsedFreeTrial: json['hasUsedFreeTrial'] as bool? ?? false,
      hasUsedTrial: json['hasUsedTrial'] as bool? ?? false,
      hasActivePlan: json['hasActivePlan'] as bool? ?? false,
      currentPlan: json['currentPlan'] != null 
          ? EnhancedPlan.fromJson(json['currentPlan'])
          : null,
      isSystemAdmin: json['isSystemAdmin'] as bool? ?? false,
      canAccessPMS: json['canAccessPMS'] as bool? ?? false,
      canAccessPOS: json['canAccessPOS'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role.value,
      'accessToken': accessToken,
      'hotelId': hotelId,
      'restaurantId': restaurantId,
      'hasHotel': hasHotel,
      'planType': planType?.value,
      'subscriptionStatus': subscriptionStatus.value,
      'subscriptionId': subscriptionId,
      'subscriptionDate': subscriptionDate,
      'subscriptionEndDate': subscriptionEndDate,
      'trialEndDate': trialEndDate,
      'isTrialActive': isTrialActive,
      'daysLeftInTrial': daysLeftInTrial,
      'isFreeTrial': isFreeTrial,
      'hasUsedFreeTrial': hasUsedFreeTrial,
      'hasUsedTrial': hasUsedTrial,
      'hasActivePlan': hasActivePlan,
      'currentPlan': currentPlan?.toJson(),
      'isSystemAdmin': isSystemAdmin,
      'canAccessPMS': canAccessPMS,
      'canAccessPOS': canAccessPOS,
    };
  }

  /// Check if user can access a specific plan type
  bool canAccessPlanType(PlanType requestedPlanType) {
    // System admins can access everything
    if (isSystemAdmin) return true;
    
    // Bundle plan users can access both PMS and POS
    if (planType == PlanType.bundle) return true;
    
    // POS plan users can access POS
    if (planType == PlanType.pos && requestedPlanType == PlanType.pos) return true;
    
    // PMS plan users can only access PMS
    if (planType == PlanType.pms && requestedPlanType == PlanType.pms) return true;
    
    // Allow users with no plan, inactive subscription, or POS plan to access PMS
    if (requestedPlanType == PlanType.pms && 
        (!_isSubscriptionActive() || planType == null || planType == PlanType.pos)) {
      return true;
    }
    
    // For POS access, allow users who have had POS plans before
    if (requestedPlanType == PlanType.pos) {
      if (planType == PlanType.pos) return true;
      if (planType == null && (subscriptionStatus == SubscriptionStatus.trial || 
                               subscriptionStatus == SubscriptionStatus.active)) return true;
      if (planType != null && !_isSubscriptionActive()) return true;
      if (subscriptionStatus != SubscriptionStatus.none) return true;
    }
    
    return false;
  }

  /// Check if subscription is active
  bool _isSubscriptionActive() {
    return subscriptionStatus == SubscriptionStatus.active || 
           subscriptionStatus == SubscriptionStatus.trial;
  }

  /// Get user's primary system access
  SystemAccess get primarySystemAccess {
    if (canAccessPMS && canAccessPOS) return SystemAccess.both;
    if (canAccessPMS) return SystemAccess.pms;
    if (canAccessPOS) return SystemAccess.pos;
    return SystemAccess.none;
  }

  /// Get appropriate dashboard route based on role and plan access
  String get dashboardRoute {
    if (role == UserRole.systemAdmin) return '/admin-dashboard';
    if (role == UserRole.hotelAdmin) {
      if (canAccessPMS && canAccessPOS) return '/manager-dashboard';
      if (canAccessPMS) return '/pms-dashboard';
      if (canAccessPOS) return '/pos-dashboard';
    }
    if (role == UserRole.frontDesk) return '/front-desk';
    if (role == UserRole.restaurantManager) return '/restaurant-manager';
    if (role == UserRole.housekeeper) return '/housekeeper-dashboard';
    return '/dashboard';
  }

  @override
  List<Object?> get props => [
    id, name, email, phone, role, accessToken, hotelId, restaurantId,
    hasHotel, planType, subscriptionStatus, subscriptionId, subscriptionDate,
    subscriptionEndDate, trialEndDate, isTrialActive, daysLeftInTrial,
    isFreeTrial, hasUsedFreeTrial, hasUsedTrial, hasActivePlan, currentPlan,
    isSystemAdmin, canAccessPMS, canAccessPOS
  ];
}

/// Enhanced plan model
class EnhancedPlan extends Equatable {
  final String id;
  final PlanType type;
  final String tier;
  final String name;
  final String marketingName;
  final int? monthlyPriceCents;
  final String currency;
  final Map<String, dynamic> features;
  final String supportLevel;
  final String? subscriptionDate;
  final String? subscriptionEndDate;
  final String? subscriptionId;
  final String? transactionId;
  final String? trialEndDate;
  final bool isTrialActive;
  final int daysLeftInTrial;
  final bool isFreeTrial;
  final String? paymentMethod;
  final String status;

  const EnhancedPlan({
    required this.id,
    required this.type,
    required this.tier,
    required this.name,
    required this.marketingName,
    this.monthlyPriceCents,
    required this.currency,
    required this.features,
    required this.supportLevel,
    this.subscriptionDate,
    this.subscriptionEndDate,
    this.subscriptionId,
    this.transactionId,
    this.trialEndDate,
    required this.isTrialActive,
    required this.daysLeftInTrial,
    required this.isFreeTrial,
    this.paymentMethod,
    required this.status,
  });

  factory EnhancedPlan.fromJson(Map<String, dynamic> json) {
    return EnhancedPlan(
      id: json['_id'] as String,
      type: PlanType.fromString(json['type'] as String? ?? 'bundle'),
      tier: json['tier'] as String,
      name: json['name'] as String,
      marketingName: json['marketingName'] as String,
      monthlyPriceCents: json['monthlyPriceCents'] as int?,
      currency: json['currency'] as String? ?? 'USD',
      features: json['features'] as Map<String, dynamic>? ?? {},
      supportLevel: json['supportLevel'] as String? ?? 'email',
      subscriptionDate: json['subscriptionDate'] as String?,
      subscriptionEndDate: json['subscriptionEndDate'] as String?,
      subscriptionId: json['subscriptionId'] as String?,
      transactionId: json['transactionId'] as String?,
      trialEndDate: json['trialEndDate'] as String?,
      isTrialActive: json['isTrialActive'] as bool? ?? false,
      daysLeftInTrial: json['daysLeftInTrial'] as int? ?? 0,
      isFreeTrial: json['isFreeTrial'] as bool? ?? false,
      paymentMethod: json['paymentMethod'] as String?,
      status: json['status'] as String? ?? 'none',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'type': type.value,
      'tier': tier,
      'name': name,
      'marketingName': marketingName,
      'monthlyPriceCents': monthlyPriceCents,
      'currency': currency,
      'features': features,
      'supportLevel': supportLevel,
      'subscriptionDate': subscriptionDate,
      'subscriptionEndDate': subscriptionEndDate,
      'subscriptionId': subscriptionId,
      'transactionId': transactionId,
      'trialEndDate': trialEndDate,
      'isTrialActive': isTrialActive,
      'daysLeftInTrial': daysLeftInTrial,
      'isFreeTrial': isFreeTrial,
      'paymentMethod': paymentMethod,
      'status': status,
    };
  }

  @override
  List<Object?> get props => [
    id, type, tier, name, marketingName, monthlyPriceCents, currency,
    features, supportLevel, subscriptionDate, subscriptionEndDate,
    subscriptionId, transactionId, trialEndDate, isTrialActive,
    daysLeftInTrial, isFreeTrial, paymentMethod, status
  ];
}

/// System access enumeration
enum SystemAccess {
  none,
  pms,
  pos,
  both
}

/// Enhanced authentication state
class EnhancedAuthState extends Equatable {
  final bool isAuthenticated;
  final EnhancedUser? user;
  final bool isLoading;
  final String? error;
  final PlanType? requestedPlanType;
  final SystemAccess systemAccess;

  const EnhancedAuthState({
    this.isAuthenticated = false,
    this.user,
    this.isLoading = false,
    this.error,
    this.requestedPlanType,
    this.systemAccess = SystemAccess.none,
  });

  EnhancedAuthState copyWith({
    bool? isAuthenticated,
    EnhancedUser? user,
    bool? isLoading,
    String? error,
    PlanType? requestedPlanType,
    SystemAccess? systemAccess,
  }) {
    return EnhancedAuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      requestedPlanType: requestedPlanType ?? this.requestedPlanType,
      systemAccess: systemAccess ?? this.systemAccess,
    );
  }

  @override
  List<Object?> get props => [
    isAuthenticated, user, isLoading, error, requestedPlanType, systemAccess
  ];
}

/// Login request with plan type specification
class EnhancedLoginRequest extends Equatable {
  final String email;
  final String password;
  final String recaptchaToken;
  final PlanType planType;

  const EnhancedLoginRequest({
    required this.email,
    required this.password,
    required this.recaptchaToken,
    required this.planType,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'recaptchaToken': recaptchaToken,
      'planType': planType.value,
    };
  }

  @override
  List<Object> get props => [email, password, recaptchaToken, planType];
}

/// Enhanced login response
class EnhancedLoginResponse extends Equatable {
  final bool success;
  final String message;
  final EnhancedUser? data;

  const EnhancedLoginResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory EnhancedLoginResponse.fromJson(Map<String, dynamic> json) {
    return EnhancedLoginResponse(
      success: json['success'] as bool,
      message: json['message'] as String? ?? '',
      data: json['data'] != null ? EnhancedUser.fromJson(json['data']) : null,
    );
  }

  @override
  List<Object?> get props => [success, message, data];
}
