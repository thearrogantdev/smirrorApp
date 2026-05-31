import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:smirror_app/bloc/backendConnection/app_websocket_bloc.dart';
import 'package:smirror_app/bloc/backendConnection/app_websocket_event.dart';
import 'package:smirror_app/bloc/backendConnection/back_app_websocket_bloc.dart';
import 'package:smirror_app/bloc/backendConnection/back_app_websocket_state.dart';
import 'package:smirror_app/l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:smirror_app/services/user_service.dart';
import 'package:smirror_app/services/websocket_service.dart';

class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({super.key});

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isSubmitting = false;
  bool _newPasswordVisible = false;
  bool _confirmPasswordVisible = false;

  static const _fieldNewPassword = 'new_password';
  static const _fieldConfirmPassword = 'confirm_password';

  void _submit() {
    if (!(_formKey.currentState?.saveAndValidate() ?? false)) return;

    final fields = _formKey.currentState!.value;
    final newPassword = fields[_fieldNewPassword] as String;

    context.read<AppWebSocketBloc>().add(
          AppWebSocketChangePassword(newPassword: newPassword),
        );

    setState(() => _isSubmitting = true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<BackAppWebSocketBloc, BackAppWebSocketState>(
      listener: (context, state) {
        if (state is BackAppWebSocketResultReceived && _isSubmitting) {
          setState(() => _isSubmitting = false);
          if (state.result.success) {
            final userService = GetIt.I<UserService>();
            final wsService = GetIt.I<WebSocketService>();
            final newPassword =
                _formKey.currentState!.value[_fieldNewPassword] as String;

            final username = userService.currentUser?.username;
            if (username != null) {
              wsService.saveCredentials(
                username: username,
                password: newPassword,
              );
            }

            Navigator.of(context).pop();
          }
        }
      },
      child: AlertDialog(
        title: Text(l10n.changePasswordTitle),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: FormBuilder(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FormBuilderTextField(
                  name: _fieldNewPassword,
                  obscureText: !_newPasswordVisible,
                  decoration: InputDecoration(
                    labelText: l10n.newPassword,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _newPasswordVisible
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                      onPressed: () => setState(
                          () => _newPasswordVisible = !_newPasswordVisible),
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
                    labelText: l10n.confirmNewPassword,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _confirmPasswordVisible
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                      onPressed: () => setState(() =>
                          _confirmPasswordVisible = !_confirmPasswordVisible),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.validatorRequired;
                    }
                    final newPass = _formKey
                        .currentState?.fields[_fieldNewPassword]?.value as String?;
                    if (value != newPass) {
                      return l10n.adminValidatorPasswordMismatch;
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: _isSubmitting ? null : _submit,
            child: _isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.apply),
          ),
        ],
      ),
    );
  }
}
