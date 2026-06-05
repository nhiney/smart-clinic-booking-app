// lib/features/admin/presentation/widgets/patient_list_item.dart
import 'package:flutter/material.dart';
import '../../domain/entities/facility_entities.dart';
import '../screens/patient_detail_screen.dart';

class PatientListItem extends StatelessWidget {
  final Patient patient;

  const PatientListItem({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    String shortName = patient.name.isNotEmpty 
        ? patient.name.split(' ').take(2).map((e) => e.isNotEmpty ? e[0] : '').join().toUpperCase()
        : 'BN';

    final dynamic dynamicPatient = patient;

    bool isPatientVip = false;
    try {
      isPatientVip = dynamicPatient.isVip ?? dynamicPatient.is_verified ?? false;
    } catch (_) {}

    String patientCode = '';
    try {
      patientCode = dynamicPatient.code ?? dynamicPatient.insuranceId ?? dynamicPatient.insurance_id ?? patient.id.substring(0, 5);
      if (patientCode.length > 8) {
        patientCode = patientCode.substring(0, 6); // Rút ngắn mã BHYT dài cho đẹp UI
      }
    } catch (_) {
      patientCode = patient.id.substring(0, 5);
    }

    List<String> patientDiagnoses = [];
    try {
      final rawDiag = dynamicPatient.diagnoses;
      if (rawDiag is List) {
        patientDiagnoses = rawDiag.map((e) => e.toString()).toList();
      } else {
        final String? singleDiag = dynamicPatient.diagnosis;
        if (singleDiag != null && singleDiag.isNotEmpty) {
          patientDiagnoses = [singleDiag];
        }
      }
    } catch (_) {
      patientDiagnoses = ['Khám tổng quát'];
    }

    int visitsCount = 0;
    try {
      visitsCount = dynamicPatient.totalVisits ?? (dynamicPatient.lastVisit != null ? 1 : 0);
    } catch (_) {}

    String lastVisitDisplay = 'Chưa có';
    try {
      if (dynamicPatient.lastVisit != null) {
        lastVisitDisplay = dynamicPatient.lastVisit.toString();
        if (lastVisitDisplay.contains('(')) {
          lastVisitDisplay = lastVisitDisplay.split(' ')[0];
        }
      }
    } catch (_) {}

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PatientDetailScreen(patient: patient),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.01),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: const Color(0xFFEBF3FF),
                      child: Text(
                        shortName,
                        style: const TextStyle(color: Color(0xFF0066FF), fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    if (isPatientVip)
                      const CircleAvatar(
                        radius: 8,
                        backgroundColor: Colors.amber,
                        child: Icon(Icons.star, size: 10, color: Colors.white),
                      )
                  ],
                ),
                const SizedBox(width: 12),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            patient.name,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                          ),
                          if (isPatientVip)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF6E6),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                '★ VIP',
                                style: TextStyle(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '#$patientCode · ${patient.age} tuổi',
                        style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: patientDiagnoses.map((diag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '🩺 $diag',
                              style: const TextStyle(fontSize: 12, color: Color(0xFF475569), fontWeight: FontWeight.w500),
                            ),
                          );
                        }).toList(),
                      )
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            const SizedBox(height: 12),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 14, color: Color(0xFF94A3B8)),
                    const SizedBox(width: 6),
                    Text(
                      '$visitsCount lượt khám · Gần nhất: $lastVisitDisplay',
                      style: const TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Color(0xFF94A3B8)),
              ],
            )
          ],
        ),
      ),
    );
  }
}