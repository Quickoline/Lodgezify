class HotelProfile {
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
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const HotelProfile({
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
    this.createdAt,
    this.updatedAt,
  });

  factory HotelProfile.fromJson(Map<String, dynamic> json) {
    return HotelProfile(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      address: json['address'] ?? '',
      location: HotelLocation.fromJson(json['location'] ?? {}),
      category: json['category'] ?? 'luxury',
      starRating: json['starRating'] ?? 5,
      amenities: List<String>.from(json['amenities'] ?? []),
      contactInfo: ContactInfo.fromJson(json['contactInfo'] ?? {}),
      policies: HotelPolicies.fromJson(json['policies'] ?? {}),
      images: List<String>.from(json['images'] ?? []),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
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
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  HotelProfile copyWith({
    String? id,
    String? name,
    String? description,
    String? address,
    HotelLocation? location,
    String? category,
    int? starRating,
    List<String>? amenities,
    ContactInfo? contactInfo,
    HotelPolicies? policies,
    List<String>? images,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HotelProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      address: address ?? this.address,
      location: location ?? this.location,
      category: category ?? this.category,
      starRating: starRating ?? this.starRating,
      amenities: amenities ?? this.amenities,
      contactInfo: contactInfo ?? this.contactInfo,
      policies: policies ?? this.policies,
      images: images ?? this.images,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class HotelLocation {
  final String type;
  final List<double> coordinates; // [longitude, latitude]

  const HotelLocation({
    required this.type,
    required this.coordinates,
  });

  factory HotelLocation.fromJson(Map<String, dynamic> json) {
    return HotelLocation(
      type: json['type'] ?? 'Point',
      coordinates: List<double>.from(json['coordinates'] ?? [0.0, 0.0]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'coordinates': coordinates,
    };
  }

  HotelLocation copyWith({
    String? type,
    List<double>? coordinates,
  }) {
    return HotelLocation(
      type: type ?? this.type,
      coordinates: coordinates ?? this.coordinates,
    );
  }
}

class ContactInfo {
  final String phone;
  final String email;
  final String website;

  const ContactInfo({
    required this.phone,
    required this.email,
    required this.website,
  });

  factory ContactInfo.fromJson(Map<String, dynamic> json) {
    return ContactInfo(
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      website: json['website'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'email': email,
      'website': website,
    };
  }

  ContactInfo copyWith({
    String? phone,
    String? email,
    String? website,
  }) {
    return ContactInfo(
      phone: phone ?? this.phone,
      email: email ?? this.email,
      website: website ?? this.website,
    );
  }
}

class HotelPolicies {
  final String checkIn;
  final String checkOut;
  final String cancellation;

  const HotelPolicies({
    required this.checkIn,
    required this.checkOut,
    required this.cancellation,
  });

  factory HotelPolicies.fromJson(Map<String, dynamic> json) {
    return HotelPolicies(
      checkIn: json['checkIn'] ?? '',
      checkOut: json['checkOut'] ?? '',
      cancellation: json['cancellation'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'checkIn': checkIn,
      'checkOut': checkOut,
      'cancellation': cancellation,
    };
  }

  HotelPolicies copyWith({
    String? checkIn,
    String? checkOut,
    String? cancellation,
  }) {
    return HotelPolicies(
      checkIn: checkIn ?? this.checkIn,
      checkOut: checkOut ?? this.checkOut,
      cancellation: cancellation ?? this.cancellation,
    );
  }
}

class ProfileUpdateRequest {
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

  const ProfileUpdateRequest({
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

// Amenity options for the UI
class AmenityOption {
  final String value;
  final String label;
  final String description;
  final String icon;

  const AmenityOption({
    required this.value,
    required this.label,
    required this.description,
    required this.icon,
  });
}

class CategoryOption {
  final String value;
  final String label;
  final String description;
  final String color;

  const CategoryOption({
    required this.value,
    required this.label,
    required this.description,
    required this.color,
  });
}

// Static data for UI
class ProfileConstants {
  static const List<AmenityOption> amenityOptions = [
    AmenityOption(
      value: 'wifi',
      label: 'Internet/Wi-Fi',
      description: 'High-speed internet access',
      icon: 'wifi',
    ),
    AmenityOption(
      value: 'parking',
      label: 'On Premise Parking',
      description: 'Convenient on-site parking',
      icon: 'car',
    ),
    AmenityOption(
      value: 'frontdesk',
      label: '24-hour Front Desk',
      description: 'Round-the-clock front desk',
      icon: 'clock',
    ),
    AmenityOption(
      value: 'pool',
      label: 'Swimming Pool',
      description: 'Refreshing swimming facilities',
      icon: 'waves',
    ),
    AmenityOption(
      value: 'bar',
      label: 'Bar',
      description: 'Well-stocked beverages',
      icon: 'wine',
    ),
    AmenityOption(
      value: 'restaurant',
      label: 'Restaurant',
      description: 'In-house dining options',
      icon: 'utensils',
    ),
    AmenityOption(
      value: 'coffee_lobby',
      label: 'Coffee/Tea in Lobby',
      description: 'Complimentary beverages',
      icon: 'coffee',
    ),
    AmenityOption(
      value: 'vending',
      label: 'Vending Machine',
      description: '24/7 snacks and drinks',
      icon: 'shopping_cart',
    ),
    AmenityOption(
      value: 'room_service',
      label: 'Room Service',
      description: 'In-room dining',
      icon: 'utensils_crossed',
    ),
    AmenityOption(
      value: 'spa',
      label: 'Spa',
      description: 'Relaxation & wellness',
      icon: 'heart_handshake',
    ),
    AmenityOption(
      value: 'gym',
      label: 'Gym',
      description: 'Fitness center',
      icon: 'dumbbell',
    ),
    AmenityOption(
      value: 'breakfast',
      label: 'Breakfast',
      description: 'Morning meal service',
      icon: 'coffee',
    ),
    AmenityOption(
      value: 'shuttle',
      label: 'Shuttle Service',
      description: 'Transportation service',
      icon: 'bus',
    ),
    AmenityOption(
      value: 'currency',
      label: 'Currency Exchange',
      description: 'Money exchange',
      icon: 'building',
    ),
    AmenityOption(
      value: 'dry_cleaning',
      label: 'Dry Cleaning',
      description: 'Professional cleaning',
      icon: 'shirt',
    ),
    AmenityOption(
      value: 'laundry',
      label: 'Laundry',
      description: 'Laundry service',
      icon: 'shirt',
    ),
    AmenityOption(
      value: 'meeting',
      label: 'Meeting Facilities',
      description: 'Conference/event spaces',
      icon: 'users',
    ),
    AmenityOption(
      value: 'atm',
      label: 'ATM On Site',
      description: 'Cash withdrawal',
      icon: 'credit_card',
    ),
    AmenityOption(
      value: 'power_backup',
      label: '24h Power Backup',
      description: 'Uninterrupted power',
      icon: 'power',
    ),
    AmenityOption(
      value: 'luggage',
      label: 'Luggage Storage',
      description: 'Secure baggage storage',
      icon: 'luggage',
    ),
    AmenityOption(
      value: 'safe',
      label: 'Safety Deposit Box',
      description: 'In-room safes',
      icon: 'lock_keyhole',
    ),
    AmenityOption(
      value: 'elevator',
      label: 'Elevator',
      description: 'Lift access',
      icon: 'building_2',
    ),
    AmenityOption(
      value: 'concierge',
      label: 'Concierge',
      description: 'Personal assistance',
      icon: 'heart_handshake',
    ),
    AmenityOption(
      value: 'airport',
      label: 'Airport Transfer',
      description: 'Pickup/drop-off',
      icon: 'plane',
    ),
    AmenityOption(
      value: 'rental',
      label: 'Rental Car',
      description: 'Car rental',
      icon: 'car_taxi_front',
    ),
    AmenityOption(
      value: 'valet',
      label: 'Valet Parking',
      description: 'Valet service',
      icon: 'parking_circle',
    ),
    AmenityOption(
      value: 'tours',
      label: 'Tours',
      description: 'Guided arrangements',
      icon: 'map',
    ),
    AmenityOption(
      value: 'workspace',
      label: 'Dedicated Workspace',
      description: 'Business center',
      icon: 'laptop',
    ),
    AmenityOption(
      value: 'garden',
      label: 'Garden',
      description: 'Landscaped outdoor area',
      icon: 'tree',
    ),
    AmenityOption(
      value: 'outdoor_dining',
      label: 'Outdoor Dining',
      description: 'Al fresco options',
      icon: 'utensils_crossed',
    ),
    AmenityOption(
      value: 'outdoor_furniture',
      label: 'Outdoor Furniture',
      description: 'Outdoor seating',
      icon: 'palmtree',
    ),
  ];

  static const List<CategoryOption> categoryOptions = [
    CategoryOption(
      value: 'budget',
      label: 'Budget',
      description: 'Affordable accommodation',
      color: 'emerald',
    ),
    CategoryOption(
      value: 'business',
      label: 'Business',
      description: 'Professional amenities',
      color: 'slate',
    ),
    CategoryOption(
      value: 'luxury',
      label: 'Luxury',
      description: 'Premium experience',
      color: 'amber',
    ),
    CategoryOption(
      value: 'resort',
      label: 'Resort',
      description: 'Vacation destination',
      color: 'rose',
    ),
  ];

  static const int minImages = 4;
  static const int maxImages = 5;
  static const int maxDescriptionLength = 1000;
}
