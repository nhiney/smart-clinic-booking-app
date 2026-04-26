import '../../entities/doctor_entity.dart';
import '../../repositories/doctor_repository.dart';

class SearchDoctorsUseCase {
  final DoctorRepository repository;

  SearchDoctorsUseCase(this.repository);

  Future<List<DoctorEntity>> call(String query) async {
    final all = await repository.getDoctors();
    final trimmed = query.trim();
    if (trimmed.isEmpty) return all;
    final q = trimmed.toLowerCase();
    return all.where((d) {
      return d.name.toLowerCase().contains(q) ||
          d.specialty.toLowerCase().contains(q) ||
          d.hospital.toLowerCase().contains(q) ||
          d.displayClinic.toLowerCase().contains(q);
    }).toList();
  }
}
