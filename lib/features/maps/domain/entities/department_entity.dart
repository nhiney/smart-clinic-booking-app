class DepartmentEntity {
  final String id;
  final String name;
  final String description;
  final String iconName;
  final int doctorCount;
  final int order;

  const DepartmentEntity({
    required this.id,
    required this.name,
    this.description = '',
    this.iconName = 'local_hospital',
    this.doctorCount = 0,
    this.order = 0,
  });
}
