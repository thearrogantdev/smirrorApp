import 'package:smirror_app/bloc/viewConfig/view_config_models.dart';

class ViewConfigState {
  final List<ViewConfigPage> pages;
  final int currentPageIndex;
  final bool snapToGrid;

  /// Theme index for the view (0 = Light, 1 = Dark, 2 = Blue, 3 = Neon).
  final int selectedTheme;

  /// Language code for the view (e.g., 'en', 'de').
  final String selectedLanguage;

  ViewConfigState({
    required this.pages,
    this.currentPageIndex = 0,
    this.snapToGrid = true,
    this.selectedTheme = 0,
    this.selectedLanguage = 'en',
  });

  ViewConfigPage get currentPage => pages.isEmpty
      ? ViewConfigPage(id: 0, pageNumber: 0, items: [])
      : pages[currentPageIndex];

  ViewConfigState copyWith({
    List<ViewConfigPage>? pages,
    int? currentPageIndex,
    bool? snapToGrid,
    int? selectedTheme,
    String? selectedLanguage,
  }) {
    return ViewConfigState(
      pages: pages ?? this.pages,
      currentPageIndex: currentPageIndex ?? this.currentPageIndex,
      snapToGrid: snapToGrid ?? this.snapToGrid,
      selectedTheme: selectedTheme ?? this.selectedTheme,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
    );
  }
}
