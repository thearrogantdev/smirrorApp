import 'package:smirror_app/objectbox/home_dashboard.dart';

abstract class HAState {}

class HAInitial extends HAState {}

class HALoading extends HAState {}

class HASuccess extends HAState {
  final List<DashboardItem> dashboardItems;
  final List<Dashboard> dashboards;
  final int? currentDashboardId;
  final bool snapToGrid;

  HASuccess({
    required this.dashboardItems,
    required this.dashboards,
    this.currentDashboardId,
    this.snapToGrid = true,
  });

  HASuccess copyWith({
    List<DashboardItem>? dashboardItems,
    List<Dashboard>? dashboards,
    int? currentDashboardId,
    bool? snapToGrid,
  }) {
    return HASuccess(
      dashboardItems: dashboardItems ?? this.dashboardItems,
      dashboards: dashboards ?? this.dashboards,
      currentDashboardId: currentDashboardId ?? this.currentDashboardId,
      snapToGrid: snapToGrid ?? this.snapToGrid,
    );
  }
}

class HAError extends HAState {
  final String message;
  HAError(this.message);
}
