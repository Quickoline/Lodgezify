import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/booking_models.dart';
import '../constants/theme.dart';

class BookingFilterWidget extends StatefulWidget {
  final BookingFilter filter;
  final Function(BookingFilter) onFilterChanged;

  const BookingFilterWidget({
    super.key,
    required this.filter,
    required this.onFilterChanged,
  });

  @override
  State<BookingFilterWidget> createState() => _BookingFilterWidgetState();
}

class _BookingFilterWidgetState extends State<BookingFilterWidget> {
  late BookingFilter _currentFilter;

  @override
  void initState() {
    super.initState();
    _currentFilter = widget.filter;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Filters',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: AppFontWeights.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              if (_hasActiveFilters())
                TextButton(
                  onPressed: _clearFilters,
                  child: Text(
                    'Clear',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.blue[600],
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 8.h),
          // Date filters
          Row(
            children: [
              Expanded(
                child: _buildDateFilter(
                  label: 'From',
                  value: _currentFilter.startDate,
                  onChanged: (value) => _updateFilter(startDate: value),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildDateFilter(
                  label: 'To',
                  value: _currentFilter.endDate,
                  onChanged: (value) => _updateFilter(endDate: value),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          // Status and source filters
          Row(
            children: [
              Expanded(
                child: _buildDropdownFilter(
                  label: 'Status',
                  value: _currentFilter.status,
                  items: const ['confirmed', 'pending', 'cancelled', 'completed'],
                  onChanged: (value) => _updateFilter(status: value),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildDropdownFilter(
                  label: 'Source',
                  value: _currentFilter.source,
                  items: const ['direct', 'booking.com', 'expedia', 'airbnb'],
                  onChanged: (value) => _updateFilter(source: value),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateFilter({
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
            color: AppColors.textSecondary,
            fontWeight: AppFontWeights.medium,
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

  Widget _buildDropdownFilter({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: AppColors.textSecondary,
            fontWeight: AppFontWeights.medium,
          ),
        ),
        SizedBox(height: 4.h),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: AppColors.gray[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: AppColors.gray[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: AppColors.blue[600]!),
            ),
          ),
          items: [
            DropdownMenuItem<String>(
              value: null,
              child: Text(
                'All',
                style: TextStyle(fontSize: 12.sp),
              ),
            ),
            ...items.map((item) => DropdownMenuItem<String>(
              value: item,
              child: Text(
                item.toUpperCase(),
                style: TextStyle(fontSize: 12.sp),
              ),
            )),
          ],
          onChanged: onChanged,
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

  void _updateFilter({
    String? startDate,
    String? endDate,
    String? status,
    String? source,
  }) {
    setState(() {
      _currentFilter = _currentFilter.copyWith(
        startDate: startDate,
        endDate: endDate,
        status: status,
        source: source,
      );
    });
    widget.onFilterChanged(_currentFilter);
  }

  void _clearFilters() {
    setState(() {
      _currentFilter = const BookingFilter();
    });
    widget.onFilterChanged(_currentFilter);
  }

  bool _hasActiveFilters() {
    return _currentFilter.startDate != null ||
           _currentFilter.endDate != null ||
           _currentFilter.status != null ||
           _currentFilter.source != null;
  }
}
