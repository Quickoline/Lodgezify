import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/staff_models.dart';
import '../models/enhanced_auth_models.dart';
import '../services/staff_api_service.dart';
import '../constants/theme.dart';

class StaffScreen extends ConsumerStatefulWidget {
  final EnhancedUser user;
  final LoginContext? loginContext;
  final String? selectedRole;
  
  const StaffScreen({
    super.key,
    required this.user,
    this.loginContext,
    this.selectedRole,
  });

  @override
  ConsumerState<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends ConsumerState<StaffScreen> {
  StaffData? staffData;
  bool isLoading = true;
  String? errorMessage;
  String searchQuery = '';
  
  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedRole = '';
  List<String> _selectedPermissions = [];
  bool _isFormLoading = false;
  String? _formSuccess;
  String? _formError;

  @override
  void initState() {
    super.initState();
    _loadStaffData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadStaffData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      print('🔄 Loading staff data...');
      final data = await StaffApiService.getStaffData();
      print('✅ Staff data loaded successfully');
      print('👥 Total staff: ${data.totalCount}');
      print('✅ Active staff: ${data.activeCount}');
      print('❌ Inactive staff: ${data.inactiveCount}');

      setState(() {
        staffData = data;
        isLoading = false;
      });
    } catch (e) {
      print('❌ Staff loading error: $e');
      setState(() {
        errorMessage = 'Failed to load staff data: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _createStaff() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRole.isEmpty) {
      setState(() {
        _formError = 'Please select a role';
      });
      return;
    }
    if (_selectedPermissions.isEmpty) {
      setState(() {
        _formError = 'Please select at least one permission';
      });
      return;
    }

    setState(() {
      _isFormLoading = true;
      _formError = null;
      _formSuccess = null;
    });

    try {
      final request = StaffCreateRequest(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        role: _selectedRole,
        permissions: _selectedPermissions,
      );

      final success = await StaffApiService.createStaff(request);
      
      if (success) {
        setState(() {
          _formSuccess = 'Staff member created successfully! Credentials have been sent to ${_emailController.text.trim()}';
          _clearForm();
        });
        _loadStaffData(); // Refresh the list
        
        // Clear success message after 5 seconds
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted) {
            setState(() {
              _formSuccess = null;
            });
          }
        });
      } else {
        setState(() {
          _formError = 'Failed to create staff member. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _formError = 'Error creating staff: $e';
      });
    } finally {
      setState(() {
        _isFormLoading = false;
      });
    }
  }

  void _clearForm() {
    _nameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _selectedRole = '';
    _selectedPermissions.clear();
  }

  void _togglePermission(String permission) {
    setState(() {
      if (_selectedPermissions.contains(permission)) {
        _selectedPermissions.remove(permission);
      } else {
        _selectedPermissions.add(permission);
      }
    });
  }

