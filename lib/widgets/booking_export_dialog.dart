import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/theme.dart';

class BookingExportDialog extends StatefulWidget {
  final List<dynamic> bookings;
  final Function(String startDate, String endDate) onExport;

  const BookingExportDialog({
    super.key,
    required this.bookings,
    required this.onExport,
  });

  @override
  State<BookingExportDialog> createState() => _BookingExportDialogState();
}

class _BookingExportDialogState extends State<BookingExportDialog> {
  String? exportStartDate;
  String? exportEndDate;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Export Bookings',
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: AppFontWeights.bold,
          color: AppColors.textPrimary,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose a date range to export bookings by check-in date. Leave blank to export all.',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 16.h),
          
          // Date range inputs
          Row(
            children: [
              Expanded(
                child: _buildDateInput(
                  label: 'From',
                  value: exportStartDate,
                  onChanged: (value) => setState(() => exportStartDate = value),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildDateInput(
                  label: 'To',
                  value: exportEndDate,
                  onChanged: (value) => setState(() => exportEndDate = value),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16.h),
          
          // Export info
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.blue[50],
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16.w,
                  color: AppColors.blue[600],
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    '${widget.bookings.length} bookings will be exported',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.blue[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _exportBookings,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.blue[600],
            foregroundColor: AppColors.white,
          ),
          child: Text(
            'Export',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: AppFontWeights.medium,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateInput({
    required String label,
    required String? value,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: AppFontWeights.medium,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 4.h),
        InkWell(
          onTap: () => _selectDate(label, onChanged),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.gray[300]!),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16.w,
                  color: AppColors.textSecondary,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    value ?? 'Select date',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: value != null ? AppColors.textPrimary : AppColors.textSecondary,
                    ),
                  ),
                ),
                if (value != null)
                  GestureDetector(
                    onTap: () => onChanged(null),
                    child: Icon(
                      Icons.clear,
                      size: 16.w,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _selectDate(String label, Function(String?) onChanged) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    
    if (picked != null) {
      final dateString = picked.toIso8601String().split('T')[0];
      onChanged(dateString);
    }
  }

  void _exportBookings() {
    // For now, just show a success message
    // In a real app, you would implement actual file export
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Exporting ${widget.bookings.length} bookings...',
          style: TextStyle(fontSize: 14.sp),
        ),
        backgroundColor: AppColors.green[600],
        duration: const Duration(seconds: 2),
      ),
    );
    
    widget.onExport(
      exportStartDate ?? '',
      exportEndDate ?? '',
    );
    
    Navigator.of(context).pop();
  }
}
