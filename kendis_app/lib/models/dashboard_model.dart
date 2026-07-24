class DriverDashboardModel {
  final DriverInfo driver;
  final DashboardSummary summary;
  final List<CostPeriodItem> costPeriod;
  final List<PopularDestinationItem> popularDestinations;
  final List<RecentActivityItem> recentActivities;
  final int notifikasiBelumDibaca;

  DriverDashboardModel({
    required this.driver,
    required this.summary,
    required this.costPeriod,
    required this.popularDestinations,
    required this.recentActivities,
    this.notifikasiBelumDibaca = 0,
  });

  factory DriverDashboardModel.fromJson(Map<String, dynamic> json) {
    return DriverDashboardModel(
      driver: DriverInfo.fromJson(json['driver']),
      summary: DashboardSummary.fromJson(json['summary']),
      costPeriod: (json['cost_period'] as List)
          .map((e) => CostPeriodItem.fromJson(e))
          .toList(),
      popularDestinations: (json['popular_destinations'] as List)
          .map((e) => PopularDestinationItem.fromJson(e))
          .toList(),
      recentActivities: (json['recent_activities'] as List)
          .map((e) => RecentActivityItem.fromJson(e))
          .toList(),
      notifikasiBelumDibaca: json['notifikasi_belum_dibaca'] ?? 0,
    );
  }
}

class DriverInfo {
  final int id;
  final String name;
  final String role;

  DriverInfo({required this.id, required this.name, required this.role});

  factory DriverInfo.fromJson(Map<String, dynamic> json) {
    return DriverInfo(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Driver',
      role: json['role'] ?? 'Driver Operasional',
    );
  }
}

class DashboardSummary {
  final int activeTasks;
  final int completedTasksWeek;
  final double reportedCostTotal;
  final int receiptCount;
  final int tasksNeedReport;

  DashboardSummary({
    required this.activeTasks,
    required this.completedTasksWeek,
    required this.reportedCostTotal,
    required this.receiptCount,
    required this.tasksNeedReport,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      activeTasks: json['active_tasks'] ?? 0,
      completedTasksWeek: json['completed_tasks_week'] ?? 0,
      reportedCostTotal: (json['reported_cost_total'] ?? 0).toDouble(),
      receiptCount: json['receipt_count'] ?? 0,
      tasksNeedReport: json['tasks_need_report'] ?? 0,
    );
  }
}

class CostPeriodItem {
  final String month;
  final double bbm;
  final double parkir;
  final double tol;

  CostPeriodItem({
    required this.month,
    required this.bbm,
    required this.parkir,
    required this.tol,
  });

  factory CostPeriodItem.fromJson(Map<String, dynamic> json) {
    return CostPeriodItem(
      month: json['month'] ?? '',
      bbm: (json['bbm'] ?? 0).toDouble(),
      parkir: (json['parkir'] ?? 0).toDouble(),
      tol: (json['tol'] ?? 0).toDouble(),
    );
  }
}

class PopularDestinationItem {
  final String city;
  final int tripCount;

  PopularDestinationItem({required this.city, required this.tripCount});

  factory PopularDestinationItem.fromJson(Map<String, dynamic> json) {
    return PopularDestinationItem(
      city: json['city'] ?? '',
      tripCount: json['trip_count'] ?? 0,
    );
  }
}

class RecentActivityItem {
  final String type;
  final String title;
  final String subtitle;
  final String? value;
  final String status;
  final String activityDate;

  RecentActivityItem({
    required this.type,
    required this.title,
    required this.subtitle,
    this.value,
    required this.status,
    required this.activityDate,
  });

  factory RecentActivityItem.fromJson(Map<String, dynamic> json) {
    return RecentActivityItem(
      type: json['type'] ?? 'trip',
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      value: json['value'],
      status: json['status'] ?? '',
      activityDate: json['activity_date'] ?? '',
    );
  }
}
