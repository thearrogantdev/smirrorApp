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
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';
import 'package:smirror_app/bloc/backendConnection/back_app_websocket_state.dart';
import 'package:smirror_wire/generated/back_app_back_app_generated.dart' as backmsg;
import 'package:smirror_app/services/websocket_service.dart';
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

  // On Web, request and await the Google clientId from backend so GSI can initialize
  if (kIsWeb && (repo.clientId == null || repo.clientId!.isEmpty)) {
    appBloc.add(
      AppWebSocketSendSimpleCommandRequested(
        commandType: appmsg.AppSimpleCommandType.GET_GOOGLE_SECRET,
      ),
    );
    for (int i = 0; i < 30; i++) {
      if (repo.clientId != null && repo.clientId!.isNotEmpty) {
        break;
      }
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  await repo.ensureTokenPresent(
    appBloc: appBloc,
    backStream: backStream,
    force: true,
  );
  if (!context.mounted) return null;

  final connected = ValueNotifier<bool>(repo.hasToken);

  // Local state variables for manual OAuth copy-paste flow on Web
  bool isWebLoading = false;
  String? webErrorMessage;
  final TextEditingController webUrlController = TextEditingController();

  String? extractCode(String input) {
    try {
      final uri = Uri.parse(input.trim());
      if (uri.queryParameters.containsKey('code')) {
        return uri.queryParameters['code'];
      }
    } catch (_) {}
    final reg = RegExp(r'[?&]code=([^&]+)');
    final match = reg.firstMatch(input);
    if (match != null) {
      return Uri.decodeComponent(match.group(1)!);
    }
    if (input.length > 20 && !input.contains('/') && !input.contains('?')) {
      return input;
    }
    return null;
  }

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
  if (!context.mounted) return null;

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
                if (kIsWeb)
                  StatefulBuilder(
                    builder: (ctx2, setState) {
                      if (isWebLoading) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text("Linking Google account... Please wait."),
                            ],
                          ),
                        );
                      }

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            "Google Calendar access requires authorization. Since this app runs on a local IP, follow these steps:",
                            style: Theme.of(ctx).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "1. Click the button below to sign in and grant permission. It will open in a new window/tab.",
                            style: Theme.of(ctx).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 8),
                          FilledButton.icon(
                            onPressed: () async {
                              if (repo.clientId == null || repo.clientId!.isEmpty) {
                                setState(() {
                                  webErrorMessage = "Client ID is empty. Re-opening dialog might help.";
                                });
                                return;
                              }
                              final redirectUri = 'http://localhost';

                              final authUrl = 'https://accounts.google.com/o/oauth2/v2/auth'
                                  '?client_id=${repo.clientId}'
                                  '&redirect_uri=${Uri.encodeComponent(redirectUri)}'
                                  '&response_type=code'
                                  '&scope=${Uri.encodeComponent('https://www.googleapis.com/auth/calendar.readonly')}'
                                  '&access_type=offline'
                                  '&prompt=consent';
                              final uri = Uri.parse(authUrl);
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri, mode: LaunchMode.externalApplication);
                              } else {
                                setState(() {
                                  webErrorMessage = "Could not open authorization page automatically. Please visit: $authUrl";
                                });
                              }
                            },
                            icon: const Icon(Icons.open_in_new),
                            label: const Text("Open Google Consent Page"),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "2. The consent screen will redirect to a broken page starting with 'http://localhost${Uri.base.port == 0 || Uri.base.port == 80 || Uri.base.port == 443 ? "" : ":${Uri.base.port}"}/'. This is normal. Copy that entire broken URL from your browser's address bar, paste it below, and click 'Link Account'.",
                            style: Theme.of(ctx).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: webUrlController,
                            decoration: InputDecoration(
                              labelText: "Paste Redirection URL",
                              hintText: "http://localhost/?code=...",
                              errorText: webErrorMessage,
                              border: const OutlineInputBorder(),
                            ),
                            onChanged: (_) {
                              if (webErrorMessage != null) {
                                setState(() {
                                  webErrorMessage = null;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 12),
                          FilledButton.icon(
                            onPressed: () async {
                              final input = webUrlController.text.trim();
                              if (input.isEmpty) {
                                setState(() {
                                  webErrorMessage = "Please paste the redirect URL first.";
                                });
                                return;
                              }

                              final code = extractCode(input);
                              if (code == null) {
                                setState(() {
                                  webErrorMessage = "Could not find a valid code in the pasted text.";
                                });
                                return;
                              }

                              setState(() {
                                isWebLoading = true;
                                webErrorMessage = null;
                              });

                              try {
                                final resultFuture = backStream
                                    .where((s) => s is BackAppWebSocketResultReceived)
                                    .cast<BackAppWebSocketResultReceived>()
                                    .firstWhere((s) => s.result.errorCode == backmsg.ErrorCode.ADD_TOKEN)
                                    .timeout(const Duration(seconds: 15));

                                appBloc.add(
                                  AppWebSocketRequestGoogleToken(
                                    code: code,
                                    adminPassword: GetIt.I<WebSocketService>().password
                                  ),
                                );

                                final resultState = await resultFuture;
                                if (resultState.result.success) {
                                  await repo.ensureTokenPresent(
                                    appBloc: appBloc,
                                    backStream: backStream,
                                    force: true,
                                  );

                                  if (repo.hasToken) {
                                    final fetched = await repo.fetchCalendars();
                                    calendars = fetched;
                                    for (final id in existingIds) {
                                      final hasExisting = calendars.any((c) => c.id == id);
                                      if (!hasExisting && id.isNotEmpty && id != 'primary') {
                                        calendars.insert(0, GoogleCalendarEntry(id: id, summary: id));
                                      }
                                    }
                                    connected.value = true;
                                  } else {
                                    setState(() {
                                      webErrorMessage = "Auth code accepted, but token could not be verified.";
                                    });
                                  }
                                } else {
                                  setState(() {
                                    webErrorMessage = resultState.result.errorMessage ?? "Failed to add token.";
                                  });
                                }
                              } catch (e) {
                                setState(() {
                                  webErrorMessage = "Failed to communicate with backend: $e";
                                });
                              } finally {
                                setState(() {
                                  isWebLoading = false;
                                });
                              }
                            },
                            icon: const Icon(Icons.link),
                            label: const Text("Link Account"),
                          ),
                        ],
                      );
                    },
                  )
                else
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

  webUrlController.dispose();
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
