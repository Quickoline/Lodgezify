# Enhanced Authentication System

## Overview

This Flutter app now includes a comprehensive **relationshipful authentication system** that integrates seamlessly with your existing POS/PMS backend architecture. The system provides plan-based access control, role management, and unified authentication across both Property Management System (PMS) and Point of Sale (POS) systems.

## Key Features

### 🔐 **Plan-Based Access Control**
- **PMS Plan**: Access to Property Management System only
- **POS Plan**: Access to Point of Sale system only  
- **Bundle Plan**: Full access to both PMS and POS systems
- **System Admin**: Full system access with administrative privileges

### 👥 **Role-Based Authentication**
- **System Admin**: Complete system access
- **Hotel Admin**: Hotel management with plan-based restrictions
- **Front Desk**: Guest services and check-in operations
- **Restaurant Manager**: Restaurant and POS operations
- **Housekeeper**: Housekeeping and maintenance operations

### 🎯 **Relationshipful Authentication**
- **Unified Login**: Single login interface with plan type selection
- **Smart Routing**: Automatic dashboard routing based on user role and plan access
- **Access Validation**: Real-time plan access validation with backend integration
- **Trial Management**: Comprehensive trial status tracking and management

## Architecture

### Models (`lib/models/enhanced_auth_models.dart`)
```dart
// Core authentication models
- EnhancedUser: Complete user model with plan access control
- EnhancedPlan: Plan information with features and pricing
- PlanType: Enum for PMS, POS, and Bundle plans
- UserRole: Enum for different user roles
- SystemAccess: Enum for system access levels
```

### Services (`lib/services/enhanced_auth_service.dart`)
```dart
// Authentication service with backend integration
- EnhancedAuthService: Main authentication service
- Plan type validation and access control
- Token management and storage
- Backend API integration
```

### Providers (`lib/providers/enhanced_auth_provider.dart`)
```dart
// State management with Riverpod
- EnhancedAuthNotifier: Authentication state management
- Real-time access control validation
- User session management
- Error handling and loading states
```

### Screens
```dart
// Enhanced authentication screens
- EnhancedLoginScreen: Unified login with plan selection
- EnhancedDashboardScreen: Role-based dashboard with system access
```

## Usage

### 1. **Enhanced Login Flow**
```dart
// Navigate to enhanced login
context.go('/enhanced-login');

// The login screen provides:
// - Plan type selection (PMS, POS, Bundle)
// - Email/password authentication
// - reCAPTCHA verification
// - Automatic dashboard routing
```

### 2. **Access Control Validation**
```dart
// Check if user can access specific plan type
final canAccessPMS = await authService.canAccessPlanType(PlanType.pms);
final canAccessPOS = await authService.canAccessPlanType(PlanType.pos);

// Get user's system access
final systemAccess = await authService.getSystemAccess();
```

### 3. **Role-Based Navigation**
```dart
// Automatic dashboard routing based on user role and plan access
final dashboardRoute = user.dashboardRoute;
// Returns: '/pms-dashboard', '/pos-dashboard', '/manager-dashboard', etc.
```

## Backend Integration

### API Endpoints
```dart
// Enhanced authentication endpoints
POST /api/v1.0/admin/login          // Admin login with plan type
POST /api/v1/staff/hotel/login      // Staff login for POS
POST /api/v1.0/admin/forgot-password // Password reset
POST /api/v1.0/admin/reset-password  // Password reset confirmation
```

### Plan Access Validation
The system integrates with your existing backend plan validation logic:

```typescript
// Backend plan access validation (from your server)
canAccessPlanType(planType: 'pms' | 'pos' | 'bundle'): boolean {
  // System admins can access everything
  if (this.role === AdminRole.SYSTEM_ADMIN) return true;
  
  // Bundle plan users can access both PMS and POS
  if (this.planType === 'bundle') return true;
  
  // POS plan users can access POS
  if (this.planType === 'pos' && planType === 'pos') return true;
  
  // PMS plan users can only access PMS
  if (this.planType === 'pms' && planType === 'pms') return true;
  
  // Additional access rules...
}
```

## Navigation Flow

### 1. **Onboarding Screen**
- Enhanced Login (Recommended) → `/enhanced-login`
- Login as POS → `/pos-login`
- Login as PMS → `/pms-login`
- Signup as PMS → `/pms-signup`

### 2. **Enhanced Login Screen**
- Plan type selection (PMS, POS, Bundle)
- Email/password authentication
- reCAPTCHA verification
- Automatic routing to appropriate dashboard

### 3. **Dashboard Routing**
```dart
// Automatic routing based on user role and plan access
System Admin → /admin-dashboard
Hotel Admin + Bundle → /manager-dashboard
Hotel Admin + PMS → /pms-dashboard
Hotel Admin + POS → /pos-dashboard
Front Desk → /front-desk
Restaurant Manager → /restaurant-manager
Housekeeper → /housekeeper-dashboard
```

