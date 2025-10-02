import 'package:flutter/material.dart';

class HotelFormData {
  String name;
  String description;
  String address;
  HotelLocation location;
  String category;
  int starRating;
  List<String> amenities;
  ContactInfo contactInfo;
  HotelPolicies policies;
  List<String> images;

  HotelFormData({
    required this.name,
    required this.description,
    required this.address,
    required this.location,
    required this.category,
    required this.starRating,
    required this.amenities,
    required this.contactInfo,
    required this.policies,
    required this.images,
  });

  factory HotelFormData.initial() {
    return HotelFormData(
      name: '',
      description: '',
      address: '',
      location: HotelLocation.initial(),
      category: 'luxury',
      starRating: 5,
      amenities: [],
      contactInfo: ContactInfo.initial(),
      policies: HotelPolicies.initial(),
      images: [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'address': address,
      'location': location.toJson(),
      'category': category,
      'starRating': starRating,
      'amenities': amenities,
      'contactInfo': contactInfo.toJson(),
      'policies': policies.toJson(),
      'images': images,
    };
  }
}

class HotelLocation {
  String type;
  List<double> coordinates;

  HotelLocation({
    required this.type,
    required this.coordinates,
  });

  factory HotelLocation.initial() {
    return HotelLocation(
      type: 'Point',
      coordinates: [0.0, 0.0],
    );
  }

  factory HotelLocation.fromJson(Map<String, dynamic> json) {
    return HotelLocation(
      type: json['type'] as String,
      coordinates: (json['coordinates'] as List<dynamic>).cast<double>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'coordinates': coordinates,
    };
  }
}

class ContactInfo {
  String phone;
  String email;
  String website;

  ContactInfo({
    required this.phone,
    required this.email,
    required this.website,
  });

  factory ContactInfo.initial() {
    return ContactInfo(
      phone: '',
      email: '',
      website: '',
    );
  }

  factory ContactInfo.fromJson(Map<String, dynamic> json) {
    return ContactInfo(
      phone: json['phone'] as String,
      email: json['email'] as String,
      website: json['website'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'email': email,
      'website': website,
    };
  }
}

class HotelPolicies {
  String checkIn;
  String checkOut;
  String cancellation;

  HotelPolicies({
    required this.checkIn,
    required this.checkOut,
    required this.cancellation,
  });

  factory HotelPolicies.initial() {
    return HotelPolicies(
      checkIn: '',
      checkOut: '',
      cancellation: '',
    );
  }

  factory HotelPolicies.fromJson(Map<String, dynamic> json) {
    return HotelPolicies(
      checkIn: json['checkIn'] as String,
      checkOut: json['checkOut'] as String,
      cancellation: json['cancellation'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'checkIn': checkIn,
      'checkOut': checkOut,
      'cancellation': cancellation,
    };
  }
}

class HotelCreationResponse {
  final bool success;
  final String message;
  final HotelData? data;

  HotelCreationResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory HotelCreationResponse.fromJson(Map<String, dynamic> json) {
    return HotelCreationResponse(
      success: json['success'] as bool,
      message: json['message'] as String? ?? '',
      data: json['data'] != null ? HotelData.fromJson(json['data']) : null,
    );
  }
}

class HotelData {
  final String id;
  final String name;
  final String description;
  final String address;
  final HotelLocation location;
  final String category;
  final int starRating;
  final List<String> amenities;
  final ContactInfo contactInfo;
  final HotelPolicies policies;
  final List<String> images;
  final String createdAt;
  final String updatedAt;

  HotelData({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.location,
    required this.category,
    required this.starRating,
    required this.amenities,
    required this.contactInfo,
    required this.policies,
    required this.images,
    required this.createdAt,
    required this.updatedAt,
  });

  factory HotelData.fromJson(Map<String, dynamic> json) {
    return HotelData(
      id: json['_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      address: json['address'] as String,
      location: HotelLocation.fromJson(json['location']),
      category: json['category'] as String,
      starRating: json['starRating'] as int,
      amenities: (json['amenities'] as List<dynamic>).cast<String>(),
      contactInfo: ContactInfo.fromJson(json['contactInfo']),
      policies: HotelPolicies.fromJson(json['policies']),
      images: (json['images'] as List<dynamic>).cast<String>(),
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }
}


class AmenityOption {
  final String value;
  final String label;
  final IconData icon;
  final String description;

  AmenityOption({
    required this.value,
    required this.label,
    required this.icon,
    required this.description,
  });
}

class CategoryOption {
  final String value;
  final String label;
  final String description;
  final Color color;

  CategoryOption({
    required this.value,
    required this.label,
    required this.description,
    required this.color,
  });
}

class ImageUploadResponse {
  final bool success;
  final String message;
  final String? imageUrl;

  ImageUploadResponse({
    required this.success,
    required this.message,
    this.imageUrl,
  });

  factory ImageUploadResponse.fromJson(Map<String, dynamic> json) {
    return ImageUploadResponse(
      success: json['success'] as bool,
      message: json['message'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
    );
  }
}
