import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get_it/get_it.dart';
import 'package:smirror_app/bloc/backendConnection/app_websocket_bloc.dart';
import 'package:smirror_app/bloc/backendConnection/app_websocket_event.dart';
import 'package:smirror_app/bloc/backendConnection/back_app_websocket_bloc.dart';
import 'package:smirror_app/bloc/viewConfig/view_config_models.dart';
import 'package:smirror_app/dialogs/widget_config_dialog.dart';
import 'package:smirror_wire/generated/app_back_app_back_generated.dart' as appmsg;
import 'package:smirror_wire/generated/widget_internals_widget_internals_generated.dart';
import 'package:smirror_app/l10n/app_localizations.dart' show AppLocalizations;
import 'package:smirror_app/services/google_token_service.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

// Optional extra fields for a calendar-using widget.
const _fMaxResults = 'k_maxResults';

const List<String> _availableFonts = [
  'Roboto',
  'Open Sans',
  'Montserrat',
  'Lato',
  'Orbitron',
  'Raleway',
  'Roboto Mono',
];

// (duplicate removed)

String _readString(List<ViewConfigProperty>? props, int key, String fallback) {
  if (props == null) return fallback;
  for (final p in props) {
    if (p.key == key) return p.stringValue ?? fallback;
  }
  return fallback;
}

int _readInt(List<ViewConfigProperty>? props, int key, int fallback) {
  if (props == null) return fallback;
  for (final p in props) {
    if (p.key == key) return p.intValue ?? fallback;
  }
  return fallback;
}

