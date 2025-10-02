import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../models/drawer_models.dart';
import '../models/enhanced_auth_models.dart';
import '../screens/bookings_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/direct_booking_screen.dart';
import '../screens/staff_screen.dart';
import '../screens/check_in_screen.dart';
import '../screens/check_out_screen.dart';
import '../screens/guest_history_screen.dart';
import '../screens/edit_profile_screen.dart';
import '../screens/front_desk_dashboard.dart';
import '../screens/housekeeper_dashboard.dart';
import '../screens/restaurant_dashboard.dart';
import '../constants/theme.dart';

class AppDrawer extends StatelessWidget {
  final EnhancedUser? user;
  final LoginContext? loginContext;
  final String? selectedRole; // Direct role selection from login screen

  const AppDrawer({
    super.key,
    this.user,
    this.loginContext,
    this.selectedRole,
  });

  @override
  Widget build(BuildContext context) {
    // Determine menu items based on login context and role selection
    final menuItems = _getMenuItemsBasedOnContext();
    final effectiveRole = _getEffectiveRole();

    return Drawer(
      child: Column(
        children: [
          _buildDrawerHeader(context, effectiveRole),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                return _buildDrawerItem(context, item);
              },
            ),
          ),
          _buildDrawerFooter(context),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context, PlanType effectiveRole) {
    String title;
    String subtitle;
    IconData icon;
    Color headerColor;

    switch (effectiveRole) {
      case PlanType.pms:
        title = 'PMS Dashboard';
        subtitle = 'Hotel Management System';
        icon = Icons.hotel;
        headerColor = AppColors.blue[600]!;
        break;
      case PlanType.pos:
        title = 'POS Dashboard';
        subtitle = 'Restaurant Management';
        icon = Icons.restaurant;
        headerColor = AppColors.orange[600]!;
        break;
      case PlanType.bundle:
        title = 'Dashboard';
        subtitle = 'Complete Business Solution';
        icon = Icons.dashboard;
        headerColor = AppColors.purple[600]!;
        break;
    }

    return Container(
      height: 200.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [headerColor, headerColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    color: AppColors.white,
                    size: 32.w,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 20.sp,
                            fontWeight: AppFontWeights.bold,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: AppColors.white.withOpacity(0.9),
                            fontSize: 14.sp,
                            fontWeight: AppFontWeights.medium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              if (user != null) ...[
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.person,
                        color: AppColors.white,
                        size: 16.w,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        user!.name,
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 12.sp,
                          fontWeight: AppFontWeights.medium,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, DrawerItem item) {
    return ListTile(
      leading: Icon(
        item.icon,
        color: AppColors.textPrimary,
        size: 20.w,
      ),
      title: Text(
        item.title,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14.sp,
          fontWeight: AppFontWeights.medium,
        ),
      ),
      enabled: item.isEnabled,
      onTap: () {
        if (item.isEnabled) {
          _navigateToRoute(context, item.route);
        }
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 4.h,
      ),
    );
  }

  Widget _buildDrawerFooter(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.gray[50],
        border: Border(
          top: BorderSide(
            color: AppColors.gray[200]!,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              Icons.settings,
              color: AppColors.textSecondary,
              size: 20.w,
            ),
            title: Text(
              'Settings',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14.sp,
                fontWeight: AppFontWeights.medium,
              ),
            ),
            onTap: () {
              Navigator.of(context).pop();
              _navigateToRoute(context, '/settings');
            },
            contentPadding: EdgeInsets.zero,
          ),
          ListTile(
            leading: Icon(
              Icons.logout,
              color: AppColors.red[600],
              size: 20.w,
            ),
            title: Text(
              'Logout',
              style: TextStyle(
                color: AppColors.red[600],
                fontSize: 14.sp,
                fontWeight: AppFontWeights.medium,
              ),
            ),
            onTap: () {
              Navigator.of(context).pop();
              _showLogoutDialog(context);
            },
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  void _navigateToRoute(BuildContext context, String route) {
    // Navigate to the appropriate screen
    switch (route) {
      case '/dashboard':
        // Already on dashboard, just close drawer
        Navigator.of(context).pop();
        break;
      case '/bookings':
        // Close drawer first, then navigate
        Navigator.of(context).pop();
        // Small delay to ensure drawer closes before navigation
        Future.delayed(const Duration(milliseconds: 100), () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => BookingsScreen(
                user: user,
                loginContext: loginContext,
                selectedRole: selectedRole,
              ),
            ),
          );
        });
        break;
      case '/profile':
        // Close drawer first, then navigate
        Navigator.of(context).pop();
        // Small delay to ensure drawer closes before navigation
        Future.delayed(const Duration(milliseconds: 100), () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ProfileScreen(
                user: user!,
                loginContext: loginContext,
                selectedRole: selectedRole,
              ),
            ),
          );
        });
        break;
      case '/staff':
        // Close drawer first, then navigate
        Navigator.of(context).pop();
        // Small delay to ensure drawer closes before navigation
        Future.delayed(const Duration(milliseconds: 100), () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => StaffScreen(
                user: user!,
                loginContext: loginContext,
                selectedRole: selectedRole,
              ),
            ),
          );
        });
        break;
      case '/direct-booking':
        // Close drawer first, then navigate
        Navigator.of(context).pop();
        // Small delay to ensure drawer closes before navigation
        Future.delayed(const Duration(milliseconds: 100), () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => DirectBookingScreen(
                user: user!,
                loginContext: loginContext,
                selectedRole: selectedRole,
              ),
            ),
          );
        });
        break;
      case '/check-in':
        Navigator.of(context).pop();
        Future.delayed(const Duration(milliseconds: 100), () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CheckInScreen(
                user: user!,
                loginContext: loginContext,
                selectedRole: selectedRole,
              ),
            ),
          );
        });
        break;
      case '/check-out':
        Navigator.of(context).pop();
        Future.delayed(const Duration(milliseconds: 100), () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CheckOutScreen(
                user: user!,
                loginContext: loginContext,
                selectedRole: selectedRole,
              ),
            ),
          );
        });
        break;
      case '/guest-history':
        Navigator.of(context).pop();
        Future.delayed(const Duration(milliseconds: 100), () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => GuestHistoryScreen(
                user: user!,
                loginContext: loginContext,
                selectedRole: selectedRole,
              ),
            ),
          );
        });
        break;
      case '/edit-profile':
        Navigator.of(context).pop();
        Future.delayed(const Duration(milliseconds: 100), () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => EditProfileScreen(
                user: user!,
                loginContext: loginContext,
                selectedRole: selectedRole,
              ),
            ),
          );
        });
        break;
      case '/front-desk-dashboard':
        Navigator.of(context).pop();
        Future.delayed(const Duration(milliseconds: 100), () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => FrontDeskDashboard(
                user: user!,
                loginContext: loginContext,
                selectedRole: selectedRole,
              ),
            ),
          );
        });
        break;
      case '/housekeeper-dashboard':
        Navigator.of(context).pop();
        Future.delayed(const Duration(milliseconds: 100), () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => HousekeeperDashboard(
                user: user!,
                loginContext: loginContext,
                selectedRole: selectedRole,
              ),
            ),
          );
        });
        break;
      case '/restaurant-dashboard':
        Navigator.of(context).pop();
        Future.delayed(const Duration(milliseconds: 100), () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => RestaurantDashboard(
                user: user!,
                loginContext: loginContext,
                selectedRole: selectedRole,
              ),
            ),
          );
        });
        break;
      case '/rooms':
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rooms management coming soon!')),
        );
        break;
      case '/restaurant':
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Restaurant management coming soon!')),
        );
        break;
      case '/payments':
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payments management coming soon!')),
        );
        break;
      case '/reports':
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reports & Analytics coming soon!')),
        );
        break;
      case '/support':
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Support Tickets coming soon!')),
        );
        break;
      case '/plan':
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Your Plan coming soon!')),
        );
        break;
      case '/subscription-history':
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Subscription History coming soon!')),
        );
        break;
      case '/new-order':
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('New Order coming soon!')),
        );
        break;
      case '/table-management':
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Table Management coming soon!')),
        );
        break;
      case '/order-history':
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order History coming soon!')),
        );
        break;
      case '/room-management':
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Room Management coming soon!')),
        );
        break;
      default:
        // For other routes, close drawer and show a snackbar for now
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Navigating to $route'),
            duration: const Duration(seconds: 1),
          ),
        );
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Logout',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: AppFontWeights.bold,
              color: AppColors.textPrimary,
            ),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14.sp,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to login screen
                context.go('/');
              },
              child: Text(
                'Logout',
                style: TextStyle(
                  color: AppColors.red[600],
                  fontSize: 14.sp,
                  fontWeight: AppFontWeights.medium,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  List<DrawerItem> _getMenuItemsBasedOnContext() {
    // For PMS login context, always show PMS menu
    if (loginContext == LoginContext.pms) {
      print('🔧 AppDrawer: Using PMS menu items');
      return DrawerMenuConfig.pmsMenuItems;
    }
    
    // For POS login context, determine based on selectedRole directly
    if (loginContext == LoginContext.pos) {
      // Use selectedRole directly instead of parsing from user data
      final staffRole = selectedRole?.toLowerCase();
      print('🔧 AppDrawer: POS context, selected role: $staffRole');
      
      switch (staffRole) {
        case 'hotel_admin':
          print('🔧 AppDrawer: Using Hotel Admin menu items');
          return DrawerMenuConfig.hotelAdminMenuItems;
        case 'front_desk':
          print('🔧 AppDrawer: Using Front Desk menu items');
          return DrawerMenuConfig.frontDeskMenuItems;
        case 'housekeeper':
          print('🔧 AppDrawer: Using Housekeeper menu items');
          return DrawerMenuConfig.housekeeperMenuItems;
        case 'restaurant_manager':
          print('🔧 AppDrawer: Using Restaurant Manager menu items');
          return DrawerMenuConfig.restaurantMenuItems;
        default:
          print('🔧 AppDrawer: Default to Hotel Admin menu items for role: $staffRole');
          // Default to hotel admin if no specific role
          return DrawerMenuConfig.hotelAdminMenuItems;
      }
    }
    
    // For direct login or fallback, use bundle menu
    print('🔧 AppDrawer: Using bundle menu items');
    return DrawerMenuConfig.bundleMenuItems;
  }

  PlanType _getEffectiveRole() {
    // If login context is provided, prioritize it over plan type
    if (loginContext != null) {
      switch (loginContext!) {
        case LoginContext.pms:
          return PlanType.pms;
        case LoginContext.pos:
          return PlanType.pos;
        case LoginContext.direct:
          return user?.planType ?? PlanType.bundle;
      }
    }
    
    // Fallback to user's plan type
    return user?.planType ?? PlanType.bundle;
  }
}
