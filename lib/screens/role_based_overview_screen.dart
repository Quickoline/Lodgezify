import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/dashboard_models.dart';
import '../models/enhanced_auth_models.dart';
import '../services/dashboard_api_service.dart';
import '../widgets/metric_card.dart';
import '../widgets/chart_widget.dart';
import '../widgets/transaction_list.dart';
import '../widgets/timeline_widget.dart';
import '../widgets/app_drawer.dart';
import '../constants/theme.dart';
import 'front_desk_dashboard.dart';
import 'housekeeper_dashboard.dart';
import 'restaurant_dashboard.dart';

class RoleBasedOverviewScreen extends ConsumerStatefulWidget {
  final EnhancedUser? user;
  final LoginContext? loginContext;
  final String? selectedRole; // Direct role selection from login screen
  
  const RoleBasedOverviewScreen({
    super.key, 
    this.user, 
    this.loginContext,
    this.selectedRole,
  });

  @override
  ConsumerState<RoleBasedOverviewScreen> createState() => _RoleBasedOverviewScreenState();
}

class _RoleBasedOverviewScreenState extends ConsumerState<RoleBasedOverviewScreen> {
  DashboardData? dashboardData;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final user = widget.user ?? _createDemoUser();
      final hotelId = user.hotelId;

      print('🔄 Loading dashboard data for hotel: $hotelId');
      final data = await DashboardApiService.getDashboardData(
        hotelId: hotelId,
      );
      print('✅ Dashboard data loaded successfully');
      print('📊 Revenue: ${data.revenueToday?.value}');
      print('📊 Occupancy: ${data.occupancyRate?.value}');
      print('📊 Reservations: ${data.activeReservations?.value}');
      print('📊 Room Service: ${data.roomServiceOrders?.value}');

