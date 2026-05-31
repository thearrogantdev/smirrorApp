class HAEntityState {
  final String entityId;
  final String state; // e.g., 'on', '22.5', 'unavailable'
  final Map<String, dynamic> attributes;

  HAEntityState({
    required this.entityId,
    required this.state,
    required this.attributes,
  });

  factory HAEntityState.fromJson(Map<String, dynamic> json) {
    return HAEntityState(
      entityId: json['entity_id'],
      state: json['state'],
      attributes: json['attributes'] ?? {},
    );
  }
}
