import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';

import 'package:auto_route/auto_route.dart';
import 'toml_download_helper.dart';
import 'package:flat_buffers/flat_buffers.dart' as fb;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smirror_app/dialogs/app_dialog.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get_it/get_it.dart';
import 'package:smirror_app/bloc/backendConnection/app_websocket_bloc.dart';
import 'package:smirror_app/bloc/backendConnection/app_websocket_event.dart';
import 'package:smirror_app/bloc/backendConnection/back_app_websocket_bloc.dart';
import 'package:smirror_app/bloc/backendConnection/back_app_websocket_state.dart';
import 'package:smirror_wire/generated/app_back_app_back_generated.dart'
    as appmsg;
import 'package:smirror_wire/generated/back_app_back_app_generated.dart'
    as backmsg;
import 'package:smirror_wire/generated/permission_generated.dart';
import 'package:smirror_app/l10n/app_localizations.dart';
import 'package:smirror_app/services/home_assistant_api_service.dart';
import 'package:smirror_app/services/open_weather_validation_service.dart';
import 'package:smirror_app/services/user_service.dart';
import 'package:smirror_app/services/websocket_service.dart';
import 'device_settings_card.dart';
import 'users_table.dart';
import 'create_user_form.dart';
import 'tokens_table.dart';
import 'location_config_dialog.dart';
import 'toml_upload_card.dart';
import 'system_updates_card.dart';
import 'google_calendar_tokens_card.dart';

