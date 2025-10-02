import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/theme.dart';
import '../services/auth_service.dart';
import '../models/enhanced_auth_models.dart';

class POSLoginScreen extends StatefulWidget {
  const POSLoginScreen({super.key});

  @override
  State<POSLoginScreen> createState() => _POSLoginScreenState();
}

class _POSLoginScreenState extends State<POSLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String _selectedRole = 'hotel_admin'; // Default role

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await AuthService.login(
        _emailController.text.trim(),
        _passwordController.text,
        'pos', // Plan type for POS access
        '', // No reCAPTCHA token needed
        staffRole: _selectedRole, // Pass selected role
      );

      if (response.success && response.user != null) {
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message),
              backgroundColor: response.message.contains('Demo') ? Colors.orange : Colors.green,
            ),
          );
          
          // Navigate to dashboard with user data, POS login context, and selected role
          context.go('/dashboard', extra: {
            'user': response.user,
            'loginContext': LoginContext.pos,
            'selectedRole': _selectedRole, // Pass the selected role directly
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.secondary[600],
        foregroundColor: AppColors.textInverse,
        title: const Text('POS Login'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.lg.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: AppSpacing.xxl.h),
                
                // Logo and Title
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80.w,
                        height: 80.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                          child: Image.asset(
                            'assets/images/logo.jpg',
                            width: 80.w,
                            height: 80.h,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              // Fallback to icon if image fails to load
                              return Container(
                                color: AppColors.secondary[100],
                                child: Icon(
                                  Icons.restaurant,
                                  size: 40.sp,
                                  color: AppColors.secondary[600],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: AppSpacing.md.h),
                      Text(
                        'POS Login',
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: AppFontWeights.bold,
                        ),
                      ),
                      SizedBox(height: AppSpacing.sm.h),
                      Text(
                        'Restaurant Management System',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: AppSpacing.xxl.h),
                
                // Role Selection
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: InputDecoration(
                    labelText: 'Staff Role',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppBorderRadius.md),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'hotel_admin',
                      child: Text('Hotel Admin'),
                    ),
                    DropdownMenuItem(
                      value: 'front_desk',
                      child: Text('Front Desk'),
                    ),
                    DropdownMenuItem(
                      value: 'housekeeper',
                      child: Text('Housekeeper'),
                    ),
                    DropdownMenuItem(
                      value: 'restaurant_manager',
                      child: Text('Restaurant Manager'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value ?? 'hotel_admin';
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select your role';
                    }
                    return null;
                  },
                ),
                
                SizedBox(height: AppSpacing.lg.h),
                
                // Email Field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppBorderRadius.md),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                
                SizedBox(height: AppSpacing.lg.h),
                
                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppBorderRadius.md),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                
                SizedBox(height: AppSpacing.xl.h),
                
                // Login Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary[600],
                    foregroundColor: AppColors.textInverse,
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl.w,
                      vertical: AppSpacing.lg.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppBorderRadius.md),
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
                          'Login to POS',
                          style: TextStyle(
                            fontSize: AppFontSizes.lg.sp,
                            fontWeight: AppFontWeights.semibold,
                          ),
                        ),
                ),
                
                SizedBox(height: AppSpacing.lg.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