  List<StaffMember> get _filteredStaff {
    if (staffData == null) return [];
    if (searchQuery.isEmpty) return staffData!.staff;
    
    return staffData!.staff.where((member) {
      final query = searchQuery.toLowerCase();
      return member.name.toLowerCase().contains(query) ||
             member.email.toLowerCase().contains(query) ||
             member.role.toLowerCase().contains(query);
    }).toList();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return AppColors.green[600]!;
      case 'inactive':
        return AppColors.gray[500]!;
      default:
        return AppColors.gray[400]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Staff Management'),
        backgroundColor: AppColors.secondary[600],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStaffData,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? _buildErrorWidget()
              : _buildStaffContent(),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64.sp,
            color: AppColors.red[300],
          ),
          SizedBox(height: 16.h),
          Text(
            'Failed to load staff data',
            style: TextStyle(
              fontSize: 18.sp,
              color: AppColors.red[600],
              fontWeight: AppFontWeights.semibold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            errorMessage ?? 'Unknown error',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: _loadStaffData,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary[600],
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffContent() {
    return RefreshIndicator(
      onRefresh: _loadStaffData,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(),
            SizedBox(height: 20.h),

            // Search Bar
            _buildSearchBar(),
            SizedBox(height: 20.h),

            // Staff Creation Form
            _buildStaffForm(),
            SizedBox(height: 20.h),

            // Staff Stats
            _buildStaffStats(),
            SizedBox(height: 20.h),

            // Staff List
            _buildStaffList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      elevation: 2,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          gradient: LinearGradient(
            colors: [
              AppColors.secondary[50]!,
              AppColors.secondary[100]!,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.people,
              size: 28.w,
              color: AppColors.secondary[600],
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Staff Management',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: AppFontWeights.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Manage your hotel staff members and their roles',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Card(
      elevation: 1,
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: TextField(
          onChanged: (value) {
            setState(() {
              searchQuery = value;
            });
          },
          decoration: InputDecoration(
            hintText: 'Search staff...',
            prefixIcon: const Icon(Icons.search),
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
              borderSide: BorderSide(color: AppColors.secondary[500]!),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          ),
        ),
      ),
    );
  }

  Widget _buildStaffForm() {
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
                'Add New Staff',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: AppFontWeights.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 16.h),

              // Name and Email - Stack vertically for mobile
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12.h),

              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter valid email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12.h),

              // Phone and Role - Stack vertically for mobile
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Phone',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter phone';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12.h),


              DropdownButtonFormField<String>(
                value: _selectedRole.isEmpty ? null : _selectedRole,
                decoration: InputDecoration(
                  labelText: 'Role',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                items: StaffConstants.roleOptions.map((role) {
                  return DropdownMenuItem(
                    value: role.value,
                    child: Text(
                      role.label,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedRole = value ?? '';
                  });
                },
              ),
              SizedBox(height: 16.h),

              // Permissions
              Text(
                'Permissions',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: AppFontWeights.semibold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColors.gray[50],
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: AppColors.gray[200]!),
                ),
                child: Wrap(
                  spacing: 6.w,
                  runSpacing: 6.h,
                  children: StaffConstants.permissionOptions.map((permission) {
                    final isSelected = _selectedPermissions.contains(permission.value);
                    return FilterChip(
                      label: Text(
                        permission.label,
                        style: TextStyle(fontSize: 12.sp),
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        _togglePermission(permission.value);
                      },
                      selectedColor: AppColors.secondary[100],
                      checkmarkColor: AppColors.secondary[600],
                      backgroundColor: Colors.white,
                      side: BorderSide(
                        color: isSelected ? AppColors.secondary[300]! : AppColors.gray[300]!,
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 16.h),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isFormLoading ? null : _createStaff,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary[600],
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: _isFormLoading
                      ? SizedBox(
                          height: 20.h,
                          width: 20.w,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Create Staff',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: AppFontWeights.semibold,
                          ),
                        ),
                ),
              ),

              // Form Messages
              if (_formSuccess != null) ...[
                SizedBox(height: 12.h),
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColors.green[50],
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: AppColors.green[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: AppColors.green[600], size: 20.w),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          _formSuccess!,
                          style: TextStyle(
                            color: AppColors.green[700],
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              if (_formError != null) ...[
                SizedBox(height: 12.h),
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColors.red[50],
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: AppColors.red[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: AppColors.red[600], size: 20.w),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          _formError!,
                          style: TextStyle(
                            color: AppColors.red[700],
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStaffStats() {
    if (staffData == null) return const SizedBox();

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Staff',
            staffData!.totalCount.toString(),
            Icons.people,
            AppColors.blue[600]!,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildStatCard(
            'Active',
            staffData!.activeCount.toString(),
            Icons.check_circle,
            AppColors.green[600]!,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildStatCard(
            'Inactive',
            staffData!.inactiveCount.toString(),
            Icons.cancel,
            AppColors.red[600]!,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24.w),
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

  Widget _buildStaffList() {
    if (staffData == null) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Staff Members',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: AppFontWeights.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppColors.secondary[100],
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                '${_filteredStaff.length} members',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.secondary[600],
                  fontWeight: AppFontWeights.medium,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        if (_filteredStaff.isEmpty)
          Card(
            elevation: 1,
            child: Container(
              padding: EdgeInsets.all(24.w),
              child: Column(
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 48.w,
                    color: AppColors.gray[400],
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'No staff members found',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: AppColors.textSecondary,
                      fontWeight: AppFontWeights.medium,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Try adjusting your search or add new staff members',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          Column(
            children: _filteredStaff.map((member) => _buildStaffItem(member)).toList(),
          ),
      ],
    );
  }

  Widget _buildStaffItem(StaffMember member) {
    return Card(
      margin: EdgeInsets.only(bottom: 8.h),
      elevation: 1,
      child: Container(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20.r,
                  backgroundColor: AppColors.secondary[100],
                  child: Text(
                    member.name[0].toUpperCase(),
                    style: TextStyle(
                      color: AppColors.secondary[600],
                      fontWeight: AppFontWeights.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.name,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: AppFontWeights.semibold,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        StaffConstants.getRoleLabel(member.role),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: _getStatusColor(member.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    member.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: AppFontWeights.bold,
                      color: _getStatusColor(member.status),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            
            // Contact Information
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.email, size: 14.w, color: AppColors.textSecondary),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          member.email,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.phone, size: 14.w, color: AppColors.textSecondary),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          member.phone,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Permissions
            if (member.permissions.isNotEmpty) ...[
              SizedBox(height: 12.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.gray[50],
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(color: AppColors.gray[200]!),
                ),
                child: Wrap(
                  spacing: 4.w,
                  runSpacing: 4.h,
                  children: member.permissions.map((permission) {
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: AppColors.secondary[50],
                        borderRadius: BorderRadius.circular(4.r),
                        border: Border.all(color: AppColors.secondary[200]!),
                      ),
                      child: Text(
                        StaffConstants.getPermissionLabel(permission),
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: AppColors.secondary[600],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