@RoutePage()
class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  bool _isSubmitting = false;
  bool _isCheckingForUpdates = false;
  bool _isUploadingTomlConfig = false;
  bool _isDownloadingTomlConfig = false;
  bool _isUpdatingFrontend = false;
  bool _isUpdatingBackend = false;
  bool _isUpdatingWebapp = false;
  bool _isChainUpdating = false;
  String _currentFrontendVersion = "";
  String _currentBackendVersion = "";
  String _currentWebappVersion = "";

  late final TextEditingController _deviceNameController;
  bool _autoSwitch = false;
  List<backmsg.UserInfoT> _users = [];
  backmsg.NewUpdateAvailableT? _availableUpdate;
  bool _checkedForUpdates = false;
  bool _noNewUpdates = false;

  // Token assignment state for new users
  final Map<String, bool> _tokensToAssign = {};
  final Map<String, bool> _tokensAvailable = {};
  String? _pendingNewUserPassword;
  String? _pendingNewUserName;

  /// Maps userId to list of provider names they possess tokens for.
  final Map<int, List<String>> _userTokensMap = {};
  int? _pendingTokenUserId;
  String? _pendingTokenProvider;
  String? _selectedTomlFileName;
  String? _selectedTomlContent;

  @override
  void initState() {
    super.initState();
    _deviceNameController = TextEditingController();
    context.read<AppWebSocketBloc>().add(
      AppWebSocketSendSimpleCommandRequested(
        commandType: appmsg.AppSimpleCommandType.GET_ADMIN_INFO,
      ),
    );
  }

  @override
  void dispose() {
    _deviceNameController.dispose();
    super.dispose();
  }

  void _deleteUser(backmsg.UserInfoT user) {
    context.read<AppWebSocketBloc>().add(AppWebSocketDeleteUser(user.userId));
    // Optimistic update
    setState(() => _users.removeWhere((u) => u.userId == user.userId));
    // Refresh from backend
    context.read<AppWebSocketBloc>().add(
      AppWebSocketSendSimpleCommandRequested(
        commandType: appmsg.AppSimpleCommandType.GET_ADMIN_INFO,
      ),
    );
  }

  bool _submit() {
    if (!(_formKey.currentState?.saveAndValidate() ?? false)) return false;

    final fields = _formKey.currentState!.value;
    final password = fields['password'] as String;
    final name = (fields['name'] as String).trim();

    _pendingNewUserPassword = password;
    _pendingNewUserName = name;

    final builder = fb.Builder(initialSize: 256);
    final message = appmsg.AppBackMessageT(
      payloadType: appmsg.AppBackPayloadTypeId.CreateUser,
      payload: appmsg.CreateUserT(name: name, password: password),
    );

    builder.finish(message.pack(builder));
    GetIt.I<WebSocketService>().send(builder.buffer);
    setState(() => _isSubmitting = true);
    return true;
  }

  void _togglePermission(backmsg.UserInfoT user, Permission permission) {
    final newRights = (user.rights & permission.value) != 0
        ? user.rights & ~permission.value
        : user.rights | permission.value;

    context.read<AppWebSocketBloc>().add(
      AppWebSocketChangeUserPermission(userId: user.userId, rights: newRights),
    );

    // Optimistic update
    setState(() {
      final idx = _users.indexWhere((u) => u.userId == user.userId);
      if (idx != -1) {
        _users[idx] = backmsg.UserInfoT()
          ..userId = user.userId
          ..name = user.name
          ..rights = newRights;
      }
    });
  }

  void _handleResult(backmsg.ResultT result) {
    setState(() => _isSubmitting = false);

    if (result.success) {
      _formKey.currentState?.reset();
      // Refresh user list
      context.read<AppWebSocketBloc>().add(
        AppWebSocketSendSimpleCommandRequested(
          commandType: appmsg.AppSimpleCommandType.GET_ADMIN_INFO,
        ),
      );
    }
  }

  void _updateDeviceSettings() {
    context.read<AppWebSocketBloc>().add(
      AppWebSocketChangeDeviceSettings(
        autoSwitch: _autoSwitch,
        deviceName: _deviceNameController.text,
      ),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.adminSettingsSuccess),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
  }

  void _checkForUpdates() {
    setState(() {
      _isCheckingForUpdates = true;
      _checkedForUpdates = true;
      _noNewUpdates = false;
      _availableUpdate = null;
    });

    context.read<AppWebSocketBloc>().add(
      AppWebSocketSendSimpleCommandRequested(
        commandType: appmsg.AppSimpleCommandType.CHECK_FOR_UPDATES,
      ),
    );
  }

  void _triggerUpdate(appmsg.AppSimpleCommandType commandType) {
    setState(() {
      if (commandType == appmsg.AppSimpleCommandType.UPDATE_FRONTEND) {
        _isUpdatingFrontend = true;
      } else if (commandType == appmsg.AppSimpleCommandType.UPDATE_BACKEND) {
        _isUpdatingBackend = true;
      } else if (commandType == appmsg.AppSimpleCommandType.UPDATE_WEBAPP) {
        _isUpdatingWebapp = true;
      }
    });
    context.read<AppWebSocketBloc>().add(
      AppWebSocketSendSimpleCommandRequested(commandType: commandType),
    );
  }

  void _startChainedUpdate() {
    setState(() {
      _isChainUpdating = true;
    });
    _runNextChainStep();
  }

  void _runNextChainStep() {
    if (!_isChainUpdating) return;

    final frontendVersion = _normalizeVersion(_availableUpdate?.versionFrontend);
    final webappVersion = _normalizeVersion(_availableUpdate?.versionWebapp);
    final backendVersion = _normalizeVersion(_availableUpdate?.versionBackend);

    if (frontendVersion.isNotEmpty) {
      _triggerUpdate(appmsg.AppSimpleCommandType.UPDATE_FRONTEND);
    } else if (webappVersion.isNotEmpty) {
      _triggerUpdate(appmsg.AppSimpleCommandType.UPDATE_WEBAPP);
    } else if (backendVersion.isNotEmpty) {
      _triggerUpdate(appmsg.AppSimpleCommandType.UPDATE_BACKEND);
    } else {
      setState(() {
        _isChainUpdating = false;
      });
    }
  }

  void _showAdminSnackBar(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isSuccess
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.error,
        ),
      );
  }

  Future<void> _pickTomlFile() async {
    final l10n = AppLocalizations.of(context)!;
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['toml'],
      withData: true,
    );

    if (!mounted || result == null || result.files.isEmpty) return;

    final file = result.files.single;
    final bytes = file.bytes;
    if (bytes == null) {
      _showAdminSnackBar(l10n.adminTomlReadError);
      return;
    }

    try {
      final content = utf8.decode(bytes);
      setState(() {
        _selectedTomlFileName = file.name;
        _selectedTomlContent = content;
      });
    } on FormatException {
      _showAdminSnackBar(l10n.adminTomlReadError);
    }
  }

  void _uploadTomlConfig() {
    final content = _selectedTomlContent;
    if (content == null || content.isEmpty) return;

    context.read<AppWebSocketBloc>().add(
      AppWebSocketUploadConfig(config: content),
    );
    setState(() => _isUploadingTomlConfig = true);
  }

  void _downloadTomlConfig() {
    context.read<AppWebSocketBloc>().add(
      AppWebSocketSendSimpleCommandRequested(
        commandType: appmsg.AppSimpleCommandType.GET_TOML_CONFIG,
      ),
    );
    setState(() => _isDownloadingTomlConfig = true);
  }

  Future<void> _handleDownloadedToml(String content) async {
    final l10n = AppLocalizations.of(context)!;

    // Fallback 1: Copy to clipboard (works everywhere)
    try {
      await Clipboard.setData(ClipboardData(text: content));
    } catch (_) {}

    if (!mounted) return;

    if (kIsWeb) {
      try {
        triggerWebDownload(content, 'smirror.toml');
        _showAdminSnackBar(l10n.adminTomlDownloadSuccess, isSuccess: true);
      } catch (e) {
        _showAdminSnackBar("Configuration copied to clipboard.", isSuccess: true);
      }
    } else {
      try {
        String? outputFile = await FilePicker.saveFile(
          dialogTitle: 'Save TOML Config:',
          fileName: 'smirror.toml',
          bytes: Uint8List.fromList(utf8.encode(content)),
        );
        if (outputFile != null) {
          final file = File(outputFile);
          await file.writeAsString(content);
          _showAdminSnackBar(l10n.adminTomlDownloadSuccess, isSuccess: true);
        } else {
          _showAdminSnackBar("Configuration copied to clipboard.", isSuccess: true);
        }
      } catch (e) {
        _showAdminSnackBar("Configuration copied to clipboard.", isSuccess: true);
      }
    }
  }

  Future<void> _showRestartDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final shouldRestart = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.adminTomlRestartTitle),
        content: Text(l10n.adminTomlRestartMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.adminTomlRestartYes),
          ),
        ],
      ),
    );

    if (!mounted || shouldRestart != true) return;

    context.read<AppWebSocketBloc>().add(
      AppWebSocketSendSimpleCommandRequested(
        commandType: appmsg.AppSimpleCommandType.RESTART,
      ),
    );
  }

  String _normalizeVersion(String? version) => version?.trim() ?? '';

  void _showCreateUserDialog() {
    final l10n = AppLocalizations.of(context)!;

    final currentUsername = GetIt.I<UserService>().currentUser?.username;
    final adminUser = _users.where((u) => u.name == currentUsername).firstOrNull;
    final adminBackendId = adminUser?.userId.toInt() ?? GetIt.I<UserService>().currentUser?.localUserId ?? 0;
    final adminTokens = _userTokensMap[adminBackendId] ?? [];

    setState(() {
      _tokensAvailable['OpenWeather'] = adminTokens.any(
        (t) => t.toLowerCase() == 'openweather',
      );
      _tokensAvailable['HomeAssistant'] = adminTokens.any(
        (t) => t.toLowerCase() == 'homeassistant',
      );

      // Default to checked if available
      _tokensToAssign['OpenWeather'] = _tokensAvailable['OpenWeather']!;
      _tokensToAssign['HomeAssistant'] = _tokensAvailable['HomeAssistant']!;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final theme = Theme.of(context);
            return AppDialog(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.adminCreateUserTitle,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Flexible(
                    child: SingleChildScrollView(
                      child: CreateUserForm(
                        formKey: _formKey,
                        isSubmitting: _isSubmitting,
                        passwordVisible: _passwordVisible,
                        confirmPasswordVisible: _confirmPasswordVisible,
                        selectedTokens: _tokensToAssign,
                        tokensAvailable: _tokensAvailable,
                        onTokenChanged: (key, val) {
                          setState(() => _tokensToAssign[key] = val);
                          setDialogState(() {});
                        },
                        onPasswordVisibilityChanged: (v) {
                          setState(() => _passwordVisible = v);
                          setDialogState(() {});
                        },
                        onConfirmPasswordVisibilityChanged: (v) {
                          setState(() => _confirmPasswordVisible = v);
                          setDialogState(() {});
                        },
                        onSubmit: () {
                          if (_submit()) {
                            Navigator.of(context).pop();
                          }
                        },
                        onCancel: () => Navigator.of(context).pop(),
                        l10n: l10n,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _handlePendingAssignments(
    backmsg.AdminInfoT info,
    String name,
    String password,
  ) async {
    final newUser = info.users?.where((u) => u.name == name).firstOrNull;
    if (newUser == null) return;

    final appBloc = context.read<AppWebSocketBloc>();

    if (_tokensToAssign['OpenWeather'] == true) {
      final repo = GetIt.I<OpenWeatherTokenRepository>();
      appBloc.add(
        AppWebSocketAddTokenToUser(
          userId: newUser.userId.toInt(),
          userPassword: password,
          adminPassword: GetIt.I<WebSocketService>().password,
          provider: repo.provider,
        ),
      );
    }
    if (_tokensToAssign['HomeAssistant'] == true) {
      final repo = GetIt.I<HomeAssistantApiService>();
      appBloc.add(
        AppWebSocketAddTokenToUser(
          userId: newUser.userId.toInt(),
          userPassword: password,
          adminPassword: GetIt.I<WebSocketService>().password,
          provider: repo.provider,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final frontendVersion = _normalizeVersion(
      _availableUpdate?.versionFrontend,
    );
    final backendVersion = _normalizeVersion(_availableUpdate?.versionBackend);
    final webappVersion = _normalizeVersion(_availableUpdate?.versionWebapp);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<BackAppWebSocketBloc, BackAppWebSocketState>(
      listener: (context, state) {
        if (state is BackAppWebSocketGotAdminInfo) {
          final newUsers = state.info.users ?? [];
          final updateAvailable = state.info.updateAvailable;
          final hasInitialUpdate =
              _normalizeVersion(updateAvailable?.versionFrontend).isNotEmpty ||
              _normalizeVersion(updateAvailable?.versionBackend).isNotEmpty ||
              _normalizeVersion(updateAvailable?.versionWebapp).isNotEmpty;

          setState(() {
            _users = newUsers;
            _autoSwitch = state.info.autoSwitch;
            if (_deviceNameController.text != state.info.deviceName) {
              _deviceNameController.text = state.info.deviceName ?? "";
            }
            _currentFrontendVersion = _normalizeVersion(
              state.info.versionFrontend,
            );
            _currentBackendVersion = _normalizeVersion(
              state.info.versionBackend,
            );
            _currentWebappVersion = "";
            _checkedForUpdates = true;
            _isCheckingForUpdates = false;
            _noNewUpdates = !hasInitialUpdate;
            _availableUpdate = hasInitialUpdate ? updateAvailable : null;
            // Populate tokens map from AdminInfo
            _userTokensMap.clear();
            for (final t in state.info.tokens ?? []) {
              _userTokensMap[t.userId.toInt()] = t.provider ?? [];
            }
          });

          // Handle pending token assignments
          if (_pendingNewUserName != null && _pendingNewUserPassword != null) {
            _handlePendingAssignments(
              state.info,
              _pendingNewUserName!,
              _pendingNewUserPassword!,
            );
            _pendingNewUserName = null;
            _pendingNewUserPassword = null;
          }
        }

        if (state is BackAppWebSocketGotNewUpdateAvailable) {
          setState(() {
            _isCheckingForUpdates = false;
            _checkedForUpdates = true;
            _noNewUpdates = false;
            _availableUpdate = state.updateInfo;
          });
        }

        if (state is BackAppWebSocketResultReceived) {
          if (state.result.errorCode == backmsg.ErrorCode.FRONTEND_UPDATED) {
            setState(() {
              _isUpdatingFrontend = false;
              if (_availableUpdate != null) {
                _availableUpdate = backmsg.NewUpdateAvailableT(
                  versionFrontend: "",
                  versionBackend: _availableUpdate?.versionBackend,
                  versionWebapp: _availableUpdate?.versionWebapp,
                );
              }
            });
            _showAdminSnackBar(l10n.errorFrontendUpdated, isSuccess: true);
            context.read<AppWebSocketBloc>().add(
              AppWebSocketSendSimpleCommandRequested(
                commandType: appmsg.AppSimpleCommandType.GET_ADMIN_INFO,
              ),
            );
            if (_isChainUpdating) {
              _runNextChainStep();
            }
          } else if (state.result.errorCode ==
              backmsg.ErrorCode.BACKEND_UPDATED) {
            setState(() {
              _isUpdatingBackend = false;
              if (_availableUpdate != null) {
                _availableUpdate = backmsg.NewUpdateAvailableT(
                  versionFrontend: _availableUpdate?.versionFrontend,
                  versionBackend: "",
                  versionWebapp: _availableUpdate?.versionWebapp,
                );
              }
            });
            _showAdminSnackBar(l10n.errorBackendUpdated, isSuccess: true);
            context.read<AppWebSocketBloc>().add(
              AppWebSocketSendSimpleCommandRequested(
                commandType: appmsg.AppSimpleCommandType.GET_ADMIN_INFO,
              ),
            );
            if (_isChainUpdating) {
              _runNextChainStep();
            }
          } else if (state.result.errorCode ==
              backmsg.ErrorCode.WEBAPP_UPDATED) {
            setState(() {
              _isUpdatingWebapp = false;
              if (_availableUpdate != null) {
                _availableUpdate = backmsg.NewUpdateAvailableT(
                  versionFrontend: _availableUpdate?.versionFrontend,
                  versionBackend: _availableUpdate?.versionBackend,
                  versionWebapp: "",
                );
              }
            });
            _showAdminSnackBar(l10n.errorWebappUpdated, isSuccess: true);
            context.read<AppWebSocketBloc>().add(
              AppWebSocketSendSimpleCommandRequested(
                commandType: appmsg.AppSimpleCommandType.GET_ADMIN_INFO,
              ),
            );
            if (_isChainUpdating) {
              _runNextChainStep();
            }
          } else if (state.result.errorCode ==
              backmsg.ErrorCode.UPDATED_FAILED) {
            setState(() {
              _isUpdatingFrontend = false;
              _isUpdatingBackend = false;
              _isUpdatingWebapp = false;
              _isChainUpdating = false;
            });
            _showAdminSnackBar(
              state.result.errorMessage?.isNotEmpty == true
                  ? state.result.errorMessage!
                  : l10n.errorUpdateFailed,
            );
          }

          if (_isCheckingForUpdates &&
              state.result.errorCode == backmsg.ErrorCode.NO_NEW_UPDATES) {
            setState(() {
              _isCheckingForUpdates = false;
              _checkedForUpdates = true;
              _noNewUpdates = true;
              _availableUpdate = null;
            });
          }

          if (state.result.errorCode == backmsg.ErrorCode.ADD_TOKEN) {
            if (_pendingTokenUserId != null && _pendingTokenProvider != null) {
              setState(() {
                final userTokens = _userTokensMap[_pendingTokenUserId!] ?? [];
                if (!userTokens.any(
                  (t) =>
                      t.toLowerCase() == _pendingTokenProvider!.toLowerCase(),
                )) {
                  _userTokensMap[_pendingTokenUserId!] = [
                    ...userTokens,
                    _pendingTokenProvider!,
                  ];
                }
                _pendingTokenUserId = null;
                _pendingTokenProvider = null;
              });
            }
          }

          if (_isSubmitting) {
            _handleResult(state.result);
          }

          if (_isUploadingTomlConfig) {
            if (state.result.errorCode == backmsg.ErrorCode.TOML_CONFIG_ERROR) {
              final errorMessage = state.result.errorMessage;
              setState(() => _isUploadingTomlConfig = false);
              _showAdminSnackBar(
                errorMessage != null && errorMessage.isNotEmpty
                    ? l10n.adminTomlUploadErrorWithMessage(errorMessage)
                    : l10n.adminTomlUploadError,
              );
            } else if (state.result.success &&
                state.result.errorCode == backmsg.ErrorCode.BACKEND_UPDATED) {
              // Wait, backmsg.ErrorCode.OK or BACKEND_UPDATED is used for success depending on context. Let's make sure it handles both.
              setState(() => _isUploadingTomlConfig = false);
              _showAdminSnackBar(l10n.adminTomlUploadSuccess, isSuccess: true);
              _showRestartDialog();
            } else if (state.result.success &&
                state.result.errorCode == backmsg.ErrorCode.OK) {
              setState(() => _isUploadingTomlConfig = false);
              _showAdminSnackBar(l10n.adminTomlUploadSuccess, isSuccess: true);
              _showRestartDialog();
            } else if (!state.result.success) {
              setState(() => _isUploadingTomlConfig = false);
              _showAdminSnackBar(
                state.result.errorMessage?.isNotEmpty == true
                    ? state.result.errorMessage!
                    : l10n.errorConfigError,
              );
            }
          }
          if (_isDownloadingTomlConfig && !state.result.success) {
            setState(() => _isDownloadingTomlConfig = false);
            _showAdminSnackBar(
              state.result.errorMessage?.isNotEmpty == true
                  ? state.result.errorMessage!
                  : l10n.errorConfigError,
            );
          }
        }

        if (state is BackAppWebSocketGotTomlConfig) {
          setState(() => _isDownloadingTomlConfig = false);
          _handleDownloadedToml(state.tomlConfig.config ?? '');
        }
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF0F0F13),
                    const Color(0xFF16161A),
                    const Color(0xFF1F1C2C),
                  ]
                : [
                    const Color(0xFFF1F2F6),
                    const Color(0xFFE2E5EC),
                    const Color(0xFFD5D9E5),
                  ],
          ),
        ),
        child: DefaultTabController(
          length: 3,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: Text(
                l10n.adminScreenTitle,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(60),
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.black.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.black.withValues(alpha: 0.05),
                    ),
                  ),
                  child: TabBar(
                    dividerColor: Colors.transparent,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6B4EFF), Color(0xFF8B75FF)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6B4EFF).withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor:
                        isDark ? Colors.white60 : Colors.black54,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 13,
                    ),
                    tabs: [
                      Tab(
                        height: 40,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.people_outline_rounded, size: 18),
                            const SizedBox(width: 8),
                            Text(l10n.adminUsersTitle.split(' ').first),
                          ],
                        ),
                      ),
                      Tab(
                        height: 40,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.tune_rounded, size: 18),
                            const SizedBox(width: 8),
                            Text(l10n.adminDeviceSettingsTitle.split(' ').first),
                          ],
                        ),
                      ),
                      Tab(
                        height: 40,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.system_update_alt_rounded, size: 18),
                            const SizedBox(width: 8),
                            Text(l10n.adminUpdateSectionTitle.split(' ').first),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            body: TabBarView(
              children: [
                _buildUsersTab(l10n, isDark),
                _buildGeneralTab(l10n, isDark),
                _buildSystemTab(l10n, isDark, frontendVersion, backendVersion, webappVersion),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGeneralTab(AppLocalizations l10n, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DeviceSettingsCard(
                deviceNameController: _deviceNameController,
                autoSwitch: _autoSwitch,
                onAutoSwitchChanged: (v) {
                  setState(() => _autoSwitch = v);
                  _updateDeviceSettings();
                },
                onSubmit: _updateDeviceSettings,
                l10n: l10n,
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? Theme.of(context)
                          .colorScheme
                          .surfaceContainer
                          .withValues(alpha: 0.6)
                      : Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.05),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  clipBehavior: Clip.antiAlias,
                  borderRadius: BorderRadius.circular(24),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.location_on_rounded,
                        color: Colors.blue,
                        size: 24,
                      ),
                    ),
                    title: Text(
                      l10n.locationSettingsTitle,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    subtitle: Text(
                      l10n.locationConfig,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () async {
                      final result = await showDialog<bool>(
                        context: context,
                        builder: (context) => const LocationConfigDialog(),
                      );
                      if (!mounted) return;
                      if (result == true) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.locationSaved)),
                        );
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TomlUploadCard(
                isUploading: _isUploadingTomlConfig,
                isDownloading: _isDownloadingTomlConfig,
                selectedFileName: _selectedTomlFileName,
                selectedContent: _selectedTomlContent,
                onPickFile: _pickTomlFile,
                onUpload: _uploadTomlConfig,
                onDownload: _downloadTomlConfig,
                l10n: l10n,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUsersTab(AppLocalizations l10n, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 850),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? Theme.of(context)
                          .colorScheme
                          .surfaceContainer
                          .withValues(alpha: 0.6)
                      : Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.05),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: UsersTable(
                  users: _users,
                  onTogglePermission: _togglePermission,
                  onDeleteUser: _deleteUser,
                  onAddUser: _showCreateUserDialog,
                  l10n: l10n,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? Theme.of(context)
                          .colorScheme
                          .surfaceContainer
                          .withValues(alpha: 0.6)
                      : Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.05),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: TokensTable(
                  l10n: l10n,
                  users: _users,
                  userTokens: _userTokensMap,
                  onTokenSent: (userId, provider) {
                    _pendingTokenUserId = userId;
                    _pendingTokenProvider = provider;
                  },
                  onTokenDeleted: (provider) {
                    setState(() {
                      for (final tokens in _userTokensMap.values) {
                        tokens.removeWhere(
                          (t) => t.toLowerCase() == provider.toLowerCase(),
                        );
                      }
                    });
                  },
                ),
              ),
              const SizedBox(height: 24),
              GoogleCalendarTokensCard(
                users: _users,
                userTokens: _userTokensMap,
                l10n: l10n,
                onDeleteGoogleToken: (u) {
                  context.read<AppWebSocketBloc>().add(
                        AppWebSocketDeleteToken(
                          provider: 'google',
                          userID: u.userId,
                        ),
                      );
                  setState(() {
                    _userTokensMap[u.userId.toInt()]?.removeWhere(
                      (t) => t.toLowerCase() == 'google',
                    );
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSystemTab(
    AppLocalizations l10n,
    bool isDark,
    String frontendVersion,
    String backendVersion,
    String webappVersion,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SystemUpdatesCard(
                isChecking: _isCheckingForUpdates,
                checked: _checkedForUpdates,
                noNewUpdates: _noNewUpdates,
                currentFrontendVersion: _currentFrontendVersion,
                currentBackendVersion: _currentBackendVersion,
                currentWebappVersion: _currentWebappVersion,
                availableFrontendVersion: frontendVersion,
                availableBackendVersion: backendVersion,
                availableWebappVersion: webappVersion,
                isUpdatingFrontend: _isUpdatingFrontend,
                isUpdatingBackend: _isUpdatingBackend,
                isUpdatingWebapp: _isUpdatingWebapp,
                onCheckForUpdates: _checkForUpdates,
                onStartUpdate: _startChainedUpdate,
                l10n: l10n,
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? Theme.of(context)
                          .colorScheme
                          .surfaceContainer
                          .withValues(alpha: 0.6)
                      : Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.05),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.power_settings_new_rounded,
                                color: Colors.orange,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                "System Actions",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Perform advanced maintenance commands on the smart mirror. Restarting will reconnect all active services.",
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                    height: 1.4,
                                  ),
                        ),
                        const SizedBox(height: 24),
                        Align(
                          alignment: Alignment.centerRight,
                          child: OutlinedButton.icon(
                            onPressed: _showRestartDialog,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.orange,
                              side: const BorderSide(color: Colors.orange),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.restart_alt_rounded,
                                size: 18),
                            label: const Text("Restart Smart Mirror"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
