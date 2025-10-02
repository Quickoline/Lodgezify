import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/theme.dart';

class RecaptchaWidget extends StatefulWidget {
  final Function(String) onTokenReceived;
  final Function(String) onError;
  final bool isRequired;

  const RecaptchaWidget({
    super.key,
    required this.onTokenReceived,
    required this.onError,
    this.isRequired = true,
  });

  @override
  State<RecaptchaWidget> createState() => _RecaptchaWidgetState();
}

class _RecaptchaWidgetState extends State<RecaptchaWidget> {
  bool _isLoading = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md.w),
      decoration: BoxDecoration(
        color: AppColors.gray[50],
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        border: Border.all(color: AppColors.gray[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.security,
                size: 20.sp,
                color: AppColors.primary[600],
              ),
              SizedBox(width: AppSpacing.sm.w),
              Text(
                'Security Verification',
                style: TextStyle(
                  fontSize: AppFontSizes.md.sp,
                  fontWeight: AppFontWeights.semibold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm.h),
          Text(
            'Please complete the reCAPTCHA verification to continue.',
            style: TextStyle(
              fontSize: AppFontSizes.sm.sp,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: AppSpacing.md.h),
          
          // reCAPTCHA Container
          Container(
            height: 80.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppBorderRadius.sm),
              border: Border.all(color: AppColors.gray[300]!),
            ),
            child: _buildRecaptchaContainer(),
          ),
          
          if (_errorMessage != null) ...[
            SizedBox(height: AppSpacing.sm.h),
            Row(
              children: [
                Icon(
                  Icons.error_outline,
                  size: 16.sp,
                  color: Colors.red,
                ),
                SizedBox(width: AppSpacing.xs.w),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(
                      fontSize: AppFontSizes.sm.sp,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRecaptchaContainer() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 20.h,
              width: 20.w,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary[600],
              ),
            ),
            SizedBox(height: AppSpacing.xs.h),
            Text(
              'Loading verification...',
              style: TextStyle(
                fontSize: AppFontSizes.xs.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.verified_user,
            size: 32.sp,
            color: AppColors.primary[600],
          ),
          SizedBox(height: AppSpacing.xs.h),
          Text(
            'reCAPTCHA Verification',
            style: TextStyle(
              fontSize: AppFontSizes.sm.sp,
              fontWeight: AppFontWeights.medium,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSpacing.xs.h),
          Text(
            'Click to verify you are human',
            style: TextStyle(
              fontSize: AppFontSizes.xs.sp,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _simulateRecaptcha() {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Simulate reCAPTCHA verification
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Generate a mock reCAPTCHA token
        final token = 'mock_recaptcha_token_${DateTime.now().millisecondsSinceEpoch}';
        widget.onTokenReceived(token);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    // Auto-trigger reCAPTCHA for demo purposes
    Future.delayed(const Duration(milliseconds: 500), () {
      _simulateRecaptcha();
    });
  }
}
