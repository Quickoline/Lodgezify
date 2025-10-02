import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/theme.dart';
import '../models/enhanced_auth_models.dart';
import '../widgets/app_drawer.dart';

class CheckInScreen extends ConsumerStatefulWidget {
  final EnhancedUser user;
  final LoginContext? loginContext;
  final String? selectedRole;
  
  const CheckInScreen({
    super.key,
    required this.user,
    this.loginContext,
    this.selectedRole,
  });

  @override
  ConsumerState<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends ConsumerState<CheckInScreen> {
  final _searchController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isSearching = false;
  List<Map<String, dynamic>> _searchResults = [];
  Map<String, dynamic>? _selectedGuest;
  Map<String, dynamic>? _selectedBooking;
  bool _showSearchResults = false;

  // Form fields for check-in
  final _roomNumberController = TextEditingController();
  final _checkInDateController = TextEditingController();
  final _checkOutDateController = TextEditingController();
  final _specialRequestsController = TextEditingController();
  final _paymentMethodController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    _roomNumberController.dispose();
    _checkInDateController.dispose();
    _checkOutDateController.dispose();
    _specialRequestsController.dispose();
    _paymentMethodController.dispose();
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
      
      // Mock search results
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
            'status': 'confirmed'
          },
          {
            'id': '2',
            'name': 'Jane Smith',
            'email': 'jane.smith@email.com',
            'phone': '+1234567891',
            'bookingId': 'BK002',
            'roomNumber': '102',
            'checkIn': '2024-01-15',
            'checkOut': '2024-01-18',
            'status': 'confirmed'
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
      _selectedBooking = guest;
      _showSearchResults = false;
      _roomNumberController.text = guest['roomNumber'] ?? '';
      _checkInDateController.text = guest['checkIn'] ?? '';
      _checkOutDateController.text = guest['checkOut'] ?? '';
    });
  }

  Future<void> _processCheckIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Check-in completed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Clear form
        _clearForm();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Check-in failed: $e'),
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
      _selectedBooking = null;
      _searchController.clear();
      _roomNumberController.clear();
      _checkInDateController.clear();
      _checkOutDateController.clear();
      _specialRequestsController.clear();
      _paymentMethodController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Guest Check-In'),
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
            
            // Guest Details Section
            if (_selectedGuest != null) ...[
              _buildGuestDetailsSection(),
              SizedBox(height: 20.h),
            ],
            
            // Check-in Form
            if (_selectedGuest != null) _buildCheckInForm(),
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
                      subtitle: Text('${guest['email']} • ${guest['phone']}'),
                      trailing: Text(
                        guest['status'].toUpperCase(),
                        style: TextStyle(
                          color: guest['status'] == 'confirmed' ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
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
            _buildInfoRow('Name', _selectedGuest!['name']),
            _buildInfoRow('Email', _selectedGuest!['email']),
            _buildInfoRow('Phone', _selectedGuest!['phone']),
            _buildInfoRow('Booking ID', _selectedGuest!['bookingId']),
            _buildInfoRow('Room', _selectedGuest!['roomNumber']),
            _buildInfoRow('Check-in Date', _selectedGuest!['checkIn']),
            _buildInfoRow('Check-out Date', _selectedGuest!['checkOut']),
          ],
        ),
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

  Widget _buildCheckInForm() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Check-in Details',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: AppFontWeights.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 16.h),
              
              // Room Number
              TextFormField(
                controller: _roomNumberController,
                decoration: InputDecoration(
                  labelText: 'Room Number',
                  prefixIcon: const Icon(Icons.room),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter room number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              
              // Check-in Date
              TextFormField(
                controller: _checkInDateController,
                decoration: InputDecoration(
                  labelText: 'Check-in Date',
                  prefixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                readOnly: true,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    _checkInDateController.text = 
                        '${date.day}/${date.month}/${date.year}';
                  }
                },
              ),
              SizedBox(height: 16.h),
              
              // Check-out Date
              TextFormField(
                controller: _checkOutDateController,
                decoration: InputDecoration(
                  labelText: 'Check-out Date',
                  prefixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                readOnly: true,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 1)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    _checkOutDateController.text = 
                        '${date.day}/${date.month}/${date.year}';
                  }
                },
              ),
              SizedBox(height: 16.h),
              
              // Payment Method
              DropdownButtonFormField<String>(
                value: _paymentMethodController.text.isEmpty ? null : _paymentMethodController.text,
                decoration: InputDecoration(
                  labelText: 'Payment Method',
                  prefixIcon: const Icon(Icons.payment),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'cash', child: Text('Cash')),
                  DropdownMenuItem(value: 'credit_card', child: Text('Credit Card')),
                  DropdownMenuItem(value: 'debit_card', child: Text('Debit Card')),
                ],
                onChanged: (value) {
                  _paymentMethodController.text = value ?? '';
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select payment method';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              
              // Special Requests
              TextFormField(
                controller: _specialRequestsController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Special Requests (Optional)',
                  prefixIcon: const Icon(Icons.note),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              
              // Check-in Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _processCheckIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary[600],
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
                        'Complete Check-in',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: AppFontWeights.semibold,
                        ),
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
