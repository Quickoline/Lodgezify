import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/booking_models.dart';
import '../models/enhanced_auth_models.dart';
import '../services/booking_api_service.dart';
import '../constants/theme.dart';
import '../widgets/booking_list_view.dart';
import '../widgets/booking_calendar_view.dart';
import '../widgets/booking_stats_cards.dart';
import '../widgets/booking_filter_widget.dart';

class BookingsScreen extends ConsumerStatefulWidget {
  final EnhancedUser? user;
  final LoginContext? loginContext;
  final String? selectedRole;

  const BookingsScreen({
    super.key,
    this.user,
    this.loginContext,
    this.selectedRole,
  });

  @override
  ConsumerState<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends ConsumerState<BookingsScreen>
    with TickerProviderStateMixin {
  BookingsData? bookingsData;
  HotelInfo? hotelInfo;
  bool isLoading = true;
  String? errorMessage;
  ViewMode viewMode = ViewMode.list;
  BookingFilter filter = const BookingFilter();
  bool showExportDialog = false;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadBookingData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadBookingData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      print('🔄 Loading booking data...');
      
      // Load booking data and hotel info in parallel
      final results = await Future.wait([
        BookingApiService.getBookingSummary(),
        BookingApiService.getHotelInfo(),
      ]);

      final bookingsData = results[0] as BookingsData;
      final hotelInfo = results[1] as HotelInfo;

      print('✅ Booking data loaded successfully');
      print('📊 Total bookings: ${bookingsData.bookings.length}');
      print('🏨 Hotel: ${hotelInfo.name}');

      setState(() {
        this.bookingsData = bookingsData;
        this.hotelInfo = hotelInfo;
        isLoading = false;
      });
    } catch (e) {
      print('❌ Booking loading error: $e');
      setState(() {
        errorMessage = 'Failed to load booking data: $e';
        isLoading = false;
      });
    }
  }

  void _onBookingUpdate(BookingSummary updatedBooking) {
    if (bookingsData != null) {
      setState(() {
        bookingsData = BookingsData(
          bookings: bookingsData!.bookings
              .map((booking) => booking.id == updatedBooking.id ? updatedBooking : booking)
              .toList(),
          upcomingCheckIns: bookingsData!.upcomingCheckIns,
          upcomingCheckOuts: bookingsData!.upcomingCheckOuts,
          cancellations: bookingsData!.cancellations,
          noShows: bookingsData!.noShows,
        );
      });
    }
  }

  void _onFilterChanged(BookingFilter newFilter) {
    setState(() {
      filter = newFilter;
    });
  }

  List<BookingSummary> get filteredBookings {
    if (bookingsData == null) return [];
    
    return bookingsData!.bookings.where((booking) {
      // Date filtering
      if (filter.startDate != null || filter.endDate != null) {
        final checkInTime = DateTime.tryParse(booking.checkIn);
        if (checkInTime == null) return false;
        
        if (filter.startDate != null) {
          final startDate = DateTime.parse(filter.startDate!);
          if (checkInTime.isBefore(startDate)) return false;
        }
        
        if (filter.endDate != null) {
          final endDate = DateTime.parse(filter.endDate!).add(const Duration(days: 1));
          if (checkInTime.isAfter(endDate)) return false;
        }
      }
      
      // Status filtering
      if (filter.status != null && booking.status != filter.status) {
        return false;
      }
      
      // Source filtering
      if (filter.source != null && booking.source != filter.source) {
        return false;
      }
      
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Bookings & Reservations',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: AppFontWeights.bold,
            color: AppColors.white,
          ),
        ),
        backgroundColor: _getAppBarColor(),
        foregroundColor: AppColors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBookingData,
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => setState(() => showExportDialog = true),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48.h),
          child: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.white,
            labelColor: AppColors.white,
            unselectedLabelColor: AppColors.white.withOpacity(0.7),
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.list, size: 16.w),
                    SizedBox(width: 4.w),
                    Text('List', style: TextStyle(fontSize: 12.sp)),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_today, size: 16.w),
                    SizedBox(width: 4.w),
                    Text('Calendar', style: TextStyle(fontSize: 12.sp)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: isLoading
          ? _buildLoadingWidget()
          : errorMessage != null
              ? _buildErrorWidget()
              : _buildBookingContent(),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: _getAppBarColor(),
            strokeWidth: 3,
          ),
          SizedBox(height: 16.h),
          Text(
            'Loading bookings...',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64.w,
              color: AppColors.red[300],
            ),
            SizedBox(height: 16.h),
            Text(
              'Failed to load bookings',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: AppFontWeights.bold,
                color: AppColors.red[600],
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              errorMessage ?? 'Unknown error',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: _loadBookingData,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _getAppBarColor(),
                foregroundColor: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingContent() {
    if (bookingsData == null) return const SizedBox();

    return Column(
      children: [
        // Stats Cards
        BookingStatsCards(
          upcomingCheckIns: bookingsData!.upcomingCheckIns,
          upcomingCheckOuts: bookingsData!.upcomingCheckOuts,
          cancellations: bookingsData!.cancellations,
          noShows: bookingsData!.noShows,
        ),
        
        // Filter Widget
        BookingFilterWidget(
          filter: filter,
          onFilterChanged: _onFilterChanged,
        ),
        
        // Content based on tab
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              BookingListView(
                bookings: filteredBookings,
                onBookingUpdate: _onBookingUpdate,
                hotelInfo: hotelInfo ?? const HotelInfo(
                  name: 'Hotel',
                  address: '',
                  contact: '',
                  logo: '/logo.png',
                ),
              ),
              BookingCalendarView(
                bookings: filteredBookings,
                onBookingUpdate: _onBookingUpdate,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getAppBarColor() {
    final effectiveRole = _getEffectiveRole();
    switch (effectiveRole) {
      case PlanType.pms:
        return AppColors.blue[600]!;
      case PlanType.pos:
        return AppColors.orange[600]!;
      case PlanType.bundle:
        return AppColors.purple[600]!;
      default:
        return AppColors.blue[600]!;
    }
  }

  PlanType _getEffectiveRole() {
    // If login context is provided, prioritize it over plan type
    if (widget.loginContext != null) {
      switch (widget.loginContext!) {
        case LoginContext.pms:
          return PlanType.pms;
        case LoginContext.pos:
          return PlanType.pos;
        case LoginContext.direct:
          return widget.user?.planType ?? PlanType.bundle;
      }
    }
    
    // Fallback to user's plan type
    return widget.user?.planType ?? PlanType.bundle;
  }
}

enum ViewMode { list, calendar }
