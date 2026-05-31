import 'dart:async';
import 'dart:ui' show ImageFilter;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smirror_app/models/device_connection.dart';
import 'package:smirror_app/services/websocket_service.dart';
import 'package:smirror_app/l10n/app_localizations.dart';
import 'package:smirror_app/core/responsive.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final _ws = GetIt.I<WebSocketService>();
  final _loginFormKey = GlobalKey<FormBuilderState>();
  final _deviceFormKey = GlobalKey<FormBuilderState>();

  bool _isAddingDevice = false;
  bool _isConnecting = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final compact = isMobile(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: StreamBuilder<DeviceConnection?>(
        stream: _ws.activeDevice$,
        initialData: _ws.activeDevice,
        builder: (context, activeSnap) {
          final activeDevice = activeSnap.data;

          return StreamBuilder<WsStatus>(
            stream: _ws.status$,
            initialData: _ws.statusValue,
            builder: (context, statusSnap) {
              final status = statusSnap.data ?? WsStatus.disconnected;

              return Container(
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
                child: SafeArea(
                  child: kIsWeb
                      ? _buildWebLayout(loc, activeDevice, status, isDark)
                      : Center(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 32,
                            ),
                            child: Container(
                              constraints: const BoxConstraints(maxWidth: 1100),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Header
                                  _buildHeader(loc, isDark),
                                  const SizedBox(height: 32),

                                  // Main Layout
                                  if (compact)
                                    Column(
                                      children: [
                                        _buildDeviceCard(loc, activeDevice, isDark),
                                        const SizedBox(height: 24),
                                        _buildAuthCard(loc, activeDevice, status, isDark),
                                      ],
                                    )
                                  else
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex: 11,
                                          child: _buildDeviceCard(loc, activeDevice, isDark),
                                        ),
                                        const SizedBox(width: 32),
                                        Expanded(
                                          flex: 12,
                                          child: _buildAuthCard(loc, activeDevice, status, isDark),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildWebLayout(
    AppLocalizations loc,
    DeviceConnection? activeDevice,
    WsStatus status,
    bool isDark,
  ) {
    return Stack(
      children: [
        // Decorative background elements for premium feel
        Positioned(
          top: -120,
          left: -120,
          child: Container(
            width: 360,
            height: 360,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF6B4EFF).withValues(alpha: isDark ? 0.12 : 0.06),
            ),
          ),
        ),
        Positioned(
          bottom: -160,
          right: -80,
          child: Container(
            width: 440,
            height: 440,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF00E5FF).withValues(alpha: isDark ? 0.12 : 0.06),
            ),
          ),
        ),

        Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 460),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E1E28).withValues(alpha: 0.6)
                    : Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.06),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                    blurRadius: 32,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 44,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // App Logo container with gradient
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6B4EFF), Color(0xFF00E5FF)],
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6B4EFF).withValues(alpha: 0.3),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.monitor_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          loc.appTitle,
                          style: GoogleFonts.outfit(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: isDark ? Colors.white : const Color(0xFF1E1E24),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Smart Mirror Web Dashboard",
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white60 : Colors.black54,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 36),

                        // Form content
                        _buildAuthContent(loc, activeDevice, status, isDark),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(AppLocalizations loc, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6B4EFF), Color(0xFF00E5FF)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6B4EFF).withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.settings_input_hdmi_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              loc.appTitle,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
                color: isDark ? Colors.white : const Color(0xFF1E1E24),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          loc.landingTitle,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
            color: isDark ? Colors.white : const Color(0xFF1E1E24),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          loc.landingSubtitle,
          style: TextStyle(
            fontSize: 16,
            height: 1.5,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildDeviceCard(AppLocalizations loc, DeviceConnection? activeDevice, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A24).withValues(alpha: 0.7) : Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.landingDeviceSectionTitle,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1E1E24),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            loc.landingDeviceSectionSubtitle,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white54 : Colors.black54,
            ),
          ),
          const SizedBox(height: 24),

          // Device list stream
          StreamBuilder<List<DeviceConnection>>(
            stream: _ws.devices$,
            initialData: _ws.devices,
            builder: (context, snapshot) {
              final devices = snapshot.data ?? [];
              if (devices.isEmpty && !_isAddingDevice) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.devices_other_rounded,
                          size: 48,
                          color: isDark ? Colors.white24 : Colors.black26,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          loc.noDevicesConfigured,
                          style: TextStyle(
                            color: isDark ? Colors.white54 : Colors.black54,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                children: [
                  ...devices.map((device) {
                    final isActive = device.id == activeDevice?.id;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: InkWell(
                        onTap: () => _ws.setActiveDevice(device),
                        borderRadius: BorderRadius.circular(16),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: isActive
                                ? (isDark
                                    ? const Color(0xFF6B4EFF).withValues(alpha: 0.15)
                                    : const Color(0xFF6B4EFF).withValues(alpha: 0.08))
                                : (isDark
                                    ? Colors.white.withValues(alpha: 0.02)
                                    : Colors.black.withValues(alpha: 0.02)),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isActive
                                  ? const Color(0xFF6B4EFF)
                                  : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)),
                              width: isActive ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isActive ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                                color: isActive ? const Color(0xFF6B4EFF) : (isDark ? Colors.white30 : Colors.black38),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      device.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: isDark ? Colors.white : const Color(0xFF1E1E24),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${device.ip}:${device.port}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: isDark ? Colors.white54 : Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, size: 20),
                                color: isDark ? Colors.white38 : Colors.black38,
                                hoverColor: Colors.redAccent.withValues(alpha: 0.1),
                                onPressed: () {
                                  _ws.removeDevice(device.id);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              );
            },
          ),

          const SizedBox(height: 8),

          // Inline Add Device Form
          if (_isAddingDevice)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.black.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.01),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                ),
              ),
              child: FormBuilder(
                key: _deviceFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FormBuilderTextField(
                      name: 'ip',
                      decoration: InputDecoration(
                        labelText: loc.ipAddress,
                        prefixIcon: const Icon(Icons.lan_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                      ]),
                    ),
                    const SizedBox(height: 12),
                    FormBuilderTextField(
                      name: 'port',
                      decoration: InputDecoration(
                        labelText: loc.port,
                        prefixIcon: const Icon(Icons.numbers_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      initialValue: '9002',
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        FormBuilderValidators.numeric(),
                      ]),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => setState(() => _isAddingDevice = false),
                          child: Text(loc.cancel),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: _saveDevice,
                          child: Text(loc.save),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => setState(() => _isAddingDevice = true),
                icon: const Icon(Icons.add_rounded),
                label: Text(loc.addDevice),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAuthCard(
    AppLocalizations loc,
    DeviceConnection? activeDevice,
    WsStatus status,
    bool isDark,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A24).withValues(alpha: 0.7) : Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.landingLoginSectionTitle,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1E1E24),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            loc.landingLoginSectionSubtitle,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white54 : Colors.black54,
            ),
          ),
          const SizedBox(height: 24),

          _buildAuthContent(loc, activeDevice, status, isDark),
        ],
      ),
    );
  }

  Widget _buildAuthContent(
    AppLocalizations loc,
    DeviceConnection? activeDevice,
    WsStatus status,
    bool isDark,
  ) {
    if (activeDevice == null) {
      return _buildCenteredMessage(
        Icons.arrow_back_rounded,
        loc.landingSelectDeviceFirst,
        isDark,
      );
    }

    if (status == WsStatus.connecting || status == WsStatus.reconnecting || _isConnecting) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Center(
          child: Column(
            children: [
              const SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(
                  strokeWidth: 4,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6B4EFF)),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Connecting to ${activeDevice.name}...',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1E1E24),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please wait while the connection is established.',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (status == WsStatus.disconnected) {
      return Column(
        children: [
          _buildCenteredMessage(
            Icons.cloud_off_rounded,
            loc.landingNoConnectionPossible,
            isDark,
            color: Colors.redAccent,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => _ws.reconnect(),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(loc.haRetry),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      );
    }

    // unauthorized / regular login screen
    return FormBuilder(
      key: _loginFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_errorMessage != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, color: Colors.redAccent),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          if (!kIsWeb) ...[
            Text(
              'Device: ${activeDevice.name} (${activeDevice.ip})',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: isDark ? Colors.white60 : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
          ],

          FormBuilderTextField(
            name: 'username',
            decoration: InputDecoration(
              labelText: loc.username,
              prefixIcon: const Icon(Icons.person_outline_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            validator: FormBuilderValidators.required(),
          ),
          const SizedBox(height: 16),

          FormBuilderTextField(
            name: 'password',
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: loc.password,
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            validator: FormBuilderValidators.required(),
            onSubmitted: (_) => _login(),
          ),
          const SizedBox(height: 28),

          SizedBox(
            width: double.infinity,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [Color(0xFF6B4EFF), Color(0xFF8B75FF)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6B4EFF).withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  loc.apply,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenteredMessage(IconData icon, String message, bool isDark, {Color? color}) {
    final useColor = color ?? (isDark ? Colors.white30 : Colors.black38);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 16),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 54, color: useColor),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black87,
                fontSize: 14,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveDevice() {
    if (_deviceFormKey.currentState?.saveAndValidate() ?? false) {
      final values = _deviceFormKey.currentState!.value;
      final ip = values['ip'] as String;
      final port = int.parse(values['port'] as String);

      final newDevice = DeviceConnection(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: ip,
        ip: ip,
        port: port,
      );

      _ws.addDevice(newDevice);
      setState(() {
        _isAddingDevice = false;
      });
    }
  }

  Future<void> _login() async {
    if (_loginFormKey.currentState?.saveAndValidate() ?? false) {
      setState(() {
        _isConnecting = true;
        _errorMessage = null;
      });

      final values = _loginFormKey.currentState!.value;
      final username = values['username'] as String;
      final password = values['password'] as String;

      final result = await _ws.applyCredentialsAndConnect(
        username: username,
        password: password,
      );

      if (!mounted) return;

      setState(() {
        _isConnecting = false;
        final loc = AppLocalizations.of(context)!;
        if (result == LoginResult.success) {
          // Success is handled by state/status listener causing LandingScreen to unmount
        } else if (result == LoginResult.unauthorized) {
          _errorMessage = loc.errorInvalidCredentials;
        } else {
          _errorMessage = loc.landingNoConnectionPossible;
        }
      });
    }
  }
}
