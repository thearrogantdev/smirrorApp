import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get_it/get_it.dart';
import 'package:smirror_app/models/device_connection.dart';
import 'package:smirror_app/services/websocket_service.dart';
import 'package:smirror_app/l10n/app_localizations.dart';
import 'package:smirror_app/dialogs/login_dialog.dart';

class DeviceConnectionDialog extends StatefulWidget {
  const DeviceConnectionDialog({super.key});

  @override
  State<DeviceConnectionDialog> createState() => _DeviceConnectionDialogState();
}

class _DeviceConnectionDialogState extends State<DeviceConnectionDialog> {
  final _ws = GetIt.I<WebSocketService>();
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isAdding = false;
  bool _isTesting = false;
  String? _testResult;
  bool _testSuccess = false;

  DeviceConnection? _selectedDevice;

  @override
  void initState() {
    super.initState();
    _selectedDevice = _ws.activeDevice;
  }

  Future<void> _testConnection() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      setState(() {
        _isTesting = true;
        _testResult = null;
      });
      final values = _formKey.currentState!.value;
      final ip = values['ip'] as String;
      final port = int.parse(values['port'] as String);

      try {
        final result = await _ws.testConnection(ip, port);
        if (mounted) {
          setState(() {
            final loc = AppLocalizations.of(context)!;
            switch (result) {
              case TestConnectionResult.success:
                _testResult = loc.testResultSuccess;
                _testSuccess = true;
                break;
              case TestConnectionResult.unauthorized:
                _testResult = loc.testResultUnauthorized;
                _testSuccess =
                    true; // Still a successful connection to the device port
                break;
              case TestConnectionResult.outdated:
                _testResult = loc.testResultOutdated;
                _testSuccess = false;
                break;
              case TestConnectionResult.failed:
                _testResult = loc.testResultFailed;
                _testSuccess = false;
                break;
            }
          });
        }
      } finally {
        if (mounted) {
          setState(() {
            _isTesting = false;
          });
        }
      }
    }
  }

  void _addDevice() {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final values = _formKey.currentState!.value;
      final newDevice = DeviceConnection(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: values['ip'] as String,
        ip: values['ip'] as String,
        port: int.parse(values['port'] as String),
      );
      _ws.addDevice(newDevice);
      setState(() {
        _isAdding = false;
        _selectedDevice = newDevice;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(_isAdding ? loc.addDevice : loc.deviceConnection),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: _isAdding
              ? FormBuilder(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      FormBuilderTextField(
                        name: 'ip',
                        decoration: InputDecoration(labelText: loc.ipAddress),
                        validator: FormBuilderValidators.required(),
                      ),
                      FormBuilderTextField(
                        name: 'port',
                        decoration: InputDecoration(labelText: loc.port),
                        keyboardType: TextInputType.number,
                        initialValue: '9002',
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                          FormBuilderValidators.numeric(),
                        ]),
                      ),
                      const SizedBox(height: 16),
                      if (_testResult != null || _isTesting)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Row(
                            children: [
                              if (_testResult != null)
                                Expanded(
                                  child: Text(
                                    _testResult!,
                                    style: TextStyle(
                                      color: _testSuccess
                                          ? Colors.green
                                          : Colors.red,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              if (_isTesting)
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                  ),
                                  child: SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      OverflowBar(
                        alignment: MainAxisAlignment.end,
                        spacing: 8,
                        overflowSpacing: 8,
                        children: [
                          TextButton(
                            onPressed: _isTesting ? null : _testConnection,
                            child: Text(loc.haConfigTest),
                          ),
                          TextButton(
                            onPressed: () => setState(() {
                              _isAdding = false;
                              _testResult = null;
                              _testSuccess = false;
                            }),
                            child: Text(loc.cancel),
                          ),
                          FilledButton(
                            onPressed: _addDevice,
                            child: Text(loc.save),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              : StreamBuilder<List<DeviceConnection>>(
                  stream: _ws.devices$,
                  initialData: _ws.devices,
                  builder: (context, snapshot) {
                    final devices = snapshot.data ?? [];
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: devices.length + 1,
                      itemBuilder: (context, index) {
                        if (index == devices.length) {
                          return ListTile(
                            leading: const Icon(Icons.add),
                            title: Text(loc.addDevice),
                            onTap: () => setState(() => _isAdding = true),
                          );
                        }

                        final device = devices[index];
                        final isActive =
                            device.id ==
                            (_selectedDevice?.id ?? _ws.activeDevice?.id);
                        return ListTile(
                          title: Text(device.name),
                          subtitle: Text('${device.ip}:${device.port}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              _ws.removeDevice(device.id);
                              if (_selectedDevice?.id == device.id) {
                                setState(() => _selectedDevice = null);
                              }
                            },
                          ),
                          leading: Icon(
                            isActive
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                            color: isActive
                                ? Theme.of(context).colorScheme.primary
                                : null,
                          ),
                          onTap: () {
                            setState(() {
                              _selectedDevice = device;
                              _isAdding = false;
                            });
                          },
                        );
                      },
                    );
                  },
                ),
        ),
      ),
      actions: _isAdding
          ? null
          : [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(loc.close),
              ),
              FilledButton(
                onPressed: _selectedDevice != null
                      ? () async {
                        await _ws.setActiveDevice(_selectedDevice);
                        if (!context.mounted) return;
                        if (_ws.statusValue == WsStatus.unauthorized) {
                          await showLoginDialog(context);
                        }
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      }
                    : null,
                child: Text(loc.apply),
              ),
            ],
    );
  }
}
