import '../../domain/entities/department_entity.dart';

class DepartmentModel extends DepartmentEntity {
  const DepartmentModel({
    required super.id,
    required super.name,
    super.description,
    super.iconName,
    super.doctorCount,
    super.order,
  });

  factory DepartmentModel.fromJson(Map<String, dynamic> json, String docId) {
    return DepartmentModel(
      id: (json['id'] ?? docId) as String,
      name: (json['name'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      iconName: (json['iconName'] as String?) ?? 'local_hospital',
      doctorCount: (json['doctorCount'] as num?)?.toInt() ?? 0,
      order: (json['order'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconName': iconName,
      'doctorCount': doctorCount,
      'order': order,
    };
  }
}
