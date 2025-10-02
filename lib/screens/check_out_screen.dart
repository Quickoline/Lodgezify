import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/theme.dart';
import '../models/enhanced_auth_models.dart';
import '../widgets/app_drawer.dart';

class CheckOutScreen extends ConsumerStatefulWidget {
  final EnhancedUser user;
  final LoginContext? loginContext;
  final String? selectedRole;
  
  const CheckOutScreen({
    super.key,
    required this.user,
    this.loginContext,
    this.selectedRole,
  });

  @override
  ConsumerState<CheckOutScreen> createState() => _CheckOutScreenState();
}

class _CheckOutScreenState extends ConsumerState<CheckOutScreen> {
  final _searchController = TextEditingController();
  bool _isLoading = false;
  bool _isSearching = false;
  List<Map<String, dynamic>> _searchResults = [];
  Map<String, dynamic>? _selectedGuest;
  Map<String, dynamic>? _checkoutDetails;
  bool _showSearchResults = false;
  bool _checkoutSuccess = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchGuests() async {
    if (_searchController.text.trim().isEmpty) return;

    setState(() {
      _isSearching = true;
      _showSearchResults = true;
    });

    try {
      // Simulate API call - replace with actual API
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock search results for checked-in guests
      setState(() {
        _searchResults = [
          {
            'id': '1',
            'name': 'John Doe',
            'email': 'john.doe@email.com',
            'phone': '+1234567890',
            'bookingId': 'BK001',
            'roomNumber': '101',
            'checkIn': '2024-01-15',
            'checkOut': '2024-01-17',
            'status': 'checked_in',
            'totalAmount': 250.00,
            'paidAmount': 100.00,
            'remainingBalance': 150.00,
            'securityDeposit': 50.00,
            'roomServiceCharges': 25.00,
          },
          {
            'id': '2',
            'name': 'Jane Smith',
            'email': 'jane.smith@email.com',
            'phone': '+1234567891',
            'bookingId': 'BK002',
            'roomNumber': '102',
            'checkIn': '2024-01-14',
            'checkOut': '2024-01-18',
            'status': 'checked_in',
            'totalAmount': 400.00,
            'paidAmount': 400.00,
            'remainingBalance': 0.00,
            'securityDeposit': 100.00,
            'roomServiceCharges': 0.00,
          },
        ];
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Search failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  void _selectGuest(Map<String, dynamic> guest) {
    setState(() {
      _selectedGuest = guest;
      _showSearchResults = false;
      
      // Simulate fetching checkout details
      _checkoutDetails = {
        'guest': guest,
        'booking': {
          'id': guest['bookingId'],
          'checkIn': guest['checkIn'],
          'checkOut': guest['checkOut'],
          'status': guest['status'],
        },
        'room': {
          'number': guest['roomNumber'],
          'type': 'Deluxe Room',
        },
        'summary': {
          'totalAmount': guest['totalAmount'],
          'paidAmount': guest['paidAmount'],
          'remainingBalance': guest['remainingBalance'],
          'securityDeposit': guest['securityDeposit'],
          'roomServiceCharges': guest['roomServiceCharges'],
          'securityDepositRefund': guest['securityDeposit'] - (guest['roomServiceCharges'] ?? 0),
        },
      };
    });
  }

  Future<void> _processCheckout() async {
    if (_checkoutDetails == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        setState(() {
          _checkoutSuccess = true;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Check-out completed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Check-out failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _clearForm() {
    setState(() {
      _selectedGuest = null;
      _checkoutDetails = null;
      _checkoutSuccess = false;
      _searchController.clear();
      _searchResults.clear();
      _showSearchResults = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Guest Check-out'),
        backgroundColor: AppColors.primary[600],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _clearForm,
          ),
        ],
      ),
      drawer: AppDrawer(
        user: widget.user,
        loginContext: widget.loginContext,
        selectedRole: widget.selectedRole,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Section
            _buildSearchSection(),
            SizedBox(height: 20.h),
            
            // Guest Details & Checkout Summary
            if (_checkoutDetails != null && !_checkoutSuccess) ...[
              _buildGuestDetailsSection(),
              SizedBox(height: 20.h),
              _buildCheckoutSummarySection(),
              SizedBox(height: 20.h),
              _buildCheckoutButton(),
            ],
            
            // Success Message
            if (_checkoutSuccess) _buildSuccessSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Find Guest',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: AppFontWeights.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by name, email, phone, or booking ID',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    onChanged: (value) {
                      if (value.isEmpty) {
                        setState(() {
                          _showSearchResults = false;
                          _searchResults.clear();
                        });
                      }
                    },
                  ),
                ),
                SizedBox(width: 12.w),
                ElevatedButton.icon(
                  onPressed: _isSearching ? null : _searchGuests,
                  icon: _isSearching 
                    ? SizedBox(
                        width: 16.w,
                        height: 16.h,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.search),
                  label: Text(_isSearching ? 'Searching...' : 'Search'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary[600],
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            
            // Search Results
            if (_showSearchResults && _searchResults.isNotEmpty) ...[
              SizedBox(height: 12.h),
              Container(
                constraints: BoxConstraints(maxHeight: 200.h),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final guest = _searchResults[index];
                    return ListTile(
                      title: Text(guest['name']),
                      subtitle: Text('${guest['email']} • Room ${guest['roomNumber']}'),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            guest['status'].toUpperCase(),
                            style: TextStyle(
                              color: guest['status'] == 'checked_in' ? Colors.green : Colors.orange,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.sp,
                            ),
                          ),
                          if (guest['remainingBalance'] > 0)
                            Text(
                              'Balance: \$${guest['remainingBalance'].toStringAsFixed(2)}',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 10.sp,
                              ),
                            ),
                        ],
                      ),
                      onTap: () => _selectGuest(guest),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGuestDetailsSection() {
    final guest = _checkoutDetails!['guest'];
    final booking = _checkoutDetails!['booking'];
    final room = _checkoutDetails!['room'];

    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Guest Information',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: AppFontWeights.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 12.h),
            _buildInfoRow('Name', guest['name']),
            _buildInfoRow('Email', guest['email']),
            _buildInfoRow('Phone', guest['phone']),
            _buildInfoRow('Booking ID', guest['bookingId']),
            _buildInfoRow('Room', '${room['number']} (${room['type']})'),
            _buildInfoRow('Check-in Date', booking['checkIn']),
            _buildInfoRow('Check-out Date', booking['checkOut']),
            _buildInfoRow('Status', booking['status'].toUpperCase()),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckoutSummarySection() {
    final summary = _checkoutDetails!['summary'];
    final hasOutstandingBalance = summary['remainingBalance'] > 0;

    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Checkout Summary',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: AppFontWeights.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 16.h),
            
            // Payment Status
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: hasOutstandingBalance ? Colors.red[50] : Colors.green[50],
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: hasOutstandingBalance ? Colors.red[200]! : Colors.green[200]!,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    hasOutstandingBalance ? Icons.warning : Icons.check_circle,
                    color: hasOutstandingBalance ? Colors.red[600] : Colors.green[600],
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      hasOutstandingBalance 
                        ? 'Outstanding balance must be paid before checkout'
                        : 'Payment completed - ready for checkout',
                      style: TextStyle(
                        color: hasOutstandingBalance ? Colors.red[700] : Colors.green[700],
                        fontWeight: AppFontWeights.medium,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            
            // Financial Summary
            _buildSummaryRow('Total Amount', '\$${summary['totalAmount'].toStringAsFixed(2)}'),
            _buildSummaryRow('Amount Paid', '\$${summary['paidAmount'].toStringAsFixed(2)}'),
            if (summary['roomServiceCharges'] > 0)
              _buildSummaryRow('Room Service Charges', '\$${summary['roomServiceCharges'].toStringAsFixed(2)}'),
            _buildSummaryRow('Security Deposit', '\$${summary['securityDeposit'].toStringAsFixed(2)}'),
            
            const Divider(),
            
            _buildSummaryRow(
              'Remaining Balance', 
              '\$${summary['remainingBalance'].toStringAsFixed(2)}',
              isHighlight: true,
              isRed: hasOutstandingBalance,
            ),
            _buildSummaryRow(
              'Security Deposit Refund', 
              '\$${summary['securityDepositRefund'].toStringAsFixed(2)}',
              isHighlight: true,
              isGreen: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isHighlight = false, bool isRed = false, bool isGreen = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isHighlight ? AppFontWeights.semibold : AppFontWeights.medium,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isHighlight ? AppFontWeights.bold : AppFontWeights.medium,
              color: isRed ? Colors.red[600] : (isGreen ? Colors.green[600] : AppColors.textPrimary),
              fontSize: isHighlight ? 16.sp : 14.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100.w,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: AppFontWeights.medium,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutButton() {
    final summary = _checkoutDetails!['summary'];
    final hasOutstandingBalance = summary['remainingBalance'] > 0;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: hasOutstandingBalance ? null : (_isLoading ? null : _processCheckout),
        style: ElevatedButton.styleFrom(
          backgroundColor: hasOutstandingBalance ? Colors.grey : AppColors.primary[600],
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        child: _isLoading
          ? SizedBox(
              height: 20.h,
              width: 20.w,
              child: const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : Text(
              hasOutstandingBalance 
                ? 'Cannot Checkout - Outstanding Balance'
                : 'Complete Check-out',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: AppFontWeights.semibold,
              ),
            ),
      ),
    );
  }

  Widget _buildSuccessSection() {
    final guest = _checkoutDetails!['guest'];
    final summary = _checkoutDetails!['summary'];

    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          children: [
            Icon(
              Icons.check_circle,
              size: 64.sp,
              color: Colors.green[600],
            ),
            SizedBox(height: 16.h),
            Text(
              'Checkout Complete!',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: AppFontWeights.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Guest has been successfully checked out',
              style: TextStyle(
                fontSize: 16.sp,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            
            // Summary
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Column(
                children: [
                  Text(
                    'Checkout Summary',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: AppFontWeights.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  _buildInfoRow('Guest', guest['name']),
                  _buildInfoRow('Room', '${_checkoutDetails!['room']['number']}'),
                  _buildInfoRow('Total Paid', '\$${summary['totalAmount'].toStringAsFixed(2)}'),
                  _buildInfoRow('Security Deposit Refund', '\$${summary['securityDepositRefund'].toStringAsFixed(2)}'),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _clearForm,
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                    child: const Text('New Checkout'),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _clearForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary[600],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                    child: const Text('Done'),
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
