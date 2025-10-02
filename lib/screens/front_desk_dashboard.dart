import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/theme.dart';
import '../models/enhanced_auth_models.dart';
import '../widgets/app_drawer.dart';
import 'check_in_screen.dart';
import 'check_out_screen.dart';
import 'guest_history_screen.dart';
import 'edit_profile_screen.dart';

class FrontDeskDashboard extends ConsumerStatefulWidget {
  final EnhancedUser user;
  final LoginContext? loginContext;
  final String? selectedRole;
  
  const FrontDeskDashboard({
    super.key,
    required this.user,
    this.loginContext,
    this.selectedRole,
  });

  @override
  ConsumerState<FrontDeskDashboard> createState() => _FrontDeskDashboardState();
}

class _FrontDeskDashboardState extends ConsumerState<FrontDeskDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    _screens.addAll([
      _buildDashboardHome(),
      CheckInScreen(user: widget.user, loginContext: widget.loginContext),
      CheckOutScreen(user: widget.user, loginContext: widget.loginContext),
      GuestHistoryScreen(user: widget.user, loginContext: widget.loginContext),
      EditProfileScreen(user: widget.user, loginContext: widget.loginContext),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        backgroundColor: AppColors.primary[600],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications feature coming soon!')),
              );
            },
          ),
        ],
      ),
      drawer: AppDrawer(
        user: widget.user,
        loginContext: widget.loginContext,
        selectedRole: widget.selectedRole,
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: AppColors.primary[600],
        unselectedItemColor: AppColors.textSecondary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.login),
            label: 'Check In',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout),
            label: 'Check Out',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Guest History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Front Desk Dashboard';
      case 1:
        return 'Guest Check-In';
      case 2:
        return 'Guest Check-Out';
      case 3:
        return 'Guest History';
      case 4:
        return 'Edit Profile';
      default:
        return 'Front Desk';
    }
  }

  Widget _buildDashboardHome() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section
          _buildWelcomeSection(),
          SizedBox(height: 20.h),
          
          // Quick Actions
          _buildQuickActionsSection(),
          SizedBox(height: 20.h),
          
          // Today's Summary
          _buildTodaysSummarySection(),
          SizedBox(height: 20.h),
          
          // Recent Activity
          _buildRecentActivitySection(),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Card(
      elevation: 2,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          gradient: LinearGradient(
            colors: [
              AppColors.primary[600]!.withOpacity(0.1),
              AppColors.primary[600]!.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.desk,
              size: 32.sp,
              color: AppColors.primary[600],
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome to Front Desk',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: AppFontWeights.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Manage guest check-ins, check-outs, and guest services efficiently.',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: AppFontWeights.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12.h),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
          childAspectRatio: 1.2,
          children: [
            _buildActionCard(
              'Check In',
              Icons.login,
              AppColors.green[600]!,
              () => setState(() => _selectedIndex = 1),
            ),
            _buildActionCard(
              'Check Out',
              Icons.logout,
              AppColors.orange[600]!,
              () => setState(() => _selectedIndex = 2),
            ),
            _buildActionCard(
              'Guest History',
              Icons.history,
              AppColors.blue[600]!,
              () => setState(() => _selectedIndex = 3),
            ),
            _buildActionCard(
              'Profile',
              Icons.person,
              AppColors.purple[600]!,
              () => setState(() => _selectedIndex = 4),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32.sp,
                color: color,
              ),
              SizedBox(height: 8.h),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: AppFontWeights.semibold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodaysSummarySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Today's Summary",
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: AppFontWeights.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Check-ins',
                '12',
                Icons.login,
                AppColors.green[600]!,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildSummaryCard(
                'Check-outs',
                '8',
                Icons.logout,
                AppColors.orange[600]!,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Active Guests',
                '45',
                Icons.people,
                AppColors.blue[600]!,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildSummaryCard(
                'Available Rooms',
                '23',
                Icons.room,
                AppColors.purple[600]!,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            Icon(
              icon,
              size: 24.sp,
              color: color,
            ),
            SizedBox(height: 8.h),
            Text(
              value,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: AppFontWeights.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: AppFontWeights.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12.h),
        Card(
          elevation: 2,
          child: Column(
            children: [
              _buildActivityItem(
                'John Doe checked in to Room 101',
                '2 minutes ago',
                Icons.login,
                AppColors.green[600]!,
              ),
              _buildActivityItem(
                'Jane Smith checked out from Room 205',
                '15 minutes ago',
                Icons.logout,
                AppColors.orange[600]!,
              ),
              _buildActivityItem(
                'Room service order for Room 301',
                '30 minutes ago',
                Icons.room_service,
                AppColors.blue[600]!,
              ),
              _buildActivityItem(
                'Guest complaint resolved',
                '1 hour ago',
                Icons.support_agent,
                AppColors.purple[600]!,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(String title, String time, IconData icon, Color color) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              icon,
              size: 20.sp,
              color: color,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: AppFontWeights.medium,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
