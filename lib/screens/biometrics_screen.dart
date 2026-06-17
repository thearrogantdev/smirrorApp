import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import 'package:get_it/get_it.dart';
import 'package:smirror_app/bloc/backendConnection/app_websocket_bloc.dart';
import 'package:smirror_app/bloc/backendConnection/app_websocket_event.dart';
import 'package:smirror_app/bloc/backendConnection/back_app_websocket_bloc.dart';
import 'package:smirror_app/bloc/backendConnection/back_app_websocket_state.dart';
import 'package:smirror_app/services/session_context_service.dart';
import 'package:smirror_app/l10n/app_localizations.dart';
import 'package:smirror_wire/generated/back_app_back_app_generated.dart' as backmsg;

@RoutePage()
class BiometricsScreen extends StatefulWidget {
  const BiometricsScreen({super.key});

  @override
  State<BiometricsScreen> createState() => _BiometricsScreenState();
}

class _BiometricsScreenState extends State<BiometricsScreen> {
  Timer? _trainingTimer;
  bool _isTraining = false;
  BuildContext? _dialogContext;

  void _startTraining(BuildContext context) {
    if (_isTraining) return;

    setState(() {
      _isTraining = true;
    });

    final loc = AppLocalizations.of(context)!;

    // Start 80 seconds timeout timer to hard reset/remove popup
    _trainingTimer = Timer(const Duration(seconds: 80), () {
      _stopTrainingAndCloseDialog();
    });

    // Send the websocket request
    context.read<AppWebSocketBloc>().add(
      AppWebSocketStartFaceTrainingRequested(),
    );

    // Show blocking dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        _dialogContext = dialogContext;
        return PopScope(
          canPop: false, // Prevent back button on Android
          child: AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 24),
                Text(
                  loc.biometricsFaceTrainingStart,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _stopTrainingAndCloseDialog() {
    if (!_isTraining) return;

    _trainingTimer?.cancel();
    _trainingTimer = null;

    setState(() {
      _isTraining = false;
    });

    if (_dialogContext != null) {
      Navigator.of(_dialogContext!).pop();
      _dialogContext = null;
    }
  }

  @override
  void dispose() {
    _trainingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = GetIt.I<SessionContextService>();
    final hasFace = session.hasFace;
    final hasFingerPrint = session.hasFingerPrint;
    final loc = AppLocalizations.of(context)!;

    return BlocListener<BackAppWebSocketBloc, BackAppWebSocketState>(
      listener: (context, state) {
        if (state is BackAppWebSocketResultReceived) {
          final errorCode = state.result.errorCode;
          if (errorCode == backmsg.ErrorCode.FACE_TRAINING_SUCCESS ||
              errorCode == backmsg.ErrorCode.FACE_TRAINING_FAILED) {
            _stopTrainingAndCloseDialog();
          }
        } else if (state is BackAppWebSocketFailure) {
          _stopTrainingAndCloseDialog();
        }
      },
      child: Scaffold(
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
                                    ? () => _startTraining(context)
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
      ),
    );
  }
}
