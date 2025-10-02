import 'package:equatable/equatable.dart';

/// Booking summary model matching the React interface
class BookingSummary extends Equatable {
  final String id;
  final String reservationId;
  final String guest;
  final String room;
  final String checkIn;
  final String checkOut;
  final String status;
  final String source;
  final PaymentStatus paymentStatus;
  final double amount;

  const BookingSummary({
    required this.id,
    required this.reservationId,
    required this.guest,
    required this.room,
    required this.checkIn,
    required this.checkOut,
    required this.status,
    required this.source,
    required this.paymentStatus,
    required this.amount,
  });

  factory BookingSummary.fromJson(Map<String, dynamic> json) {
    return BookingSummary(
      id: json['id']?.toString() ?? '',
      reservationId: json['reservationId']?.toString() ?? '-',
      guest: json['guest']?.toString() ?? 'Unknown Guest',
      room: json['room']?.toString() ?? 'N/A',
      checkIn: json['checkIn']?.toString() ?? '',
      checkOut: json['checkOut']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      source: json['source']?.toString() ?? 'direct',
      paymentStatus: _parsePaymentStatus(json['paymentStatus']),
      amount: (json['amount'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reservationId': reservationId,
      'guest': guest,
      'room': room,
      'checkIn': checkIn,
      'checkOut': checkOut,
      'status': status,
      'source': source,
      'paymentStatus': paymentStatus.value,
      'amount': amount,
    };
  }

  static PaymentStatus _parsePaymentStatus(dynamic status) {
    if (status == null) return PaymentStatus.pending;
    
    final statusStr = status.toString().toLowerCase();
    switch (statusStr) {
      case 'authorized':
        return PaymentStatus.authorized;
      case 'paid':
        return PaymentStatus.paid;
      case 'refunded':
        return PaymentStatus.refunded;
      default:
        return PaymentStatus.pending;
    }
  }

  @override
  List<Object?> get props => [
        id,
        reservationId,
        guest,
        room,
        checkIn,
        checkOut,
        status,
        source,
        paymentStatus,
        amount,
      ];
}

/// Payment status enum
enum PaymentStatus {
  pending('pending'),
  authorized('authorized'),
  paid('paid'),
  refunded('refunded');

  const PaymentStatus(this.value);
  final String value;
}

/// Bookings data model containing summary statistics
class BookingsData extends Equatable {
  final List<BookingSummary> bookings;
  final int upcomingCheckIns;
  final int upcomingCheckOuts;
  final int cancellations;
  final int noShows;

  const BookingsData({
    required this.bookings,
    required this.upcomingCheckIns,
    required this.upcomingCheckOuts,
    required this.cancellations,
    required this.noShows,
  });

  factory BookingsData.fromJson(Map<String, dynamic> json) {
    final bookingsList = (json['bookings'] as List<dynamic>?)
        ?.map((booking) => BookingSummary.fromJson(booking))
        .toList() ?? [];

    return BookingsData(
      bookings: bookingsList,
      upcomingCheckIns: json['upcomingCheckIns'] ?? 0,
      upcomingCheckOuts: json['upcomingCheckOuts'] ?? 0,
      cancellations: json['cancellations'] ?? 0,
      noShows: json['noShows'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookings': bookings.map((booking) => booking.toJson()).toList(),
      'upcomingCheckIns': upcomingCheckIns,
      'upcomingCheckOuts': upcomingCheckOuts,
      'cancellations': cancellations,
      'noShows': noShows,
    };
  }

  @override
  List<Object?> get props => [
        bookings,
        upcomingCheckIns,
        upcomingCheckOuts,
        cancellations,
        noShows,
      ];
}

/// Hotel information model
class HotelInfo extends Equatable {
  final String name;
  final String address;
  final String contact;
  final String logo;

  const HotelInfo({
    required this.name,
    required this.address,
    required this.contact,
    required this.logo,
  });

  factory HotelInfo.fromJson(Map<String, dynamic> json) {
    return HotelInfo(
      name: json['name']?.toString() ?? 'Hotel',
      address: json['address']?.toString() ?? '',
      contact: json['contact']?.toString() ?? '',
      logo: json['logo']?.toString() ?? '/logo.png',
    );
  }

  @override
  List<Object?> get props => [name, address, contact, logo];
}

/// Booking filter model
class BookingFilter extends Equatable {
  final String? startDate;
  final String? endDate;
  final String? status;
  final String? source;

  const BookingFilter({
    this.startDate,
    this.endDate,
    this.status,
    this.source,
  });

  BookingFilter copyWith({
    String? startDate,
    String? endDate,
    String? status,
    String? source,
  }) {
    return BookingFilter(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      source: source ?? this.source,
    );
  }

  @override
  List<Object?> get props => [startDate, endDate, status, source];
}
