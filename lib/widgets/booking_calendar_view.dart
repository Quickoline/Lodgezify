import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/booking_models.dart';
import '../constants/theme.dart';

class BookingCalendarView extends StatefulWidget {
  final List<BookingSummary> bookings;
  final Function(BookingSummary) onBookingUpdate;

  const BookingCalendarView({
    super.key,
    required this.bookings,
    required this.onBookingUpdate,
  });

  @override
  State<BookingCalendarView> createState() => _BookingCalendarViewState();
}

class _BookingCalendarViewState extends State<BookingCalendarView> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Calendar header
          Container(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Text(
                  'Calendar View',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: AppFontWeights.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _focusedDay = DateTime.now();
                      _selectedDay = null;
                    });
                  },
                  icon: Icon(
                    Icons.today,
                    size: 20.w,
                    color: AppColors.blue[600],
                  ),
                  tooltip: 'Today',
                ),
              ],
            ),
          ),
          
          // Calendar - Flexible height to prevent overflow
          SizedBox(
            height: 350.h, // Reduced height for calendar
            child: _buildCalendar(),
          ),
          
          // Selected day bookings - Scrollable section
          if (_selectedDay != null)
            _buildSelectedDayBookings(),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
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
        children: [
          // Month navigation
          _buildMonthNavigation(),
          
          // Calendar grid
          Expanded(
            child: _buildCalendarGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthNavigation() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.blue[50],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12.r),
          topRight: Radius.circular(12.r),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              setState(() {
                _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1);
              });
            },
            icon: Icon(
              Icons.chevron_left,
              size: 20.w,
              color: AppColors.blue[600],
            ),
          ),
          Expanded(
            child: Text(
              '${_getMonthName(_focusedDay.month)} ${_focusedDay.year}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: AppFontWeights.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1);
              });
            },
            icon: Icon(
              Icons.chevron_right,
              size: 20.w,
              color: AppColors.blue[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final lastDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);
    final firstDayWeekday = firstDayOfMonth.weekday;
    final daysInMonth = lastDayOfMonth.day;

    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          // Weekday headers
          _buildWeekdayHeaders(),
          SizedBox(height: 8.h),
          
          // Calendar days - Flexible height grid
          Expanded(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1,
              ),
              itemCount: 42, // 6 weeks * 7 days
              itemBuilder: (context, index) {
                final dayNumber = index - firstDayWeekday + 1;
                final isCurrentMonth = dayNumber > 0 && dayNumber <= daysInMonth;
                final day = isCurrentMonth ? DateTime(_focusedDay.year, _focusedDay.month, dayNumber) : null;
                
                return _buildDayCell(day, dayNumber, isCurrentMonth);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeaders() {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    
    return Row(
      children: weekdays.map((day) => Expanded(
        child: Text(
          day,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: AppFontWeights.bold,
            color: AppColors.textSecondary,
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildDayCell(DateTime? day, int dayNumber, bool isCurrentMonth) {
    if (!isCurrentMonth) {
      return Container();
    }

    final dayBookings = _getBookingsForDay(day!);
    final isSelected = _selectedDay != null && 
        _selectedDay!.year == day.year &&
        _selectedDay!.month == day.month &&
        _selectedDay!.day == day.day;
    final isToday = day.year == DateTime.now().year &&
        day.month == DateTime.now().month &&
        day.day == DateTime.now().day;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDay = day;
        });
      },
      child: Container(
        margin: EdgeInsets.all(1.w),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.blue[600]!
              : isToday 
                  ? AppColors.blue[100]!
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
          border: isToday 
              ? Border.all(color: AppColors.blue[600]!, width: 1)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              dayNumber.toString(),
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: isSelected || isToday 
                    ? AppFontWeights.bold 
                    : AppFontWeights.medium,
                color: isSelected 
                    ? AppColors.white
                    : isToday 
                        ? AppColors.blue[600]!
                        : AppColors.textPrimary,
              ),
            ),
            if (dayBookings.isNotEmpty) ...[
              SizedBox(height: 2.h),
              Container(
                width: 4.w,
                height: 4.w,
                decoration: BoxDecoration(
                  color: isSelected 
                      ? AppColors.white
                      : AppColors.green[600]!,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedDayBookings() {
    final dayBookings = _getBookingsForDay(_selectedDay!);
    
    return Container(
      margin: EdgeInsets.all(16.w),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Bookings for ${_formatDate(_selectedDay!)}',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: AppFontWeights.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          if (dayBookings.isEmpty)
            Text(
              'No bookings for this day',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
              ),
            )
          else
            // Use ListView for scrollable bookings with fixed height
            SizedBox(
              height: 120.h, // Further reduced height to prevent overflow
              child: ListView.builder(
                itemCount: dayBookings.length,
                itemBuilder: (context, index) {
                  return _buildBookingItem(dayBookings[index]);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBookingItem(BookingSummary booking) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.gray[50],
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(color: AppColors.gray[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 2.w,
            height: 16.h,
            decoration: BoxDecoration(
              color: _getStatusColor(booking.status),
              borderRadius: BorderRadius.circular(1.r),
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  booking.guest,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: AppFontWeights.bold,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Room ${booking.room} • ${booking.status.toUpperCase()}',
                  style: TextStyle(
                    fontSize: 8.sp,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            '\$${booking.amount.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: AppFontWeights.bold,
              color: AppColors.green[600],
            ),
          ),
        ],
      ),
    );
  }

  List<BookingSummary> _getBookingsForDay(DateTime day) {
    return widget.bookings.where((booking) {
      final checkIn = DateTime.tryParse(booking.checkIn);
      final checkOut = DateTime.tryParse(booking.checkOut);
      
      if (checkIn == null || checkOut == null) return false;
      
      return day.isAfter(checkIn.subtract(const Duration(days: 1))) &&
             day.isBefore(checkOut.add(const Duration(days: 1)));
    }).toList();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return AppColors.green[600]!;
      case 'pending':
        return AppColors.orange[600]!;
      case 'cancelled':
        return AppColors.red[600]!;
      case 'completed':
        return AppColors.blue[600]!;
      default:
        return AppColors.gray[600]!;
    }
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
