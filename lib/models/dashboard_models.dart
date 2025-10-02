class DashboardMetrics {
  final String title;
  final String value;
  final String change;
  final String trend;

  DashboardMetrics({
    required this.title,
    required this.value,
    required this.change,
    required this.trend,
  });

  factory DashboardMetrics.fromJson(Map<String, dynamic> json) {
    return DashboardMetrics(
      title: json['title'] ?? '',
      value: json['value'] ?? '',
      change: json['change'] ?? '',
      trend: json['trend'] ?? 'flat',
    );
  }
}

class TimelineEvent {
  final String time;
  final String event;
  final String room;
  final String guest;

  TimelineEvent({
    required this.time,
    required this.event,
    required this.room,
    required this.guest,
  });

  factory TimelineEvent.fromJson(Map<String, dynamic> json) {
    return TimelineEvent(
      time: json['time'] ?? '',
      event: json['event'] ?? '',
      room: json['room'] ?? '',
      guest: json['guest'] ?? '',
    );
  }
}

class MonthlyData {
  final String date;
  final double revenue;
  final double occupancy;

  MonthlyData({
    required this.date,
    required this.revenue,
    required this.occupancy,
  });

  factory MonthlyData.fromJson(Map<String, dynamic> json) {
    return MonthlyData(
      date: json['date'] ?? '',
      revenue: (json['revenue'] ?? 0).toDouble(),
      occupancy: (json['occupancy'] ?? 0).toDouble(),
    );
  }
}

class Transaction {
  final String id;
  final String guest;
  final String amount;
  final String date;
  final String method;
  final String status;

  Transaction({
    required this.id,
    required this.guest,
    required this.amount,
    required this.date,
    required this.method,
    required this.status,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] ?? '',
      guest: json['guest'] ?? '',
      amount: json['amount'] ?? '',
      date: json['date'] ?? '',
      method: json['method'] ?? '',
      status: json['status'] ?? '',
    );
  }
}

class PaymentMethod {
  final String method;
  final double percentage;

  PaymentMethod({
    required this.method,
    required this.percentage,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      method: json['method'] ?? '',
      percentage: (json['percentage'] ?? 0).toDouble(),
    );
  }
}

class RevenueSource {
  final String source;
  final double amount;

  RevenueSource({
    required this.source,
    required this.amount,
  });

  factory RevenueSource.fromJson(Map<String, dynamic> json) {
    return RevenueSource(
      source: json['source'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
    );
  }
}

class GuestSatisfaction {
  final double avgRating;
  final int count;
  final Map<String, int> distribution;

  GuestSatisfaction({
    required this.avgRating,
    required this.count,
    required this.distribution,
  });

  factory GuestSatisfaction.fromJson(Map<String, dynamic> json) {
    return GuestSatisfaction(
      avgRating: (json['avgRating'] ?? 0).toDouble(),
      count: json['count'] ?? 0,
      distribution: Map<String, int>.from(json['distribution'] ?? {}),
    );
  }
}

class DashboardData {
  final DashboardMetrics revenueToday;
  final DashboardMetrics occupancyRate;
  final DashboardMetrics activeReservations;
  final DashboardMetrics roomServiceOrders;
  final GuestSatisfaction guestSatisfaction;
  final List<MonthlyData> revenueTrend;
  final List<MonthlyData> occupancyTrend;
  final List<TimelineEvent> timeline;
  final List<Transaction> recentTransactions;
  final List<PaymentMethod> paymentMethods;
  final List<RevenueSource> revenueBySource;

  DashboardData({
    required this.revenueToday,
    required this.occupancyRate,
    required this.activeReservations,
    required this.roomServiceOrders,
    required this.guestSatisfaction,
    required this.revenueTrend,
    required this.occupancyTrend,
    required this.timeline,
    required this.recentTransactions,
    required this.paymentMethods,
    required this.revenueBySource,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      revenueToday: DashboardMetrics.fromJson(json['revenueToday'] ?? {}),
      occupancyRate: DashboardMetrics.fromJson(json['occupancyRate'] ?? {}),
      activeReservations: DashboardMetrics.fromJson(json['activeReservations'] ?? {}),
      roomServiceOrders: DashboardMetrics.fromJson(json['roomServiceOrders'] ?? {}),
      guestSatisfaction: GuestSatisfaction.fromJson(json['guestSatisfaction'] ?? {}),
      revenueTrend: (json['revenueTrend'] as List<dynamic>?)
          ?.map((item) => MonthlyData.fromJson(item))
          .toList() ?? [],
      occupancyTrend: (json['occupancyTrend'] as List<dynamic>?)
          ?.map((item) => MonthlyData.fromJson(item))
          .toList() ?? [],
      timeline: (json['timeline'] as List<dynamic>?)
          ?.map((item) => TimelineEvent.fromJson(item))
          .toList() ?? [],
      recentTransactions: (json['recentTransactions'] as List<dynamic>?)
          ?.map((item) => Transaction.fromJson(item))
          .toList() ?? [],
      paymentMethods: (json['paymentMethods'] as List<dynamic>?)
          ?.map((item) => PaymentMethod.fromJson(item))
          .toList() ?? [],
      revenueBySource: (json['revenueBySource'] as List<dynamic>?)
          ?.map((item) => RevenueSource.fromJson(item))
          .toList() ?? [],
    );
  }
}
