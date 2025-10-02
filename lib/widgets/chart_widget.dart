import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/dashboard_models.dart';
import '../constants/theme.dart';

class ChartWidget extends StatelessWidget {
  final String title;
  final List<MonthlyData> data;
  final String valueKey;
  final Color color;

  const ChartWidget({
    super.key,
    required this.title,
    required this.data,
    required this.valueKey,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Card(
        elevation: 2,
        child: Container(
          height: 180.h,
          padding: EdgeInsets.all(16.w),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.bar_chart,
                  size: 32.w,
                  color: AppColors.gray[400],
                ),
                SizedBox(height: 8.h),
                Text(
                  'No data available',
                  style: TextStyle(
                    color: AppColors.gray[600],
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final maxValue = data.map((item) => 
      valueKey == 'revenue' ? item.revenue : item.occupancy
    ).reduce((a, b) => a > b ? a : b);

    return Card(
      elevation: 2,
      child: Container(
        height: 180.h,
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: AppFontWeights.semibold,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 8.h),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final availableWidth = constraints.maxWidth;
                  final barWidth = (availableWidth / data.length) - 4.w;
                  final maxBarWidth = 16.w;
                  final actualBarWidth = barWidth > maxBarWidth ? maxBarWidth : barWidth;
                  
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: data.map((item) {
                      final value = valueKey == 'revenue' ? item.revenue : item.occupancy;
                      final height = maxValue > 0 ? (value / maxValue) * 80.h : 0.0;
                      
                      return Flexible(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: actualBarWidth,
                              height: height,
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(2.r),
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              item.date,
                              style: TextStyle(
                                fontSize: 8.sp,
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
            SizedBox(height: 4.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    'Monthly ${valueKey == 'revenue' ? 'revenue' : 'occupancy'}',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (maxValue > 0)
                  Flexible(
                    child: Text(
                      'Max: ${valueKey == 'revenue' ? '\$${maxValue.toStringAsFixed(0)}' : '${maxValue.toStringAsFixed(0)}%'}',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: AppColors.textSecondary,
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
}
