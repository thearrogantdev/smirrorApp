import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import 'package:get_it/get_it.dart';
import 'package:smirror_app/bloc/backendConnection/app_websocket_bloc.dart';
import 'package:smirror_app/bloc/backendConnection/app_websocket_event.dart';
import 'package:smirror_app/services/session_context_service.dart';
import 'package:smirror_app/l10n/app_localizations.dart';

@RoutePage()
class BiometricsScreen extends StatelessWidget {
  const BiometricsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = GetIt.I<SessionContextService>();
    final hasFace = session.hasFace;
    final hasFingerPrint = session.hasFingerPrint;
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(loc.biometricsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 8),
            child: Text(
              loc.biometricsUserEnrollment,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.only(bottom: 24),
            child: Column(
              children: [
                // ── Face Recognition ─────────────────────────────────────
                Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.face_retouching_natural,
                        color: hasFace ? null : Theme.of(context).disabledColor,
                      ),
                      title: Text(loc.biometricsFaceRecognition),
                      subtitle: Text(loc.biometricsFaceSubtitle),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        right: 16.0,
                        bottom: 8.0,
                        left: 16.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Tooltip(
                            message: hasFace
                                ? ''
                                : loc.biometricsFaceUnavailableTooltip,
                            child: FilledButton.tonal(
                              onPressed: hasFace
                                  ? () {
                                      context.read<AppWebSocketBloc>().add(
                                        AppWebSocketStartFaceTrainingRequested(),
                                      );
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            loc.biometricsFaceTrainingStart,
                                          ),
                                        ),
                                      );
                                    }
                                  : null,
                              child: Text(loc.biometricsTrainFace),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 1),
                // ── Fingerprint ──────────────────────────────────────────
                Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.fingerprint,
                        color: hasFingerPrint
                            ? null
                            : Theme.of(context).disabledColor,
                      ),
                      title: Text(loc.biometricsFingerprint),
                      subtitle: Text(loc.biometricsFingerprintSubtitle),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        right: 16.0,
                        bottom: 8.0,
                        left: 16.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Tooltip(
                            message: hasFingerPrint
                                ? ''
                                : loc.biometricsFingerprintUnavailableTooltip,
                            child: FilledButton.tonal(
                              onPressed: hasFingerPrint
                                  ? () {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            loc.biometricsFingerprintStart,
                                          ),
                                        ),
                                      );
                                    }
                                  : null,
                              child: Text(loc.biometricsTrainFinger),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
