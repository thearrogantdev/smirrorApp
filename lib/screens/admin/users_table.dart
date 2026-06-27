import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:smirror_wire/generated/back_app_back_app_generated.dart' as backmsg;
import 'package:smirror_wire/generated/permission_generated.dart';
import 'package:smirror_app/l10n/app_localizations.dart';
import 'package:smirror_app/services/user_service.dart';

class UsersTable extends StatelessWidget {
  const UsersTable({
    super.key,
    required this.users,
    required this.onTogglePermission,
    required this.l10n,
    required this.onDeleteUser,
    required this.onAddUser,
  });

  final List<backmsg.UserInfoT> users;
  final void Function(backmsg.UserInfoT user, Permission permission) onTogglePermission;
  final AppLocalizations l10n;
  final void Function(backmsg.UserInfoT user) onDeleteUser;
  final VoidCallback onAddUser;

  static bool _isProtected(backmsg.UserInfoT user) {
    final currentUsername = GetIt.I<UserService>().currentUser?.username;
    return user.name == currentUsername;
  }

  // All permissions we want to show as columns
  static final _permissions = Permission.values
      .where((p) => p.value != 0 && p != Permission.Admin)
      .toList();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.adminUsersTitle, style: theme.textTheme.titleLarge),
            FilledButton.icon(
              onPressed: onAddUser,
              icon: const Icon(Icons.person_add_outlined),
              label: Text(l10n.adminCreateUserButton),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (users.isEmpty)
          Text(l10n.adminNoUsers, style: theme.textTheme.bodyMedium)
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStatePropertyAll(
                theme.colorScheme.surfaceContainerHighest,
              ),
              columns: [
                DataColumn(label: Text(l10n.adminColumnUser)),
                ..._permissions.map(
                  (p) => DataColumn(
                    label: Tooltip(
                      message: p.name,
                      child: Text(p.name, overflow: TextOverflow.ellipsis),
                    ),
                  ),
                ),
                const DataColumn(label: SizedBox.shrink()),
              ],
              rows: users.map((user) {
                return DataRow(
                  cells: [
                    DataCell(
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name ?? "",
                            style: theme.textTheme.bodyMedium,
                          ),
                          Text(
                            'ID ${user.userId}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ..._permissions.map((p) {
                      final isProtected = _isProtected(user);
                      final hasPermission = (user.rights & p.value) != 0;
                      return DataCell(
                        Tooltip(
                          message: isProtected ? l10n.adminRightsProtectedAdmin : '',
                          child: Checkbox(
                            value: hasPermission,
                            onChanged: isProtected
                                ? null
                                : (_) => onTogglePermission(user, p),
                          ),
                        ),
                      );
                    }),
                    DataCell(
                      DeleteButton(
                        user: user,
                        onDelete: () => onDeleteUser(user),
                        l10n: l10n,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}

class DeleteButton extends StatelessWidget {
  const DeleteButton({
    super.key,
    required this.user,
    required this.onDelete,
    required this.l10n,
  });

  final backmsg.UserInfoT user;
  final VoidCallback onDelete;
  final AppLocalizations l10n;

  bool get _isProtected {
    final currentUsername = GetIt.I<UserService>().currentUser?.username;
    return user.name == currentUsername;
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.adminDeleteConfirmTitle),
        content: Text(l10n.adminDeleteConfirmMessage(user.name ?? "")),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.adminDeleteConfirmButton),
          ),
        ],
      ),
    );

    if (confirmed == true) onDelete();
  }

  @override
  Widget build(BuildContext context) {
    if (_isProtected) {
      final label = l10n.adminDeleteProtectedAdmin;

      return Tooltip(
        message: label,
        child: IconButton(
          icon: Icon(
            Icons.delete_outline,
            color: Theme.of(context).colorScheme.onSurface.withAlpha(80),
          ),
          onPressed: null,
        ),
      );
    }

    return IconButton(
      icon: Icon(
        Icons.delete_outline,
        color: Theme.of(context).colorScheme.error,
      ),
      tooltip: l10n.adminDeleteUser,
      onPressed: () => _confirmDelete(context),
    );
  }
}
