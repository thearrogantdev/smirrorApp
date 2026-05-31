import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:smirror_app/bloc/viewConfig/view_config_models.dart';
import 'package:smirror_app/items/widget_type_definition.dart';
import 'package:smirror_app/l10n/app_localizations.dart' show AppLocalizations;
import 'package:smirror_wire/constants/widget_ids.dart';

const _randomDogEndpoint = 'https://dog.ceo/api/breeds/image/random';

class RandomDogWidgetType extends WidgetTypeDefinition {
  RandomDogWidgetType()
    : super(
        typeId: WidgetIds.randomDog,
        nameBuilder: (ctx) => AppLocalizations.of(ctx)!.widgetNameRandomDog,
        defaultSize: const Size(200, 200),
      );

  @override
  List<ViewConfigProperty> createDefaultProperties() => [];

  @override
  Widget buildChild(ViewConfigItem item) {
    return const _RandomDogPreview();
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

class _RandomDogPreview extends StatefulWidget {
  const _RandomDogPreview();

  @override
  State<_RandomDogPreview> createState() => _RandomDogPreviewState();
}

class _RandomDogPreviewState extends State<_RandomDogPreview> {
  String? _imageUrl;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchDogImage();
  }

  Future<void> _fetchDogImage() async {
    try {
      final response = await http.get(Uri.parse(_randomDogEndpoint));
      if (response.statusCode != 200) {
        throw Exception('Dog API request failed: ${response.statusCode}');
      }

      final data = jsonDecode(response.body);
      final imageUrl = data is Map<String, dynamic> ? data['message'] : null;
      final status = data is Map<String, dynamic> ? data['status'] : null;
      if (status != 'success' || imageUrl is! String || imageUrl.isEmpty) {
        throw Exception('Dog API returned invalid data');
      }

      if (!mounted) return;
      setState(() {
        _imageUrl = imageUrl;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: _imageUrl == null
          ? const Center(
              child: Icon(Icons.pets, color: Colors.white54, size: 40),
            )
          : Image.network(
              _imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Center(
                child: Icon(Icons.pets, color: Colors.white54, size: 40),
              ),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(child: CircularProgressIndicator());
              },
            ),
    );
  }
}
