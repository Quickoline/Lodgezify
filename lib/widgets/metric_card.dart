import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/theme.dart';

class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String change;
  final String trend;
  final IconData icon;
  final Color color;
  final bool isFullWidth;

  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.change,
    required this.trend,
    required this.icon,
    required this.color,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Container(
        width: isFullWidth ? double.infinity : null,
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 18.w,
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: AppFontWeights.medium,
                      color: AppColors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            SizedBox(height: 6.h),
            Text(
              value,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: AppFontWeights.bold,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 3.h),
            Row(
              children: [
                Icon(
                  _getTrendIcon(),
                  color: _getTrendColor(),
                  size: 14.w,
                ),
                SizedBox(width: 3.w),
                Flexible(
                  child: Text(
                    '$change from last week',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: _getTrendColor(),
                      fontWeight: AppFontWeights.medium,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getTrendIcon() {
    switch (trend.toLowerCase()) {
      case 'up':
        return Icons.trending_up;
      case 'down':
        return Icons.trending_down;
      default:
        return Icons.trending_flat;
    }
  }

  Color _getTrendColor() {
    switch (trend.toLowerCase()) {
      case 'up':
        return AppColors.green[600]!;
      case 'down':
        return AppColors.red[600]!;
      default:
        return AppColors.gray[500]!;
    }
  }
}
