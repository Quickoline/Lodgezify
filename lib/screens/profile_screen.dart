import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/enhanced_auth_models.dart';
import '../models/profile_models.dart';
import '../services/profile_api_service.dart';
import '../constants/theme.dart';
import '../widgets/app_drawer.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final EnhancedUser user;
  final LoginContext? loginContext;
  final String? selectedRole;
  
  const ProfileScreen({
    super.key,
    required this.user,
    this.loginContext,
    this.selectedRole,
  });

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  HotelProfile? _profile;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;
  bool _hasUnsavedChanges = false;

  // Form controllers
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _websiteController = TextEditingController();
  final _cancellationController = TextEditingController();

  // Form state
  String _selectedCategory = 'luxury';
  int _starRating = 5;
  List<String> _selectedAmenities = [];
  String _checkInTime = '15:00';
  String _checkOutTime = '11:00';
  List<String> _images = [];
  final List<File> _imageFiles = [];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _cancellationController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      print('🔄 Loading hotel profile...');
      final profile = await ProfileApiService.getHotelProfile();
      print('✅ Profile loaded successfully');

      setState(() {
        _profile = profile;
        _populateForm(profile);
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading profile: $e');
      setState(() {
        _errorMessage = 'Failed to load profile: $e';
        _isLoading = false;
      });
    }
  }

  void _populateForm(HotelProfile profile) {
    _nameController.text = profile.name;
    _descriptionController.text = profile.description;
    _addressController.text = profile.address;
    _phoneController.text = profile.contactInfo.phone;
    _emailController.text = profile.contactInfo.email;
    _websiteController.text = profile.contactInfo.website;
    _cancellationController.text = profile.policies.cancellation;
    
    setState(() {
      _selectedCategory = profile.category;
      _starRating = profile.starRating;
      _selectedAmenities = List.from(profile.amenities);
      _checkInTime = profile.policies.checkIn;
      _checkOutTime = profile.policies.checkOut;
      _images = List.from(profile.images);
    });
  }

  void _markAsChanged() {
    if (!_hasUnsavedChanges) {
      setState(() {
        _hasUnsavedChanges = true;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_profile == null) return;

    try {
      setState(() {
        _isSaving = true;
      });

      print('💾 Saving hotel profile...');
      
      final request = ProfileUpdateRequest(
        name: _nameController.text,
        description: _descriptionController.text,
        address: _addressController.text,
        location: _profile!.location,
        category: _selectedCategory,
        starRating: _starRating,
        amenities: _selectedAmenities,
        contactInfo: ContactInfo(
          phone: _phoneController.text,
          email: _emailController.text,
          website: _websiteController.text,
        ),
        policies: HotelPolicies(
          checkIn: _checkInTime,
          checkOut: _checkOutTime,
          cancellation: _cancellationController.text,
        ),
        images: _images,
      );

      final updatedProfile = await ProfileApiService.updateHotelProfile(request: request);
      
      setState(() {
        _profile = updatedProfile;
        _hasUnsavedChanges = false;
        _isSaving = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile updated successfully!'),
            backgroundColor: AppColors.green[600],
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('❌ Error saving profile: $e');
      setState(() {
        _isSaving = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save profile: $e'),
            backgroundColor: AppColors.red[600],
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _pickImages() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> pickedFiles = await picker.pickMultiImage();
      
      if (pickedFiles.isNotEmpty) {
        final newFiles = pickedFiles.map((file) => File(file.path)).toList();
        
        setState(() {
          _imageFiles.addAll(newFiles);
          _markAsChanged();
        });
      }
    } catch (e) {
      print('❌ Error picking images: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick images: $e'),
            backgroundColor: AppColors.red[600],
          ),
        );
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      if (index < _images.length) {
        _images.removeAt(index);
      } else {
        final fileIndex = index - _images.length;
        if (fileIndex < _imageFiles.length) {
          _imageFiles.removeAt(fileIndex);
        }
      }
      _markAsChanged();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        backgroundColor: _getAppBarColor(),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_hasUnsavedChanges)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _isSaving ? null : _saveProfile,
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
              : _buildProfileContent(),
    );
  }

  String _getAppBarTitle() {
    final effectiveRole = _getEffectiveRole();
    switch (effectiveRole) {
      case PlanType.pms:
        return 'Hotel Profile';
      case PlanType.pos:
        return 'Restaurant Profile';
      case PlanType.bundle:
        return 'Business Profile';
      default:
        return 'Profile';
    }
  }

  Color _getAppBarColor() {
    final effectiveRole = _getEffectiveRole();
    switch (effectiveRole) {
      case PlanType.pms:
        return Colors.blue[600]!;
      case PlanType.pos:
        return Colors.orange[600]!;
      case PlanType.bundle:
        return Colors.purple[600]!;
      default:
        return Colors.blue[600]!;
    }
  }

  PlanType _getEffectiveRole() {
    if (widget.loginContext != null) {
      switch (widget.loginContext!) {
        case LoginContext.pms:
          return PlanType.pms;
        case LoginContext.pos:
          return PlanType.pos;
        case LoginContext.direct:
          return widget.user.planType ?? PlanType.bundle;
      }
    }
    return widget.user.planType ?? PlanType.bundle;
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
            'Failed to load profile',
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
            onPressed: _loadProfile,
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

  Widget _buildProfileContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with unsaved changes indicator
          _buildHeader(),
          SizedBox(height: 20.h),

          // Basic Information
          _buildBasicInfoSection(),
          SizedBox(height: 20.h),

          // Category and Rating
          _buildCategoryRatingSection(),
          SizedBox(height: 20.h),

          // Address
          _buildAddressSection(),
          SizedBox(height: 20.h),

          // Contact Information
          _buildContactSection(),
          SizedBox(height: 20.h),

          // Images
          _buildImagesSection(),
          SizedBox(height: 20.h),

          // Policies
          _buildPoliciesSection(),
          SizedBox(height: 20.h),

          // Amenities
          _buildAmenitiesSection(),
          SizedBox(height: 20.h),

          // Save Button
          _buildSaveButton(),
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
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          gradient: LinearGradient(
            colors: [
              _getAppBarColor().withOpacity(0.1),
              _getAppBarColor().withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.business,
              size: 28.w,
              color: _getAppBarColor(),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getAppBarTitle(),
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: AppFontWeights.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    _hasUnsavedChanges ? 'You have unsaved changes' : 'All changes saved',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: _hasUnsavedChanges ? AppColors.orange[600] : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (_hasUnsavedChanges)
              Icon(
                Icons.edit,
                color: AppColors.orange[600],
                size: 20.w,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Information',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: AppFontWeights.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 16.h),
            
            // Hotel Name
            _buildTextField(
              controller: _nameController,
              label: 'Hotel Name',
              hint: 'Enter your hotel\'s name',
              icon: Icons.business,
              onChanged: _markAsChanged,
            ),
            SizedBox(height: 16.h),
            
            // Description
            _buildTextField(
              controller: _descriptionController,
              label: 'Description',
              hint: 'Describe your hotel\'s unique features',
              icon: Icons.description,
              maxLines: 4,
              onChanged: _markAsChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryRatingSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Category & Rating',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: AppFontWeights.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 16.h),
            
            // Category
            _buildCategorySelector(),
            SizedBox(height: 16.h),
            
            // Star Rating
            _buildStarRating(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: AppFontWeights.medium,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        DropdownButtonFormField<String>(
          value: _selectedCategory,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          ),
          items: ProfileConstants.categoryOptions.map((category) {
            return DropdownMenuItem(
              value: category.value,
              child: Text(category.label),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedCategory = value;
                _markAsChanged();
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildStarRating() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Star Rating',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: AppFontWeights.medium,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: List.generate(5, (index) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  _starRating = index + 1;
                  _markAsChanged();
                });
              },
              child: Icon(
                Icons.star,
                color: index < _starRating ? Colors.amber : Colors.grey[300],
                size: 32.w,
              ),
            );
          }),
        ),
        SizedBox(height: 4.h),
        Text(
          '$_starRating ${_starRating == 1 ? 'star' : 'stars'}',
          style: TextStyle(
            fontSize: 12.sp,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildAddressSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Address',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: AppFontWeights.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 16.h),
            _buildTextField(
              controller: _addressController,
              label: 'Address',
              hint: 'Enter the complete address',
              icon: Icons.location_on,
              onChanged: _markAsChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact Information',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: AppFontWeights.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 16.h),
            
            _buildTextField(
              controller: _phoneController,
              label: 'Phone Number',
              hint: '+1 (555) 123-4567',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
              onChanged: _markAsChanged,
            ),
            SizedBox(height: 16.h),
            
            _buildTextField(
              controller: _emailController,
              label: 'Email Address',
              hint: 'contact@yourhotel.com',
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
              onChanged: _markAsChanged,
            ),
            SizedBox(height: 16.h),
            
            _buildTextField(
              controller: _websiteController,
              label: 'Website',
              hint: 'https://yourhotel.com',
              icon: Icons.web,
              keyboardType: TextInputType.url,
              onChanged: _markAsChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagesSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hotel Images',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: AppFontWeights.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              '${_images.length + _imageFiles.length}/${ProfileConstants.maxImages} uploaded • Minimum ${ProfileConstants.minImages} required',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 16.h),
            
            // Add Image Button
            if (_images.length + _imageFiles.length < ProfileConstants.maxImages)
              GestureDetector(
                onTap: _pickImages,
                child: Container(
                  width: double.infinity,
                  height: 120.h,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.gray[300]!, style: BorderStyle.solid),
                    borderRadius: BorderRadius.circular(8.r),
                    color: AppColors.gray[50],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate,
                        size: 32.w,
                        color: AppColors.gray[400],
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Add Images',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            
            SizedBox(height: 16.h),
            
            // Image Grid
            if (_images.isNotEmpty || _imageFiles.isNotEmpty)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8.w,
                  mainAxisSpacing: 8.h,
                  childAspectRatio: 1,
                ),
                itemCount: _images.length + _imageFiles.length,
                itemBuilder: (context, index) {
                  return _buildImageItem(index);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageItem(int index) {
    final isNetworkImage = index < _images.length;
    final imageUrl = isNetworkImage ? _images[index] : null;
    final imageFile = !isNetworkImage ? _imageFiles[index - _images.length] : null;

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: AppColors.gray[200]!),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: isNetworkImage
                ? Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.gray[100],
                        child: Icon(
                          Icons.image,
                          color: AppColors.gray[400],
                        ),
                      );
                    },
                  )
                : Image.file(
                    imageFile!,
                    fit: BoxFit.cover,
                  ),
          ),
        ),
        Positioned(
          top: 4.h,
          right: 4.w,
          child: GestureDetector(
            onTap: () => _removeImage(index),
            child: Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.8),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close,
                color: Colors.white,
                size: 16.w,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPoliciesSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Policies',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: AppFontWeights.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 16.h),
            
            // Check-in Time
            _buildTimeSelector(
              label: 'Check-in Time',
              value: _checkInTime,
              onChanged: (value) {
                setState(() {
                  _checkInTime = value;
                  _markAsChanged();
                });
              },
            ),
            SizedBox(height: 16.h),
            
            // Check-out Time
            _buildTimeSelector(
              label: 'Check-out Time',
              value: _checkOutTime,
              onChanged: (value) {
                setState(() {
                  _checkOutTime = value;
                  _markAsChanged();
                });
              },
            ),
            SizedBox(height: 16.h),
            
            // Cancellation Policy
            _buildTextField(
              controller: _cancellationController,
              label: 'Cancellation Policy',
              hint: '24 hours before check-in for full refund',
              icon: Icons.cancel,
              onChanged: _markAsChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSelector({
    required String label,
    required String value,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: AppFontWeights.medium,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: () async {
            final TimeOfDay? picked = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.fromDateTime(
                DateTime.parse('1970-01-01 $value:00'),
              ),
            );
            if (picked != null) {
              final formattedTime = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
              onChanged(formattedTime);
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.gray[300]!),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.access_time,
                  color: AppColors.textSecondary,
                  size: 20.w,
                ),
                SizedBox(width: 8.w),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_drop_down,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAmenitiesSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hotel Amenities',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: AppFontWeights.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Select the amenities your hotel offers (${_selectedAmenities.length} selected)',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 16.h),
            
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8.w,
                mainAxisSpacing: 8.h,
                childAspectRatio: 3,
              ),
              itemCount: ProfileConstants.amenityOptions.length,
              itemBuilder: (context, index) {
                final amenity = ProfileConstants.amenityOptions[index];
                final isSelected = _selectedAmenities.contains(amenity.value);
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedAmenities.remove(amenity.value);
                      } else {
                        _selectedAmenities.add(amenity.value);
                      }
                      _markAsChanged();
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.green[50] : AppColors.gray[50],
                      border: Border.all(
                        color: isSelected ? AppColors.green[400]! : AppColors.gray[200]!,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getAmenityIcon(amenity.icon),
                          size: 16.w,
                          color: isSelected ? AppColors.green[600] : AppColors.textSecondary,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            amenity.label,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: isSelected ? AppFontWeights.medium : AppFontWeights.regular,
                              color: isSelected ? AppColors.green[800] : AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isSaving ? null : _saveProfile,
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
        label: Text(_isSaving ? 'Saving...' : 'Save Profile'),
        style: ElevatedButton.styleFrom(
          backgroundColor: _getAppBarColor(),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    required VoidCallback onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: AppFontWeights.medium,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          onChanged: (_) => onChanged(),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 20.w),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          ),
        ),
      ],
    );
  }

  IconData _getAmenityIcon(String iconName) {
    switch (iconName) {
      case 'wifi':
        return Icons.wifi;
      case 'car':
        return Icons.directions_car;
      case 'clock':
        return Icons.access_time;
      case 'waves':
        return Icons.waves;
      case 'wine':
        return Icons.local_bar;
      case 'utensils':
        return Icons.restaurant;
      case 'coffee':
        return Icons.coffee;
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'utensils_crossed':
        return Icons.room_service;
      case 'heart_handshake':
        return Icons.favorite;
      case 'dumbbell':
        return Icons.fitness_center;
      case 'bus':
        return Icons.directions_bus;
      case 'building':
        return Icons.business;
      case 'shirt':
        return Icons.checkroom;
      case 'users':
        return Icons.people;
      case 'credit_card':
        return Icons.credit_card;
      case 'power':
        return Icons.power;
      case 'luggage':
        return Icons.luggage;
      case 'lock_keyhole':
        return Icons.lock;
      case 'building_2':
        return Icons.elevator;
      case 'plane':
        return Icons.flight;
      case 'car_taxi_front':
        return Icons.local_taxi;
      case 'parking_circle':
        return Icons.local_parking;
      case 'map':
        return Icons.map;
      case 'laptop':
        return Icons.laptop;
      case 'tree':
        return Icons.park;
      case 'palmtree':
        return Icons.beach_access;
      default:
        return Icons.check;
    }
  }
}
