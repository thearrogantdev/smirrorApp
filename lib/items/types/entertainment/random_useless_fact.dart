import 'package:smirror_app/items/general_text_diplay_widget_base.dart';
import 'package:smirror_wire/constants/widget_ids.dart';
import 'package:smirror_app/l10n/app_localizations.dart';

class RandomUselessFactWidgetType extends GeneralTextDisplayWidgetBase {
  RandomUselessFactWidgetType()
    : super(
        typeId: WidgetIds.randomUselessFact, // ID: 14
        nameBuilder: (ctx) =>
            AppLocalizations.of(ctx)!.widgetNameRandomUselessFact,
      );
}