## State Management

### Authentication State
```dart
class EnhancedAuthState {
  final bool isAuthenticated;
  final EnhancedUser? user;
  final bool isLoading;
  final String? error;
  final PlanType? requestedPlanType;
  final SystemAccess systemAccess;
}
```

### Providers
```dart
// Core providers
final enhancedAuthProvider = StateNotifierProvider<EnhancedAuthNotifier, EnhancedAuthState>
final isEnhancedAuthenticatedProvider = Provider<bool>
final currentEnhancedUserProvider = Provider<EnhancedUser?>
final systemAccessProvider = Provider<SystemAccess>
final planTypeAccessProvider = Provider.family<bool, PlanType>
```

## Security Features

### 🔒 **Token Management**
- Secure token storage with SharedPreferences
- Automatic token refresh and validation
- Token expiration handling

### 🛡️ **Access Control**
- Plan-based access validation
- Role-based permission checking
- Real-time access control updates

### 🔐 **Authentication Flow**
- reCAPTCHA integration for bot protection
- Secure password handling
- Session management

## Migration from Legacy System

### ✅ **Legacy System Removed**
The old authentication system has been completely removed and replaced with the enhanced authentication system:

```dart
// Current routes (enhanced authentication only)
/login          // Enhanced login with plan selection
/dashboard      // Enhanced role-based dashboard
/pms-dashboard  // PMS dashboard
/pos-dashboard  // POS dashboard
```

### ✅ **Migration Complete**
1. **Phase 1**: ✅ Deployed enhanced authentication
2. **Phase 2**: ✅ Updated onboarding to use enhanced login
3. **Phase 3**: ✅ Migrated all routes to enhanced authentication
4. **Phase 4**: ✅ Removed legacy authentication system

## 🗑️ **Old System Removal**

The old authentication system has been completely removed and replaced with the enhanced system:

### **Removed Components**
- ❌ `lib/models/auth_models.dart` - Old authentication models
- ❌ `lib/screens/dashboard/dashboard_screen.dart` - Old dashboard screen
- ❌ `lib/screens/dashboard/pms_dashboard_screen.dart` - Old PMS dashboard screen
- ❌ `lib/screens/dashboard/pos_dashboard_screen.dart` - Old POS dashboard screen
- ❌ `lib/widgets/dashboard_sidebar.dart` - Old dashboard sidebar
- ❌ `lib/screens/auth/login_screen.dart` - Old login screen
- ❌ `lib/screens/pms_auth/pms_login_screen.dart` - Old PMS login screen  
- ❌ `lib/screens/pms_auth/pms_signup_screen.dart` - Old PMS signup screen
- ❌ `lib/screens/pos_auth/pos_login_screen.dart` - Old POS login screen
- ❌ `lib/providers/auth_provider.dart` - Old authentication provider
- ❌ `lib/providers/pms_auth_provider.dart` - Old PMS authentication provider
- ❌ `lib/services/api_service.dart` - Old API service
- ❌ `lib/services/auth_service.dart` - Old authentication service
- ❌ `lib/services/dummy_auth_service.dart` - Old dummy authentication service

### **Updated Components**
- ✅ `lib/main.dart` - Updated router configuration and removed old imports
- ✅ `lib/screens/onboarding_screen.dart` - Updated to use enhanced system

## Benefits

### 🚀 **For Users**
- **Unified Experience**: Single login for all systems
- **Smart Routing**: Automatic navigation to appropriate dashboard
- **Clear Access Control**: Transparent plan-based access
- **Trial Management**: Clear trial status and expiration

### 🏗️ **For Developers**
- **Maintainable Code**: Clean separation of concerns
- **Type Safety**: Strong typing with enums and models
- **State Management**: Reactive state with Riverpod
- **Backend Integration**: Seamless API integration

### 🏢 **For Business**
- **Plan Flexibility**: Easy plan upgrades and changes
- **User Management**: Clear role and permission management
- **Analytics**: Better user behavior tracking
- **Scalability**: Easy addition of new plan types and roles

## Getting Started

### 1. **Access Enhanced Login**
Navigate to `/enhanced-login` from the onboarding screen or directly.

### 2. **Select Plan Type**
Choose your system access:
- **PMS**: Property Management System
- **POS**: Point of Sale System  
- **Bundle**: Both systems

### 3. **Authenticate**
Enter your credentials and complete reCAPTCHA verification.

### 4. **Automatic Routing**
The system will automatically route you to the appropriate dashboard based on your role and plan access.

## Support

For technical support or questions about the enhanced authentication system, please refer to the development team or create an issue in the project repository.

---

**Note**: This enhanced authentication system provides a robust, scalable foundation for your hotel management and POS applications while maintaining backward compatibility with existing systems.
