import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/theme.dart';
import '../models/enhanced_auth_models.dart';
import '../widgets/app_drawer.dart';

class RoomsScreen extends ConsumerStatefulWidget {
  final EnhancedUser? user;
  final LoginContext? loginContext;
  final String? selectedRole;

  const RoomsScreen({
    super.key,
    this.user,
    this.loginContext,
    this.selectedRole,
  });

  @override
  ConsumerState<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends ConsumerState<RoomsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Rooms Management'),
        backgroundColor: AppColors.primary[600],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Add room functionality coming soon!')),
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
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(32.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.hotel,
                size: 64.sp,
                color: AppColors.primary[600],
              ),
              SizedBox(height: 16.h),
              Text(
                'Rooms Management',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: AppFontWeights.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Manage room availability, pricing, and maintenance',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Rooms management coming soon!')),
                  );
                },
                icon: const Icon(Icons.hotel),
                label: const Text('Manage Rooms'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary[600],
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