      setState(() {
        dashboardData = data;
        isLoading = false;
      });
    } catch (e) {
      print('❌ Dashboard loading error: $e');
      setState(() {
        errorMessage = 'Failed to load dashboard data: $e';
        isLoading = false;
      });
    }
  }

  Widget _buildRoleSpecificDashboard(EnhancedUser user, String staffRole) {
    print('🔧 RoleBasedOverview: Building role-specific dashboard for: $staffRole');
    switch (staffRole) {
      case 'hotel_admin':
        // Hotel admin gets the full dashboard with all features
        print('🔧 RoleBasedOverview: Routing to Hotel Admin dashboard');
        return _buildGeneralDashboard(user);
      case 'front_desk':
        print('🔧 RoleBasedOverview: Routing to Front Desk dashboard');
        return FrontDeskDashboard(
          user: user,
          loginContext: widget.loginContext,
          selectedRole: widget.selectedRole,
        );
      case 'housekeeper':
        print('🔧 RoleBasedOverview: Routing to Housekeeper dashboard');
        return HousekeeperDashboard(
          user: user,
          loginContext: widget.loginContext,
          selectedRole: widget.selectedRole,
        );
      case 'restaurant_manager':
        print('🔧 RoleBasedOverview: Routing to Restaurant Manager dashboard');
        return RestaurantDashboard(
          user: user,
          loginContext: widget.loginContext,
          selectedRole: widget.selectedRole,
        );
      default:
        // For other roles, show the general dashboard
        print('🔧 RoleBasedOverview: Default routing to general dashboard');
        return _buildGeneralDashboard(user);
    }
  }

  Widget _buildGeneralDashboard(EnhancedUser user) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(_getAppBarTitle(user)),
        backgroundColor: _getAppBarColor(user),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
          ),
        ],
      ),
      drawer: AppDrawer(
        user: user,
        loginContext: widget.loginContext,
        selectedRole: widget.selectedRole,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? _buildErrorWidget()
              : _buildDashboardContent(user),
    );
  }

  // Create a demo user for testing when no user is passed
  EnhancedUser _createDemoUser() {
    return const EnhancedUser(
      id: 'demo_user',
      email: 'demo@lodgezify.com',
      name: 'Demo User',
      phone: '+1234567890',
      role: UserRole.systemAdmin,
      accessToken: 'demo_token',
      hotelId: 'hotel_001',
      restaurantId: 'restaurant_001',
      hasHotel: true,
      planType: PlanType.bundle,
      subscriptionStatus: SubscriptionStatus.active,
      subscriptionId: 'sub_demo',
      subscriptionDate: '2024-01-01',
      subscriptionEndDate: '2024-12-31',
      trialEndDate: null,
      isTrialActive: false,
      daysLeftInTrial: 0,
      isFreeTrial: false,
      hasUsedFreeTrial: false,
      hasUsedTrial: false,
      hasActivePlan: true,
      currentPlan: null,
      isSystemAdmin: true,
      canAccessPMS: true,
      canAccessPOS: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use passed user or create a demo user for testing
    final user = widget.user ?? _createDemoUser();
    print('🔧 RoleBasedOverview: Build called with loginContext: ${widget.loginContext}');
    print('🔧 RoleBasedOverview: Selected role: ${widget.selectedRole}');
    print('🔧 RoleBasedOverview: User role: ${user.role}');

    // For POS login context, use selectedRole directly instead of parsing from user
    if (widget.loginContext == LoginContext.pos) {
      final staffRole = widget.selectedRole?.toLowerCase();
      print('🔧 RoleBasedOverview: POS context detected, selected role: $staffRole');
      if (staffRole != null && staffRole != 'systemadmin') {
        print('🔧 RoleBasedOverview: Routing to role-specific dashboard for: $staffRole');
        return _buildRoleSpecificDashboard(user, staffRole);
      } else {
        print('🔧 RoleBasedOverview: Selected role is null or systemadmin, using general dashboard');
      }
    }

    // For PMS login context or default, show general dashboard
    print('🔧 RoleBasedOverview: Using general dashboard');
    return _buildGeneralDashboard(user);
  }

  String _getAppBarTitle(EnhancedUser user) {
    final effectiveRole = _getEffectiveRole(user);
    switch (effectiveRole) {
      case PlanType.pms:
        return 'PMS Dashboard';
      case PlanType.pos:
        return 'POS Dashboard';
      case PlanType.bundle:
        return 'Dashboard Overview';
      default:
        return 'Dashboard';
    }
  }

  Color _getAppBarColor(EnhancedUser user) {
    final effectiveRole = _getEffectiveRole(user);
    switch (effectiveRole) {
      case PlanType.pms:
        return Colors.blue[600]!;
      case PlanType.pos:
        return Colors.orange[600]!;
      case PlanType.bundle:
        return Colors.purple[600]!;
      default:
        return Colors.blue[600]!;
    }
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load dashboard data',
            style: TextStyle(
              fontSize: 18,
              color: Colors.red[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage ?? 'Unknown error',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadDashboardData,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent(EnhancedUser user) {
    if (dashboardData == null) return const SizedBox();

    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome message based on user role
            _buildWelcomeSection(user),
            SizedBox(height: 20.h),

            // Key Metrics Row - show different metrics based on role
            _buildMetricsRow(user),
            SizedBox(height: 20.h),

            // Charts Section (only for hotel admin and system admin)
            if (_shouldShowCharts(user)) ...[
              _buildChartsSection(),
              SizedBox(height: 20.h),
            ],

            // Timeline Section (only for hotel admin and system admin)
            if (_shouldShowTimeline(user)) ...[
              _buildTimelineSection(),
              SizedBox(height: 20.h),
            ],

            // Recent Transactions (only for hotel admin and system admin)
            if (_shouldShowTransactions(user)) ...[
              _buildTransactionsSection(),
              SizedBox(height: 20.h),
            ],

            // Payment Methods & Revenue Sources (only for hotel admin and system admin)
            if (_shouldShowPaymentAnalysis(user)) ...[
              _buildPaymentAnalysisSection(),
              SizedBox(height: 20.h), // Add bottom padding for better scrolling
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(EnhancedUser user) {
    final effectiveRole = _getEffectiveRole(user);
    String welcomeText;
    String subtitle;
    IconData icon;

    switch (effectiveRole) {
      case PlanType.pms:
        welcomeText = 'PMS Dashboard';
        subtitle = 'Welcome back! Here\'s what\'s happening with your hotel today.';
        icon = Icons.hotel;
        break;
      case PlanType.pos:
        welcomeText = 'POS Dashboard';
        subtitle = 'Welcome back! Here\'s what\'s happening with your restaurant today.';
        icon = Icons.restaurant;
        break;
      case PlanType.bundle:
        welcomeText = 'Dashboard Overview';
        subtitle = 'Welcome back! Here\'s what\'s happening with your business today.';
        icon = Icons.dashboard;
        break;
      default:
        welcomeText = 'Dashboard';
        subtitle = 'Welcome back!';
        icon = Icons.dashboard;
    }

    return Card(
      elevation: 2,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          gradient: LinearGradient(
            colors: [
              _getAppBarColor(user).withOpacity(0.1),
              _getAppBarColor(user).withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 28.w,
              color: _getAppBarColor(user),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    welcomeText,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: AppFontWeights.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Determine effective role based on login context and plan type
  PlanType _getEffectiveRole(EnhancedUser user) {
    // If login context is provided, prioritize it over plan type
    if (widget.loginContext != null) {
      switch (widget.loginContext!) {
        case LoginContext.pms:
          return PlanType.pms;
        case LoginContext.pos:
          return PlanType.pos;
        case LoginContext.direct:
          return user.planType ?? PlanType.bundle;
      }
    }
    
    // Fallback to user's plan type
    return user.planType ?? PlanType.bundle;
  }

  // Plan-based access control methods (now using effective role)
  bool _shouldShowCharts(EnhancedUser user) {
    final effectiveRole = _getEffectiveRole(user);
    return effectiveRole == PlanType.pms || effectiveRole == PlanType.pos || effectiveRole == PlanType.bundle;
  }

  bool _shouldShowTimeline(EnhancedUser user) {
    final effectiveRole = _getEffectiveRole(user);
    return effectiveRole == PlanType.pms || effectiveRole == PlanType.pos || effectiveRole == PlanType.bundle;
  }

  bool _shouldShowTransactions(EnhancedUser user) {
    final effectiveRole = _getEffectiveRole(user);
    return effectiveRole == PlanType.pms || effectiveRole == PlanType.bundle;
  }

  bool _shouldShowPaymentAnalysis(EnhancedUser user) {
    final effectiveRole = _getEffectiveRole(user);
    return effectiveRole == PlanType.pms || effectiveRole == PlanType.bundle;
  }

  Widget _buildMetricsRow(EnhancedUser user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getMetricsTitle(user),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 12),
        _buildRoleSpecificMetrics(user),
      ],
    );
  }

  String _getMetricsTitle(EnhancedUser user) {
    final effectiveRole = _getEffectiveRole(user);
    switch (effectiveRole) {
      case PlanType.pms:
        return 'Hotel Metrics';
      case PlanType.pos:
        return 'Restaurant Metrics';
      case PlanType.bundle:
        return 'Key Metrics';
      default:
        return 'Key Metrics';
    }
  }

  Widget _buildRoleSpecificMetrics(EnhancedUser user) {
    final effectiveRole = _getEffectiveRole(user);
    switch (effectiveRole) {
      case PlanType.pms:
        return _buildPMSMetrics();
      case PlanType.pos:
        return _buildPOSMetrics();
      case PlanType.bundle:
        return _buildBothMetrics();
      default:
        return _buildDefaultMetrics();
    }
  }

  Widget _buildPMSMetrics() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: MetricCard(
                title: 'Revenue Today',
                value: dashboardData!.revenueToday.value,
                change: dashboardData!.revenueToday.change,
                trend: dashboardData!.revenueToday.trend,
                icon: Icons.attach_money,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MetricCard(
                title: 'Occupancy Rate',
                value: dashboardData!.occupancyRate.value,
                change: dashboardData!.occupancyRate.change,
                trend: dashboardData!.occupancyRate.trend,
                icon: Icons.hotel,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: MetricCard(
                title: 'Active Reservations',
                value: dashboardData!.activeReservations.value,
                change: dashboardData!.activeReservations.change,
                trend: dashboardData!.activeReservations.trend,
                icon: Icons.event_available,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MetricCard(
                title: 'Room Service Orders',
                value: dashboardData!.roomServiceOrders.value,
                change: dashboardData!.roomServiceOrders.change,
                trend: dashboardData!.roomServiceOrders.trend,
                icon: Icons.room_service,
                color: Colors.purple,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        MetricCard(
          title: 'Guest Satisfaction',
          value: '${dashboardData!.guestSatisfaction.avgRating.toStringAsFixed(1)}/5',
          change: '${dashboardData!.guestSatisfaction.count} reviews',
          trend: 'up',
          icon: Icons.star,
          color: Colors.amber,
          isFullWidth: true,
        ),
      ],
    );
  }

  Widget _buildPOSMetrics() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: MetricCard(
                title: 'Revenue Today',
                value: dashboardData!.revenueToday.value,
                change: dashboardData!.revenueToday.change,
                trend: dashboardData!.revenueToday.trend,
                icon: Icons.attach_money,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MetricCard(
                title: 'Occupancy Rate',
                value: dashboardData!.occupancyRate.value,
                change: dashboardData!.occupancyRate.change,
                trend: dashboardData!.occupancyRate.trend,
                icon: Icons.hotel,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: MetricCard(
                title: 'Active Reservations',
                value: dashboardData!.activeReservations.value,
                change: dashboardData!.activeReservations.change,
                trend: dashboardData!.activeReservations.trend,
                icon: Icons.event_available,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MetricCard(
                title: 'Room Service Orders',
                value: dashboardData!.roomServiceOrders.value,
                change: dashboardData!.roomServiceOrders.change,
                trend: dashboardData!.roomServiceOrders.trend,
                icon: Icons.room_service,
                color: Colors.purple,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        MetricCard(
          title: 'Guest Satisfaction',
          value: '${dashboardData!.guestSatisfaction.avgRating.toStringAsFixed(1)}/5',
          change: '${dashboardData!.guestSatisfaction.count} reviews',
          trend: 'up',
          icon: Icons.star,
          color: Colors.amber,
          isFullWidth: true,
        ),
      ],
    );
  }

  Widget _buildBothMetrics() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: MetricCard(
                title: 'Revenue Today',
                value: dashboardData!.revenueToday.value,
                change: dashboardData!.revenueToday.change,
                trend: dashboardData!.revenueToday.trend,
                icon: Icons.attach_money,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MetricCard(
                title: 'Occupancy Rate',
                value: dashboardData!.occupancyRate.value,
                change: dashboardData!.occupancyRate.change,
                trend: dashboardData!.occupancyRate.trend,
                icon: Icons.hotel,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: MetricCard(
                title: 'Active Reservations',
                value: dashboardData!.activeReservations.value,
                change: dashboardData!.activeReservations.change,
                trend: dashboardData!.activeReservations.trend,
                icon: Icons.event_available,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MetricCard(
                title: 'Room Service Orders',
                value: dashboardData!.roomServiceOrders.value,
                change: dashboardData!.roomServiceOrders.change,
                trend: dashboardData!.roomServiceOrders.trend,
                icon: Icons.room_service,
                color: Colors.purple,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        MetricCard(
          title: 'Guest Satisfaction',
          value: '${dashboardData!.guestSatisfaction.avgRating.toStringAsFixed(1)}/5',
          change: '${dashboardData!.guestSatisfaction.count} reviews',
          trend: 'up',
          icon: Icons.star,
          color: Colors.amber,
          isFullWidth: true,
        ),
      ],
    );
  }

  Widget _buildDefaultMetrics() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: MetricCard(
                title: 'Revenue Today',
                value: dashboardData!.revenueToday.value,
                change: dashboardData!.revenueToday.change,
                trend: dashboardData!.revenueToday.trend,
                icon: Icons.attach_money,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MetricCard(
                title: 'Occupancy Rate',
                value: dashboardData!.occupancyRate.value,
                change: dashboardData!.occupancyRate.change,
                trend: dashboardData!.occupancyRate.trend,
                icon: Icons.hotel,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: MetricCard(
                title: 'Active Reservations',
                value: dashboardData!.activeReservations.value,
                change: dashboardData!.activeReservations.change,
                trend: dashboardData!.activeReservations.trend,
                icon: Icons.event_available,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MetricCard(
                title: 'Room Service Orders',
                value: dashboardData!.roomServiceOrders.value,
                change: dashboardData!.roomServiceOrders.change,
                trend: dashboardData!.roomServiceOrders.trend,
                icon: Icons.room_service,
                color: Colors.purple,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        MetricCard(
          title: 'Guest Satisfaction',
          value: '${dashboardData!.guestSatisfaction.avgRating.toStringAsFixed(1)}/5',
          change: '${dashboardData!.guestSatisfaction.count} reviews',
          trend: 'up',
          icon: Icons.star,
          color: Colors.amber,
          isFullWidth: true,
        ),
      ],
    );
  }

  Widget _buildChartsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Trends & Analytics',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: AppFontWeights.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12.h),
        // Use Column for mobile-first responsive design
        Column(
          children: [
            ChartWidget(
              title: 'Revenue Trend',
              data: dashboardData!.revenueTrend,
              valueKey: 'revenue',
              color: AppColors.green[600]!,
            ),
            SizedBox(height: 12.h),
            ChartWidget(
              title: 'Occupancy Rate',
              data: dashboardData!.occupancyTrend,
              valueKey: 'occupancy',
              color: AppColors.blue[600]!,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimelineSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Today's Timeline",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 12),
        TimelineWidget(
          events: dashboardData!.timeline,
        ),
      ],
    );
  }

  Widget _buildTransactionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Transactions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 12),
        TransactionList(
          transactions: dashboardData!.recentTransactions,
        ),
      ],
    );
  }

  Widget _buildPaymentAnalysisSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Analysis',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 12),
        Column(
          children: [
            _buildPaymentMethodsCard(),
            const SizedBox(height: 12),
            _buildRevenueSourcesCard(),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentMethodsCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Methods',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            ...dashboardData!.paymentMethods.map((method) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    method.method.toUpperCase(),
                    style: const TextStyle(fontSize: 14),
                  ),
                  Text(
                    '${method.percentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.blue[600],
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueSourcesCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Revenue by Source',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            ...dashboardData!.revenueBySource.map((source) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      source.source.toUpperCase(),
                      style: const TextStyle(fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: Text(
                      '\$${source.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.green[600],
                      ),
                      textAlign: TextAlign.end,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}
