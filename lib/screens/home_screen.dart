import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:smirror_app/dialogs/app_dialog.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smirror_app/bloc/backendConnection/app_websocket_bloc.dart';
import 'package:smirror_app/bloc/backendConnection/app_websocket_event.dart';
import 'package:smirror_app/bloc/backendConnection/back_app_websocket_bloc.dart';
import 'package:smirror_app/bloc/backendConnection/back_app_websocket_state.dart';
import 'package:smirror_app/bloc/setup_cubit.dart';
import 'package:smirror_wire/generated/app_back_app_back_generated.dart'
    as appmsg;
import 'package:smirror_wire/generated/back_app_back_app_generated.dart'
    as backmsg;
import 'package:smirror_app/l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:smirror_app/services/session_context_service.dart';

/// Describes which M3 color role a button uses.
enum ControlButtonVariant { primary, secondary, tertiary }

/// Simple model to describe an action button on the Home screen.
class ControlAction {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final ControlButtonVariant variant;
  final Color? colorOverride;

  const ControlAction({
    required this.label,
    required this.icon,
    required this.onTap,
    this.onLongPress,
    this.variant = ControlButtonVariant.primary,
    this.colorOverride,
  });
}

/// A large, tactile control button — uses M3 theme colour roles.
class ControlButton extends StatefulWidget {
  final ControlAction action;

  const ControlButton({super.key, required this.action});

  @override
  State<ControlButton> createState() => _ControlButtonState();
}

class _ControlButtonState extends State<ControlButton> {
  bool _isPressed = false;

  Color _resolveColor(ColorScheme cs) {
    switch (widget.action.variant) {
      case ControlButtonVariant.primary:
        return cs.primary;
      case ControlButtonVariant.secondary:
        return cs.secondary;
      case ControlButtonVariant.tertiary:
        return cs.tertiary;
    }
  }

  Color _resolveContainerColor(ColorScheme cs) {
    switch (widget.action.variant) {
      case ControlButtonVariant.primary:
        return cs.primaryContainer;
      case ControlButtonVariant.secondary:
        return cs.secondaryContainer;
      case ControlButtonVariant.tertiary:
        return cs.tertiaryContainer;
    }
  }

