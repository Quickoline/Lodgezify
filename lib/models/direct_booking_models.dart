class DirectBookingConfig {
  final String versionNumber;
  final String developerId;
  final String deviceIp;
  final String secretApiKey;
  final bool isConfigured;
  final DateTime? lastUpdated;

  const DirectBookingConfig({
    required this.versionNumber,
    required this.developerId,
    required this.deviceIp,
    required this.secretApiKey,
    required this.isConfigured,
    this.lastUpdated,
  });

  factory DirectBookingConfig.fromJson(Map<String, dynamic> json) {
    return DirectBookingConfig(
      versionNumber: json['versionNumber'] ?? '',
      developerId: json['developerId'] ?? '',
      deviceIp: json['deviceIp'] ?? '',
      secretApiKey: json['secretApiKey'] ?? '',
      isConfigured: json['isConfigured'] ?? false,
      lastUpdated: json['lastUpdated'] != null 
          ? DateTime.parse(json['lastUpdated']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'versionNumber': versionNumber,
      'developerId': developerId,
      'deviceIp': deviceIp,
      'secretApiKey': secretApiKey,
      'isConfigured': isConfigured,
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }

  DirectBookingConfig copyWith({
    String? versionNumber,
    String? developerId,
    String? deviceIp,
    String? secretApiKey,
    bool? isConfigured,
    DateTime? lastUpdated,
  }) {
    return DirectBookingConfig(
      versionNumber: versionNumber ?? this.versionNumber,
      developerId: developerId ?? this.developerId,
      deviceIp: deviceIp ?? this.deviceIp,
      secretApiKey: secretApiKey ?? this.secretApiKey,
      isConfigured: isConfigured ?? this.isConfigured,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class DirectBookingUpdateRequest {
  final String versionNumber;
  final String developerId;
  final String deviceIp;
  final String secretApiKey;

  const DirectBookingUpdateRequest({
    required this.versionNumber,
    required this.developerId,
    required this.deviceIp,
    required this.secretApiKey,
  });

  Map<String, dynamic> toJson() {
    return {
      'versionNumber': versionNumber,
      'developerId': developerId,
      'deviceIp': deviceIp,
      'secretApiKey': secretApiKey,
    };
  }
}

class DirectBookingStatus {
  final bool isEnabled;
  final bool hasValidCredentials;
  final String statusMessage;
  final String lastTestResult;
  final DateTime? lastTestDate;

  const DirectBookingStatus({
    required this.isEnabled,
    required this.hasValidCredentials,
    required this.statusMessage,
    required this.lastTestResult,
    this.lastTestDate,
  });

  factory DirectBookingStatus.fromJson(Map<String, dynamic> json) {
    return DirectBookingStatus(
      isEnabled: json['isEnabled'] ?? false,
      hasValidCredentials: json['hasValidCredentials'] ?? false,
      statusMessage: json['statusMessage'] ?? '',
      lastTestResult: json['lastTestResult'] ?? '',
      lastTestDate: json['lastTestDate'] != null 
          ? DateTime.parse(json['lastTestDate']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isEnabled': isEnabled,
      'hasValidCredentials': hasValidCredentials,
      'statusMessage': statusMessage,
      'lastTestResult': lastTestResult,
      'lastTestDate': lastTestDate?.toIso8601String(),
    };
  }
}

// Configuration field definitions
class ConfigField {
  final String key;
  final String label;
  final String placeholder;
  final String hint;
  final String defaultValue;
  final bool isRequired;
  final bool isSecure;
  final String inputType;

  const ConfigField({
    required this.key,
    required this.label,
    required this.placeholder,
    required this.hint,
    required this.defaultValue,
    required this.isRequired,
    required this.isSecure,
    required this.inputType,
  });
}

class DirectBookingConstants {
  static const List<ConfigField> configFields = [
    ConfigField(
      key: 'secretApiKey',
      label: 'Secret API Key',
      placeholder: 'Your Global Payments secret API key',
      hint: 'Required for payment processing',
      defaultValue: '',
      isRequired: true,
      isSecure: true,
      inputType: 'text',
    ),
    ConfigField(
      key: 'versionNumber',
      label: 'Version Number',
      placeholder: 'e.g. 2021-03-22',
      hint: 'Default: 6294',
      defaultValue: '6294',
      isRequired: false,
      isSecure: false,
      inputType: 'text',
    ),
    ConfigField(
      key: 'developerId',
      label: 'Developer ID',
      placeholder: 'Your Global Payments developer ID',
      hint: 'Default: 002914',
      defaultValue: '002914',
      isRequired: false,
      isSecure: false,
      inputType: 'text',
    ),
    ConfigField(
      key: 'deviceIp',
      label: 'Device IP',
      placeholder: 'e.g. 192.168.1.50',
      hint: 'Your device IP address',
      defaultValue: '',
      isRequired: false,
      isSecure: false,
      inputType: 'text',
    ),
  ];

  static const String defaultStatusMessage = 'Direct Billing Not Enabled';
  static const String defaultStatusSubtext = 'Set up your own Global Payments credentials below to enable direct billing.';
  static const String usingDefaultMessage = 'Using default credentials - set up your own for direct billing';
}
