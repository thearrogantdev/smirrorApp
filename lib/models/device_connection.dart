import 'package:equatable/equatable.dart';

class DeviceConnection extends Equatable {
  final String id;
  final String name;
  final String ip;
  final int port;

  const DeviceConnection({
    required this.id,
    required this.name,
    required this.ip,
    required this.port,
  });

  factory DeviceConnection.fromJson(Map<String, dynamic> json) {
    return DeviceConnection(
      id: json['id'] as String,
      name: json['name'] as String,
      ip: json['ip'] as String,
      port: json['port'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'ip': ip, 'port': port};
  }

  @override
  List<Object?> get props => [id, name, ip, port];
}
