import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/theme.dart';
import '../models/enhanced_auth_models.dart';
import '../widgets/app_drawer.dart';

class HousekeeperDashboard extends ConsumerStatefulWidget {
  final EnhancedUser user;
  final LoginContext? loginContext;
  final String? selectedRole;
  
  const HousekeeperDashboard({
    super.key,
    required this.user,
    this.loginContext,
    this.selectedRole,
  });

  @override
  ConsumerState<HousekeeperDashboard> createState() => _HousekeeperDashboardState();
}

class _HousekeeperDashboardState extends ConsumerState<HousekeeperDashboard> {
  List<Map<String, dynamic>> _assignedRooms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAssignedRooms();
  }

  Future<void> _loadAssignedRooms() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate API call - replace with actual API
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock data
      setState(() {
        _assignedRooms = [
          {
            'id': '1',
            'roomNumber': '101',
            'floor': 1,
            'type': 'Deluxe Room',
            'status': 'cleaning',
            'assignedAt': '2024-01-15T10:00:00Z',
            'priority': 'high',
            'notes': 'Guest checked out, needs deep cleaning',
          },
          {
            'id': '2',
            'roomNumber': '205',
            'floor': 2,
            'type': 'Suite',
            'status': 'available',
            'assignedAt': '2024-01-15T09:30:00Z',
            'priority': 'medium',
            'notes': 'Regular cleaning required',
          },
          {
            'id': '3',
            'roomNumber': '301',
            'floor': 3,
            'type': 'Standard Room',
            'status': 'maintenance',
            'assignedAt': '2024-01-15T08:00:00Z',
            'priority': 'low',
            'notes': 'Minor maintenance needed',
          },
        ];
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load assigned rooms: $e'),
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

  Future<void> _updateRoomStatus(String roomId, String newStatus) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        _assignedRooms = _assignedRooms.map((room) {
          if (room['id'] == roomId) {
            return {...room, 'status': newStatus};
          }
          return room;
        }).toList();
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Room status updated to ${newStatus.replaceAll('_', ' ')}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update room status: $e'),
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
        title: const Text('Housekeeper Dashboard'),
        backgroundColor: AppColors.primary[600],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAssignedRooms,
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
          : _assignedRooms.isEmpty
              ? _buildEmptyState()
              : _buildRoomsList(),
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
              Icons.room_service,
              size: 64.sp,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 16.h),
            Text(
              'No Rooms Assigned',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: AppFontWeights.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'You don\'t have any rooms assigned to you at the moment.',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: _loadAssignedRooms,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
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

  Widget _buildRoomsList() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(),
          SizedBox(height: 20.h),
          
          // Rooms Grid
          _buildRoomsGrid(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
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
              Icons.cleaning_services,
              size: 32.sp,
              color: AppColors.primary[600],
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Assigned Rooms',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: AppFontWeights.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Manage and update status of rooms assigned to you',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColors.primary[600],
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Text(
                '${_assignedRooms.length} Rooms',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.sp,
                  fontWeight: AppFontWeights.semibold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 0.75,
      ),
      itemCount: _assignedRooms.length,
      itemBuilder: (context, index) {
        final room = _assignedRooms[index];
        return _buildRoomCard(room);
      },
    );
  }

  Widget _buildRoomCard(Map<String, dynamic> room) {
    final status = room['status'];
    final priority = room['priority'];
    
    Color statusColor;
    IconData statusIcon;
    
    switch (status) {
      case 'cleaning':
        statusColor = AppColors.orange[600]!;
        statusIcon = Icons.cleaning_services;
        break;
      case 'available':
        statusColor = AppColors.green[600]!;
        statusIcon = Icons.check_circle;
        break;
      case 'maintenance':
        statusColor = AppColors.red[600]!;
        statusIcon = Icons.build;
        break;
      default:
        statusColor = AppColors.grey[600]!;
        statusIcon = Icons.help;
    }

    Color priorityColor;
    switch (priority) {
      case 'high':
        priorityColor = Colors.red;
        break;
      case 'medium':
        priorityColor = Colors.orange;
        break;
      case 'low':
        priorityColor = Colors.green;
        break;
      default:
        priorityColor = Colors.grey;
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Room Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Room ${room['roomNumber']}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: AppFontWeights.bold,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  width: 6.w,
                  height: 6.h,
                  decoration: BoxDecoration(
                    color: priorityColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Text(
              '${room['type']} • Floor ${room['floor']}',
              style: TextStyle(
                fontSize: 10.sp,
                color: AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 8.h),
            
            // Status
            Row(
              children: [
                Icon(
                  statusIcon,
                  size: 12.sp,
                  color: statusColor,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: AppFontWeights.semibold,
                      color: statusColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 6.h),
            
            // Notes
            if (room['notes'] != null && room['notes'].isNotEmpty) ...[
              Text(
                'Notes:',
                style: TextStyle(
                  fontSize: 9.sp,
                  fontWeight: AppFontWeights.medium,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                room['notes'],
                style: TextStyle(
                  fontSize: 9.sp,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            
            const Spacer(),
            
            // Action Buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showStatusDialog(room),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary[600],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 6.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                ),
                child: Text(
                  'Update',
                  style: TextStyle(fontSize: 10.sp),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStatusDialog(Map<String, dynamic> room) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Room ${room['roomNumber']} Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Current status: ${room['status']}'),
            SizedBox(height: 16.h),
            Text('Select new status:'),
            SizedBox(height: 16.h),
            ...['cleaning', 'available', 'maintenance'].map((status) => 
              ListTile(
                title: Text(status.toUpperCase()),
                leading: Radio<String>(
                  value: status,
                  groupValue: room['status'],
                  onChanged: (value) {
                    if (value != null) {
                      _updateRoomStatus(room['id'], value);
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
