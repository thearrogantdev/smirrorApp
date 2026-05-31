import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get_it/get_it.dart';
import 'package:smirror_app/services/websocket_service.dart';
import 'package:smirror_app/l10n/app_localizations.dart';

Future<void> showLoginDialog(BuildContext context) async {
  return showDialog<void>(
    context: context,
    builder: (context) => const LoginDialog(),
  );
}

class LoginDialog extends StatefulWidget {
  const LoginDialog({super.key});

  @override
  State<LoginDialog> createState() => _LoginDialogState();
}

class _LoginDialogState extends State<LoginDialog> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _ws = GetIt.I<WebSocketService>();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  Future<void> _login() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final values = _formKey.currentState!.value;
      final username = values['username'] as String;
      final password = values['password'] as String;

      final result = await _ws.applyCredentialsAndConnect(
        username: username,
        password: password,
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        final loc = AppLocalizations.of(context)!;
        if (result == LoginResult.success) {
          Navigator.of(context).pop();
        } else if (result == LoginResult.unauthorized) {
          _errorMessage = loc.errorInvalidCredentials;
        } else {
          _errorMessage = loc.errorConfigError;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(loc.changeUserLogin),
      content: SizedBox(
        width: 400,
        child: FormBuilder(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              FormBuilderTextField(
                name: 'username',
                decoration: InputDecoration(
                  labelText: loc.username,
                  prefixIcon: const Icon(Icons.person),
                ),
                validator: FormBuilderValidators.required(),
              ),
              const SizedBox(height: 16),
              FormBuilderTextField(
                name: 'password',
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: loc.password,
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                validator: FormBuilderValidators.required(),
                onSubmitted: (_) => _login(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text(loc.cancel),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _login,
          child: _isLoading 
            ? const SizedBox(
                width: 16, height: 16, 
                child: CircularProgressIndicator(strokeWidth: 2)
              ) 
            : Text(loc.apply),
        ),
      ],
    );
  }
}
