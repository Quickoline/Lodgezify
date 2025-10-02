import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'screens/onboarding_screen.dart';
import 'screens/pms_login_screen.dart';
import 'screens/pos_login_screen.dart';
import 'screens/role_based_overview_screen.dart';
import 'models/enhanced_auth_models.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'Lodgezify Dashboard',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            appBarTheme: const AppBarTheme(
              centerTitle: true,
              elevation: 0,
            ),
            cardTheme: CardTheme(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          routerConfig: _router,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/pms-login',
      builder: (context, state) => const PMSLoginScreen(),
    ),
    GoRoute(
      path: '/pos-login',
      builder: (context, state) => const POSLoginScreen(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) {
        // Handle both old and new navigation structures
        if (state.extra is Map<String, dynamic>) {
          final data = state.extra as Map<String, dynamic>;
          final user = data['user'] as EnhancedUser?;
          final loginContext = data['loginContext'] as LoginContext?;
          final selectedRole = data['selectedRole'] as String?;
          return RoleBasedOverviewScreen(
            user: user, 
            loginContext: loginContext,
            selectedRole: selectedRole,
          );
        } else if (state.extra is EnhancedUser) {
          // Backward compatibility for direct user navigation
          final user = state.extra as EnhancedUser;
          return RoleBasedOverviewScreen(user: user, loginContext: LoginContext.direct);
        } else {
          // No user data, show demo
          return const RoleBasedOverviewScreen(loginContext: LoginContext.direct);
        }
      },
    ),
  ],
);