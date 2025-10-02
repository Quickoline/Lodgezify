# Access Control Implementation Guide

## Overview

This document describes the comprehensive access control system implemented in the Flutter app, covering sidebar items, dashboard screens, and endpoint access based on user roles and plan types.

## Architecture

### 🏗️ **Three-Layer Access Control**

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   FRONTEND      │    │   MIDDLEWARE    │    │   BACKEND       │
│   (UI Layer)    │    │   (Logic Layer) │    │   (API Layer)   │
│                 │    │                 │    │                 │
│ • Sidebar Items │    │ • Route Guards  │    │ • Endpoint      │
│ • Screen Access │    │ • Feature Check │    │   Protection    │
│ • User Interface│    │ • Plan Validation│    │ • JWT Validation│
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 1. Access Control Utilities

### 📁 **File: `lib/utils/access_control.dart`**

**Purpose**: Core access control logic for role-based and plan-based permissions.

**Key Features**:
- **Feature Access Control**: Check if user can access specific features
- **Plan-Based Access**: Validate plan types (PMS, POS, Bundle)
- **Role-Based Access**: Validate user roles (Admin, Staff, etc.)
- **Sidebar Generation**: Generate accessible sidebar items
- **Route Protection**: Validate route access

**Usage**:
```dart
// Check if user can access a feature
bool canAccess = AccessControl.canAccessFeature(user, 'pms_dashboard');

// Get accessible sidebar items
List<SidebarItem> items = AccessControl.getSidebarItems(user);

// Check route access
bool canAccessRoute = AccessControl.canAccessRoute(user, '/pms-dashboard');
```

## 2. Sidebar Access Control

### 📁 **File: `lib/widgets/enhanced_dashboard_sidebar.dart`**

**Purpose**: Dynamic sidebar with role-based and plan-based access control.

**Features**:
- **Dynamic Menu Items**: Show only accessible features
- **Visual Indicators**: Lock icons for restricted features
- **Upgrade Prompts**: Show upgrade messages for locked features
- **System Access Cards**: Display user's access level
- **Plan Information**: Show current plan details

**Access Control Logic**:
```dart
// Generate sidebar items based on user access
final sidebarItems = AccessControl.getSidebarItems(widget.user);

// Check if feature is accessible
final isAccessible = AccessControl.canAccessFeature(widget.user, item.feature);

// Check if upgrade is needed
final needsUpgrade = AccessControl.needsPlanUpgrade(widget.user, item.feature);
```

## 3. Screen-Level Access Control

### 📁 **File: `lib/middleware/access_control_middleware.dart`**

**Purpose**: Screen-level access control with middleware and wrappers.

**Components**:

#### **AccessControlWrapper**
```dart
AccessControlWrapper(
  feature: 'pms_dashboard',
  child: YourScreen(),
  fallback: AccessDeniedScreen(),
)
```

#### **AccessControlMixin**
```dart
class YourScreen extends ConsumerStatefulWidget with AccessControlMixin {
  @override
  Widget build(BuildContext context) {
    if (!canAccessFeature('pms_dashboard')) {
      showAccessDenied('pms_dashboard');
      return AccessDeniedScreen();
    }
    return YourScreenContent();
  }
}
```

#### **Protected Screen Components**
- **PMSProtectedScreen**: For PMS-specific features
- **POSProtectedScreen**: For POS-specific features

## 4. Endpoint Access Control

### 📁 **File: `lib/services/enhanced_api_service.dart`**

**Purpose**: API service with built-in access control for all endpoints.

**Features**:
- **Automatic Access Validation**: Check access before API calls
- **Role-Based Endpoint Protection**: Different access levels per role
- **Plan-Based Restrictions**: Plan-specific endpoint access
- **Error Handling**: Proper error responses for access denied

**Usage**:
```dart
final apiService = EnhancedApiService(dio: dio, user: user);

// Automatically checks access control
final response = await apiService.get('/api/v1/admin/hotels');

// Check if user can access feature
bool canAccess = apiService.canAccessFeature('pms_dashboard');
```

## 5. Route Protection

### 📁 **File: `lib/main.dart`**

**Purpose**: Router-level access control with automatic redirects.

