import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:smirror_app/bloc/backendConnection/app_websocket_bloc.dart';
import 'package:smirror_app/bloc/backendConnection/app_websocket_event.dart';
import 'package:smirror_wire/generated/back_app_back_app_generated.dart' as backmsg;
import 'package:smirror_app/l10n/app_localizations.dart';
import 'package:smirror_app/services/home_assistant_api_service.dart';
import 'package:smirror_app/services/open_weather_validation_service.dart';
import 'package:smirror_app/services/token_provider.dart';
import 'package:smirror_app/services/user_service.dart';
import 'package:smirror_app/services/websocket_service.dart';
import 'package:smirror_app/screens/admin/ha_connection_dialog.dart';

class TokensTable extends StatefulWidget {
  const TokensTable({
    super.key,
    required this.l10n,
    required this.users,
    required this.userTokens,
    this.onTokenSent,
    this.onTokenDeleted,
  });
  final AppLocalizations l10n;
  final List<backmsg.UserInfoT> users;
  final Map<int, List<String>> userTokens;
  final void Function(int userId, String provider)? onTokenSent;
  final void Function(String provider)? onTokenDeleted;

  @override
  State<TokensTable> createState() => _TokensTableState();
}

class _TokensTableState extends State<TokensTable> {
  Future<void> _showOpenWeatherTokenDialog() async {
    final repo = GetIt.I<OpenWeatherTokenRepository>();
    final appBloc = context.read<AppWebSocketBloc>();

    String tempToken = repo.accessTokenOrNull ?? '';

    final success = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(widget.l10n.adminEditTokenTitle("OpenWeather")),
          content: TextField(
            decoration: const InputDecoration(labelText: "API Key"),
            controller: TextEditingController(text: tempToken),
            onChanged: (val) => tempToken = val.trim(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(widget.l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(widget.l10n.adminEditTokenSave),
            ),
          ],
        );
      },
    );

    if (success == true && tempToken.isNotEmpty) {
      repo.setTokenFromUserInput(tempToken);
      appBloc.add(AppWebSocketSendToken(
        provider: 'openweather',
        accessToken: tempToken,
        refreshToken: '',
        tokenType: '',
        expiresAtMs: 0,
        adminPassword: GetIt.I<WebSocketService>().password,
      ));
      widget.onTokenSent?.call(
        GetIt.I<UserService>().currentUser!.localUserId,
        'openweather',
      );
    }
  }

  Future<void> _showHAConfigDialog() async {
    final repo = GetIt.I<HomeAssistantApiService>();
    final bool? saved = await showDialog<bool>(
      context: context,
      builder: (context) => HAConfigDialog(
        initialUrl: repo.url.isEmpty ? null : repo.url,
        onTokenSent: widget.onTokenSent,
      ),
    );

    if (saved == true) {
      if (!mounted) return;
      setState(() {});
    }
  }



  Future<void> _assignTokenToUser(String providerName, String providerId,
      TokenProvider repo, backmsg.UserInfoT user) async {
    final appBloc = context.read<AppWebSocketBloc>();

    String password = '';
    if (!mounted) return;
    final bool? doAssign = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Assign $providerName to ${user.name}'),
        content: TextField(
          obscureText: true,
          decoration: const InputDecoration(labelText: 'User Password'),
          onChanged: (val) => password = val,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(widget.l10n.cancel)),
          FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Assign'))
        ],
      ),
    );

    if (doAssign == true && password.isNotEmpty) {
      appBloc.add(AppWebSocketAddTokenToUser(
        userId: user.userId.toInt(),
        userPassword: password,
        adminPassword: GetIt.I<WebSocketService>().password,
        provider: providerId,
      ));
      widget.onTokenSent?.call(user.userId.toInt(), providerId);

      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Assigning token...')));
    }
  }
  void _deleteToken(String providerId, TokenProvider providerRepo) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(widget.l10n.adminTokenDeleteConfirmTitle),
        content: Text(widget.l10n.adminTokenDeleteConfirmText),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(widget.l10n.adminTokenDeleteConfirmNo),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red.withValues(alpha: 0.1),
              foregroundColor: Colors.red,
            ),
            child: Text(widget.l10n.adminTokenDeleteConfirmYes),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      context.read<AppWebSocketBloc>().add(
        AppWebSocketDeleteToken(provider: providerId),
      );
      providerRepo.resetToken();
      widget.onTokenDeleted?.call(providerId);
    }
  }


  Widget _buildTokenRow(String providerName, String providerId,
      TokenProvider providerRepo, VoidCallback onEdit) {
    final theme = Theme.of(context);
    final currentUserId = GetIt.I<UserService>().currentUser?.localUserId;
    final adminHasToken = widget.userTokens[currentUserId]?.any(
          (t) => t.toLowerCase() == providerId.toLowerCase(),
        ) ??
        false;

    return ValueListenableBuilder<TokenStatus>(
      valueListenable: providerRepo.status,
      builder: (ctx, status, child) {
        // The admin has the token if it's either validated in the current session
        // or the backend AdminInfo says they have it.
        final isPresentInRepo = status == TokenStatus.present;
        final effectiveIsPresent = adminHasToken || isPresentInRepo;
        final isChecking = status == TokenStatus.checking;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: isChecking
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : Icon(
                      effectiveIsPresent ? Icons.check_circle : Icons.error_outline,
                      color: effectiveIsPresent ? Colors.green : Colors.orange,
                    ),
              title: Text(providerName),
              subtitle: Text(
                effectiveIsPresent
                    ? widget.l10n.adminTokenPresent
                    : widget.l10n.adminTokenAbsent,
                style: theme.textTheme.labelSmall,
              ),
              trailing: FilledButton.tonal(
                onPressed: effectiveIsPresent 
                    ? () => _deleteToken(providerId, providerRepo) 
                    : onEdit,
                style: effectiveIsPresent 
                    ? FilledButton.styleFrom(
                        backgroundColor: Colors.red.withValues(alpha: 0.1),
                        foregroundColor: Colors.red,
                      ) 
                    : null,
                child: Text(effectiveIsPresent
                    ? widget.l10n.adminTokenDelete
                    : widget.l10n.adminTokenAdd),
              ),
            ),
            if (effectiveIsPresent && widget.users.isNotEmpty)
              Padding(
                padding:
                    const EdgeInsets.only(left: 40.0, top: 8.0, bottom: 8.0),
                child: Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text('Assign to user:', style: theme.textTheme.bodySmall),
                    ...widget.users
                        .where((u) => u.name != "admin" && u.name != "guest" && u.userId != 1) // current user is admin user
                        .map((u) {
                      final usersTokens =
                          widget.userTokens[u.userId.toInt()] ?? [];
                      // Normalize providerId for matching (e.g. google, openweather, HomeAssistant)
                      final hasToken = usersTokens.any(
                          (t) => t.toLowerCase() == providerId.toLowerCase());

                      return ActionChip(
                        label: Text(u.name ?? 'User ${u.userId}'),
                        backgroundColor: hasToken
                            ? Colors.green.withValues(alpha: 0.2)
                            : null,
                        side: hasToken
                            ? const BorderSide(color: Colors.green)
                            : null,
                        onPressed: () => _assignTokenToUser(
                            providerName, providerId, providerRepo, u),
                      );
                    }),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final providers = <({
      String name,
      String id,
      TokenProvider repo,
      VoidCallback onEdit
    })>[
      (
        name: "OpenWeather",
        id: "openweather",
        repo: GetIt.I<OpenWeatherTokenRepository>(),
        onEdit: _showOpenWeatherTokenDialog
      ),
      (
        name: "Home Assistant",
        id: "HomeAssistant",
        repo: GetIt.I<HomeAssistantApiService>(),
        onEdit: _showHAConfigDialog
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(Icons.key, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Text(widget.l10n.adminTokenTitle, style: theme.textTheme.titleLarge),
          ],
        ),
        const SizedBox(height: 16),
        for (int i = 0; i < providers.length; i++) ...[
          if (i > 0) const Divider(),
          _buildTokenRow(
            providers[i].name,
            providers[i].id,
            providers[i].repo,
            providers[i].onEdit,
          ),
        ],
      ],
    );
  }
}
