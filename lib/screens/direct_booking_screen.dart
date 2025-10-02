import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/enhanced_auth_models.dart';
import '../models/direct_booking_models.dart';
import '../services/direct_booking_api_service.dart';
import '../constants/theme.dart';
import '../widgets/app_drawer.dart';

class DirectBookingScreen extends ConsumerStatefulWidget {
  final EnhancedUser user;
  final LoginContext? loginContext;
  final String? selectedRole;
  
  const DirectBookingScreen({
    super.key,
    required this.user,
    this.loginContext,
    this.selectedRole,
  });

  @override
  ConsumerState<DirectBookingScreen> createState() => _DirectBookingScreenState();
}

class _DirectBookingScreenState extends ConsumerState<DirectBookingScreen> {
  DirectBookingConfig? _config;
  // DirectBookingStatus? _status; // Will be used for status display in future
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isTesting = false;
  String? _errorMessage;
  bool _hasUnsavedChanges = false;

  // Form controllers
  final _versionNumberController = TextEditingController();
  final _developerIdController = TextEditingController();
  final _deviceIpController = TextEditingController();
  final _secretApiKeyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDirectBookingData();
  }

  @override
  void dispose() {
    _versionNumberController.dispose();
    _developerIdController.dispose();
    _deviceIpController.dispose();
    _secretApiKeyController.dispose();
    super.dispose();
  }

  Future<void> _loadDirectBookingData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      print('🔄 Loading direct booking data...');
      final config = await DirectBookingApiService.getDirectBookingConfig();
      print('✅ Direct booking data loaded successfully');

      setState(() {
        _config = config;
        _populateForm(config);
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading direct booking data: $e');
      setState(() {
        _errorMessage = 'Failed to load direct booking data: $e';
        _isLoading = false;
      });
    }
  }

  void _populateForm(DirectBookingConfig config) {
    _versionNumberController.text = config.versionNumber;
    _developerIdController.text = config.developerId;
    _deviceIpController.text = config.deviceIp;
    _secretApiKeyController.text = config.secretApiKey;
    
    setState(() {
      _hasUnsavedChanges = false;
    });
  }

  void _markAsChanged() {
    if (!_hasUnsavedChanges) {
      setState(() {
        _hasUnsavedChanges = true;
      });
    }
  }

  Future<void> _saveConfiguration() async {
    try {
      setState(() {
        _isSaving = true;
      });

      print('💾 Saving direct booking configuration...');
      
      final request = DirectBookingUpdateRequest(
        versionNumber: _versionNumberController.text,
        developerId: _developerIdController.text,
        deviceIp: _deviceIpController.text,
        secretApiKey: _secretApiKeyController.text,
      );

      final updatedConfig = await DirectBookingApiService.updateDirectBookingConfig(request: request);
      
      setState(() {
        _config = updatedConfig;
        _hasUnsavedChanges = false;
        _isSaving = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Configuration saved successfully!'),
            backgroundColor: AppColors.green[600],
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('❌ Error saving configuration: $e');
      setState(() {
        _isSaving = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save configuration: $e'),
            backgroundColor: AppColors.red[600],
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _testConfiguration() async {
    try {
      setState(() {
        _isTesting = true;
      });

      print('🧪 Testing direct booking configuration...');
      
      final request = DirectBookingUpdateRequest(
        versionNumber: _versionNumberController.text,
        developerId: _developerIdController.text,
        deviceIp: _deviceIpController.text,
        secretApiKey: _secretApiKeyController.text,
      );

      final testStatus = await DirectBookingApiService.testDirectBookingConfig(request: request);
      
      setState(() {
        _isTesting = false;
      });

      if (mounted) {
        final message = testStatus.hasValidCredentials 
            ? 'Configuration test successful!'
            : 'Configuration test failed: ${testStatus.lastTestResult}';
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: testStatus.hasValidCredentials 
                ? AppColors.green[600] 
                : AppColors.red[600],
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('❌ Error testing configuration: $e');
      setState(() {
        _isTesting = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to test configuration: $e'),
            backgroundColor: AppColors.red[600],
            duration: const Duration(seconds: 3),
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
        title: const Text('Direct Booking'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_hasUnsavedChanges)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _isSaving ? null : _saveConfiguration,
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
          : _errorMessage != null
              ? _buildErrorWidget()
              : _buildDirectBookingContent(),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.red[300],
          ),
          SizedBox(height: 16.h),
          Text(
            'Failed to load direct booking data',
            style: TextStyle(
              fontSize: 18.sp,
              color: AppColors.red[600],
              fontWeight: AppFontWeights.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            _errorMessage ?? 'Unknown error',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: _loadDirectBookingData,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blue[600],
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDirectBookingContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(),
          SizedBox(height: 20.h),

          // Default Credentials Card
          _buildDefaultCredentialsCard(),
          SizedBox(height: 20.h),

          // Current Configuration
          _buildCurrentConfigurationCard(),
          SizedBox(height: 20.h),

          // General Settings
          _buildGeneralSettingsCard(),
          SizedBox(height: 20.h),

          // Test Configuration Button
          _buildTestButton(),
          SizedBox(height: 20.h),
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
              AppColors.blue[50]!,
              AppColors.blue[100]!,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.payment,
                  size: 28.w,
                  color: AppColors.blue[600],
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Global Payments Configuration',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: AppFontWeights.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Configure your Global Payments integration for secure payment processing.',
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
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultCredentialsCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 24.w,
                  color: AppColors.orange[600],
                ),
                SizedBox(width: 12.w),
                Text(
                  'Using Default Credentials',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: AppFontWeights.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              DirectBookingConstants.usingDefaultMessage,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.orange[50],
                border: Border.all(color: AppColors.orange[200]!),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DirectBookingConstants.defaultStatusMessage,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: AppFontWeights.bold,
                      color: AppColors.orange[800],
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    DirectBookingConstants.defaultStatusSubtext,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.orange[700],
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

  Widget _buildCurrentConfigurationCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Configuration',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: AppFontWeights.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 16.h),
            _buildConfigRow('Version Number', _config?.versionNumber.isNotEmpty == true ? _config!.versionNumber : 'Not configured'),
            _buildConfigRow('Developer ID', _config?.developerId.isNotEmpty == true ? _config!.developerId : 'Not configured'),
            _buildConfigRow('Device IP', _config?.deviceIp.isNotEmpty == true ? _config!.deviceIp : 'Not configured'),
            _buildConfigRow('Secret API Key', _config?.secretApiKey.isNotEmpty == true ? '••••••••••••••••' : 'Not configured'),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigRow(String label, String value) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.gray[200]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textPrimary,
                fontWeight: AppFontWeights.medium,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralSettingsCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'General Settings',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: AppFontWeights.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 20.h),
            
            // Secret API Key
            _buildInputField(
              controller: _secretApiKeyController,
              field: DirectBookingConstants.configFields[0],
            ),
            SizedBox(height: 16.h),
            
            // Version Number
            _buildInputField(
              controller: _versionNumberController,
              field: DirectBookingConstants.configFields[1],
            ),
            SizedBox(height: 16.h),
            
            // Developer ID
            _buildInputField(
              controller: _developerIdController,
              field: DirectBookingConstants.configFields[2],
            ),
            SizedBox(height: 16.h),
            
            // Device IP
            _buildInputField(
              controller: _deviceIpController,
              field: DirectBookingConstants.configFields[3],
            ),
            SizedBox(height: 24.h),
            
            // Save Section
            _buildSaveSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required ConfigField field,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          field.label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: AppFontWeights.medium,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          obscureText: field.isSecure,
          onChanged: (_) => _markAsChanged(),
          decoration: InputDecoration(
            hintText: field.placeholder,
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
              borderSide: BorderSide(color: AppColors.blue[500]!),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          ),
        ),
        if (field.hint.isNotEmpty) ...[
          SizedBox(height: 4.h),
          Text(
            field.hint,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSaveSection() {
    return Column(
      children: [
        Text(
          _hasUnsavedChanges ? 'You have unsaved changes' : 'No changes to save',
          style: TextStyle(
            fontSize: 14.sp,
            color: _hasUnsavedChanges ? AppColors.orange[600] : AppColors.textSecondary,
            fontWeight: _hasUnsavedChanges ? AppFontWeights.medium : AppFontWeights.regular,
          ),
        ),
        SizedBox(height: 16.h),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isSaving ? null : _saveConfiguration,
            icon: _isSaving 
                ? SizedBox(
                    width: 16.w,
                    height: 16.h,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.save),
            label: Text(_isSaving ? 'Saving...' : 'Save Configuration'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blue[600],
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTestButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _isTesting ? null : _testConfiguration,
        icon: _isTesting 
            ? SizedBox(
                width: 16.w,
                height: 16.h,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              )
            : const Icon(Icons.science),
        label: Text(_isTesting ? 'Testing...' : 'Test Configuration'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.blue[600],
          side: BorderSide(color: AppColors.blue[600]!),
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
      ),
    );
  }
}