**Features**:
- **Authentication Guards**: Redirect unauthenticated users
- **Access Control Redirects**: Redirect based on user permissions
- **Protected Route Detection**: Identify routes requiring authentication

**Implementation**:
```dart
redirect: (context, state) {
  final authState = container.read(enhancedAuthProvider);
  final user = authState.user;
  
  // Authentication check
  if (!authState.isAuthenticated && _isProtectedRoute(state.location)) {
    return '/login';
  }
  
  // Access control check
  if (authState.isAuthenticated && user != null) {
    final redirectRoute = AccessControlRouteGuard.getRedirectRoute(user, state.location);
    if (redirectRoute != null) {
      return redirectRoute;
    }
  }
  
  return null;
}
```

## 6. Access Control Matrix

### 🎯 **User Roles & Permissions**

| Role | PMS Access | POS Access | Admin Access | Features |
|------|------------|------------|--------------|----------|
| `system_admin` | ✅ Full | ✅ Full | ✅ Full | All features |
| `hotel_admin` + `bundle` | ✅ Full | ✅ Full | ❌ | PMS + POS |
| `hotel_admin` + `pms` | ✅ Full | ❌ | ❌ | PMS only |
| `hotel_admin` + `pos` | ❌ | ✅ Full | ❌ | POS only |
| `front_desk` | ❌ | ✅ Limited | ❌ | Guest services |
| `restaurant_manager` | ❌ | ✅ Limited | ❌ | Restaurant ops |
| `housekeeper` | ❌ | ✅ Limited | ❌ | Housekeeping |

### 📋 **Feature Access Matrix**

| Feature | System Admin | Hotel Admin | Front Desk | Restaurant | Housekeeper |
|---------|--------------|-------------|------------|------------|-------------|
| **PMS Features** |
| `pms_dashboard` | ✅ | ✅ (PMS/Bundle) | ❌ | ❌ | ❌ |
| `pms_bookings` | ✅ | ✅ (PMS/Bundle) | ❌ | ❌ | ❌ |
| `pms_rooms` | ✅ | ✅ (PMS/Bundle) | ❌ | ❌ | ❌ |
| `pms_reports` | ✅ | ✅ (PMS/Bundle) | ❌ | ❌ | ❌ |
| **POS Features** |
| `pos_dashboard` | ✅ | ✅ (POS/Bundle) | ✅ | ✅ | ✅ |
| `pos_restaurant` | ✅ | ✅ (POS/Bundle) | ❌ | ✅ | ❌ |
| `pos_staff` | ✅ | ✅ (POS/Bundle) | ❌ | ✅ | ❌ |
| `pos_payments` | ✅ | ✅ (POS/Bundle) | ✅ | ✅ | ❌ |
| **Admin Features** |
| `admin_dashboard` | ✅ | ❌ | ❌ | ❌ | ❌ |
| `admin_hotels` | ✅ | ✅ | ❌ | ❌ | ❌ |
| `staff_management` | ✅ | ✅ | ❌ | ✅ | ❌ |
| **Guest Services** |
| `guest_checkin` | ✅ | ✅ | ✅ | ❌ | ❌ |
| `guest_checkout` | ✅ | ✅ | ✅ | ❌ | ❌ |
| **Housekeeping** |
| `housekeeping` | ✅ | ✅ | ❌ | ❌ | ✅ |
| `room_cleaning` | ✅ | ✅ | ❌ | ❌ | ✅ |

## 7. Implementation Examples

### 🔧 **Sidebar Implementation**

```dart
// Generate sidebar items based on user access
final sidebarItems = AccessControl.getSidebarItems(user);

// Build sidebar with access control
Widget _buildMenuItems(List<SidebarItem> items) {
  return Column(
    children: items.map((item) {
      final isAccessible = AccessControl.canAccessFeature(user, item.feature);
      final needsUpgrade = AccessControl.needsPlanUpgrade(user, item.feature);
      
      return _buildMenuItem(
        item: item,
        isAccessible: isAccessible,
        needsUpgrade: needsUpgrade,
      );
    }).toList(),
  );
}
```

### 🛡️ **Screen Protection**

