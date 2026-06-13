class ClinicRoomEntity {
  final String id;
  final String name;
  final String floor;
  final String type;
  final String status;
  final String workingHours;

  const ClinicRoomEntity({
    required this.id,
    required this.name,
    this.floor = '',
    this.type = 'examination',
    this.status = 'available',
    this.workingHours = '',
  });
}
