import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smirror_app/dialogs/app_dialog.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get_it/get_it.dart';
import 'package:smirror_app/bloc/backendConnection/app_websocket_event.dart';
import 'package:smirror_app/l10n/app_localizations.dart';
import 'package:smirror_app/services/home_assistant_api_service.dart';
import 'package:smirror_app/services/websocket_service.dart';
import 'package:smirror_wire/constants/widget_ids.dart';

import '../../bloc/backendConnection/app_websocket_bloc.dart';

class HAConfigDialog extends StatefulWidget {
  final String? initialUrl;
  final void Function(int userId, String provider)? onTokenSent;
  final int userId;
  const HAConfigDialog({
    super.key,
    this.initialUrl,
    this.onTokenSent,
    required this.userId,
  });

  @override
  State<HAConfigDialog> createState() => _HAConfigDialogState();
}

class _HAConfigDialogState extends State<HAConfigDialog> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isTesting = false;
  HAValidationResult? _testResult;

  Future<void> _testAndSave(bool onlyTest) async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      setState(() {
        _isTesting = true;
        _testResult = null;
      });

      final values = _formKey.currentState!.value;
      final String url = values['url'];
      final String token = values['token'];
      final bloc = context.read<AppWebSocketBloc>();
      final nav = Navigator.of(context);

      final result = await GetIt.I<HomeAssistantApiService>().testConnection(
        url,
        token,
      );

      if (result.ok && !onlyTest) {
        if (!mounted) return;
        bloc.add(
          AppWebSocketSendToken(
            provider: PropertyIdsSingleHADashboard.tokenName,
            accessToken: token,
            url: url,
            tokenType: 'Bearer',
            expiresAtMs: 0,
            adminPassword: GetIt.I<WebSocketService>().password,
          ),
        );

        final service = GetIt.I<HomeAssistantApiService>();

        // Initialize with the new URL
        service.setUrl(url);

        // IMPORTANT: Update local status
        service.setTokenFromUserInput(token, url: url);
        widget.onTokenSent?.call(
          widget.userId,
          service.provider,
        );

        nav.pop(true);
      }

      setState(() {
        _isTesting = false;
        _testResult = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    final theme = Theme.of(context);

    return AppDialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            loc.haConfigTitle,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Flexible(
            child: SingleChildScrollView(
              child: FormBuilder(
                key: _formKey,
                initialValue: {'url': widget.initialUrl ?? 'http://homeassistant:8123'},
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FormBuilderTextField(
                      name: 'url',
                      decoration: InputDecoration(
                        labelText: loc.haConfigUrlLabel,
                        hintText: loc.haConfigUrlHint,
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(
                          errorText: loc.haConfigRequiredField,
                        ),
                        (value) {
                          if (value == null || value.isEmpty) return null;

                          final uri = Uri.tryParse(value);

                          // Basic Validity Check
                          if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
                            return loc.haConfigInvalidUrl;
                          }

                          // Prohibit .local addresses while app can solve this it is often inconsistent or disabled on minimal Linux distribution
                          if (uri.host.toLowerCase().endsWith('.local')) {
                            return loc.haConfigNoLocalError;
                          }

                          return null;
                        },
                      ]),
                    ),
                    const SizedBox(height: 16),
                    FormBuilderTextField(
                      name: 'token',
                      decoration: InputDecoration(labelText: loc.haConfigTokenLabel),
                      obscureText: true,
                      validator: FormBuilderValidators.required(
                        errorText: loc.haConfigRequiredField,
                      ),
                    ),
                    if (_testResult != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        _testResult!.ok
                            ? loc.haConfigSuccess
                            : (_testResult!.message ?? ""),
                        style: TextStyle(
                          color: _testResult!.ok ? Colors.green : Colors.red,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Cancel Button
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(loc.cancel),
              ),
              const SizedBox(width: 8),

              // Test Button
              TextButton(
                onPressed: _isTesting ? null : () => _testAndSave(true),
                child: _isTesting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(loc.haConfigTest),
              ),
              const SizedBox(width: 8),

              // Save Button
              ElevatedButton(
                onPressed: _isTesting ? null : () => _testAndSave(false),
                child: Text(loc.save),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
