import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:smirror_app/bloc/viewConfig/view_config_event.dart';
import 'package:smirror_app/bloc/viewConfig/view_config_models.dart';
import 'package:smirror_app/bloc/viewConfig/view_config_state.dart';
import 'package:smirror_app/database/view_store.dart';
import 'package:smirror_app/services/user_service.dart';

class ViewConfigBloc extends Bloc<ViewConfigEvent, ViewConfigState> {
  final ViewStore _repository = GetIt.I<ViewStore>();
  final UserService _userService = GetIt.I<UserService>();
  int? _viewId;

  late final StreamSubscription<User?> _userSub;

  ViewConfigBloc({int? initialViewId})
    : super(
        ViewConfigState(
          pages: initialViewId != null
              ? GetIt.I<ViewStore>().loadPagesForView(initialViewId)
              : [
                  ViewConfigPage(
                    id: DateTime.now().microsecondsSinceEpoch,
                    pageNumber: 0,
                    items: [],
                  ),
                ],
        ),
      ) {
    on<AddPageEvent>(_onAddPage);
    on<RemovePageEvent>(_onRemovePage);
    on<SwitchPageEvent>(_onSwitchPage);
    on<AddItemEvent>(_onAddItem);
    on<UpdateItemEvent>(_onUpdateItem);
    on<RemoveItemEvent>(_onRemoveItem);
    on<ToggleSnapEvent>(_onToggleSnapEvent);
    on<SetThemeEvent>(_onSetTheme);
    on<SetLanguageEvent>(_onSetLanguage);
    on<UserChangedEvent>(_onUserChanged);

    _userSub = _userService.onUserChanged.listen((u) async {
      add(UserChangedEvent(u));
    });

    final cur = _userService.currentUser;
    if (cur != null) {
      add(UserChangedEvent(_userService.currentUser));
    }
  }

  Future<void> _onUserChanged(
    UserChangedEvent event,
    Emitter<ViewConfigState> emit,
  ) async {
    final u = event.user;

    if (u == null) {
      emit(state.copyWith(pages: [], currentPageIndex: 0));
      return;
    }

    try {
      final userId = u.localUserId;
      final views = _repository.getViewsForUser(userId);

      int viewId;
      if (views.isEmpty) {
        viewId = _repository.createViewForUser(userId);
      } else {
        viewId = views.first.id;
      }

      _viewId = viewId;
      final pages = _repository.loadPagesForView(viewId);
      final theme = _repository.getThemeForView(viewId);
      final language = _repository.getLanguageForView(viewId);
      emit(
        state.copyWith(
          pages: pages,
          currentPageIndex: 0,
          selectedTheme: theme,
          selectedLanguage: language,
        ),
      );
    } catch (e) {
      // Handle errors here
    }
  }

  // Persist helper uses the current _viewId
  void _persist(List<ViewConfigPage> pages) {
    if (_viewId == null) return;
    _repository.savePagesForView(_viewId!, pages);
  }

  // --- existing handlers mostly unchanged but using _persist ---
  void _onToggleSnapEvent(
    ToggleSnapEvent event,
    Emitter<ViewConfigState> emit,
  ) {
    emit(state.copyWith(snapToGrid: !state.snapToGrid));
  }

  void _onSetTheme(SetThemeEvent event, Emitter<ViewConfigState> emit) {
    if (_viewId == null) return;
    _repository.saveThemeForView(_viewId!, event.theme);
    emit(state.copyWith(selectedTheme: event.theme));
  }

  void _onSetLanguage(SetLanguageEvent event, Emitter<ViewConfigState> emit) {
    if (_viewId == null) return;
    _repository.saveLanguageForView(_viewId!, event.language);
    emit(state.copyWith(selectedLanguage: event.language));
  }

  void _onAddPage(AddPageEvent event, Emitter<ViewConfigState> emit) {
    final newPage = ViewConfigPage(
      id: DateTime.now().microsecondsSinceEpoch,
      pageNumber: state.pages.length,
      items: [],
    );

    final pages = [...state.pages, newPage];
    _persist(pages);
    emit(state.copyWith(pages: pages, currentPageIndex: pages.length - 1));
  }

  void _onRemovePage(RemovePageEvent event, Emitter<ViewConfigState> emit) {
    if (state.pages.length <= 1) return;
    final pages = [...state.pages]..removeAt(state.currentPageIndex);
    final newIndex = state.currentPageIndex.clamp(0, pages.length - 1);
    _persist(pages);
    emit(state.copyWith(pages: pages, currentPageIndex: newIndex));
  }

  void _onSwitchPage(SwitchPageEvent event, Emitter<ViewConfigState> emit) {
    if (event.index case final i when i >= 0 && i < state.pages.length) {
      emit(state.copyWith(currentPageIndex: i));
    }
  }

  void _onAddItem(AddItemEvent event, Emitter<ViewConfigState> emit) {
    if (state.pages.isEmpty) return;
    final page = state.currentPage;
    final newItem = ViewConfigItem(
      id: DateTime.now().microsecondsSinceEpoch,
      position: event.position,
      size: event.size,
      widgetType: event.widgetType,
      properties: event.properties,
    );

    final updatedPage = page.copyWith(items: [...page.items, newItem]);
    final pages = [...state.pages]..[state.currentPageIndex] = updatedPage;
    _persist(pages);
    emit(state.copyWith(pages: pages));
  }

  void _onUpdateItem(UpdateItemEvent event, Emitter<ViewConfigState> emit) {
    if (state.pages.isEmpty) return;
    final page = state.currentPage;
    final updatedItems = [
      for (final item in page.items)
        if (item.id == event.updatedItem.id) event.updatedItem else item,
    ];
    final updatedPage = page.copyWith(items: updatedItems);
    final pages = [...state.pages]..[state.currentPageIndex] = updatedPage;
    _persist(pages);
    emit(state.copyWith(pages: pages));
  }

  void _onRemoveItem(RemoveItemEvent event, Emitter<ViewConfigState> emit) {
    if (state.pages.isEmpty) return;
    final page = state.currentPage;
    final updatedItems = [
      for (final item in page.items)
        if (item.id != event.item.id) item,
    ];
    final updatedPage = page.copyWith(items: updatedItems);
    final pages = [...state.pages]..[state.currentPageIndex] = updatedPage;
    _persist(pages);
    emit(state.copyWith(pages: pages));
  }

  @override
  Future<void> close() {
    _userSub.cancel();
    return super.close();
  }
}
