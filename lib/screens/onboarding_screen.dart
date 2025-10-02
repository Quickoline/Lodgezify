import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/theme.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg.w),
          child: Column(
            children: [
              // Header
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    Container(
                      width: 120.w,
                      height: 120.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                        child: Image.asset(
                          'assets/images/logo.jpg',
                          width: 120.w,
                          height: 120.h,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            // Fallback to icon if image fails to load
                            return Container(
                              width: 120.w,
                              height: 120.h,
                              decoration: BoxDecoration(
                                color: AppColors.primary[100],
                                borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                              ),
                              child: Icon(
                                Icons.hotel,
                                size: 60.sp,
                                color: AppColors.primary[600],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: AppSpacing.md.h),
                    Text(
                      'Lodgezify',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: AppFontWeights.bold,
                        fontSize: 32.sp,
                      ),
                    ),
                    SizedBox(height: AppSpacing.sm.h),
                    Text(
                      'Complete Hotel Management Solution',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 14.sp,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              // Main Content
              Expanded(
                flex: 3,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                    Text(
                      'Welcome to Lodgezify',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: AppFontWeights.bold,
                        fontSize: 24.sp,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: AppSpacing.sm.h),
                    Text(
                      'Choose your system to get started',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 16.sp,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: AppSpacing.xl.h),
                    
                    // Navigation Buttons
                    Column(
                      children: [
                        // PMS Login
                        _buildNavButton(
                          context,
                          'PMS Login',
                          AppColors.primary[600]!,
                          () => context.go('/pms-login'),
                          isRecommended: true,
                        ),
                        SizedBox(height: AppSpacing.lg.h),
                        // POS Login
                        _buildNavButton(
                          context,
                          'POS Login',
                          AppColors.secondary[600]!,
                          () => context.go('/pos-login'),
                        ),
                      ],
                    ),
                  ],
                ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavButton(
    BuildContext context,
    String title,
    Color backgroundColor,
    VoidCallback onPressed, {
    bool isRecommended = false,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: AppColors.textInverse,
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.xl.w,
            vertical: AppSpacing.lg.h,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppBorderRadius.md),
          ),
          elevation: isRecommended ? 5 : 3,
          shadowColor: Colors.black.withOpacity(0.1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isRecommended) ...[
              Icon(
                Icons.star,
                size: 16.sp,
                color: AppColors.textInverse,
              ),
              SizedBox(width: AppSpacing.sm.w),
            ],
            Text(
              title,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: AppFontWeights.semibold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
