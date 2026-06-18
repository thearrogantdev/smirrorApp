class DeviceEntity {
  int id;
  String connectionId; // The unique ID from DeviceConnection model
  String name;
  String ip;
  int port;

  DeviceEntity({
    this.id = 0,
    required this.connectionId,
    required this.name,
    required this.ip,
    required this.port,
  });
}
