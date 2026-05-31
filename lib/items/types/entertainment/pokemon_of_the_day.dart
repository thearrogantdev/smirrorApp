import 'package:flutter/material.dart';
import 'package:smirror_app/bloc/viewConfig/view_config_models.dart';
import 'package:smirror_wire/constants/widget_ids.dart';
import 'package:smirror_app/items/widget_type_definition.dart';
import 'package:smirror_app/l10n/app_localizations.dart' show AppLocalizations;

class PokemonOfTheDayWidgetType extends WidgetTypeDefinition {
  PokemonOfTheDayWidgetType()
    : super(
        typeId: WidgetIds.pokemonOfTheDay,
        nameBuilder: (ctx) =>
            AppLocalizations.of(ctx)!.widgetNamePokemonOfTheDay,
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
      ),
      child: Center(
        child: Image.network(
          // Static preview for the config app (Bulbasaur)
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/1.png',
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => const Icon(
            Icons.catching_pokemon,
            color: Colors.white24,
            size: 50,
          ),
        ),
      ),
    );
  }

  @override
  Future<List<ViewConfigProperty>?> promptForProperties(
    BuildContext context, {
    List<ViewConfigProperty>? initial,
    VoidCallback? onDelete,
  }) {
    return Future.value(createDefaultProperties());
  }
}
