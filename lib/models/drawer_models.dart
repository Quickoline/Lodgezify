import 'package:flutter/material.dart';
import 'enhanced_auth_models.dart';

/// Model for drawer menu items
class DrawerItem {
  final String title;
  final IconData icon;
  final String route;
  final bool isEnabled;
  final LoginContext? requiredContext; // null means available for all contexts

  const DrawerItem({
    required this.title,
    required this.icon,
    required this.route,
    this.isEnabled = true,
    this.requiredContext,
  });
}

/// Drawer menu configuration based on login context
class DrawerMenuConfig {
  static const List<DrawerItem> pmsMenuItems = [
    DrawerItem(
      title: 'Overview',
      icon: Icons.dashboard,
      route: '/dashboard',
      requiredContext: LoginContext.pms,
    ),
    DrawerItem(
      title: 'Bookings',
      icon: Icons.event_available,
      route: '/bookings',
      requiredContext: LoginContext.pms,
    ),
    DrawerItem(
      title: 'Rooms',
      icon: Icons.hotel,
      route: '/rooms',
      requiredContext: LoginContext.pms,
    ),
    DrawerItem(
      title: 'Direct Booking',
      icon: Icons.add_circle,
      route: '/direct-booking',
      requiredContext: LoginContext.pms,
    ),
    DrawerItem(
      title: 'Reports',
      icon: Icons.analytics,
      route: '/reports',
      requiredContext: LoginContext.pms,
    ),
    DrawerItem(
      title: 'Support Tickets',
      icon: Icons.support_agent,
      route: '/support',
      requiredContext: LoginContext.pms,
    ),
    DrawerItem(
      title: 'Your Plan',
      icon: Icons.credit_card,
      route: '/plan',
      requiredContext: LoginContext.pms,
    ),
    DrawerItem(
      title: 'Subscription History',
      icon: Icons.history,
      route: '/subscription-history',
      requiredContext: LoginContext.pms,
    ),
    DrawerItem(
      title: 'Profile',
      icon: Icons.person,
      route: '/profile',
      requiredContext: LoginContext.pms,
    ),
  ];

  static const List<DrawerItem> posMenuItems = [
    DrawerItem(
      title: 'Overview',
      icon: Icons.dashboard,
      route: '/dashboard',
      requiredContext: LoginContext.pos,
    ),
    DrawerItem(
      title: 'Bookings',
      icon: Icons.event_available,
      route: '/bookings',
      requiredContext: LoginContext.pos,
    ),
    DrawerItem(
      title: 'Rooms',
      icon: Icons.hotel,
      route: '/rooms',
      requiredContext: LoginContext.pos,
    ),
    DrawerItem(
      title: 'Restaurant',
      icon: Icons.restaurant,
      route: '/restaurant',
      requiredContext: LoginContext.pos,
    ),
    DrawerItem(
      title: 'Payments',
      icon: Icons.payment,
      route: '/payments',
      requiredContext: LoginContext.pos,
    ),
    DrawerItem(
      title: 'Staff',
      icon: Icons.people,
      route: '/staff',
      requiredContext: LoginContext.pos,
    ),
    DrawerItem(
      title: 'Reports',
      icon: Icons.analytics,
      route: '/reports',
      requiredContext: LoginContext.pos,
    ),
    DrawerItem(
      title: 'Support Tickets',
      icon: Icons.support_agent,
      route: '/support',
      requiredContext: LoginContext.pos,
    ),
    DrawerItem(
      title: 'Your Plan',
      icon: Icons.credit_card,
      route: '/plan',
      requiredContext: LoginContext.pos,
    ),
    DrawerItem(
      title: 'Profile',
      icon: Icons.person,
      route: '/profile',
      requiredContext: LoginContext.pos,
    ),
  ];

  // Front Desk Staff Menu
  static const List<DrawerItem> frontDeskMenuItems = [
    DrawerItem(
      title: 'Dashboard',
      icon: Icons.dashboard,
      route: '/front-desk-dashboard',
    ),
    DrawerItem(
      title: 'Check In',
      icon: Icons.login,
      route: '/check-in',
    ),
    DrawerItem(
      title: 'Check Out',
      icon: Icons.logout,
      route: '/check-out',
    ),
    DrawerItem(
      title: 'Bookings',
      icon: Icons.event_available,
      route: '/bookings',
    ),
    DrawerItem(
      title: 'Guest History',
      icon: Icons.history,
      route: '/guest-history',
    ),
    DrawerItem(
      title: 'Room Management',
      icon: Icons.room,
      route: '/room-management',
    ),
    DrawerItem(
      title: 'Reports & Analytics',
      icon: Icons.analytics,
      route: '/reports',
    ),
    DrawerItem(
      title: 'Edit Profile',
      icon: Icons.person,
      route: '/edit-profile',
    ),
  ];