/// Show a config dialog for a Google Calendar-powered widget:
/// - Ensures a Google token exists (backend or new via UI button)
/// - (Optional) lets the user edit calendarId / maxResults fields
///
/// If you don't need calendarId/maxResults, just omit the prop IDs
/// (pass null) and we’ll only take care of the token.
Future<List<ViewConfigProperty>?> promptGoogleCalendarProperties(
  BuildContext context, {
  required int calendarIdPropId,
  required int fontSizePropId,
  required int fontFamilyPropId,
  List<ViewConfigProperty>? initial,
  VoidCallback? onDelete,
}) async {
  final loc = AppLocalizations.of(context)!;
  final appBloc = context.read<AppWebSocketBloc>();
  final backStream = context.read<BackAppWebSocketBloc>().stream;
  final repo = GetIt.I<GoogleTokenRepository>();

  await repo.ensureTokenPresent(appBloc: appBloc, backStream: backStream);
  if (!context.mounted) return null;

  final connected = ValueNotifier<bool>(repo.hasToken);

  // 2. Read existing values
  List<String> existingIds = [];
  final calProp = initial?.where((p) => p.key == calendarIdPropId).firstOrNull;
  if (calProp != null) {
    if (calProp.type == ViewConfigPropertyType.rawBytes &&
        calProp.rawBytes != null &&
        calProp.rawBytes!.isNotEmpty) {
      try {
        final fb = GoogleCaledarIds(calProp.rawBytes!);
        existingIds = fb.ids?.toList() ?? [];
      } catch (e) {
        debugPrint('Error parsing calendar IDs flatbuf: $e');
      }
    } else if (calProp.type == ViewConfigPropertyType.string &&
        calProp.stringValue != null) {
      existingIds = [calProp.stringValue!];
    }
  }
  if (existingIds.isEmpty) existingIds = ['primary'];

  final existingSize = _readInt(initial, fontSizePropId, 14);
  final rawFont = _readString(initial, fontFamilyPropId, 'Roboto');
  final initialFont = _availableFonts.contains(rawFont) ? rawFont : 'Roboto';

  GlobalKey<FormBuilderState>? fbKey;

  // 3. Fetch calendars if connected
  List<GoogleCalendarEntry> calendars = [];
  if (repo.hasToken) {
    calendars = await repo.fetchCalendars();

    // Ensure all existing IDs are in the list (or at least known)
    for (final id in existingIds) {
      final hasExisting = calendars.any((c) => c.id == id);
      if (!hasExisting && id.isNotEmpty && id != 'primary') {
        calendars.insert(0, GoogleCalendarEntry(id: id, summary: id));
      }
    }
  }

  final values = await showConfigDialog<Map<String, dynamic>>(
    context: context,
    title: loc.googleCalendarSettingsTitle,
    onDelete: onDelete,
    initialValues: {
      'calIds': existingIds,
      'calIdSingle': existingIds.isNotEmpty ? existingIds.first : 'primary',
      'size': existingSize.toString(),
      'font': initialFont,
    },
    buildForm: (ctx, formKey) {
      fbKey = formKey;
      return ValueListenableBuilder<bool>(
        valueListenable: connected,
        builder: (_, isConnected, _) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!isConnected) ...[

                FilledButton.icon(
                  onPressed: () async {
                    appBloc.add(
                      AppWebSocketSendSimpleCommandRequested(
                        commandType: appmsg.AppSimpleCommandType.GET_GOOGLE_SECRET,
                      ),
                    );

                    if (repo.clientId == null || repo.clientId!.isEmpty) {
                      await Future.delayed(const Duration(milliseconds: 300));
                    }

                    if (repo.clientId == null || repo.clientId!.isEmpty) {
                      if (!ctx.mounted) return;
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(
                            content: Text("Google credentials not configured on backend.")),
                      );
                      return;
                    }

                    final headers = await repo.ensureAuthorizationHeaders(
                      scopes: const ['https://www.googleapis.com/auth/calendar.readonly'],
                      fromUserGesture: true,
                    );

                    if (headers != null) {
                      repo.sendToBackend(appBloc: appBloc);
                      calendars = await repo.fetchCalendars();
                      // Ensure all existing IDs are in the list (or at least known)
                      for (final id in existingIds) {
                        final hasExisting = calendars.any((c) => c.id == id);
                        if (!hasExisting && id.isNotEmpty && id != 'primary') {
                          calendars.insert(0, GoogleCalendarEntry(id: id, summary: id));
                        }
                      }
                      connected.value = true;
                    }
                  },
                  icon: const Icon(Icons.login),
                  label: Text(loc.adminTokenAdd),
                ),
                const SizedBox(height: 16),
              ],

              if (isConnected && calendars.isNotEmpty)
                FormBuilderCheckboxGroup<String>(
                  name: 'calIds',
                  decoration: InputDecoration(
                    labelText: loc.googleCalendarIdLabel,
                  ),
                  options:
                      calendars
                          .map(
                            (c) => FormBuilderFieldOption(
                              value: c.id,
                              child: Text(c.summary),
                            ),
                          )
                          .toList(),
                  validator: FormBuilderValidators.required(),
                )
              else
                FormBuilderTextField(
                  name: 'calIdSingle',
                  decoration: InputDecoration(
                    labelText: loc.googleCalendarIdLabel,
                    hintText:
                        isConnected
                            ? (calendars.isEmpty
                                ? 'No calendars found - enter ID manually'
                                : 'primary')
                            : null,
                  ),
                  validator: FormBuilderValidators.required(),
                ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: FormBuilderTextField(
                      name: 'size',
                      decoration: InputDecoration(labelText: loc.fontSize),
                      keyboardType: TextInputType.number,
                      validator: FormBuilderValidators.integer(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FormBuilderDropdown<String>(
                      name: 'font',
                      decoration: InputDecoration(labelText: loc.fontFamily),
                      items:
                          _availableFonts
                              .map(
                                (f) =>
                                    DropdownMenuItem(value: f, child: Text(f)),
                              )
                              .toList(),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      );
    },
    onSubmit: (values) async {
      if (!connected.value) {
        return null; // Don't let users save if they have no token.
      }

      // Optional sanity for numeric field
      if (values[_fMaxResults] != null) {
        final asStr = values[_fMaxResults].toString();
        final parsed = int.tryParse(asStr);
        if (parsed == null || parsed <= 0) {
          fbKey?.currentState?.fields[_fMaxResults]?.invalidate(
            loc.googleMaxResultsInvalid,
          );
          return null;
        }
      }

      return values; // close dialog
    },
  );

  if (values == null) return null;

  final List<String> selectedIds =
      (values['calIds'] as List<dynamic>?)?.cast<String>() ??
      [values['calIdSingle'] as String];

  final serializedIds =
      GoogleCaledarIdsObjectBuilder(ids: selectedIds).toBytes();

  return [
    ViewConfigProperty(
      key: calendarIdPropId,
      type: ViewConfigPropertyType.rawBytes,
      rawBytes: serializedIds,
    ),
    ViewConfigProperty(
      key: fontSizePropId,
      type: ViewConfigPropertyType.int,
      intValue: int.tryParse(values['size'].toString()) ?? 14,
    ),
    ViewConfigProperty(
      key: fontFamilyPropId,
      type: ViewConfigPropertyType.string,
      stringValue: values['font'],
    ),
  ];
}
