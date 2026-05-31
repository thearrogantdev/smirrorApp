import 'package:smirror_app/objectbox/home_dashboard.dart';

abstract class HAEvent {}

class FetchHAStates extends HAEvent {}

class RefreshHAStates extends HAEvent {}

/// Starts watching the ObjectBox items for a specific dashboard
class LoadDashboard extends HAEvent {
  final int dashboardId;
  LoadDashboard(this.dashboardId);
}

/// Persistence actions
class SaveDashboardItem extends HAEvent {
  final DashboardItem item;
  SaveDashboardItem(this.item);
}

class DeleteDashboardItem extends HAEvent {
  final int itemId;
  DeleteDashboardItem(this.itemId);
}



class DashboardsUpdated extends HAEvent {
  final List<Dashboard> dashboards;
  DashboardsUpdated(this.dashboards);
}

class ClearDashboards extends HAEvent {}

class ToggleSnapEvent extends HAEvent {}

class SwitchDashboard extends HAEvent {
  final int dashboardId;
  SwitchDashboard(this.dashboardId);
}

class AddDashboardEvent extends HAEvent {
  final int id;
  final String name;
  final double width;
  final double height;
  AddDashboardEvent({
    required this.name,
    this.id = 0,
    this.width = 1920.0,
    this.height = 1080.0,
  });
}

class UpdateDashboardEvent extends HAEvent {
  final Dashboard dashboard;
  UpdateDashboardEvent(this.dashboard);
}

class DeleteDashboardEvent extends HAEvent {
  final int dashboardId;
  DeleteDashboardEvent(this.dashboardId);
}
