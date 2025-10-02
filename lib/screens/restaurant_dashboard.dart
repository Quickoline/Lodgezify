import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/theme.dart';
import '../models/enhanced_auth_models.dart';
import '../widgets/app_drawer.dart';

class RestaurantDashboard extends ConsumerStatefulWidget {
  final EnhancedUser user;
  final LoginContext? loginContext;
  final String? selectedRole;
  
  const RestaurantDashboard({
    super.key,
    required this.user,
    this.loginContext,
    this.selectedRole,
  });

  @override
  ConsumerState<RestaurantDashboard> createState() => _RestaurantDashboardState();
}

class _RestaurantDashboardState extends ConsumerState<RestaurantDashboard> {
  int _selectedIndex = 0;
  List<Map<String, dynamic>> _orders = [];
  List<Map<String, dynamic>> _tables = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate API call - replace with actual API
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock data
      setState(() {
        _orders = [
          {
            'id': '1',
            'tableNumber': '5',
            'customerName': 'John Doe',
            'items': [
              {'name': 'Chicken Burger', 'quantity': 2, 'price': 15.99},
              {'name': 'French Fries', 'quantity': 1, 'price': 8.99},
            ],
            'total': 40.97,
            'status': 'pending',
            'orderTime': '2024-01-15T12:30:00Z',
          },
          {
            'id': '2',
            'tableNumber': '3',
            'customerName': 'Jane Smith',
            'items': [
              {'name': 'Caesar Salad', 'quantity': 1, 'price': 12.99},
              {'name': 'Coca Cola', 'quantity': 2, 'price': 3.99},
            ],
            'total': 20.97,
            'status': 'preparing',
            'orderTime': '2024-01-15T12:15:00Z',
          },
        ];

        _tables = [
          {'number': '1', 'status': 'available', 'capacity': 4},
          {'number': '2', 'status': 'occupied', 'capacity': 2, 'customer': 'Mike Johnson'},
          {'number': '3', 'status': 'occupied', 'capacity': 4, 'customer': 'Jane Smith'},
          {'number': '4', 'status': 'reserved', 'capacity': 6, 'customer': 'Reserved for 7 PM'},
          {'number': '5', 'status': 'occupied', 'capacity': 2, 'customer': 'John Doe'},
          {'number': '6', 'status': 'available', 'capacity': 4},
        ];
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load data: $e'),
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

  Future<void> _updateOrderStatus(String orderId, String newStatus) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        _orders = _orders.map((order) {
          if (order['id'] == orderId) {
            return {...order, 'status': newStatus};
          }
          return order;
        }).toList();
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order status updated to ${newStatus.replaceAll('_', ' ')}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update order status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        backgroundColor: AppColors.primary[600],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      drawer: AppDrawer(
        user: widget.user,
        loginContext: widget.loginContext,
        selectedRole: widget.selectedRole,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildSelectedScreen(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: AppColors.primary[600],
        unselectedItemColor: AppColors.textSecondary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.table_restaurant),
            label: 'Tables',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
        ],
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Restaurant Dashboard';
      case 1:
        return 'Active Orders';
      case 2:
        return 'Table Management';
      case 3:
        return 'Order History';
      default:
        return 'Restaurant';
    }
  }

