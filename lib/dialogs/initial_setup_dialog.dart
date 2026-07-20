import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smirror_app/dialogs/app_dialog.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:smirror_app/bloc/backendConnection/app_websocket_bloc.dart';
import 'package:smirror_app/bloc/backendConnection/app_websocket_event.dart';
import 'package:smirror_app/bloc/backendConnection/back_app_websocket_bloc.dart';
import 'package:smirror_app/bloc/backendConnection/back_app_websocket_state.dart';
import 'package:smirror_app/l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:smirror_app/services/websocket_service.dart';

class InitialSetupDialog extends StatefulWidget {
  final bool initialAutoSwitch;

  const InitialSetupDialog({super.key, required this.initialAutoSwitch});

  @override
  State<InitialSetupDialog> createState() => _InitialSetupDialogState();
}

class _InitialSetupDialogState extends State<InitialSetupDialog> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  bool _isSubmitting = false;

  static const _fieldDeviceName = 'device_name';
  static const _fieldAutoSwitch = 'auto_switch';
  static const _fieldPassword = 'password';
  static const _fieldConfirmPassword = 'confirm_password';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return BlocListener<BackAppWebSocketBloc, BackAppWebSocketState>(
      listener: (context, state) {
        if (state is BackAppWebSocketResultReceived && _isSubmitting) {
          if (state.result.success) {
            // If the result is specifically for password change or just a generic success
            // we should update the local credentials
            final newPassword =
                _formKey.currentState?.fields[_fieldPassword]?.value as String?;
            if (newPassword != null) {
              GetIt.I<WebSocketService>().saveCredentials(
                username: 'admin',
                password: newPassword,
              );
            }
            Navigator.of(context).pop();
          } else {
            setState(() => _isSubmitting = false);
          }
        }
      },
      child: PopScope(
        canPop: false, // Force setup completion
        child: AppDialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.auto_fix_high_rounded,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.setupDialogTitle,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l10n.setupDialogDescription,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 24),
                      FormBuilder(
                        key: _formKey,
                        initialValue: {
                          _fieldAutoSwitch: widget.initialAutoSwitch,
                          _fieldDeviceName: '',
                        },
                        child: Column(
                          children: [
                            FormBuilderTextField(
                              name: _fieldDeviceName,
                              decoration: InputDecoration(
                                labelText: l10n.adminDeviceName,
                                prefixIcon: const Icon(Icons.badge_outlined),
                                border: const OutlineInputBorder(),
                                filled: true,
                              ),
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.required(),
                                FormBuilderValidators.minLength(3),
                                FormBuilderValidators.maxLength(32),
                              ]),
                            ),
                            const SizedBox(height: 16),
                            FormBuilderSwitch(
                              name: _fieldAutoSwitch,
                              title: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(l10n.adminAutoSwitch),
                                  const SizedBox(width: 8),
                                  Tooltip(
                                    message: l10n.adminAutoSwitchTooltip,
                                    triggerMode: TooltipTriggerMode.tap,
                                    child: const Icon(Icons.help_outline, size: 20),
                                  ),
                                ],
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                              ),
                            ),
                            const Divider(height: 32),
                            FormBuilderTextField(
                              name: _fieldPassword,
                              obscureText: !_passwordVisible,
                              decoration: InputDecoration(
                                labelText: l10n.setupAdminPasswordLabel,
                                prefixIcon: const Icon(Icons.lock_outline),
                                border: const OutlineInputBorder(),
                                filled: true,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _passwordVisible
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                  ),
                                  onPressed: () => setState(
                                    () => _passwordVisible = !_passwordVisible,
                                  ),
                                ),
                              ),
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.required(),
                                FormBuilderValidators.minLength(8),
                              ]),
                            ),
                            const SizedBox(height: 16),
                            FormBuilderTextField(
                              name: _fieldConfirmPassword,
                              obscureText: !_confirmPasswordVisible,
                              decoration: InputDecoration(
                                labelText: l10n.setupAdminPasswordConfirmLabel,
                                prefixIcon: const Icon(Icons.lock_reset_outlined),
                                border: const OutlineInputBorder(),
                                filled: true,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _confirmPasswordVisible
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                  ),
                                  onPressed: () => setState(
                                    () => _confirmPasswordVisible =
                                        !_confirmPasswordVisible,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                final password =
                                    _formKey
                                            .currentState
                                            ?.fields[_fieldPassword]
                                            ?.value
                                        as String?;
                                if (value == null || value.isEmpty) {
                                  return l10n.validatorRequired;
                                }
                                if (value != password) {
                                  return l10n.adminValidatorPasswordMismatch;
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (_isSubmitting)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    FilledButton.icon(
                      onPressed: _submit,
                      icon: const Icon(Icons.check),
                      label: Text(l10n.apply),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!(_formKey.currentState?.saveAndValidate() ?? false)) return;

    final fields = _formKey.currentState!.value;
    final newName = fields[_fieldDeviceName] as String;
    final autoSwitch = fields[_fieldAutoSwitch] as bool;
    final newPassword = fields[_fieldPassword] as String;

    setState(() => _isSubmitting = true);

    // 1. Update Device Settings
    context.read<AppWebSocketBloc>().add(
      AppWebSocketChangeDeviceSettings(
        autoSwitch: autoSwitch,
        deviceName: newName,
      ),
    );

    // 2. Change Admin Password (old password is "admin" for initial setup)
    context.read<AppWebSocketBloc>().add(
      AppWebSocketChangePassword(
        newPassword: newPassword,
      ),
    );
  }
}