  // Housekeeper Menu
  static const List<DrawerItem> housekeeperMenuItems = [
    DrawerItem(
      title: 'Rooms',
      icon: Icons.room,
      route: '/housekeeper-dashboard',
    ),
  ];

  // Restaurant Manager Menu
  static const List<DrawerItem> restaurantMenuItems = [
    DrawerItem(
      title: 'Home',
      icon: Icons.home,
      route: '/restaurant-dashboard',
    ),
    DrawerItem(
      title: 'New Order',
      icon: Icons.add_circle,
      route: '/new-order',
    ),
    DrawerItem(
      title: 'Table',
      icon: Icons.table_restaurant,
      route: '/table-management',
    ),
    DrawerItem(
      title: 'Order History',
      icon: Icons.history,
      route: '/order-history',
    ),
  ];

  // Hotel Admin Menu (POS Hotel Admin)
  static const List<DrawerItem> hotelAdminMenuItems = [
    DrawerItem(
      title: 'Overview',
      icon: Icons.dashboard,
      route: '/dashboard',
    ),
    DrawerItem(
      title: 'Bookings',
      icon: Icons.event_available,
      route: '/bookings',
    ),
    DrawerItem(
      title: 'Rooms',
      icon: Icons.hotel,
      route: '/rooms',
    ),
    DrawerItem(
      title: 'Restaurant',
      icon: Icons.restaurant,
      route: '/restaurant',
    ),
    DrawerItem(
      title: 'Payments',
      icon: Icons.payment,
      route: '/payments',
    ),
    DrawerItem(
      title: 'Staff',
      icon: Icons.people,
      route: '/staff',
    ),
    DrawerItem(
      title: 'Reports',
      icon: Icons.analytics,
      route: '/reports',
    ),
    DrawerItem(
      title: 'Support Tickets',
      icon: Icons.support_agent,
      route: '/support',
    ),
    DrawerItem(
      title: 'Your Plan',
      icon: Icons.credit_card,
      route: '/plan',
    ),
    DrawerItem(
      title: 'Profile',
      icon: Icons.person,
      route: '/profile',
    ),
  ];

  static const List<DrawerItem> bundleMenuItems = [
    DrawerItem(
      title: 'Overview',
      icon: Icons.dashboard,
      route: '/dashboard',
    ),
    DrawerItem(
      title: 'Bookings',
      icon: Icons.event_available,
      route: '/bookings',
    ),
    DrawerItem(
      title: 'Rooms',
      icon: Icons.hotel,
      route: '/rooms',
    ),
    DrawerItem(
      title: 'Restaurant',
      icon: Icons.restaurant,
      route: '/restaurant',
    ),
    DrawerItem(
      title: 'Payments',
      icon: Icons.payment,
      route: '/payments',
    ),
    DrawerItem(
      title: 'Staff',
      icon: Icons.people,
      route: '/staff',
    ),
    DrawerItem(
      title: 'Reports',
      icon: Icons.analytics,
      route: '/reports',
    ),
    DrawerItem(
      title: 'Support Tickets',
      icon: Icons.support_agent,
      route: '/support',
    ),
    DrawerItem(
      title: 'Your Plan',
      icon: Icons.credit_card,
      route: '/plan',
    ),
    DrawerItem(
      title: 'Subscription History',
      icon: Icons.history,
      route: '/subscription-history',
    ),
    DrawerItem(
      title: 'Profile',
      icon: Icons.person,
      route: '/profile',
    ),
  ];

  /// Get menu items based on login context
  static List<DrawerItem> getMenuItems(LoginContext? loginContext) {
    switch (loginContext) {
      case LoginContext.pms:
        return pmsMenuItems;
      case LoginContext.pos:
        return posMenuItems;
      case LoginContext.direct:
      case null:
        return bundleMenuItems;
    }
  }
}
