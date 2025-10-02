import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/booking_models.dart';
import '../constants/theme.dart';

class BookingListView extends StatelessWidget {
  final List<BookingSummary> bookings;
  final Function(BookingSummary) onBookingUpdate;
  final HotelInfo hotelInfo;

  const BookingListView({
    super.key,
    required this.bookings,
    required this.onBookingUpdate,
    required this.hotelInfo,
  });

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return _buildBookingCard(booking);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 64.w,
              color: AppColors.gray[400],
            ),
            SizedBox(height: 16.h),
            Text(
              'No bookings found',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: AppFontWeights.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Try adjusting your filters or check back later',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingCard(BookingSummary booking) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
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
          // Header with status
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: _getStatusColor(booking.status).withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.r),
                topRight: Radius.circular(12.r),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.guest,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: AppFontWeights.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Room ${booking.room} • ${booking.reservationId}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(booking.status),
              ],
            ),
          ),
          
          // Booking details
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                _buildDetailRow(
                  icon: Icons.login,
                  label: 'Check-in',
                  value: _formatDate(booking.checkIn),
                  color: AppColors.green[600]!,
                ),
                SizedBox(height: 8.h),
                _buildDetailRow(
                  icon: Icons.logout,
                  label: 'Check-out',
                  value: _formatDate(booking.checkOut),
                  color: AppColors.blue[600]!,
                ),
                SizedBox(height: 8.h),
                _buildDetailRow(
                  icon: Icons.public,
                  label: 'Source',
                  value: booking.source.toUpperCase(),
                  color: AppColors.purple[600]!,
                ),
                SizedBox(height: 8.h),
                _buildDetailRow(
                  icon: Icons.payment,
                  label: 'Payment',
                  value: _getPaymentStatusText(booking.paymentStatus),
                  color: _getPaymentStatusColor(booking.paymentStatus),
                ),
                SizedBox(height: 12.h),
                // Amount and actions
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '\$${booking.amount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: AppFontWeights.bold,
                          color: AppColors.green[600],
                        ),
                      ),
                    ),
                    _buildActionButtons(booking),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: _getStatusColor(status),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: AppFontWeights.bold,
          color: AppColors.white,
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16.w,
          color: color,
        ),
        SizedBox(width: 8.w),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 12.sp,
            color: AppColors.textSecondary,
            fontWeight: AppFontWeights.medium,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.textPrimary,
              fontWeight: AppFontWeights.medium,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BookingSummary booking) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (booking.status == 'pending')
          IconButton(
            onPressed: () => _updateBookingStatus(booking, 'confirmed'),
            icon: Icon(
              Icons.check,
              size: 16.w,
              color: AppColors.green[600],
            ),
            tooltip: 'Confirm',
          ),
        if (booking.status == 'confirmed')
          IconButton(
            onPressed: () => _updateBookingStatus(booking, 'cancelled'),
            icon: Icon(
              Icons.cancel,
              size: 16.w,
              color: AppColors.red[600],
            ),
            tooltip: 'Cancel',
          ),
        IconButton(
          onPressed: () => _showBookingDetails(booking),
          icon: Icon(
            Icons.info_outline,
            size: 16.w,
            color: AppColors.blue[600],
          ),
          tooltip: 'Details',
        ),
      ],
    );
  }

  void _updateBookingStatus(BookingSummary booking, String newStatus) {
    final updatedBooking = BookingSummary(
      id: booking.id,
      reservationId: booking.reservationId,
      guest: booking.guest,
      room: booking.room,
      checkIn: booking.checkIn,
      checkOut: booking.checkOut,
      status: newStatus,
      source: booking.source,
      paymentStatus: booking.paymentStatus,
      amount: booking.amount,
    );
    onBookingUpdate(updatedBooking);
  }

  void _showBookingDetails(BookingSummary booking) {
    // TODO: Implement booking details dialog
    print('Show details for booking: ${booking.id}');
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

  Color _getPaymentStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.paid:
        return AppColors.green[600]!;
      case PaymentStatus.authorized:
        return AppColors.blue[600]!;
      case PaymentStatus.pending:
        return AppColors.orange[600]!;
      case PaymentStatus.refunded:
        return AppColors.red[600]!;
    }
  }

  String _getPaymentStatusText(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.paid:
        return 'Paid';
      case PaymentStatus.authorized:
        return 'Authorized';
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.refunded:
        return 'Refunded';
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}
