import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/theme.dart';

class BookingStatsCards extends StatelessWidget {
  final int upcomingCheckIns;
  final int upcomingCheckOuts;
  final int cancellations;
  final int noShows;

  const BookingStatsCards({
    super.key,
    required this.upcomingCheckIns,
    required this.upcomingCheckOuts,
    required this.cancellations,
    required this.noShows,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Booking Overview',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: AppFontWeights.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          // First row - Check-ins and Check-outs
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Upcoming Check-ins',
                  value: upcomingCheckIns.toString(),
                  icon: Icons.login,
                  color: AppColors.green[600]!,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildStatCard(
                  title: 'Upcoming Check-outs',
                  value: upcomingCheckOuts.toString(),
                  icon: Icons.logout,
                  color: AppColors.blue[600]!,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          // Second row - Cancellations and No-shows
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Cancellations',
                  value: cancellations.toString(),
                  icon: Icons.cancel,
                  color: AppColors.red[600]!,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildStatCard(
                  title: 'No Shows',
                  value: noShows.toString(),
                  icon: Icons.person_off,
                  color: AppColors.orange[600]!,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.gray[200]!,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20.w,
                ),
              ),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: AppFontWeights.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.textSecondary,
              fontWeight: AppFontWeights.medium,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