```dart
// Protect entire screen
class PMSBookingsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PMSProtectedScreen(
      feature: 'pms_bookings',
      title: 'Bookings',
      child: BookingsContent(),
    );
  }
}

// Protect specific features within screen
class DashboardScreen extends ConsumerWidget with AccessControlMixin {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Column(
        children: [
          if (canAccessFeature('pms_dashboard'))
            PMSOverviewWidget(),
          if (canAccessFeature('pos_dashboard'))
            POSOverviewWidget(),
        ],
      ),
    );
  }
}
```

### 🔌 **API Protection**

```dart
// Automatically protected API calls
final apiService = EnhancedApiService(dio: dio, user: user);

try {
  // This will automatically check access control
  final response = await apiService.get('/api/v1/admin/hotels');
  // Handle response
} on DioException catch (e) {
  if (e.response?.statusCode == 403) {
    // Access denied
    showAccessDeniedDialog(context, 'admin_hotels');
  } else if (e.response?.statusCode == 402) {
    // Upgrade required
    showUpgradeRequiredDialog(context, user, 'admin_hotels');
  }
}
```

## 8. Error Handling

### ⚠️ **Access Denied Scenarios**

#### **Authentication Errors**
- **401 Unauthorized**: User not authenticated
- **403 Forbidden**: User authenticated but no permission
- **402 Payment Required**: User needs to upgrade plan

#### **Error Responses**
```dart
// Access denied response
{
  "success": false,
  "message": "Access denied. You do not have permission to access this endpoint.",
  "code": "ACCESS_DENIED"
}

// Upgrade required response
{
  "success": false,
  "message": "Upgrade to Bundle plan to access PMS features",
  "code": "UPGRADE_REQUIRED"
}
```

## 9. Testing Access Control

### 🧪 **Test Cases**

#### **Authentication Tests**
```dart
test('unauthenticated user redirected to login', () async {
  // Test unauthenticated user accessing protected route
  expect(redirectRoute, '/login');
});
```

#### **Access Control Tests**
```dart
test('hotel admin with POS plan cannot access PMS features', () async {
  final user = EnhancedUser(role: 'hotel_admin', planType: 'pos');
  expect(AccessControl.canAccessFeature(user, 'pms_dashboard'), false);
});
```

#### **Plan Upgrade Tests**
```dart
test('user with POS plan needs upgrade for PMS features', () async {
  final user = EnhancedUser(role: 'hotel_admin', planType: 'pos');
  expect(AccessControl.needsPlanUpgrade(user, 'pms_dashboard'), true);
});
```

## 10. Security Considerations

### 🔒 **Security Best Practices**

1. **Server-Side Validation**: Always validate permissions on the server
2. **JWT Token Validation**: Verify token authenticity and expiration
3. **Role-Based Access**: Implement proper role hierarchy
4. **Plan-Based Restrictions**: Enforce plan limitations
5. **Audit Logging**: Log access attempts and denials

### 🛡️ **Access Control Layers**

1. **Frontend Validation**: Immediate UI feedback
2. **Route Protection**: Navigation-level security
3. **API Validation**: Server-side permission checks
4. **Database Security**: Row-level security if needed

## 11. Performance Considerations

### ⚡ **Optimization Strategies**

1. **Caching**: Cache access control decisions
2. **Lazy Loading**: Load features only when needed
3. **Minimal API Calls**: Reduce unnecessary permission checks
4. **Efficient Routing**: Optimize route protection logic

## 12. Future Enhancements

### 🚀 **Planned Improvements**

1. **Granular Permissions**: Feature-level permissions
2. **Dynamic Access Control**: Runtime permission changes
3. **Audit Trail**: Complete access logging
4. **Advanced Role Management**: Custom role creation
5. **Multi-Tenant Support**: Organization-level access control

---

## Summary

The access control system provides **comprehensive security** across all layers:

- **Frontend**: Dynamic UI based on user permissions
- **Middleware**: Route and screen-level protection
- **Backend**: API endpoint security
- **Database**: Data-level access control

This implementation ensures that users can only access features appropriate to their **role** and **plan**, providing a secure and user-friendly experience while maintaining the flexibility to upgrade and access additional features as needed.