  Color _resolveOnContainerColor(ColorScheme cs) {
    switch (widget.action.variant) {
      case ControlButtonVariant.primary:
        return cs.onPrimaryContainer;
      case ControlButtonVariant.secondary:
        return cs.onSecondaryContainer;
      case ControlButtonVariant.tertiary:
        return cs.onTertiaryContainer;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = widget.action.colorOverride ?? _resolveColor(cs);
    final containerColor = widget.action.colorOverride != null
        ? widget.action.colorOverride!.withValues(alpha: 0.12)
        : _resolveContainerColor(cs);
    final onContainer =
        widget.action.colorOverride ?? _resolveOnContainerColor(cs);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.action.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      onLongPress: widget.action.onLongPress,
      child: AnimatedScale(
        scale: _isPressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutQuart,
        child: Container(
          width: 148,
          height: 148,
          decoration: BoxDecoration(
            color: containerColor,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.18),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.action.icon, size: 44, color: onContainer),
              const SizedBox(height: 10),
              Text(
                widget.action.label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: onContainer,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Centred wrap of control buttons — adapts to any screen width.
class ControlGrid extends StatelessWidget {
  final List<ControlAction> actions;

  const ControlGrid({super.key, required this.actions});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Center(
        child: Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children: actions.map((a) => ControlButton(action: a)).toList(),
        ),
      ),
    );
  }
}

@RoutePage()
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Color _ledColor = Colors.blue;
  double _ledBrightness = 255;
  bool _ledOn = false;

  void _showLedControlDialog(BuildContext context, AppWebSocketBloc appBloc) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AppDialog(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    loc.homeLedControl,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: 380,
                            child: HueRingPicker(
                              pickerColor: _ledColor,
                              onColorChanged: (color) {
                                setDialogState(() => _ledColor = color);
                                appBloc.add(
                                  AppWebSocketChangeLEDs(
                                    red: (color.r * 255).round(),
                                    green: (color.g * 255).round(),
                                    blue: (color.b * 255).round(),
                                    brightness: _ledBrightness.toInt(),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Icon(
                                Icons.brightness_medium_rounded,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  loc.brightness,
                                  style: theme.textTheme.bodyLarge
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Text(
                                '${((_ledBrightness / 255) * 100).toInt()}%',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          Slider(
                            value: _ledBrightness,
                            min: 0,
                            max: 255,
                            divisions: 255,
                            onChanged: (val) {
                              setDialogState(() => _ledBrightness = val);
                              appBloc.add(
                                AppWebSocketChangeLEDs(
                                  red: (_ledColor.r * 255).round(),
                                  green: (_ledColor.g * 255).round(),
                                  blue: (_ledColor.b * 255).round(),
                                  brightness: val.toInt(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(loc.close),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appBloc = context.read<AppWebSocketBloc>();

    // Define the list of control actions here; easy to extend later.
    List<ControlAction> buildActions(BuildContext context) {
      final loc = AppLocalizations.of(context)!;
      return [
        ControlAction(
          label: loc.homeStandBy,
          icon: Icons.bedtime_rounded,
          variant: ControlButtonVariant.secondary,
          onTap: () {
            appBloc.add(
              AppWebSocketSendSimpleCommandRequested(
                commandType: appmsg.AppSimpleCommandType.STANDBY,
              ),
            );
          },
        ),
        ControlAction(
          label: loc.homeActivateUser,
          icon: Icons.how_to_reg_rounded,
          variant: ControlButtonVariant.tertiary,
          onTap: () {
            appBloc.add(AppWebSocketActivateUserRequested());
          },
        ),
        ControlAction(
          label: loc.homeActivateGuest,
          icon: Icons.person_outline_rounded,
          variant: ControlButtonVariant.secondary,
          onTap: () {
            appBloc.add(
              AppWebSocketSendSimpleCommandRequested(
                commandType: appmsg.AppSimpleCommandType.ACTIVATE_GUEST,
              ),
            );
          },
        ),
        ControlAction(
          label: loc.homeNextTheme,
          icon: Icons.palette_rounded,
          variant: ControlButtonVariant.primary,
          onTap: () {
            appBloc.add(
              AppWebSocketSendSimpleCommandRequested(
                commandType: appmsg.AppSimpleCommandType.NEXT_THEME,
              ),
            );
          },
        ),
        ControlAction(
          label: loc.homeLedControl,
          icon: _ledOn ? Icons.light_rounded : Icons.light_outlined,
          variant: _ledOn
              ? ControlButtonVariant.primary
              : ControlButtonVariant.tertiary,
          colorOverride: _ledOn ? _ledColor : Colors.grey,
          onTap: () {
            setState(() => _ledOn = !_ledOn);
            if (_ledOn) {
              appBloc.add(
                AppWebSocketChangeLEDs(
                  red: (_ledColor.r * 255).round(),
                  green: (_ledColor.g * 255).round(),
                  blue: (_ledColor.b * 255).round(),
                  brightness: _ledBrightness.toInt(),
                ),
              );
            } else {
              appBloc.add(
                AppWebSocketSendSimpleCommandRequested(
                  commandType: appmsg.AppSimpleCommandType.LED_OFF,
                ),
              );
            }
          },
          onLongPress: () => _showLedControlDialog(context, appBloc),
        ),
      ];
    }

    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(loc.homeControlsTitle), centerTitle: true),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          // Status header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: BlocConsumer<BackAppWebSocketBloc, BackAppWebSocketState>(
              listenWhen: (previous, current) =>
                  current is BackAppWebSocketStatusReceived ||
                  current is BackAppWebSocketWelcomeReceived,
              listener: (context, state) {
                backmsg.LedStatusT? led;
                if (state is BackAppWebSocketStatusReceived) {
                  led = state.status.ledStatus;
                } else if (state is BackAppWebSocketWelcomeReceived) {
                  led = state.welcomeMessage.ledStatus;
                }
                if (led != null) {
                  setState(() {
                    _ledOn = led!.power;
                    final hasColor = led.red != 0 || led.green != 0 || led.blue != 0;
                    if (hasColor) {
                      _ledColor = Color.fromARGB(
                        255,
                        led.red,
                        led.green,
                        led.blue,
                      );
                    }
                    if (led.brightness != 0) {
                      _ledBrightness = led.brightness.toDouble();
                    }
                  });
                }
              },
              buildWhen: (previous, current) =>
                  current is BackAppWebSocketStatusReceived ||
                  current is BackAppWebSocketWelcomeReceived,
              builder: (context, state) {
                final setupState = context.watch<SetupCubit>().state;
                if (setupState.emulateHomeAssistant) {
                  return Card(
                    margin: const EdgeInsets.all(4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                    color: Theme.of(
                      context,
                    ).colorScheme.secondaryContainer.withValues(alpha: 0.4),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blueAccent,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blueAccent.withValues(
                                    alpha: 0.6,
                                  ),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  loc.emulateHomeAssistant,
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  loc.emulatedConnection,
                                  style: Theme.of(context).textTheme.labelLarge
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSecondaryContainer
                                            .withValues(alpha: 0.8),
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                // your existing builder unchanged
                if (state is BackAppWebSocketStatusReceived ||
                    state is BackAppWebSocketWelcomeReceived) {
                  final bool isOn = state is BackAppWebSocketStatusReceived
                      ? state.status.frontendOn
                      : (state as BackAppWebSocketWelcomeReceived)
                            .welcomeMessage
                            .frontendOn;
                  final String activeUser =
                      (state is BackAppWebSocketStatusReceived
                          ? state.status.activeUser
                          : (state as BackAppWebSocketWelcomeReceived)
                                .welcomeMessage
                                .activeUser) ??
                      "";
                  final deviceName =
                      GetIt.I<SessionContextService>().deviceName;
                  return Card(
                    margin: const EdgeInsets.all(4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                    color: Theme.of(context).colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.4),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      child: Row(
                        children: [
                          // Glowing dot indicator
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isOn
                                  ? Colors.greenAccent
                                  : Colors.redAccent,
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      (isOn
                                              ? Colors.greenAccent
                                              : Colors.redAccent)
                                          .withValues(alpha: 0.6),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  deviceName.isNotEmpty
                                      ? deviceName
                                      : loc.homeSystemStatus,
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${loc.homeFrontend}: ${isOn ? loc.homeOn : loc.homeOff}  •  ${loc.homeActiveUserStatus}: ${activeUser.isEmpty ? loc.homeNone : activeUser}',
                                  style: Theme.of(context).textTheme.labelLarge
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withValues(alpha: 0.6),
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return Text(loc.homeWaitingForStatus);
              },
            ),
          ),

          const SizedBox(height: 4),
          const Divider(height: 1),

          // Big buttons grid
          ControlGrid(actions: buildActions(context)),
        ],
      ),
    );
  }
}
