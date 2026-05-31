import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:smirror_app/l10n/app_localizations.dart';

class CreateUserForm extends StatelessWidget {
  const CreateUserForm({
    super.key,
    required this.formKey,
    required this.isSubmitting,
    required this.passwordVisible,
    required this.confirmPasswordVisible,
    required this.onPasswordVisibilityChanged,
    required this.onConfirmPasswordVisibilityChanged,
    required this.onSubmit,
    required this.onCancel,
    required this.l10n,
    required this.selectedTokens,
    required this.onTokenChanged,
    required this.tokensAvailable,
  });

  final GlobalKey<FormBuilderState> formKey;
  final bool isSubmitting;
  final bool passwordVisible;
  final bool confirmPasswordVisible;
  final ValueChanged<bool> onPasswordVisibilityChanged;
  final ValueChanged<bool> onConfirmPasswordVisibilityChanged;
  final VoidCallback onSubmit;
  final VoidCallback onCancel;
  final AppLocalizations l10n;
  final Map<String, bool> selectedTokens;
  final Function(String key, bool value) onTokenChanged;
  final Map<String, bool> tokensAvailable;

  static const _fieldName = 'name';
  static const _fieldPassword = 'password';
  static const _fieldConfirmPassword = 'confirm_password';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: FormBuilder(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FormBuilderTextField(
                  name: _fieldName,
                  decoration: InputDecoration(
                    labelText: l10n.adminFieldUsername,
                    prefixIcon: const Icon(Icons.person_outline),
                  ),
                  textInputAction: TextInputAction.next,
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.minLength(3),
                    FormBuilderValidators.maxLength(64),
                  ]),
                ),
                const SizedBox(height: 16),
                FormBuilderTextField(
                  name: _fieldPassword,
                  obscureText: !passwordVisible,
                  decoration: InputDecoration(
                    labelText: l10n.adminFieldPassword,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        passwordVisible
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                      onPressed: () =>
                          onPasswordVisibilityChanged(!passwordVisible),
                    ),
                  ),
                  textInputAction: TextInputAction.next,
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.minLength(8),
                  ]),
                ),
                const SizedBox(height: 16),
                FormBuilderTextField(
                  name: _fieldConfirmPassword,
                  obscureText: !confirmPasswordVisible,
                  decoration: InputDecoration(
                    labelText: l10n.adminFieldConfirmPassword,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        confirmPasswordVisible
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                      onPressed: () => onConfirmPasswordVisibilityChanged(
                        !confirmPasswordVisible,
                      ),
                    ),
                  ),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => onSubmit(),
                  validator: (value) {
                    final password =
                        formKey.currentState?.fields[_fieldPassword]?.value
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
                const SizedBox(height: 24),
                Text('Assign Configured Tokens',
                    style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                ...['Google', 'OpenWeather', 'HomeAssistant'].map((key) {
                  final isAvailable = tokensAvailable[key] ?? false;
                  return CheckboxListTile(
                    title: Text(
                        key == 'HomeAssistant' ? 'Home Assistant' : key),
                    subtitle: isAvailable ? null : const Text('Not configured in Admin', style: TextStyle(color: Colors.orange, fontSize: 12)),
                    value: isAvailable && (selectedTokens[key] ?? false),
                    onChanged: isAvailable ? (val) => onTokenChanged(key, val ?? false) : null,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    controlAffinity: ListTileControlAffinity.leading,
                  );
                }),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: onCancel,
                      child: Text(l10n.cancel),
                    ),
                    const SizedBox(width: 12),
                    FilledButton(
                      onPressed: isSubmitting ? null : onSubmit,
                      child: isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(l10n.adminCreateUserButton),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
