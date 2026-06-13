class SystemServiceEntity {
  final String id;
  final String name;
  final int latency;
  final String status;

  SystemServiceEntity({
    required this.id, 
    required this.name, 
    required this.latency, 
    required this.status
  });

  factory SystemServiceEntity.fromMap(Map<String, dynamic> map, String id) {
    return SystemServiceEntity(
      id: id,
      name: map['name'] ?? '',
      latency: (map['latency'] as num?)?.toInt() ?? 0,
      status: map['status'] ?? 'active',
    );
  }
}