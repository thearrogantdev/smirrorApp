import 'package:material_ui/material_ui.dart';
import 'package:smirror_app/bloc/viewConfig/view_config_models.dart';
import 'package:smirror_wire/constants/widget_ids.dart';
import 'package:smirror_app/items/widget_type_definition.dart';
import 'package:smirror_app/l10n/app_localizations.dart' show AppLocalizations;

class RandomPokemonWidgetType extends WidgetTypeDefinition {
  RandomPokemonWidgetType()
    : super(
        typeId: WidgetIds.randomPokemon,
        nameBuilder: (ctx) => AppLocalizations.of(ctx)!.widgetNameRandomPokemon,
        defaultSize: const Size(150, 150),
      );

  @override
  List<ViewConfigProperty> createDefaultProperties() => [];

  @override
  Widget buildChild(ViewConfigItem item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(Icons.help_outline, color: Colors.white10, size: 80),
          Image.network(
            // Representative preview (Pikachu)
            'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/25.png',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.catching_pokemon,
              color: Colors.white24,
              size: 50,
            ),
          ),
        ],
      ),
    );
  }
}
