import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:smirror_app/l10n/app_localizations.dart' show AppLocalizations;

/// Reusable wrapper: provides consistent styling + Save/Cancel handling.
/// Each caller builds its own FormBuilder UI and returns values via onSubmit.
Future<T?> showConfigDialog<T>({
  required BuildContext context,
  required String title,
  required Widget Function(
    BuildContext ctx,
    GlobalKey<FormBuilderState> formKey,
  )
  buildForm,
  required FutureOr<T?> Function(Map<String, dynamic> values) onSubmit,
  Map<String, dynamic>? initialValues,
  Future<String?> Function(Map<String, dynamic> values)? preSubmit,
  VoidCallback? onDelete,
}) async {
  final formKey = GlobalKey<FormBuilderState>();
  final loc = AppLocalizations.of(context)!;
  String? errorText;
  bool loading = false;

  return showDialog<T>(
    context: context,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setState) {
          return AlertDialog(
            title: Text(title),
            content: FormBuilder(
              key: formKey,
              initialValue: initialValues ?? const {},
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    buildForm(ctx, formKey),
                    if (errorText != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        errorText!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            actions: [
              if (onDelete != null)
                TextButton(
                  onPressed: loading ? null : onDelete,
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: Text(loc.delete),
                ),
              TextButton(
                onPressed: loading ? null : () => Navigator.of(ctx).pop(null),
                child: Text(loc.cancel),
              ),
              FilledButton(
                onPressed: loading
                    ? null
                    : () async {
                        if (formKey.currentState?.saveAndValidate() != true) {
                          return;
                        }
                        final values = formKey.currentState!.value;

                        setState(() {
                          loading = true;
                          errorText = null;
                        });

                        try {
                          if (preSubmit != null) {
                            final err = await preSubmit(
                              values,
                            ); // String? error
                            if (err != null) {
                              setState(
                                () => errorText = err,
                              ); // show top-level error
                              return; // keep dialog open
                            }
                          }

                          // onSubmit may run async key/city validation and set field errors
                          final result = await onSubmit(values);

                          if (result == null) {
                            // keep dialog open so inline errors remain visible
                            return;
                          }

                          if (!ctx.mounted || !Navigator.of(ctx).canPop()) {
                            return;
                          }
                          Navigator.of(ctx).pop(result);
                        } finally {
                          // ensure loading is turned off even if submit throws
                          if (ctx.mounted) {
                            setState(() => loading = false);
                          }
                        }
                      },
                child: loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(loc.save),
              ),
            ],
          );
        },
      );
    },
  );
}