  Widget _buildSelectedScreen() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboard();
      case 1:
        return _buildOrdersScreen();
      case 2:
        return _buildTablesScreen();
      case 3:
        return _buildHistoryScreen();
      default:
        return _buildDashboard();
    }
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section
          _buildWelcomeSection(),
          SizedBox(height: 20.h),
          
          // Quick Stats
          _buildQuickStats(),
          SizedBox(height: 20.h),
          
          // Recent Orders
          _buildRecentOrders(),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Card(
      elevation: 2,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          gradient: LinearGradient(
            colors: [
              AppColors.primary[600]!.withOpacity(0.1),
              AppColors.primary[600]!.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.restaurant,
              size: 32.sp,
              color: AppColors.primary[600],
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Restaurant Management',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: AppFontWeights.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Manage orders, tables, and restaurant operations efficiently.',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    final pendingOrders = _orders.where((order) => order['status'] == 'pending').length;
    final preparingOrders = _orders.where((order) => order['status'] == 'preparing').length;
    final occupiedTables = _tables.where((table) => table['status'] == 'occupied').length;
    final availableTables = _tables.where((table) => table['status'] == 'available').length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today\'s Overview',
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
              child: _buildStatCard(
                'Pending Orders',
                pendingOrders.toString(),
                Icons.pending,
                AppColors.orange[600]!,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildStatCard(
                'Preparing',
                preparingOrders.toString(),
                Icons.restaurant_menu,
                AppColors.blue[600]!,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Occupied Tables',
                occupiedTables.toString(),
                Icons.table_restaurant,
                AppColors.red[600]!,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildStatCard(
                'Available Tables',
                availableTables.toString(),
                Icons.event_available,
                AppColors.green[600]!,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            Icon(
              icon,
              size: 24.sp,
              color: color,
            ),
            SizedBox(height: 8.h),
            Text(
              value,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: AppFontWeights.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentOrders() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Orders',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: AppFontWeights.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12.h),
        ..._orders.take(3).map((order) => _buildOrderCard(order)),
      ],
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    Color statusColor;
    switch (order['status']) {
      case 'pending':
        statusColor = AppColors.orange[600]!;
        break;
      case 'preparing':
        statusColor = AppColors.blue[600]!;
        break;
      case 'ready':
        statusColor = AppColors.green[600]!;
        break;
      default:
        statusColor = AppColors.grey[600]!;
    }

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
                  'Order #${order['id']}',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: AppFontWeights.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    order['status'].toUpperCase(),
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: AppFontWeights.semibold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              'Table ${order['tableNumber']} • ${order['customerName']}',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Total: \$${order['total'].toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: AppFontWeights.semibold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersScreen() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: _orders.map((order) => _buildDetailedOrderCard(order)).toList(),
      ),
    );
  }

  Widget _buildDetailedOrderCard(Map<String, dynamic> order) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${order['id']}',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: AppFontWeights.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Table ${order['tableNumber']}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              'Customer: ${order['customerName']}',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 12.h),
            
            // Order Items
            Text(
              'Items:',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: AppFontWeights.semibold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            ...order['items'].map<Widget>((item) => Padding(
              padding: EdgeInsets.symmetric(vertical: 2.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${item['quantity']}x ${item['name']}',
                    style: TextStyle(fontSize: 14.sp),
                  ),
                  Text(
                    '\$${(item['price'] * item['quantity']).toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: AppFontWeights.medium,
                    ),
                  ),
                ],
              ),
            )),
            
            const Divider(),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total:',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: AppFontWeights.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '\$${order['total'].toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: AppFontWeights.bold,
                    color: AppColors.primary[600],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            
            // Status Update Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _updateOrderStatus(order['id'], 'preparing'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blue[600],
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Start Preparing'),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _updateOrderStatus(order['id'], 'ready'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green[600],
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Mark Ready'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTablesScreen() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Table Status',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: AppFontWeights.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: 1.2,
            ),
            itemCount: _tables.length,
            itemBuilder: (context, index) {
              final table = _tables[index];
              return _buildTableCard(table);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTableCard(Map<String, dynamic> table) {
    Color statusColor;
    IconData statusIcon;
    
    switch (table['status']) {
      case 'available':
        statusColor = AppColors.green[600]!;
        statusIcon = Icons.check_circle;
        break;
      case 'occupied':
        statusColor = AppColors.red[600]!;
        statusIcon = Icons.person;
        break;
      case 'reserved':
        statusColor = AppColors.orange[600]!;
        statusIcon = Icons.schedule;
        break;
      default:
        statusColor = AppColors.grey[600]!;
        statusIcon = Icons.help;
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              statusIcon,
              size: 32.sp,
              color: statusColor,
            ),
            SizedBox(height: 8.h),
            Text(
              'Table ${table['number']}',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: AppFontWeights.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              'Capacity: ${table['capacity']}',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              table['status'].toUpperCase(),
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: AppFontWeights.semibold,
                color: statusColor,
              ),
            ),
            if (table['customer'] != null) ...[
              SizedBox(height: 4.h),
              Text(
                table['customer'],
                style: TextStyle(
                  fontSize: 10.sp,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryScreen() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64.sp,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 16.h),
            Text(
              'Order History',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: AppFontWeights.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'View completed orders and sales history',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Order history feature coming soon!')),
                );
              },
              icon: const Icon(Icons.history),
              label: const Text('View History'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary[600],
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
