import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:smirror_app/bloc/homeAssistant/home_assistant_event.dart';
import 'package:smirror_app/bloc/homeAssistant/home_assistant_state.dart';
import 'package:smirror_app/database/home_assistant_store.dart';
import 'package:smirror_app/database/home_dashboard.dart';

class HABloc extends Bloc<HAEvent, HAState> {
  final _store = GetIt.I<HomeAssistantStore>();
  StreamSubscription<List<Dashboard>>? _dashboardSub;

  HABloc() : super(HAInitial()) {
    on<LoadDashboard>(_onLoadDashboard);
    on<SaveDashboardItem>(_onSaveItem);
    on<DeleteDashboardItem>(_onDeleteItem);
    on<AddDashboardEvent>(_handleAddDashboard);
    on<UpdateDashboardEvent>(_handleUpdateDashboard);
    on<DeleteDashboardEvent>(_handleDeleteDashboard);
    on<SwitchDashboard>(_handleSwitchDashboard);
    on<ToggleSnapEvent>(_handleToggleSnap);
    on<ClearDashboards>(_onClearDashboards);
    on<DashboardsUpdated>(_onDashboardsUpdated);

    _subscribeToDashboards();
  }

  void _subscribeToDashboards() {
    _dashboardSub?.cancel();
    _dashboardSub = _store.watchDashboards().listen((dashboards) {
      add(DashboardsUpdated(dashboards));
    });
  }

  void _onClearDashboards(ClearDashboards event, Emitter<HAState> emit) {
    emit(HAInitial());
  }

  Future<void> _onDashboardsUpdated(
    DashboardsUpdated event,
    Emitter<HAState> emit,
  ) async {
    if (event.dashboards.isEmpty) {
      emit(
        HASuccess(
          dashboardItems: const [],
          dashboards: const [],
          currentDashboardId: null,
        ),
      );
      return;
    }

    // Keep the currently selected dashboard if it still exists, otherwise fall back to first
    final currentId = state is HASuccess
        ? (state as HASuccess).currentDashboardId
        : null;
    final selectedId = event.dashboards.any((d) => d.id == currentId)
        ? currentId
        : event.dashboards.first.id;

    final items = _store.getItemsForDashboard(selectedId!);

    emit(
      HASuccess(
        dashboardItems: items,
        dashboards: event.dashboards,
        currentDashboardId: selectedId,
      ),
    );
  }

  @override
  Future<void> close() {
    _dashboardSub?.cancel();
    return super.close();
  }

  Future<void> _onLoadDashboard(
    LoadDashboard event,
    Emitter<HAState> emit,
  ) async {
    final items = _store.getItemsForDashboard(event.dashboardId);
    if (state is HASuccess) {
      emit(
        (state as HASuccess).copyWith(
          dashboardItems: items,
          currentDashboardId: event.dashboardId,
        ),
      );
    }
  }

  Future<void> _onSaveItem(
    SaveDashboardItem event,
    Emitter<HAState> emit,
  ) async {
    _store.saveItem(event.item);
    final dashboardId = event.item.dashboard.targetId;
    final updatedItems = _store.getItemsForDashboard(dashboardId);

    if (state is HASuccess) {
      emit(
        (state as HASuccess).copyWith(
          dashboardItems: updatedItems,
          currentDashboardId: dashboardId,
        ),
      );
    }
  }

  Future<void> _onDeleteItem(
    DeleteDashboardItem event,
    Emitter<HAState> emit,
  ) async {
    if (state is! HASuccess) return;
    final currentState = state as HASuccess;
    _store.deleteItem(event.itemId);

    final currentId = currentState.currentDashboardId;
    if (currentId != null) {
      final updatedItems = _store.getItemsForDashboard(currentId);
      emit(currentState.copyWith(dashboardItems: updatedItems));
    }
  }

  Future<void> _handleAddDashboard(
    AddDashboardEvent event,
    Emitter<HAState> emit,
  ) async {
    _store.saveDashboard(
      Dashboard(
        id: event.id, // 0 = new, non-zero = update existing
        name: event.name,
        width: event.width,
        height: event.height,
        order: 0,
      ),
    );
  }

  Future<void> _handleUpdateDashboard(
    UpdateDashboardEvent event,
    Emitter<HAState> emit,
  ) async {
    _store.saveDashboard(event.dashboard);
    if (state is HASuccess) {
      final s = state as HASuccess;
      final dashboards = _store.getAllDashboards();
      emit(s.copyWith(dashboards: dashboards));
    }
  }

  Future<void> _handleDeleteDashboard(
    DeleteDashboardEvent event,
    Emitter<HAState> emit,
  ) async {
    if (state is! HASuccess) return;
    _store.deleteDashboard(event.dashboardId);
  }

  Future<void> _handleSwitchDashboard(
    SwitchDashboard event,
    Emitter<HAState> emit,
  ) async {
    add(LoadDashboard(event.dashboardId));
  }

  void _handleToggleSnap(ToggleSnapEvent event, Emitter<HAState> emit) {
    if (state is HASuccess) {
      final s = state as HASuccess;
      emit(s.copyWith(snapToGrid: !s.snapToGrid));
    }
  }
}
