import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/theme.dart';
import '../models/enhanced_auth_models.dart';
import '../widgets/app_drawer.dart';

class GuestHistoryScreen extends ConsumerStatefulWidget {
  final EnhancedUser user;
  final LoginContext? loginContext;
  final String? selectedRole;
  
  const GuestHistoryScreen({
    super.key,
    required this.user,
    this.loginContext,
    this.selectedRole,
  });

  @override
  ConsumerState<GuestHistoryScreen> createState() => _GuestHistoryScreenState();
}

class _GuestHistoryScreenState extends ConsumerState<GuestHistoryScreen> with TickerProviderStateMixin {
  final _searchController = TextEditingController();
  bool _isLoading = false;
  bool _isSearching = false;
  List<Map<String, dynamic>> _searchResults = [];
  Map<String, dynamic>? _selectedGuest;
  List<Map<String, dynamic>> _stayHistory = [];
  List<Map<String, dynamic>> _billingHistory = [];
  List<Map<String, dynamic>> _guestNotes = [];
  bool _showSearchResults = false;
  int _selectedTabIndex = 0;

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
      
      // Mock search results
      setState(() {
        _searchResults = [
          {
            'id': '1',
            'name': 'John Doe',
            'email': 'john.doe@email.com',
            'phone': '+1234567890',
            'memberSince': '2023-01-15',
            'loyaltyStatus': 'Gold',
            'loyaltyPoints': 2500,
            'preferences': ['Non-smoking', 'High floor', 'King bed'],
          },
          {
            'id': '2',
            'name': 'Jane Smith',
            'email': 'jane.smith@email.com',
            'phone': '+1234567891',
            'memberSince': '2022-06-20',
            'loyaltyStatus': 'Platinum',
            'loyaltyPoints': 5000,
            'preferences': ['Ocean view', 'Late checkout', 'Room service'],
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
    });

    _loadGuestHistory(guest['id']);
  }

  Future<void> _loadGuestHistory(String guestId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate API call - replace with actual API
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock data
      setState(() {
        _stayHistory = [
          {
            'id': '1',
            'checkIn': 'Jan 15, 2024',
            'checkOut': 'Jan 17, 2024',
            'nights': 2,
            'room': '101',
            'roomType': 'Deluxe Room',
            'totalSpent': 350.00,
            'tags': ['Current Stay', 'Room Service'],
          },
          {
            'id': '2',
            'checkIn': 'Dec 20, 2023',
            'checkOut': 'Dec 22, 2023',
            'nights': 2,
            'room': '205',
            'roomType': 'Suite',
            'totalSpent': 500.00,
            'tags': ['Completed'],
          },
        ];

        _billingHistory = [
          {
            'id': '1',
            'description': 'Room Charge - Deluxe Room',
            'category': 'Room #101',
            'date': 'Jan 15, 2024',
            'paymentMethod': 'Card ending in 1234',
            'amount': 300.00,
          },
          {
            'id': '2',
            'description': 'Room Service Charge',
            'category': 'Room #101',
            'date': 'Jan 15, 2024',
            'paymentMethod': 'Room Charge',
            'amount': 50.00,
          },
        ];

        _guestNotes = [
          {
            'id': '1',
            'title': 'Special Request',
            'content': 'Guest requested late checkout and extra towels',
            'date': 'Jan 15, 2024',
            'staff': 'Front Desk Staff',
          },
          {
            'id': '2',
            'title': 'Dietary Requirements',
            'content': 'Vegetarian meals only, no dairy products',
            'date': 'Jan 15, 2024',
            'staff': 'Restaurant Manager',
          },
        ];
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load guest history: $e'),
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

  void _clearSearch() {
    setState(() {
      _selectedGuest = null;
      _stayHistory.clear();
      _billingHistory.clear();
      _guestNotes.clear();
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
        title: const Text('Guest History'),
        backgroundColor: AppColors.primary[600],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _clearSearch,
          ),
        ],
      ),
      drawer: AppDrawer(
        user: widget.user,
        loginContext: widget.loginContext,
        selectedRole: widget.selectedRole,
      ),
      body: _selectedGuest == null ? _buildSearchSection() : _buildGuestDetails(),
    );
  }

  Widget _buildSearchSection() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Card(
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
              Text(
                'Search by name, email, phone, or ID',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Enter name, email, phone, or ID',
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
                SizedBox(height: 16.h),
                Container(
                  constraints: BoxConstraints(maxHeight: 300.h),
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
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary[100],
                          child: Text(
                            guest['name'][0],
                            style: TextStyle(
                              color: AppColors.primary[600],
                              fontWeight: AppFontWeights.bold,
                            ),
                          ),
                        ),
                        title: Text(guest['name']),
                        subtitle: Text('${guest['email']} • ${guest['phone']}'),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              guest['loyaltyStatus'],
                              style: TextStyle(
                                color: AppColors.primary[600],
                                fontWeight: AppFontWeights.bold,
                                fontSize: 12.sp,
                              ),
                            ),
                            Text(
                              '${guest['loyaltyPoints']} pts',
                              style: TextStyle(
                                color: AppColors.textSecondary,
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
      ),
    );
  }

  Widget _buildGuestDetails() {
    return Column(
      children: [
        // Guest Info Header
        Container(
          padding: EdgeInsets.all(16.w),
          color: AppColors.primary[600],
          child: Row(
            children: [
              CircleAvatar(
                radius: 24.r,
                backgroundColor: Colors.white,
                child: Text(
                  _selectedGuest!['name'][0],
                  style: TextStyle(
                    color: AppColors.primary[600],
                    fontWeight: AppFontWeights.bold,
                    fontSize: 18.sp,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedGuest!['name'],
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: AppFontWeights.bold,
                      ),
                    ),
                    Text(
                      _selectedGuest!['email'],
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: _clearSearch,
              ),
            ],
          ),
        ),
        
        // Tab Bar
        Container(
          color: Colors.white,
          child: TabBar(
            controller: TabController(length: 3, vsync: this, initialIndex: _selectedTabIndex),
            onTap: (index) => setState(() => _selectedTabIndex = index),
            labelColor: AppColors.primary[600],
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary[600],
            tabs: const [
              Tab(text: 'Stay History'),
              Tab(text: 'Billing'),
              Tab(text: 'Notes'),
            ],
          ),
        ),
        
        // Tab Content
        Expanded(
          child: _isLoading 
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                controller: TabController(length: 3, vsync: this, initialIndex: _selectedTabIndex),
                children: [
                  _buildStayHistoryTab(),
                  _buildBillingHistoryTab(),
                  _buildNotesTab(),
                ],
              ),
        ),
      ],
    );
  }

  Widget _buildStayHistoryTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Previous Stays (${_stayHistory.length})',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: AppFontWeights.semibold,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.filter_list),
                label: const Text('Filter'),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ..._stayHistory.map((stay) => _buildStayCard(stay)),
        ],
      ),
    );
  }

  Widget _buildStayCard(Map<String, dynamic> stay) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${stay['checkIn']} - ${stay['checkOut']}',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: AppFontWeights.semibold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '\$${stay['totalSpent'].toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: AppFontWeights.bold,
                    color: AppColors.primary[600],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              '${stay['nights']} nights • Room ${stay['room']} • ${stay['roomType']}',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 8.w,
              children: stay['tags'].map<Widget>((tag) => Chip(
                label: Text(tag),
                backgroundColor: AppColors.primary[100],
                labelStyle: TextStyle(
                  color: AppColors.primary[600],
                  fontSize: 12.sp,
                ),
              )).toList(),
            ),
            SizedBox(height: 12.h),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                child: const Text('View Details'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillingHistoryTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Billing History',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: AppFontWeights.semibold,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.download),
                label: const Text('Export'),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Card(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8.r),
                      topRight: Radius.circular(8.r),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(flex: 2, child: Text('Description', style: TextStyle(fontWeight: AppFontWeights.semibold))),
                      Expanded(child: Text('Date', style: TextStyle(fontWeight: AppFontWeights.semibold))),
                      Expanded(child: Text('Method', style: TextStyle(fontWeight: AppFontWeights.semibold))),
                      Expanded(child: Text('Amount', style: TextStyle(fontWeight: AppFontWeights.semibold), textAlign: TextAlign.end)),
                    ],
                  ),
                ),
                ..._billingHistory.map((item) => Padding(
                  padding: EdgeInsets.all(12.w),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item['description'], style: TextStyle(fontWeight: AppFontWeights.medium)),
                            Text(item['category'], style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      Expanded(child: Text(item['date'])),
                      Expanded(child: Text(item['paymentMethod'])),
                      Expanded(
                        child: Text(
                          '\$${item['amount'].toStringAsFixed(2)}',
                          style: TextStyle(fontWeight: AppFontWeights.medium),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Special Requests & Notes',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: AppFontWeights.semibold,
                  color: AppColors.textPrimary,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add),
                label: const Text('Add Note'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary[600],
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ..._guestNotes.map((note) => Card(
            margin: EdgeInsets.only(bottom: 12.h),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        note['title'],
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: AppFontWeights.semibold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        note['date'],
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    note['content'],
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Added by: ${note['staff']}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }
}
