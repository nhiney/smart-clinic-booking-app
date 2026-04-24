import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Seeds the Firestore `hospitals` collection with real HCMC hospital data.
///
/// Safe to call on every app start – it checks for an existing document first
/// and skips if data is already present (no extra reads cost after first run).
Future<void> seedHospitalData() async {
  final db = FirebaseFirestore.instance;
  final col = db.collection('hospitals');

  // Guard: skip hospital seeding if already done, but still run department seed below
  final guard = await col.doc('hosp_fv').get();
  final hospitalsAlreadySeeded = guard.exists;
  if (hospitalsAlreadySeeded) {
    debugPrint('[HospitalSeeder] Hospitals already seeded – skipping hospital batch.');
  }

  if (!hospitalsAlreadySeeded) {
  final now = Timestamp.now();

  final hospitals = <Map<String, dynamic>>[
    // ── 1. Bệnh viện Chợ Rẫy ──────────────────────────────────────────────
    {
      '_docId': 'hosp_cho_ray',
      'name': 'Bệnh viện Chợ Rẫy',
      'address': '201B Nguyễn Chí Thanh, Phường 12, Quận 5, TP.HCM',
      'lat': 10.7545,
      'lng': 106.6607,
      'specialties': [
        'Tim mạch', 'Nội khoa', 'Ngoại khoa', 'Cấp cứu',
        'Chấn thương chỉnh hình', 'Thần kinh', 'Ung bướu', 'Huyết học',
      ],
      'rating': 4.5,
      'isOpen': true,
      'featured': true,
      'imageUrl':
          'https://images.unsplash.com/photo-1587350859728-117699f4a13d?auto=format&fit=crop&q=80&w=800',
      'logoUrl':
          'https://images.unsplash.com/photo-1587350859728-117699f4a13d?auto=format&fit=crop&q=80&w=200',
      'description':
          'Bệnh viện Chợ Rẫy là một trong những bệnh viện lớn nhất và lâu đời nhất tại TP.HCM, được thành lập năm 1900. Với hơn 1.800 giường bệnh và đội ngũ hàng nghìn y bác sĩ giàu kinh nghiệm, bệnh viện cung cấp dịch vụ khám chữa bệnh toàn diện từ điều trị nội trú đến các ca phẫu thuật phức tạp.',
      'phone': '028 3855 4137',
      'email': 'bvchoray@hcmc.gov.vn',
      'website': 'https://www.bvchoray.com',
      'workingHours': 'Cấp cứu: 24/7  |  Khám thường: 07:00 – 17:00 (T2–T7)',
      'type': 'public',
      'bedCount': 1800,
      'establishedYear': 1900,
      'emergencyAvailable': true,
      'parkingAvailable': true,
      'ambulanceService': true,
      'insuranceAccepted': ['BHYT', 'Bảo Việt', 'PVI', 'Prudential', 'AIA'],
      'createdAt': now,
      'updatedAt': now,
    },

    // ── 2. Bệnh viện Đại học Y Dược TP.HCM ───────────────────────────────
    {
      '_docId': 'hosp_dhyd_hcm',
      'name': 'Bệnh viện Đại học Y Dược TP.HCM',
      'address': '215 Hồng Bàng, Phường 11, Quận 5, TP.HCM',
      'lat': 10.7530,
      'lng': 106.6608,
      'specialties': [
        'Nội khoa', 'Ngoại khoa', 'Sản phụ khoa', 'Nhi khoa',
        'Ung bướu', 'Phẫu thuật thẩm mỹ', 'Tiêu hóa', 'Nội tiết',
      ],
      'rating': 4.7,
      'isOpen': true,
      'featured': true,
      'imageUrl':
          'https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?auto=format&fit=crop&q=80&w=800',
      'logoUrl':
          'https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?auto=format&fit=crop&q=80&w=200',
      'description':
          'Bệnh viện Đại học Y Dược TP.HCM là cơ sở khám chữa bệnh thực hành của Trường Đại học Y Dược TP.HCM, thành lập năm 1957. Bệnh viện kết hợp chặt chẽ giữa đào tạo và điều trị, quy tụ đội ngũ giáo sư, bác sĩ đầu ngành cùng thiết bị y tế hiện đại.',
      'phone': '028 3855 4269',
      'email': 'contact@bvdaihocyduoc.com',
      'website': 'https://www.bvdaihocyduoc.com',
      'workingHours': 'Cấp cứu: 24/7  |  Khám thường: 07:00 – 16:30 (T2–T7)',
      'type': 'public',
      'bedCount': 1000,
      'establishedYear': 1957,
      'emergencyAvailable': true,
      'parkingAvailable': true,
      'ambulanceService': true,
      'insuranceAccepted': ['BHYT', 'Bảo Việt', 'PVI', 'Manulife', 'Prudential'],
      'createdAt': now,
      'updatedAt': now,
    },

    // ── 3. Bệnh viện Nhi Đồng 1 ───────────────────────────────────────────
    {
      '_docId': 'hosp_nhi_dong_1',
      'name': 'Bệnh viện Nhi Đồng 1',
      'address': '341 Sư Vạn Hạnh, Phường 10, Quận 10, TP.HCM',
      'lat': 10.7716,
      'lng': 106.6750,
      'specialties': [
        'Nhi khoa', 'Sơ sinh', 'Tim mạch nhi', 'Ngoại nhi',
        'Thần kinh nhi', 'Huyết học nhi', 'Ung bướu nhi',
      ],
      'rating': 4.6,
      'isOpen': true,
      'featured': false,
      'imageUrl':
          'https://images.unsplash.com/photo-1576671081554-15d45958d9a4?auto=format&fit=crop&q=80&w=800',
      'logoUrl':
          'https://images.unsplash.com/photo-1576671081554-15d45958d9a4?auto=format&fit=crop&q=80&w=200',
      'description':
          'Bệnh viện Nhi Đồng 1 là bệnh viện nhi khoa lớn nhất khu vực phía Nam, được thành lập năm 1954. Bệnh viện chuyên về khám và điều trị các bệnh lý ở trẻ em từ sơ sinh đến 15 tuổi, với hơn 1.500 giường bệnh và trung tâm cấp cứu nhi khoa hoạt động 24/7.',
      'phone': '028 3927 1119',
      'email': 'info@bvnhidong1.org.vn',
      'website': 'https://www.nhidong.org.vn',
      'workingHours': 'Cấp cứu: 24/7  |  Khám thường: 06:30 – 16:30 (T2–T7)',
      'type': 'public',
      'bedCount': 1500,
      'establishedYear': 1954,
      'emergencyAvailable': true,
      'parkingAvailable': true,
      'ambulanceService': true,
      'insuranceAccepted': ['BHYT', 'Bảo Việt', 'PVI', 'AIA', 'Generali'],
      'createdAt': now,
      'updatedAt': now,
    },

    // ── 4. Bệnh viện Từ Dũ ───────────────────────────────────────────────
    {
      '_docId': 'hosp_tu_du',
      'name': 'Bệnh viện Từ Dũ',
      'address': '284 Cống Quỳnh, Phường Phạm Ngũ Lão, Quận 1, TP.HCM',
      'lat': 10.7724,
      'lng': 106.6906,
      'specialties': [
        'Sản phụ khoa', 'Hỗ trợ sinh sản (IVF)', 'Phụ khoa ung bướu',
        'Sơ sinh', 'Kế hoạch hóa gia đình',
      ],
      'rating': 4.8,
      'isOpen': true,
      'featured': true,
      'imageUrl':
          'https://images.unsplash.com/photo-1629909613654-28e377c37b09?auto=format&fit=crop&q=80&w=800',
      'logoUrl':
          'https://images.unsplash.com/photo-1629909613654-28e377c37b09?auto=format&fit=crop&q=80&w=200',
      'description':
          'Bệnh viện Từ Dũ là bệnh viện sản phụ khoa hàng đầu Việt Nam, được thành lập năm 1942. Bệnh viện có trung tâm hỗ trợ sinh sản (IVF) hiện đại, tiếp nhận hơn 50.000 ca sinh mỗi năm. Đây là địa chỉ tin cậy cho mọi vấn đề sức khỏe phụ nữ và trẻ sơ sinh.',
      'phone': '028 3839 5117',
      'email': 'bvtudu@hcmc.gov.vn',
      'website': 'https://www.tudu.com.vn',
      'workingHours': 'Cấp cứu: 24/7  |  Khám thường: 07:00 – 16:00 (T2–T7)',
      'type': 'public',
      'bedCount': 1700,
      'establishedYear': 1942,
      'emergencyAvailable': true,
      'parkingAvailable': true,
      'ambulanceService': true,
      'insuranceAccepted': ['BHYT', 'Bảo Việt', 'PVI', 'Manulife', 'Prudential', 'AIA'],
      'createdAt': now,
      'updatedAt': now,
    },

    // ── 5. Bệnh viện Nhân Dân 115 ─────────────────────────────────────────
    {
      '_docId': 'hosp_nd_115',
      'name': 'Bệnh viện Nhân Dân 115',
      'address': '527 Sư Vạn Hạnh, Phường 12, Quận 10, TP.HCM',
      'lat': 10.7726,
      'lng': 106.6684,
      'specialties': [
        'Tim mạch', 'Đột quỵ', 'Cấp cứu', 'Nội thần kinh',
        'Huyết học', 'Nội tiết', 'Thận – Tiết niệu',
      ],
      'rating': 4.4,
      'isOpen': true,
      'featured': false,
      'imageUrl':
          'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?auto=format&fit=crop&q=80&w=800',
      'logoUrl':
          'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?auto=format&fit=crop&q=80&w=200',
      'description':
          'Bệnh viện Nhân Dân 115 là bệnh viện tuyến cuối chuyên điều trị các bệnh lý thần kinh và đột quỵ. Với trung tâm cấp cứu đột quỵ hoạt động 24/7 và hệ thống máy MRI, CT tiên tiến, bệnh viện đạt nhiều kết quả xuất sắc trong can thiệp mạch não và thần kinh.',
      'phone': '028 3865 4319',
      'email': 'bvnd115@hcmc.gov.vn',
      'website': 'https://www.benhvien115.com.vn',
      'workingHours': 'Cấp cứu: 24/7  |  Khám thường: 07:00 – 16:30 (T2–T7)',
      'type': 'public',
      'bedCount': 1200,
      'establishedYear': 1975,
      'emergencyAvailable': true,
      'parkingAvailable': true,
      'ambulanceService': true,
      'insuranceAccepted': ['BHYT', 'Bảo Việt', 'PVI'],
      'createdAt': now,
      'updatedAt': now,
    },

    // ── 6. Bệnh viện FV (Franco-Vietnamese) ──────────────────────────────
    {
      '_docId': 'hosp_fv',
      'name': 'Bệnh viện FV',
      'address': '6 Nguyễn Lương Bằng, Phú Mỹ Hưng, Quận 7, TP.HCM',
      'lat': 10.7330,
      'lng': 106.7180,
      'specialties': [
        'Nội khoa', 'Ngoại khoa', 'Sản khoa', 'Cấp cứu',
        'Tim mạch', 'Ung bướu', 'Chỉnh hình', 'Thần kinh',
      ],
      'rating': 4.9,
      'isOpen': true,
      'featured': true,
      'imageUrl':
          'https://images.unsplash.com/photo-1538108168700-09ba0dd97c06?auto=format&fit=crop&q=80&w=800',
      'logoUrl':
          'https://images.unsplash.com/photo-1538108168700-09ba0dd97c06?auto=format&fit=crop&q=80&w=200',
      'description':
          'Bệnh viện FV (Franco-Viet) là bệnh viện quốc tế đạt chuẩn Joint Commission International (JCI), được thành lập năm 2003. Với chuẩn mực Pháp, FV cung cấp dịch vụ y tế chất lượng cao, đội ngũ bác sĩ trong và ngoài nước, phục vụ cả bệnh nhân Việt Nam lẫn người nước ngoài.',
      'phone': '028 5411 3333',
      'email': 'info@fvhospital.com',
      'website': 'https://www.fvhospital.com',
      'workingHours': 'Cấp cứu: 24/7  |  Khám thường: 08:00 – 20:00 (hàng ngày)',
      'type': 'international',
      'bedCount': 220,
      'establishedYear': 2003,
      'emergencyAvailable': true,
      'parkingAvailable': true,
      'ambulanceService': true,
      'insuranceAccepted': [
        'BHYT', 'Bảo Việt', 'PVI', 'Prudential', 'AIA',
        'Manulife', 'Generali', 'PJICO', 'Cigna', 'AXA',
      ],
      'createdAt': now,
      'updatedAt': now,
    },

    // ── 7. Bệnh viện Đa khoa Tâm Anh ─────────────────────────────────────
    {
      '_docId': 'hosp_tam_anh',
      'name': 'Bệnh viện Đa khoa Tâm Anh TP.HCM',
      'address': '2 Đường Số 11, Phường Trường Thọ, TP. Thủ Đức, TP.HCM',
      'lat': 10.8106,
      'lng': 106.7100,
      'specialties': [
        'Nội khoa', 'Ngoại khoa', 'Tim mạch', 'Hỗ trợ sinh sản (IVF)',
        'Ung bướu', 'Chỉnh hình', 'Nhi khoa', 'Thần kinh',
      ],
      'rating': 4.8,
      'isOpen': true,
      'featured': true,
      'imageUrl':
          'https://images.unsplash.com/photo-1579684385127-1ef15d508118?auto=format&fit=crop&q=80&w=800',
      'logoUrl':
          'https://images.unsplash.com/photo-1579684385127-1ef15d508118?auto=format&fit=crop&q=80&w=200',
      'description':
          'Bệnh viện Đa khoa Tâm Anh TP.HCM là bệnh viện tư nhân hàng đầu được thành lập năm 2020 với hơn 1.000 giường bệnh. Hệ thống được đầu tư thiết bị y tế hiện đại nhất Đông Nam Á, với đội ngũ chuyên gia đầu ngành, cam kết mang đến trải nghiệm y tế đẳng cấp cho người dân.',
      'phone': '028 7102 6789',
      'email': 'info.hcm@tamanhhospital.vn',
      'website': 'https://tamanhhospital.vn',
      'workingHours': 'Cấp cứu: 24/7  |  Khám thường: 07:00 – 20:00 (hàng ngày)',
      'type': 'private',
      'bedCount': 1000,
      'establishedYear': 2020,
      'emergencyAvailable': true,
      'parkingAvailable': true,
      'ambulanceService': true,
      'insuranceAccepted': [
        'BHYT', 'Bảo Việt', 'PVI', 'Prudential', 'AIA',
        'Manulife', 'Generali', 'Cigna',
      ],
      'createdAt': now,
      'updatedAt': now,
    },

    // ── 8. Bệnh viện Vinmec Central Park ─────────────────────────────────
    {
      '_docId': 'hosp_vinmec',
      'name': 'Bệnh viện Đa khoa Vinmec Central Park',
      'address': '208 Nguyễn Hữu Cảnh, Phường 22, Bình Thạnh, TP.HCM',
      'lat': 10.7914,
      'lng': 106.7238,
      'specialties': [
        'Nội khoa', 'Ngoại khoa', 'Tim mạch', 'Thần kinh',
        'Ung bướu', 'Hỗ trợ sinh sản (IVF)', 'Nhi khoa', 'Cột sống',
      ],
      'rating': 4.7,
      'isOpen': true,
      'featured': false,
      'imageUrl':
          'https://images.unsplash.com/photo-1516549655169-df83a0774514?auto=format&fit=crop&q=80&w=800',
      'logoUrl':
          'https://images.unsplash.com/photo-1516549655169-df83a0774514?auto=format&fit=crop&q=80&w=200',
      'description':
          'Bệnh viện Vinmec Central Park là bệnh viện đa khoa quốc tế thuộc hệ thống Vinmec, đạt chuẩn JCI. Bệnh viện cung cấp dịch vụ y tế toàn diện với phong cách phục vụ khách sạn 5 sao, phòng bệnh riêng tư cao cấp và quy trình khám chữa bệnh chuyên nghiệp.',
      'phone': '028 3622 1166',
      'email': 'centralpark@vinmec.com',
      'website': 'https://www.vinmec.com/vi/benh-vien/vinmec-central-park',
      'workingHours': 'Cấp cứu: 24/7  |  Khám thường: 07:00 – 20:00 (hàng ngày)',
      'type': 'private',
      'bedCount': 200,
      'establishedYear': 2016,
      'emergencyAvailable': true,
      'parkingAvailable': true,
      'ambulanceService': true,
      'insuranceAccepted': [
        'BHYT', 'Bảo Việt', 'PVI', 'Prudential', 'AIA',
        'Manulife', 'Generali', 'Cigna', 'AXA',
      ],
      'createdAt': now,
      'updatedAt': now,
    },

    // ── 9. Bệnh viện Hoàn Mỹ Sài Gòn ──────────────────────────────────────
    {
      '_docId': 'hosp_hoan_my',
      'name': 'Bệnh viện Hoàn Mỹ Sài Gòn',
      'address': '60 Nguyễn Văn Thương, Phường 25, Bình Thạnh, TP.HCM',
      'lat': 10.7969,
      'lng': 106.6823,
      'specialties': [
        'Nội khoa', 'Ngoại khoa', 'Sản khoa', 'Nhi khoa',
        'Tim mạch', 'Tiêu hóa', 'Chỉnh hình',
      ],
      'rating': 4.3,
      'isOpen': true,
      'featured': false,
      'imageUrl':
          'https://images.unsplash.com/photo-1584432810601-6c7f27d2362b?auto=format&fit=crop&q=80&w=800',
      'logoUrl':
          'https://images.unsplash.com/photo-1584432810601-6c7f27d2362b?auto=format&fit=crop&q=80&w=200',
      'description':
          'Bệnh viện Hoàn Mỹ Sài Gòn là bệnh viện tư nhân đầu tiên tại TP.HCM được thành lập năm 1996, tiên phong trong mô hình bệnh viện tư nhân Việt Nam. Bệnh viện cung cấp đầy đủ dịch vụ khám chữa bệnh từ nội ngoại trú đến phẫu thuật và chăm sóc tích cực.',
      'phone': '028 3516 3777',
      'email': 'saigon@hoanmy.com',
      'website': 'https://hoanmy.com/co-so/bv-hoan-my-sai-gon',
      'workingHours': 'Cấp cứu: 24/7  |  Khám thường: 07:00 – 16:30 (T2–T7)',
      'type': 'private',
      'bedCount': 400,
      'establishedYear': 1996,
      'emergencyAvailable': true,
      'parkingAvailable': true,
      'ambulanceService': true,
      'insuranceAccepted': ['BHYT', 'Bảo Việt', 'PVI', 'Prudential', 'AIA', 'Manulife'],
      'createdAt': now,
      'updatedAt': now,
    },

    // ── 10. Bệnh viện Mắt TP.HCM ─────────────────────────────────────────
    {
      '_docId': 'hosp_mat_hcm',
      'name': 'Bệnh viện Mắt TP.HCM',
      'address': '280 Điện Biên Phủ, Phường 7, Quận 3, TP.HCM',
      'lat': 10.7821,
      'lng': 106.6908,
      'specialties': [
        'Nhãn khoa', 'Phẫu thuật điều trị cận thị (LASIK)',
        'Điều trị đục thủy tinh thể', 'Bệnh võng mạc', 'Glaucoma',
      ],
      'rating': 4.5,
      'isOpen': true,
      'featured': false,
      'imageUrl':
          'https://images.unsplash.com/photo-1560250097-0b93528c311a?auto=format&fit=crop&q=80&w=800',
      'logoUrl':
          'https://images.unsplash.com/photo-1560250097-0b93528c311a?auto=format&fit=crop&q=80&w=200',
      'description':
          'Bệnh viện Mắt TP.HCM là bệnh viện chuyên khoa mắt hàng đầu tại TP.HCM, được thành lập năm 1975. Bệnh viện thực hiện hàng chục nghìn ca phẫu thuật mỗi năm, trong đó nổi bật là phẫu thuật LASIK, Phaco đục thủy tinh thể và điều trị bệnh võng mạc phức tạp.',
      'phone': '028 3930 5862',
      'email': 'bvmat@hcmc.gov.vn',
      'website': 'https://www.bvmathcm.com.vn',
      'workingHours': 'Khám thường: 07:00 – 16:00 (T2–T7)  |  Cấp cứu mắt: 24/7',
      'type': 'public',
      'bedCount': 300,
      'establishedYear': 1975,
      'emergencyAvailable': true,
      'parkingAvailable': true,
      'ambulanceService': false,
      'insuranceAccepted': ['BHYT', 'Bảo Việt', 'PVI', 'AIA'],
      'createdAt': now,
      'updatedAt': now,
    },

    // ── 11. Bệnh viện Ung Bướu TP.HCM ────────────────────────────────────
    {
      '_docId': 'hosp_ung_buou',
      'name': 'Bệnh viện Ung Bướu TP.HCM',
      'address': '3 Nơ Trang Long, Phường 7, Bình Thạnh, TP.HCM',
      'lat': 10.8040,
      'lng': 106.6997,
      'specialties': [
        'Ung thư', 'Hóa trị', 'Xạ trị', 'Phẫu thuật ung bướu',
        'Giải phẫu bệnh', 'Ung bướu nội khoa',
      ],
      'rating': 4.4,
      'isOpen': true,
      'featured': false,
      'imageUrl':
          'https://images.unsplash.com/photo-1631217668868-e9d81c890614?auto=format&fit=crop&q=80&w=800',
      'logoUrl':
          'https://images.unsplash.com/photo-1631217668868-e9d81c890614?auto=format&fit=crop&q=80&w=200',
      'description':
          'Bệnh viện Ung Bướu TP.HCM là bệnh viện chuyên khoa ung thư hàng đầu Việt Nam, được thành lập năm 1976. Với hệ thống máy xạ trị hiện đại, phòng thí nghiệm giải phẫu bệnh tiên tiến và đội ngũ chuyên gia ung bướu giàu kinh nghiệm, bệnh viện tiếp nhận hàng trăm nghìn lượt bệnh nhân mỗi năm.',
      'phone': '028 3841 4505',
      'email': 'bvub@hcmc.gov.vn',
      'website': 'https://www.bvub.com.vn',
      'workingHours': 'Cấp cứu: 24/7  |  Khám thường: 07:00 – 16:00 (T2–T7)',
      'type': 'public',
      'bedCount': 1000,
      'establishedYear': 1976,
      'emergencyAvailable': true,
      'parkingAvailable': true,
      'ambulanceService': true,
      'insuranceAccepted': ['BHYT', 'Bảo Việt', 'PVI', 'Prudential'],
      'createdAt': now,
      'updatedAt': now,
    },

    // ── 12. Bệnh viện Thống Nhất ──────────────────────────────────────────
    {
      '_docId': 'hosp_thong_nhat',
      'name': 'Bệnh viện Thống Nhất TP.HCM',
      'address': '1 Lý Thường Kiệt, Phường 7, Tân Bình, TP.HCM',
      'lat': 10.8008,
      'lng': 106.6822,
      'specialties': [
        'Nội khoa', 'Tim mạch', 'Nội tiết', 'Huyết học',
        'Phục hồi chức năng', 'Thận – Tiết niệu', 'Tiêu hóa',
      ],
      'rating': 4.2,
      'isOpen': true,
      'featured': false,
      'imageUrl':
          'https://images.unsplash.com/photo-1551601697-3b4e2aad3a96?auto=format&fit=crop&q=80&w=800',
      'logoUrl':
          'https://images.unsplash.com/photo-1551601697-3b4e2aad3a96?auto=format&fit=crop&q=80&w=200',
      'description':
          'Bệnh viện Thống Nhất TP.HCM là bệnh viện thuộc Bộ Y tế, thành lập năm 1978, chuyên về nội khoa và các bệnh lý mãn tính. Bệnh viện phục vụ cán bộ trung cao cấp và người dân khu vực phía Nam, nổi bật với chuyên khoa tim mạch, nội tiết và phục hồi chức năng.',
      'phone': '028 3849 5008',
      'email': 'bvthnhat@byt.gov.vn',
      'website': 'https://www.thongnhathospital.com',
      'workingHours': 'Cấp cứu: 24/7  |  Khám thường: 07:30 – 16:30 (T2–T7)',
      'type': 'public',
      'bedCount': 600,
      'establishedYear': 1978,
      'emergencyAvailable': true,
      'parkingAvailable': true,
      'ambulanceService': true,
      'insuranceAccepted': ['BHYT', 'Bảo Việt', 'PVI'],
      'createdAt': now,
      'updatedAt': now,
    },
  ];

  final batch = db.batch();
  for (final h in hospitals) {
    final docId = h['_docId'] as String;
    final data = Map<String, dynamic>.from(h)..remove('_docId');
    // merge: true preserves any existing admin fields (name, logoUrl) already set
    batch.set(col.doc(docId), data, SetOptions(merge: true));
  }

  await batch.commit();
  debugPrint('[HospitalSeeder] Seeded ${hospitals.length} hospitals successfully.');
  } // end if (!hospitalsAlreadySeeded)

  await _seedDepartmentsAndRooms(db);
  await _seedDoctors(db);
}

Future<void> _seedDepartmentsAndRooms(FirebaseFirestore db) async {
  // Guard: skip if already seeded
  final guard = await db
      .collection('hospitals')
      .doc('hosp_cho_ray')
      .collection('departments')
      .doc('dept_cr_cardio')
      .get();
  if (guard.exists) {
    debugPrint('[HospitalSeeder] Departments already seeded – skipping.');
    return;
  }

  // Each entry: { '_hospId': ..., '_deptId': ..., ...fields }
  final departments = <Map<String, dynamic>>[
    // ── hosp_cho_ray ──────────────────────────────────────────────────────
    {
      '_hospId': 'hosp_cho_ray',
      '_deptId': 'dept_cr_cardio',
      'name': 'Khoa Tim Mạch',
      'description': 'Chẩn đoán và điều trị các bệnh lý tim mạch, can thiệp mạch vành, đặt máy tạo nhịp.',
      'iconName': 'favorite',
      'doctorCount': 15,
      'order': 1,
    },
    {
      '_hospId': 'hosp_cho_ray',
      '_deptId': 'dept_cr_surgery',
      'name': 'Khoa Ngoại Tổng Quát',
      'description': 'Phẫu thuật tổng quát, nội soi ổ bụng, phẫu thuật tiêu hóa và các ca mổ cấp cứu.',
      'iconName': 'medical_services',
      'doctorCount': 20,
      'order': 2,
    },
    {
      '_hospId': 'hosp_cho_ray',
      '_deptId': 'dept_cr_emergency',
      'name': 'Khoa Cấp Cứu',
      'description': 'Tiếp nhận và xử lý các trường hợp cấp cứu 24/7, hồi sức tích cực.',
      'iconName': 'emergency',
      'doctorCount': 25,
      'order': 3,
    },
    {
      '_hospId': 'hosp_cho_ray',
      '_deptId': 'dept_cr_neuro',
      'name': 'Khoa Nội Thần Kinh',
      'description': 'Điều trị đột quỵ, Parkinson, động kinh và các bệnh lý thần kinh trung ương.',
      'iconName': 'psychology',
      'doctorCount': 12,
      'order': 4,
    },

    // ── hosp_dhyd_hcm ─────────────────────────────────────────────────────
    {
      '_hospId': 'hosp_dhyd_hcm',
      '_deptId': 'dept_dhyd_internal',
      'name': 'Khoa Nội Tổng Quát',
      'description': 'Khám và điều trị các bệnh nội khoa tổng quát, bệnh mãn tính.',
      'iconName': 'healing',
      'doctorCount': 18,
      'order': 1,
    },
    {
      '_hospId': 'hosp_dhyd_hcm',
      '_deptId': 'dept_dhyd_surgery',
      'name': 'Khoa Ngoại Tổng Quát',
      'description': 'Phẫu thuật tổng quát và chuyên sâu, ghép tạng, vi phẫu.',
      'iconName': 'medical_services',
      'doctorCount': 16,
      'order': 2,
    },
    {
      '_hospId': 'hosp_dhyd_hcm',
      '_deptId': 'dept_dhyd_oncology',
      'name': 'Khoa Ung Bướu',
      'description': 'Hóa trị, xạ trị và điều trị đích trong ung thư các cơ quan.',
      'iconName': 'biotech',
      'doctorCount': 14,
      'order': 3,
    },
    {
      '_hospId': 'hosp_dhyd_hcm',
      '_deptId': 'dept_dhyd_gastro',
      'name': 'Khoa Tiêu Hóa',
      'description': 'Nội soi tiêu hóa, điều trị viêm loét dạ dày, bệnh gan mật tụy.',
      'iconName': 'science',
      'doctorCount': 10,
      'order': 4,
    },

    // ── hosp_tu_du ────────────────────────────────────────────────────────
    {
      '_hospId': 'hosp_tu_du',
      '_deptId': 'dept_tudu_obstetrics',
      'name': 'Khoa Sản',
      'description': 'Theo dõi thai kỳ, hỗ trợ sinh thường và sinh mổ, chăm sóc sau sinh.',
      'iconName': 'pregnant_woman',
      'doctorCount': 30,
      'order': 1,
    },
    {
      '_hospId': 'hosp_tu_du',
      '_deptId': 'dept_tudu_gynecology',
      'name': 'Khoa Phụ Khoa',
      'description': 'Khám phụ khoa, điều trị u xơ tử cung, phẫu thuật nội soi phụ khoa.',
      'iconName': 'local_hospital',
      'doctorCount': 22,
      'order': 2,
    },
    {
      '_hospId': 'hosp_tu_du',
      '_deptId': 'dept_tudu_ivf',
      'name': 'Trung Tâm Hỗ Trợ Sinh Sản (IVF)',
      'description': 'Thụ tinh ống nghiệm, bơm tinh trùng và các kỹ thuật hỗ trợ sinh sản hiện đại.',
      'iconName': 'biotech',
      'doctorCount': 12,
      'order': 3,
    },
    {
      '_hospId': 'hosp_tu_du',
      '_deptId': 'dept_tudu_neonatal',
      'name': 'Khoa Sơ Sinh',
      'description': 'Chăm sóc trẻ sơ sinh thiếu tháng, hồi sức sơ sinh và theo dõi bệnh lý sơ sinh.',
      'iconName': 'child_care',
      'doctorCount': 15,
      'order': 4,
    },

    // ── hosp_fv ───────────────────────────────────────────────────────────
    {
      '_hospId': 'hosp_fv',
      '_deptId': 'dept_fv_emergency',
      'name': 'Khoa Cấp Cứu',
      'description': 'Cấp cứu quốc tế 24/7, hồi sức tích cực theo tiêu chuẩn JCI.',
      'iconName': 'emergency',
      'doctorCount': 20,
      'order': 1,
    },
    {
      '_hospId': 'hosp_fv',
      '_deptId': 'dept_fv_cardio',
      'name': 'Khoa Tim Mạch',
      'description': 'Tim mạch can thiệp, siêu âm tim, điều trị rối loạn nhịp.',
      'iconName': 'favorite',
      'doctorCount': 12,
      'order': 2,
    },
    {
      '_hospId': 'hosp_fv',
      '_deptId': 'dept_fv_neuro',
      'name': 'Khoa Thần Kinh',
      'description': 'Điều trị đột quỵ, thoát vị đĩa đệm, phẫu thuật thần kinh.',
      'iconName': 'psychology',
      'doctorCount': 10,
      'order': 3,
    },
    {
      '_hospId': 'hosp_fv',
      '_deptId': 'dept_fv_ortho',
      'name': 'Khoa Chỉnh Hình',
      'description': 'Phẫu thuật xương khớp, thay khớp háng/gối, phục hồi chức năng vận động.',
      'iconName': 'accessible',
      'doctorCount': 9,
      'order': 4,
    },

    // ── hosp_tam_anh ──────────────────────────────────────────────────────
    {
      '_hospId': 'hosp_tam_anh',
      '_deptId': 'dept_ta_cardio',
      'name': 'Trung Tâm Tim Mạch',
      'description': 'Can thiệp tim mạch hiện đại nhất, phẫu thuật tim hở, điều trị suy tim.',
      'iconName': 'favorite',
      'doctorCount': 18,
      'order': 1,
    },
    {
      '_hospId': 'hosp_tam_anh',
      '_deptId': 'dept_ta_ivf',
      'name': 'Trung Tâm Hỗ Trợ Sinh Sản',
      'description': 'IVF thế hệ mới, xét nghiệm di truyền tiền làm tổ (PGT), lưu trữ phôi.',
      'iconName': 'biotech',
      'doctorCount': 14,
      'order': 2,
    },
    {
      '_hospId': 'hosp_tam_anh',
      '_deptId': 'dept_ta_oncology',
      'name': 'Khoa Ung Bướu',
      'description': 'Điều trị ung thư đa mô thức, liệu pháp miễn dịch, xạ trị định vị.',
      'iconName': 'science',
      'doctorCount': 16,
      'order': 3,
    },
    {
      '_hospId': 'hosp_tam_anh',
      '_deptId': 'dept_ta_pediatrics',
      'name': 'Khoa Nhi',
      'description': 'Khám nhi tổng quát, tim mạch nhi, huyết học nhi và bệnh hiếm gặp ở trẻ em.',
      'iconName': 'child_care',
      'doctorCount': 20,
      'order': 4,
    },
  ];

  // Rooms per department: '_hospId', '_deptId', '_roomId', ...fields
  final rooms = <Map<String, dynamic>>[
    // ── hosp_cho_ray / dept_cr_cardio ─────────────────────────────────────
    {
      '_hospId': 'hosp_cho_ray', '_deptId': 'dept_cr_cardio', '_roomId': 'room_cr_c101',
      'name': 'Phòng khám C.101', 'floor': 'Tầng 1', 'type': 'examination',
      'status': 'available', 'workingHours': '07:00 – 11:30',
    },
    {
      '_hospId': 'hosp_cho_ray', '_deptId': 'dept_cr_cardio', '_roomId': 'room_cr_c102',
      'name': 'Phòng khám C.102', 'floor': 'Tầng 1', 'type': 'examination',
      'status': 'occupied', 'workingHours': '13:00 – 17:00',
    },
    {
      '_hospId': 'hosp_cho_ray', '_deptId': 'dept_cr_cardio', '_roomId': 'room_cr_c201',
      'name': 'Phòng thủ thuật C.201', 'floor': 'Tầng 2', 'type': 'procedure',
      'status': 'available', 'workingHours': '08:00 – 16:00',
    },
    // hosp_cho_ray / dept_cr_surgery
    {
      '_hospId': 'hosp_cho_ray', '_deptId': 'dept_cr_surgery', '_roomId': 'room_cr_s101',
      'name': 'Phòng khám N.101', 'floor': 'Tầng 1', 'type': 'examination',
      'status': 'available', 'workingHours': '07:00 – 11:30',
    },
    {
      '_hospId': 'hosp_cho_ray', '_deptId': 'dept_cr_surgery', '_roomId': 'room_cr_s201',
      'name': 'Phòng mổ N.201', 'floor': 'Tầng 2', 'type': 'procedure',
      'status': 'occupied', 'workingHours': '08:00 – 17:00',
    },
    // hosp_cho_ray / dept_cr_emergency
    {
      '_hospId': 'hosp_cho_ray', '_deptId': 'dept_cr_emergency', '_roomId': 'room_cr_e01',
      'name': 'Phòng cấp cứu E.01', 'floor': 'Tầng trệt', 'type': 'emergency',
      'status': 'available', 'workingHours': '24/7',
    },
    {
      '_hospId': 'hosp_cho_ray', '_deptId': 'dept_cr_emergency', '_roomId': 'room_cr_e02',
      'name': 'Phòng hồi sức E.02', 'floor': 'Tầng trệt', 'type': 'emergency',
      'status': 'occupied', 'workingHours': '24/7',
    },
    // hosp_cho_ray / dept_cr_neuro
    {
      '_hospId': 'hosp_cho_ray', '_deptId': 'dept_cr_neuro', '_roomId': 'room_cr_n101',
      'name': 'Phòng khám TK.101', 'floor': 'Tầng 1', 'type': 'examination',
      'status': 'available', 'workingHours': '07:30 – 11:30',
    },
    {
      '_hospId': 'hosp_cho_ray', '_deptId': 'dept_cr_neuro', '_roomId': 'room_cr_n102',
      'name': 'Phòng điện não TK.102', 'floor': 'Tầng 1', 'type': 'procedure',
      'status': 'available', 'workingHours': '08:00 – 16:00',
    },

    // ── hosp_dhyd_hcm ─────────────────────────────────────────────────────
    {
      '_hospId': 'hosp_dhyd_hcm', '_deptId': 'dept_dhyd_internal', '_roomId': 'room_dhyd_i101',
      'name': 'Phòng khám NTQ.101', 'floor': 'Tầng 1', 'type': 'examination',
      'status': 'available', 'workingHours': '07:00 – 11:30',
    },
    {
      '_hospId': 'hosp_dhyd_hcm', '_deptId': 'dept_dhyd_internal', '_roomId': 'room_dhyd_i102',
      'name': 'Phòng khám NTQ.102', 'floor': 'Tầng 1', 'type': 'examination',
      'status': 'occupied', 'workingHours': '13:00 – 16:30',
    },
    {
      '_hospId': 'hosp_dhyd_hcm', '_deptId': 'dept_dhyd_surgery', '_roomId': 'room_dhyd_s101',
      'name': 'Phòng khám Ngoại.101', 'floor': 'Tầng 2', 'type': 'examination',
      'status': 'available', 'workingHours': '07:00 – 11:30',
    },
    {
      '_hospId': 'hosp_dhyd_hcm', '_deptId': 'dept_dhyd_surgery', '_roomId': 'room_dhyd_s201',
      'name': 'Phòng mổ Ngoại.201', 'floor': 'Tầng 3', 'type': 'procedure',
      'status': 'occupied', 'workingHours': '07:30 – 16:00',
    },
    {
      '_hospId': 'hosp_dhyd_hcm', '_deptId': 'dept_dhyd_oncology', '_roomId': 'room_dhyd_o101',
      'name': 'Phòng khám UB.101', 'floor': 'Tầng 4', 'type': 'examination',
      'status': 'available', 'workingHours': '07:00 – 11:30',
    },
    {
      '_hospId': 'hosp_dhyd_hcm', '_deptId': 'dept_dhyd_oncology', '_roomId': 'room_dhyd_o102',
      'name': 'Phòng hóa trị UB.102', 'floor': 'Tầng 4', 'type': 'procedure',
      'status': 'available', 'workingHours': '08:00 – 16:00',
    },
    {
      '_hospId': 'hosp_dhyd_hcm', '_deptId': 'dept_dhyd_gastro', '_roomId': 'room_dhyd_g101',
      'name': 'Phòng nội soi TH.101', 'floor': 'Tầng 2', 'type': 'procedure',
      'status': 'available', 'workingHours': '07:00 – 11:00',
    },
    {
      '_hospId': 'hosp_dhyd_hcm', '_deptId': 'dept_dhyd_gastro', '_roomId': 'room_dhyd_g102',
      'name': 'Phòng khám TH.102', 'floor': 'Tầng 2', 'type': 'examination',
      'status': 'occupied', 'workingHours': '13:00 – 16:30',
    },

    // ── hosp_tu_du ────────────────────────────────────────────────────────
    {
      '_hospId': 'hosp_tu_du', '_deptId': 'dept_tudu_obstetrics', '_roomId': 'room_td_obs101',
      'name': 'Phòng khám Sản.101', 'floor': 'Tầng 1', 'type': 'examination',
      'status': 'occupied', 'workingHours': '07:00 – 11:30',
    },
    {
      '_hospId': 'hosp_tu_du', '_deptId': 'dept_tudu_obstetrics', '_roomId': 'room_td_obs102',
      'name': 'Phòng siêu âm Sản.102', 'floor': 'Tầng 1', 'type': 'procedure',
      'status': 'available', 'workingHours': '07:00 – 16:00',
    },
    {
      '_hospId': 'hosp_tu_du', '_deptId': 'dept_tudu_obstetrics', '_roomId': 'room_td_obs201',
      'name': 'Phòng sinh Sản.201', 'floor': 'Tầng 2', 'type': 'procedure',
      'status': 'occupied', 'workingHours': '24/7',
    },
    {
      '_hospId': 'hosp_tu_du', '_deptId': 'dept_tudu_gynecology', '_roomId': 'room_td_gyn101',
      'name': 'Phòng khám PK.101', 'floor': 'Tầng 1', 'type': 'examination',
      'status': 'available', 'workingHours': '07:00 – 11:30',
    },
    {
      '_hospId': 'hosp_tu_du', '_deptId': 'dept_tudu_gynecology', '_roomId': 'room_td_gyn102',
      'name': 'Phòng thủ thuật PK.102', 'floor': 'Tầng 1', 'type': 'procedure',
      'status': 'available', 'workingHours': '13:00 – 17:00',
    },
    {
      '_hospId': 'hosp_tu_du', '_deptId': 'dept_tudu_ivf', '_roomId': 'room_td_ivf101',
      'name': 'Phòng tư vấn IVF.101', 'floor': 'Tầng 3', 'type': 'examination',
      'status': 'available', 'workingHours': '07:30 – 11:30',
    },
    {
      '_hospId': 'hosp_tu_du', '_deptId': 'dept_tudu_ivf', '_roomId': 'room_td_ivf201',
      'name': 'Phòng thủ thuật IVF.201', 'floor': 'Tầng 3', 'type': 'procedure',
      'status': 'occupied', 'workingHours': '08:00 – 16:00',
    },
    {
      '_hospId': 'hosp_tu_du', '_deptId': 'dept_tudu_neonatal', '_roomId': 'room_td_neo101',
      'name': 'Phòng sơ sinh SS.101', 'floor': 'Tầng 4', 'type': 'examination',
      'status': 'available', 'workingHours': '24/7',
    },

    // ── hosp_fv ───────────────────────────────────────────────────────────
    {
      '_hospId': 'hosp_fv', '_deptId': 'dept_fv_emergency', '_roomId': 'room_fv_e01',
      'name': 'Emergency Room 1', 'floor': 'Ground Floor', 'type': 'emergency',
      'status': 'available', 'workingHours': '24/7',
    },
    {
      '_hospId': 'hosp_fv', '_deptId': 'dept_fv_emergency', '_roomId': 'room_fv_e02',
      'name': 'Resuscitation Bay 2', 'floor': 'Ground Floor', 'type': 'emergency',
      'status': 'occupied', 'workingHours': '24/7',
    },
    {
      '_hospId': 'hosp_fv', '_deptId': 'dept_fv_cardio', '_roomId': 'room_fv_c101',
      'name': 'Cardiology Clinic 101', 'floor': 'Floor 1', 'type': 'examination',
      'status': 'available', 'workingHours': '08:00 – 17:00',
    },
    {
      '_hospId': 'hosp_fv', '_deptId': 'dept_fv_cardio', '_roomId': 'room_fv_c201',
      'name': 'Cath Lab 201', 'floor': 'Floor 2', 'type': 'procedure',
      'status': 'available', 'workingHours': '08:00 – 16:00',
    },
    {
      '_hospId': 'hosp_fv', '_deptId': 'dept_fv_neuro', '_roomId': 'room_fv_n101',
      'name': 'Neurology Clinic 101', 'floor': 'Floor 1', 'type': 'examination',
      'status': 'available', 'workingHours': '08:00 – 17:00',
    },
    {
      '_hospId': 'hosp_fv', '_deptId': 'dept_fv_ortho', '_roomId': 'room_fv_o101',
      'name': 'Orthopaedics Clinic 101', 'floor': 'Floor 2', 'type': 'examination',
      'status': 'available', 'workingHours': '08:00 – 17:00',
    },
    {
      '_hospId': 'hosp_fv', '_deptId': 'dept_fv_ortho', '_roomId': 'room_fv_o201',
      'name': 'Procedure Room O.201', 'floor': 'Floor 2', 'type': 'procedure',
      'status': 'closed', 'workingHours': '08:00 – 12:00',
    },

    // ── hosp_tam_anh ──────────────────────────────────────────────────────
    {
      '_hospId': 'hosp_tam_anh', '_deptId': 'dept_ta_cardio', '_roomId': 'room_ta_c101',
      'name': 'Phòng khám TM.101', 'floor': 'Tầng 1', 'type': 'examination',
      'status': 'available', 'workingHours': '07:00 – 11:30',
    },
    {
      '_hospId': 'hosp_tam_anh', '_deptId': 'dept_ta_cardio', '_roomId': 'room_ta_c102',
      'name': 'Phòng siêu âm tim TM.102', 'floor': 'Tầng 1', 'type': 'procedure',
      'status': 'occupied', 'workingHours': '07:00 – 17:00',
    },
    {
      '_hospId': 'hosp_tam_anh', '_deptId': 'dept_ta_cardio', '_roomId': 'room_ta_c201',
      'name': 'Phòng can thiệp TM.201', 'floor': 'Tầng 2', 'type': 'procedure',
      'status': 'available', 'workingHours': '08:00 – 16:00',
    },
    {
      '_hospId': 'hosp_tam_anh', '_deptId': 'dept_ta_ivf', '_roomId': 'room_ta_ivf101',
      'name': 'Phòng tư vấn IVF.101', 'floor': 'Tầng 3', 'type': 'examination',
      'status': 'available', 'workingHours': '07:30 – 11:30',
    },
    {
      '_hospId': 'hosp_tam_anh', '_deptId': 'dept_ta_ivf', '_roomId': 'room_ta_ivf201',
      'name': 'Phòng thụ tinh IVF.201', 'floor': 'Tầng 3', 'type': 'procedure',
      'status': 'occupied', 'workingHours': '08:00 – 17:00',
    },
    {
      '_hospId': 'hosp_tam_anh', '_deptId': 'dept_ta_oncology', '_roomId': 'room_ta_o101',
      'name': 'Phòng khám UB.101', 'floor': 'Tầng 4', 'type': 'examination',
      'status': 'available', 'workingHours': '07:00 – 11:30',
    },
    {
      '_hospId': 'hosp_tam_anh', '_deptId': 'dept_ta_oncology', '_roomId': 'room_ta_o102',
      'name': 'Phòng truyền hóa chất UB.102', 'floor': 'Tầng 4', 'type': 'procedure',
      'status': 'available', 'workingHours': '08:00 – 16:00',
    },
    {
      '_hospId': 'hosp_tam_anh', '_deptId': 'dept_ta_pediatrics', '_roomId': 'room_ta_p101',
      'name': 'Phòng khám Nhi.101', 'floor': 'Tầng 1', 'type': 'examination',
      'status': 'occupied', 'workingHours': '07:00 – 11:30',
    },
    {
      '_hospId': 'hosp_tam_anh', '_deptId': 'dept_ta_pediatrics', '_roomId': 'room_ta_p102',
      'name': 'Phòng khám Nhi.102', 'floor': 'Tầng 1', 'type': 'examination',
      'status': 'available', 'workingHours': '13:00 – 17:00',
    },
  ];

  // Batch writes in groups of 400 to stay under the 500-write limit
  var batch = db.batch();
  int opCount = 0;

  Future<void> flushIfNeeded() async {
    if (opCount >= 400) {
      await batch.commit();
      debugPrint('[HospitalSeeder] Flushed batch ($opCount ops)');
      batch = db.batch();
      opCount = 0;
    }
  }

  for (final dept in departments) {
    await flushIfNeeded();
    final hospId = dept['_hospId'] as String;
    final deptId = dept['_deptId'] as String;
    final data = Map<String, dynamic>.from(dept)
      ..remove('_hospId')
      ..remove('_deptId');
    data['id'] = deptId;
    batch.set(
      db.collection('hospitals').doc(hospId).collection('departments').doc(deptId),
      data,
      SetOptions(merge: true),
    );
    opCount++;
  }

  for (final room in rooms) {
    await flushIfNeeded();
    final hospId = room['_hospId'] as String;
    final deptId = room['_deptId'] as String;
    final roomId = room['_roomId'] as String;
    final data = Map<String, dynamic>.from(room)
      ..remove('_hospId')
      ..remove('_deptId')
      ..remove('_roomId');
    data['id'] = roomId;
    batch.set(
      db
          .collection('hospitals')
          .doc(hospId)
          .collection('departments')
          .doc(deptId)
          .collection('rooms')
          .doc(roomId),
      data,
      SetOptions(merge: true),
    );
    opCount++;
  }

  if (opCount > 0) {
    await batch.commit();
    debugPrint('[HospitalSeeder] Seeded ${departments.length} departments and ${rooms.length} rooms.');
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Public force-seed: bypasses all guards, deletes then re-writes departments,
// rooms, and doctors.
// ─────────────────────────────────────────────────────────────────────────────
Future<String> forceSeedDepartmentsAndDoctors() async {
  final db = FirebaseFirestore.instance;
  int deptCount = 0;
  int doctorCount = 0;

  const avatarBase = 'https://i.pravatar.cc/150?img=';

  // ── Department + Room data ─────────────────────────────────────────────────
  final departments = <Map<String, dynamic>>[
    // ── hosp_cho_ray ──────────────────────────────────────────────────────
    {
      '_hospId': 'hosp_cho_ray', '_deptId': 'dept_cr_emergency',
      'name': 'Khoa Cấp Cứu',
      'description': 'Tiếp nhận và xử lý các trường hợp cấp cứu 24/7, hồi sức tích cực, ổn định bệnh nhân trước khi chuyển chuyên khoa.',
      'iconName': 'emergency', 'doctorCount': 40, 'order': 1,
    },
    {
      '_hospId': 'hosp_cho_ray', '_deptId': 'dept_cr_cardio',
      'name': 'Khoa Tim Mạch',
      'description': 'Chẩn đoán và điều trị các bệnh lý tim mạch, can thiệp mạch vành, đặt máy tạo nhịp và điều trị suy tim.',
      'iconName': 'favorite', 'doctorCount': 25, 'order': 2,
    },
    {
      '_hospId': 'hosp_cho_ray', '_deptId': 'dept_cr_neuro',
      'name': 'Khoa Nội Thần Kinh',
      'description': 'Điều trị đột quỵ não, Parkinson, động kinh, đau đầu mãn tính và các bệnh lý thần kinh trung ương.',
      'iconName': 'psychology', 'doctorCount': 18, 'order': 3,
    },
    {
      '_hospId': 'hosp_cho_ray', '_deptId': 'dept_cr_surgery',
      'name': 'Khoa Ngoại Tổng Quát',
      'description': 'Phẫu thuật tổng quát, nội soi ổ bụng, phẫu thuật tiêu hóa và các ca mổ cấp cứu ngoại khoa.',
      'iconName': 'medical_services', 'doctorCount': 30, 'order': 4,
    },
    {
      '_hospId': 'hosp_cho_ray', '_deptId': 'dept_cr_ortho',
      'name': 'Khoa Chấn Thương Chỉnh Hình',
      'description': 'Điều trị gãy xương, chấn thương khớp, phẫu thuật thay khớp và phục hồi chức năng vận động.',
      'iconName': 'accessible', 'doctorCount': 20, 'order': 5,
    },
    {
      '_hospId': 'hosp_cho_ray', '_deptId': 'dept_cr_oncology',
      'name': 'Khoa Ung Bướu',
      'description': 'Điều trị ung thư đa mô thức bao gồm hóa trị, xạ trị và phẫu thuật ung bướu chuyên sâu.',
      'iconName': 'biotech', 'doctorCount': 15, 'order': 6,
    },
    {
      '_hospId': 'hosp_cho_ray', '_deptId': 'dept_cr_hematology',
      'name': 'Khoa Huyết Học',
      'description': 'Chẩn đoán và điều trị các bệnh lý huyết học, bạch cầu, thiếu máu và rối loạn đông máu.',
      'iconName': 'science', 'doctorCount': 12, 'order': 7,
    },
    {
      '_hospId': 'hosp_cho_ray', '_deptId': 'dept_cr_gastro',
      'name': 'Khoa Tiêu Hóa',
      'description': 'Nội soi tiêu hóa, điều trị viêm loét dạ dày tá tràng, bệnh gan mật tụy và các bệnh đường ruột.',
      'iconName': 'healing', 'doctorCount': 14, 'order': 8,
    },

    // ── hosp_dhyd_hcm ──────────────────────────────────────────────────────
    {
      '_hospId': 'hosp_dhyd_hcm', '_deptId': 'dept_dhyd_internal',
      'name': 'Khoa Nội Tổng Quát',
      'description': 'Khám và điều trị các bệnh nội khoa tổng quát, bệnh mãn tính kết hợp đào tạo thực hành lâm sàng.',
      'iconName': 'healing', 'doctorCount': 22, 'order': 1,
    },
    {
      '_hospId': 'hosp_dhyd_hcm', '_deptId': 'dept_dhyd_surgery',
      'name': 'Khoa Ngoại Tổng Quát',
      'description': 'Phẫu thuật tổng quát và chuyên sâu, ghép tạng và vi phẫu tạo hình với đội ngũ giáo sư đầu ngành.',
      'iconName': 'medical_services', 'doctorCount': 18, 'order': 2,
    },
    {
      '_hospId': 'hosp_dhyd_hcm', '_deptId': 'dept_dhyd_gastro',
      'name': 'Khoa Tiêu Hóa – Gan Mật Tụy',
      'description': 'Nội soi tiêu hóa can thiệp, điều trị bệnh lý gan mật tụy phức tạp và nghiên cứu lâm sàng chuyên sâu.',
      'iconName': 'science', 'doctorCount': 16, 'order': 3,
    },
    {
      '_hospId': 'hosp_dhyd_hcm', '_deptId': 'dept_dhyd_oncology',
      'name': 'Khoa Ung Bướu',
      'description': 'Hóa trị, xạ trị và điều trị đích trong ung thư các cơ quan kết hợp nghiên cứu thử nghiệm lâm sàng.',
      'iconName': 'biotech', 'doctorCount': 14, 'order': 4,
    },
    {
      '_hospId': 'hosp_dhyd_hcm', '_deptId': 'dept_dhyd_endo',
      'name': 'Khoa Nội Tiết – Đái Tháo Đường',
      'description': 'Điều trị đái tháo đường, bệnh tuyến giáp, loãng xương và các rối loạn nội tiết chuyển hóa.',
      'iconName': 'psychology', 'doctorCount': 12, 'order': 5,
    },
    {
      '_hospId': 'hosp_dhyd_hcm', '_deptId': 'dept_dhyd_pediatrics',
      'name': 'Khoa Nhi',
      'description': 'Khám và điều trị bệnh lý trẻ em từ sơ sinh đến 15 tuổi với đội ngũ chuyên gia nhi khoa giàu kinh nghiệm.',
      'iconName': 'child_care', 'doctorCount': 15, 'order': 6,
    },

    // ── hosp_tu_du ─────────────────────────────────────────────────────────
    {
      '_hospId': 'hosp_tu_du', '_deptId': 'dept_tudu_obstetrics',
      'name': 'Khoa Sản Bệnh',
      'description': 'Theo dõi và điều trị thai kỳ nguy cơ cao, hỗ trợ sinh thường và sinh mổ, chăm sóc mẹ sau sinh.',
      'iconName': 'pregnant_woman', 'doctorCount': 35, 'order': 1,
    },
    {
      '_hospId': 'hosp_tu_du', '_deptId': 'dept_tudu_delivery',
      'name': 'Khoa Sinh Đẻ',
      'description': 'Đỡ sinh thường và mổ lấy thai, theo dõi chuyển dạ và xử lý tai biến sản khoa cấp cứu.',
      'iconName': 'child_care', 'doctorCount': 28, 'order': 2,
    },
    {
      '_hospId': 'hosp_tu_du', '_deptId': 'dept_tudu_gynecology',
      'name': 'Khoa Phụ Khoa',
      'description': 'Khám phụ khoa, điều trị u xơ tử cung, ung thư cổ tử cung và phẫu thuật nội soi phụ khoa nâng cao.',
      'iconName': 'favorite', 'doctorCount': 22, 'order': 3,
    },
    {
      '_hospId': 'hosp_tu_du', '_deptId': 'dept_tudu_ivf',
      'name': 'Khoa Hỗ Trợ Sinh Sản (IVF)',
      'description': 'Thụ tinh ống nghiệm, bơm tinh trùng, xét nghiệm di truyền tiền làm tổ và lưu trữ phôi dài hạn.',
      'iconName': 'science', 'doctorCount': 18, 'order': 4,
    },
    {
      '_hospId': 'hosp_tu_du', '_deptId': 'dept_tudu_neonatal',
      'name': 'Khoa Sơ Sinh',
      'description': 'Chăm sóc trẻ sơ sinh thiếu tháng, hồi sức sơ sinh và theo dõi chuyên sâu các bệnh lý sơ sinh.',
      'iconName': 'child_care', 'doctorCount': 20, 'order': 5,
    },
    {
      '_hospId': 'hosp_tu_du', '_deptId': 'dept_tudu_gyn_onco',
      'name': 'Khoa Ung Bướu Phụ Khoa',
      'description': 'Chẩn đoán và điều trị ung thư buồng trứng, cổ tử cung và các khối u phụ khoa ác tính.',
      'iconName': 'biotech', 'doctorCount': 10, 'order': 6,
    },

    // ── hosp_fv ────────────────────────────────────────────────────────────
    {
      '_hospId': 'hosp_fv', '_deptId': 'dept_fv_emergency',
      'name': 'Khoa Cấp Cứu & Hồi Sức',
      'description': 'Cấp cứu quốc tế 24/7, hồi sức tích cực theo tiêu chuẩn JCI với đội ngũ bác sĩ đa quốc tịch.',
      'iconName': 'emergency', 'doctorCount': 20, 'order': 1,
    },
    {
      '_hospId': 'hosp_fv', '_deptId': 'dept_fv_cardio',
      'name': 'Khoa Tim Mạch',
      'description': 'Tim mạch can thiệp, siêu âm tim 3D, điều trị rối loạn nhịp và cấy ghép thiết bị tim mạch.',
      'iconName': 'favorite', 'doctorCount': 15, 'order': 2,
    },
    {
      '_hospId': 'hosp_fv', '_deptId': 'dept_fv_ortho',
      'name': 'Khoa Chỉnh Hình & Cột Sống',
      'description': 'Phẫu thuật xương khớp, thay khớp háng và gối, điều trị thoát vị đĩa đệm và phục hồi chức năng.',
      'iconName': 'accessible', 'doctorCount': 14, 'order': 3,
    },
    {
      '_hospId': 'hosp_fv', '_deptId': 'dept_fv_neuro_surg',
      'name': 'Khoa Ngoại Thần Kinh',
      'description': 'Phẫu thuật não u bướu, can thiệp mạch não và điều trị các bệnh lý thần kinh cần phẫu thuật.',
      'iconName': 'psychology', 'doctorCount': 10, 'order': 4,
    },
    {
      '_hospId': 'hosp_fv', '_deptId': 'dept_fv_obstetrics',
      'name': 'Khoa Sản & Phụ Khoa',
      'description': 'Sản khoa và phụ khoa tiêu chuẩn quốc tế, sinh tự nhiên và mổ lấy thai trong môi trường hiện đại.',
      'iconName': 'pregnant_woman', 'doctorCount': 12, 'order': 5,
    },
    {
      '_hospId': 'hosp_fv', '_deptId': 'dept_fv_pediatrics',
      'name': 'Khoa Nhi',
      'description': 'Khám và điều trị toàn diện cho trẻ em với phòng khám thân thiện và bác sĩ nhi khoa quốc tế.',
      'iconName': 'child_care', 'doctorCount': 12, 'order': 6,
    },

    // ── hosp_tam_anh ───────────────────────────────────────────────────────
    {
      '_hospId': 'hosp_tam_anh', '_deptId': 'dept_ta_cardio',
      'name': 'Trung tâm Tim Mạch',
      'description': 'Can thiệp tim mạch hiện đại nhất Đông Nam Á, phẫu thuật tim hở, điều trị suy tim và bệnh van tim.',
      'iconName': 'favorite', 'doctorCount': 30, 'order': 1,
    },
    {
      '_hospId': 'hosp_tam_anh', '_deptId': 'dept_ta_ivf',
      'name': 'Trung tâm IVFMD Tâm Anh',
      'description': 'IVF thế hệ mới, xét nghiệm di truyền tiền làm tổ (PGT-A/M/SR), lưu trữ phôi và noãn đông lạnh.',
      'iconName': 'science', 'doctorCount': 20, 'order': 2,
    },
    {
      '_hospId': 'hosp_tam_anh', '_deptId': 'dept_ta_oncology',
      'name': 'Khoa Ung Bướu',
      'description': 'Điều trị ung thư đa mô thức, liệu pháp miễn dịch, xạ trị định vị thân và proton therapy.',
      'iconName': 'biotech', 'doctorCount': 18, 'order': 3,
    },
    {
      '_hospId': 'hosp_tam_anh', '_deptId': 'dept_ta_orthopedics',
      'name': 'Khoa Cơ Xương Khớp',
      'description': 'Phẫu thuật khớp nội soi, thay khớp toàn phần bằng robot, điều trị loãng xương và thoái hóa khớp.',
      'iconName': 'accessible', 'doctorCount': 16, 'order': 4,
    },
    {
      '_hospId': 'hosp_tam_anh', '_deptId': 'dept_ta_pediatrics',
      'name': 'Khoa Nhi',
      'description': 'Khám nhi tổng quát, tim mạch nhi, huyết học nhi và điều trị bệnh hiếm gặp ở trẻ em.',
      'iconName': 'child_care', 'doctorCount': 14, 'order': 5,
    },
    {
      '_hospId': 'hosp_tam_anh', '_deptId': 'dept_ta_gastro',
      'name': 'Khoa Tiêu Hóa – Gan Mật',
      'description': 'Nội soi tiêu hóa can thiệp, điều trị bệnh gan mật tụy và ghép gan với công nghệ tiên tiến.',
      'iconName': 'healing', 'doctorCount': 12, 'order': 6,
    },
  ];

  // ── Room data (3 rooms per department) ────────────────────────────────────
  final rooms = <Map<String, dynamic>>[
    // hosp_cho_ray
    {'_h': 'hosp_cho_ray', '_d': 'dept_cr_emergency', '_r': 'room_cr_em101', 'name': 'Phòng cấp cứu CC.101', 'floor': 'Tầng trệt', 'type': 'emergency', 'status': 'available', 'workingHours': '24/7'},
    {'_h': 'hosp_cho_ray', '_d': 'dept_cr_emergency', '_r': 'room_cr_em102', 'name': 'Phòng hồi sức CC.102', 'floor': 'Tầng trệt', 'type': 'emergency', 'status': 'occupied', 'workingHours': '24/7'},
    {'_h': 'hosp_cho_ray', '_d': 'dept_cr_emergency', '_r': 'room_cr_em201', 'name': 'Phòng theo dõi CC.201', 'floor': 'Tầng 2', 'type': 'examination', 'status': 'available', 'workingHours': '24/7'},

    {'_h': 'hosp_cho_ray', '_d': 'dept_cr_cardio', '_r': 'room_cr_c101', 'name': 'Phòng khám TM.101', 'floor': 'Tầng 1', 'type': 'examination', 'status': 'available', 'workingHours': '07:00 – 11:30'},
    {'_h': 'hosp_cho_ray', '_d': 'dept_cr_cardio', '_r': 'room_cr_c102', 'name': 'Phòng khám TM.102', 'floor': 'Tầng 1', 'type': 'examination', 'status': 'occupied', 'workingHours': '13:00 – 17:00'},
    {'_h': 'hosp_cho_ray', '_d': 'dept_cr_cardio', '_r': 'room_cr_c201', 'name': 'Phòng thủ thuật TM.201', 'floor': 'Tầng 2', 'type': 'procedure', 'status': 'available', 'workingHours': '08:00 – 16:00'},

    {'_h': 'hosp_cho_ray', '_d': 'dept_cr_neuro', '_r': 'room_cr_n101', 'name': 'Phòng khám TK.101', 'floor': 'Tầng 1', 'type': 'examination', 'status': 'available', 'workingHours': '07:30 – 11:30'},
    {'_h': 'hosp_cho_ray', '_d': 'dept_cr_neuro', '_r': 'room_cr_n102', 'name': 'Phòng điện não TK.102', 'floor': 'Tầng 1', 'type': 'procedure', 'status': 'available', 'workingHours': '08:00 – 16:00'},
    {'_h': 'hosp_cho_ray', '_d': 'dept_cr_neuro', '_r': 'room_cr_n201', 'name': 'Phòng MRI TK.201', 'floor': 'Tầng 2', 'type': 'procedure', 'status': 'closed', 'workingHours': '08:00 – 12:00'},

    {'_h': 'hosp_cho_ray', '_d': 'dept_cr_surgery', '_r': 'room_cr_s101', 'name': 'Phòng khám NG.101', 'floor': 'Tầng 1', 'type': 'examination', 'status': 'available', 'workingHours': '07:00 – 11:30'},
    {'_h': 'hosp_cho_ray', '_d': 'dept_cr_surgery', '_r': 'room_cr_s201', 'name': 'Phòng mổ NG.201', 'floor': 'Tầng 2', 'type': 'procedure', 'status': 'occupied', 'workingHours': '08:00 – 17:00'},
    {'_h': 'hosp_cho_ray', '_d': 'dept_cr_surgery', '_r': 'room_cr_s202', 'name': 'Phòng mổ NG.202', 'floor': 'Tầng 2', 'type': 'procedure', 'status': 'available', 'workingHours': '08:00 – 17:00'},

    {'_h': 'hosp_cho_ray', '_d': 'dept_cr_ortho', '_r': 'room_cr_or101', 'name': 'Phòng khám CH.101', 'floor': 'Tầng 1', 'type': 'examination', 'status': 'available', 'workingHours': '07:00 – 11:30'},
    {'_h': 'hosp_cho_ray', '_d': 'dept_cr_ortho', '_r': 'room_cr_or201', 'name': 'Phòng mổ CH.201', 'floor': 'Tầng 2', 'type': 'procedure', 'status': 'occupied', 'workingHours': '08:00 – 16:00'},
    {'_h': 'hosp_cho_ray', '_d': 'dept_cr_ortho', '_r': 'room_cr_or202', 'name': 'Phòng mổ CH.202', 'floor': 'Tầng 2', 'type': 'procedure', 'status': 'available', 'workingHours': '08:00 – 16:00'},

    {'_h': 'hosp_cho_ray', '_d': 'dept_cr_oncology', '_r': 'room_cr_on101', 'name': 'Phòng khám UB.101', 'floor': 'Tầng 3', 'type': 'examination', 'status': 'available', 'workingHours': '07:00 – 11:30'},
    {'_h': 'hosp_cho_ray', '_d': 'dept_cr_oncology', '_r': 'room_cr_on102', 'name': 'Phòng hóa trị UB.102', 'floor': 'Tầng 3', 'type': 'procedure', 'status': 'occupied', 'workingHours': '08:00 – 16:00'},
    {'_h': 'hosp_cho_ray', '_d': 'dept_cr_oncology', '_r': 'room_cr_on103', 'name': 'Phòng xạ trị UB.103', 'floor': 'Tầng 3', 'type': 'procedure', 'status': 'available', 'workingHours': '08:00 – 16:00'},

    {'_h': 'hosp_cho_ray', '_d': 'dept_cr_hematology', '_r': 'room_cr_he101', 'name': 'Phòng khám HH.101', 'floor': 'Tầng 4', 'type': 'examination', 'status': 'available', 'workingHours': '07:00 – 11:30'},
    {'_h': 'hosp_cho_ray', '_d': 'dept_cr_hematology', '_r': 'room_cr_he102', 'name': 'Phòng lấy máu HH.102', 'floor': 'Tầng 4', 'type': 'procedure', 'status': 'available', 'workingHours': '06:30 – 10:30'},
    {'_h': 'hosp_cho_ray', '_d': 'dept_cr_hematology', '_r': 'room_cr_he201', 'name': 'Phòng truyền máu HH.201', 'floor': 'Tầng 4', 'type': 'procedure', 'status': 'occupied', 'workingHours': '08:00 – 16:00'},

    {'_h': 'hosp_cho_ray', '_d': 'dept_cr_gastro', '_r': 'room_cr_g101', 'name': 'Phòng nội soi TH.101', 'floor': 'Tầng 2', 'type': 'procedure', 'status': 'available', 'workingHours': '07:00 – 11:00'},
    {'_h': 'hosp_cho_ray', '_d': 'dept_cr_gastro', '_r': 'room_cr_g102', 'name': 'Phòng khám TH.102', 'floor': 'Tầng 2', 'type': 'examination', 'status': 'occupied', 'workingHours': '13:00 – 16:30'},
    {'_h': 'hosp_cho_ray', '_d': 'dept_cr_gastro', '_r': 'room_cr_g201', 'name': 'Phòng siêu âm TH.201', 'floor': 'Tầng 2', 'type': 'procedure', 'status': 'available', 'workingHours': '08:00 – 16:00'},

    // hosp_dhyd_hcm
    {'_h': 'hosp_dhyd_hcm', '_d': 'dept_dhyd_internal', '_r': 'room_dhyd_i101', 'name': 'Phòng khám NTQ.101', 'floor': 'Tầng 1', 'type': 'examination', 'status': 'available', 'workingHours': '07:00 – 11:30'},
    {'_h': 'hosp_dhyd_hcm', '_d': 'dept_dhyd_internal', '_r': 'room_dhyd_i102', 'name': 'Phòng khám NTQ.102', 'floor': 'Tầng 1', 'type': 'examination', 'status': 'occupied', 'workingHours': '13:00 – 16:30'},
    {'_h': 'hosp_dhyd_hcm', '_d': 'dept_dhyd_internal', '_r': 'room_dhyd_i201', 'name': 'Phòng siêu âm NTQ.201', 'floor': 'Tầng 2', 'type': 'procedure', 'status': 'available', 'workingHours': '07:30 – 11:30'},

    {'_h': 'hosp_dhyd_hcm', '_d': 'dept_dhyd_surgery', '_r': 'room_dhyd_s101', 'name': 'Phòng khám NG.101', 'floor': 'Tầng 2', 'type': 'examination', 'status': 'available', 'workingHours': '07:00 – 11:30'},
    {'_h': 'hosp_dhyd_hcm', '_d': 'dept_dhyd_surgery', '_r': 'room_dhyd_s201', 'name': 'Phòng mổ NG.201', 'floor': 'Tầng 3', 'type': 'procedure', 'status': 'occupied', 'workingHours': '07:30 – 16:00'},
    {'_h': 'hosp_dhyd_hcm', '_d': 'dept_dhyd_surgery', '_r': 'room_dhyd_s202', 'name': 'Phòng mổ NG.202', 'floor': 'Tầng 3', 'type': 'procedure', 'status': 'available', 'workingHours': '07:30 – 16:00'},

    {'_h': 'hosp_dhyd_hcm', '_d': 'dept_dhyd_gastro', '_r': 'room_dhyd_g101', 'name': 'Phòng nội soi TH.101', 'floor': 'Tầng 2', 'type': 'procedure', 'status': 'available', 'workingHours': '07:00 – 11:00'},
    {'_h': 'hosp_dhyd_hcm', '_d': 'dept_dhyd_gastro', '_r': 'room_dhyd_g102', 'name': 'Phòng khám TH.102', 'floor': 'Tầng 2', 'type': 'examination', 'status': 'occupied', 'workingHours': '13:00 – 16:30'},
    {'_h': 'hosp_dhyd_hcm', '_d': 'dept_dhyd_gastro', '_r': 'room_dhyd_g201', 'name': 'Phòng siêu âm TH.201', 'floor': 'Tầng 2', 'type': 'procedure', 'status': 'available', 'workingHours': '07:30 – 11:30'},

    {'_h': 'hosp_dhyd_hcm', '_d': 'dept_dhyd_oncology', '_r': 'room_dhyd_o101', 'name': 'Phòng khám UB.101', 'floor': 'Tầng 4', 'type': 'examination', 'status': 'available', 'workingHours': '07:00 – 11:30'},
    {'_h': 'hosp_dhyd_hcm', '_d': 'dept_dhyd_oncology', '_r': 'room_dhyd_o102', 'name': 'Phòng hóa trị UB.102', 'floor': 'Tầng 4', 'type': 'procedure', 'status': 'available', 'workingHours': '08:00 – 16:00'},
    {'_h': 'hosp_dhyd_hcm', '_d': 'dept_dhyd_oncology', '_r': 'room_dhyd_o201', 'name': 'Phòng xạ trị UB.201', 'floor': 'Tầng 4', 'type': 'procedure', 'status': 'closed', 'workingHours': '08:00 – 12:00'},

    {'_h': 'hosp_dhyd_hcm', '_d': 'dept_dhyd_endo', '_r': 'room_dhyd_e101', 'name': 'Phòng khám NT.101', 'floor': 'Tầng 3', 'type': 'examination', 'status': 'available', 'workingHours': '07:00 – 11:30'},
    {'_h': 'hosp_dhyd_hcm', '_d': 'dept_dhyd_endo', '_r': 'room_dhyd_e102', 'name': 'Phòng khám NT.102', 'floor': 'Tầng 3', 'type': 'examination', 'status': 'occupied', 'workingHours': '13:00 – 16:30'},
    {'_h': 'hosp_dhyd_hcm', '_d': 'dept_dhyd_endo', '_r': 'room_dhyd_e201', 'name': 'Phòng xét nghiệm NT.201', 'floor': 'Tầng 3', 'type': 'procedure', 'status': 'available', 'workingHours': '06:30 – 10:00'},

    {'_h': 'hosp_dhyd_hcm', '_d': 'dept_dhyd_pediatrics', '_r': 'room_dhyd_p101', 'name': 'Phòng khám Nhi.101', 'floor': 'Tầng 1', 'type': 'examination', 'status': 'occupied', 'workingHours': '07:00 – 11:30'},
    {'_h': 'hosp_dhyd_hcm', '_d': 'dept_dhyd_pediatrics', '_r': 'room_dhyd_p102', 'name': 'Phòng khám Nhi.102', 'floor': 'Tầng 1', 'type': 'examination', 'status': 'available', 'workingHours': '13:00 – 16:30'},
    {'_h': 'hosp_dhyd_hcm', '_d': 'dept_dhyd_pediatrics', '_r': 'room_dhyd_p201', 'name': 'Phòng tiêm chủng Nhi.201', 'floor': 'Tầng 2', 'type': 'procedure', 'status': 'available', 'workingHours': '07:30 – 11:00'},

    // hosp_tu_du
    {'_h': 'hosp_tu_du', '_d': 'dept_tudu_obstetrics', '_r': 'room_td_obs101', 'name': 'Phòng khám Sản.101', 'floor': 'Tầng 1', 'type': 'examination', 'status': 'occupied', 'workingHours': '07:00 – 11:30'},
    {'_h': 'hosp_tu_du', '_d': 'dept_tudu_obstetrics', '_r': 'room_td_obs102', 'name': 'Phòng siêu âm Sản.102', 'floor': 'Tầng 1', 'type': 'procedure', 'status': 'available', 'workingHours': '07:00 – 16:00'},
    {'_h': 'hosp_tu_du', '_d': 'dept_tudu_obstetrics', '_r': 'room_td_obs201', 'name': 'Phòng sinh Sản.201', 'floor': 'Tầng 2', 'type': 'procedure', 'status': 'occupied', 'workingHours': '24/7'},

    {'_h': 'hosp_tu_du', '_d': 'dept_tudu_delivery', '_r': 'room_td_del101', 'name': 'Phòng sinh SD.101', 'floor': 'Tầng 2', 'type': 'procedure', 'status': 'occupied', 'workingHours': '24/7'},
    {'_h': 'hosp_tu_du', '_d': 'dept_tudu_delivery', '_r': 'room_td_del102', 'name': 'Phòng sinh SD.102', 'floor': 'Tầng 2', 'type': 'procedure', 'status': 'available', 'workingHours': '24/7'},
    {'_h': 'hosp_tu_du', '_d': 'dept_tudu_delivery', '_r': 'room_td_del201', 'name': 'Phòng mổ sinh SD.201', 'floor': 'Tầng 2', 'type': 'procedure', 'status': 'available', 'workingHours': '24/7'},

    {'_h': 'hosp_tu_du', '_d': 'dept_tudu_gynecology', '_r': 'room_td_gyn101', 'name': 'Phòng khám PK.101', 'floor': 'Tầng 1', 'type': 'examination', 'status': 'available', 'workingHours': '07:00 – 11:30'},
    {'_h': 'hosp_tu_du', '_d': 'dept_tudu_gynecology', '_r': 'room_td_gyn102', 'name': 'Phòng thủ thuật PK.102', 'floor': 'Tầng 1', 'type': 'procedure', 'status': 'available', 'workingHours': '13:00 – 17:00'},
    {'_h': 'hosp_tu_du', '_d': 'dept_tudu_gynecology', '_r': 'room_td_gyn201', 'name': 'Phòng nội soi PK.201', 'floor': 'Tầng 2', 'type': 'procedure', 'status': 'closed', 'workingHours': '08:00 – 12:00'},

    {'_h': 'hosp_tu_du', '_d': 'dept_tudu_ivf', '_r': 'room_td_ivf101', 'name': 'Phòng tư vấn IVF.101', 'floor': 'Tầng 3', 'type': 'examination', 'status': 'available', 'workingHours': '07:30 – 11:30'},
    {'_h': 'hosp_tu_du', '_d': 'dept_tudu_ivf', '_r': 'room_td_ivf201', 'name': 'Phòng thủ thuật IVF.201', 'floor': 'Tầng 3', 'type': 'procedure', 'status': 'occupied', 'workingHours': '08:00 – 16:00'},
    {'_h': 'hosp_tu_du', '_d': 'dept_tudu_ivf', '_r': 'room_td_ivf202', 'name': 'Phòng cấy phôi IVF.202', 'floor': 'Tầng 3', 'type': 'procedure', 'status': 'available', 'workingHours': '08:00 – 14:00'},

    {'_h': 'hosp_tu_du', '_d': 'dept_tudu_neonatal', '_r': 'room_td_neo101', 'name': 'Phòng sơ sinh SS.101', 'floor': 'Tầng 4', 'type': 'examination', 'status': 'available', 'workingHours': '24/7'},
    {'_h': 'hosp_tu_du', '_d': 'dept_tudu_neonatal', '_r': 'room_td_neo102', 'name': 'Phòng NICU SS.102', 'floor': 'Tầng 4', 'type': 'procedure', 'status': 'occupied', 'workingHours': '24/7'},
    {'_h': 'hosp_tu_du', '_d': 'dept_tudu_neonatal', '_r': 'room_td_neo201', 'name': 'Phòng theo dõi SS.201', 'floor': 'Tầng 4', 'type': 'examination', 'status': 'available', 'workingHours': '24/7'},

    {'_h': 'hosp_tu_du', '_d': 'dept_tudu_gyn_onco', '_r': 'room_td_go101', 'name': 'Phòng khám UBP.101', 'floor': 'Tầng 5', 'type': 'examination', 'status': 'available', 'workingHours': '07:00 – 11:30'},
    {'_h': 'hosp_tu_du', '_d': 'dept_tudu_gyn_onco', '_r': 'room_td_go102', 'name': 'Phòng hóa trị UBP.102', 'floor': 'Tầng 5', 'type': 'procedure', 'status': 'occupied', 'workingHours': '08:00 – 16:00'},
    {'_h': 'hosp_tu_du', '_d': 'dept_tudu_gyn_onco', '_r': 'room_td_go201', 'name': 'Phòng xạ trị UBP.201', 'floor': 'Tầng 5', 'type': 'procedure', 'status': 'available', 'workingHours': '08:00 – 12:00'},

    // hosp_fv
    {'_h': 'hosp_fv', '_d': 'dept_fv_emergency', '_r': 'room_fv_e01', 'name': 'Emergency Room 1', 'floor': 'Ground Floor', 'type': 'emergency', 'status': 'available', 'workingHours': '24/7'},
    {'_h': 'hosp_fv', '_d': 'dept_fv_emergency', '_r': 'room_fv_e02', 'name': 'Resuscitation Bay 2', 'floor': 'Ground Floor', 'type': 'emergency', 'status': 'occupied', 'workingHours': '24/7'},
    {'_h': 'hosp_fv', '_d': 'dept_fv_emergency', '_r': 'room_fv_e03', 'name': 'Triage Room 3', 'floor': 'Ground Floor', 'type': 'emergency', 'status': 'available', 'workingHours': '24/7'},

    {'_h': 'hosp_fv', '_d': 'dept_fv_cardio', '_r': 'room_fv_c101', 'name': 'Cardiology Clinic 101', 'floor': 'Floor 1', 'type': 'examination', 'status': 'available', 'workingHours': '08:00 – 17:00'},
    {'_h': 'hosp_fv', '_d': 'dept_fv_cardio', '_r': 'room_fv_c201', 'name': 'Cath Lab 201', 'floor': 'Floor 2', 'type': 'procedure', 'status': 'available', 'workingHours': '08:00 – 16:00'},
    {'_h': 'hosp_fv', '_d': 'dept_fv_cardio', '_r': 'room_fv_c202', 'name': 'Echo Lab 202', 'floor': 'Floor 2', 'type': 'procedure', 'status': 'occupied', 'workingHours': '08:00 – 17:00'},

    {'_h': 'hosp_fv', '_d': 'dept_fv_ortho', '_r': 'room_fv_o101', 'name': 'Orthopaedics Clinic 101', 'floor': 'Floor 2', 'type': 'examination', 'status': 'available', 'workingHours': '08:00 – 17:00'},
    {'_h': 'hosp_fv', '_d': 'dept_fv_ortho', '_r': 'room_fv_o201', 'name': 'Procedure Room O.201', 'floor': 'Floor 2', 'type': 'procedure', 'status': 'closed', 'workingHours': '08:00 – 12:00'},
    {'_h': 'hosp_fv', '_d': 'dept_fv_ortho', '_r': 'room_fv_o202', 'name': 'OR Ortho O.202', 'floor': 'Floor 3', 'type': 'procedure', 'status': 'available', 'workingHours': '07:30 – 16:00'},

    {'_h': 'hosp_fv', '_d': 'dept_fv_neuro_surg', '_r': 'room_fv_ns101', 'name': 'Neurosurgery Clinic 101', 'floor': 'Floor 1', 'type': 'examination', 'status': 'available', 'workingHours': '08:00 – 17:00'},
    {'_h': 'hosp_fv', '_d': 'dept_fv_neuro_surg', '_r': 'room_fv_ns201', 'name': 'Neurosurgery OR 201', 'floor': 'Floor 3', 'type': 'procedure', 'status': 'occupied', 'workingHours': '07:30 – 16:00'},
    {'_h': 'hosp_fv', '_d': 'dept_fv_neuro_surg', '_r': 'room_fv_ns202', 'name': 'Neuroradiology 202', 'floor': 'Floor 2', 'type': 'procedure', 'status': 'available', 'workingHours': '08:00 – 16:00'},

    {'_h': 'hosp_fv', '_d': 'dept_fv_obstetrics', '_r': 'room_fv_obs101', 'name': 'OB/GYN Clinic 101', 'floor': 'Floor 1', 'type': 'examination', 'status': 'available', 'workingHours': '08:00 – 17:00'},
    {'_h': 'hosp_fv', '_d': 'dept_fv_obstetrics', '_r': 'room_fv_obs201', 'name': 'Delivery Suite 201', 'floor': 'Floor 2', 'type': 'procedure', 'status': 'occupied', 'workingHours': '24/7'},
    {'_h': 'hosp_fv', '_d': 'dept_fv_obstetrics', '_r': 'room_fv_obs202', 'name': 'OB OR 202', 'floor': 'Floor 2', 'type': 'procedure', 'status': 'available', 'workingHours': '24/7'},

    {'_h': 'hosp_fv', '_d': 'dept_fv_pediatrics', '_r': 'room_fv_p101', 'name': 'Paediatrics Clinic 101', 'floor': 'Floor 1', 'type': 'examination', 'status': 'available', 'workingHours': '08:00 – 17:00'},
    {'_h': 'hosp_fv', '_d': 'dept_fv_pediatrics', '_r': 'room_fv_p102', 'name': 'Paediatrics Clinic 102', 'floor': 'Floor 1', 'type': 'examination', 'status': 'occupied', 'workingHours': '08:00 – 17:00'},
    {'_h': 'hosp_fv', '_d': 'dept_fv_pediatrics', '_r': 'room_fv_p201', 'name': 'Paed Procedure 201', 'floor': 'Floor 2', 'type': 'procedure', 'status': 'available', 'workingHours': '08:00 – 12:00'},

    // hosp_tam_anh
    {'_h': 'hosp_tam_anh', '_d': 'dept_ta_cardio', '_r': 'room_ta_c101', 'name': 'Phòng khám TM.101', 'floor': 'Tầng 1', 'type': 'examination', 'status': 'available', 'workingHours': '07:00 – 11:30'},
    {'_h': 'hosp_tam_anh', '_d': 'dept_ta_cardio', '_r': 'room_ta_c102', 'name': 'Phòng siêu âm tim TM.102', 'floor': 'Tầng 1', 'type': 'procedure', 'status': 'occupied', 'workingHours': '07:00 – 17:00'},
    {'_h': 'hosp_tam_anh', '_d': 'dept_ta_cardio', '_r': 'room_ta_c201', 'name': 'Phòng can thiệp TM.201', 'floor': 'Tầng 2', 'type': 'procedure', 'status': 'available', 'workingHours': '08:00 – 16:00'},

    {'_h': 'hosp_tam_anh', '_d': 'dept_ta_ivf', '_r': 'room_ta_ivf101', 'name': 'Phòng tư vấn IVF.101', 'floor': 'Tầng 3', 'type': 'examination', 'status': 'available', 'workingHours': '07:30 – 11:30'},
    {'_h': 'hosp_tam_anh', '_d': 'dept_ta_ivf', '_r': 'room_ta_ivf201', 'name': 'Phòng thụ tinh IVF.201', 'floor': 'Tầng 3', 'type': 'procedure', 'status': 'occupied', 'workingHours': '08:00 – 17:00'},
    {'_h': 'hosp_tam_anh', '_d': 'dept_ta_ivf', '_r': 'room_ta_ivf202', 'name': 'Phòng lưu trữ phôi IVF.202', 'floor': 'Tầng 3', 'type': 'procedure', 'status': 'available', 'workingHours': '08:00 – 16:00'},

    {'_h': 'hosp_tam_anh', '_d': 'dept_ta_oncology', '_r': 'room_ta_o101', 'name': 'Phòng khám UB.101', 'floor': 'Tầng 4', 'type': 'examination', 'status': 'available', 'workingHours': '07:00 – 11:30'},
    {'_h': 'hosp_tam_anh', '_d': 'dept_ta_oncology', '_r': 'room_ta_o102', 'name': 'Phòng truyền hóa chất UB.102', 'floor': 'Tầng 4', 'type': 'procedure', 'status': 'available', 'workingHours': '08:00 – 16:00'},
    {'_h': 'hosp_tam_anh', '_d': 'dept_ta_oncology', '_r': 'room_ta_o201', 'name': 'Phòng xạ trị UB.201', 'floor': 'Tầng 4', 'type': 'procedure', 'status': 'closed', 'workingHours': '08:00 – 12:00'},

    {'_h': 'hosp_tam_anh', '_d': 'dept_ta_orthopedics', '_r': 'room_ta_or101', 'name': 'Phòng khám CXK.101', 'floor': 'Tầng 2', 'type': 'examination', 'status': 'available', 'workingHours': '07:00 – 11:30'},
    {'_h': 'hosp_tam_anh', '_d': 'dept_ta_orthopedics', '_r': 'room_ta_or201', 'name': 'Phòng mổ robot CXK.201', 'floor': 'Tầng 3', 'type': 'procedure', 'status': 'available', 'workingHours': '07:30 – 16:00'},
    {'_h': 'hosp_tam_anh', '_d': 'dept_ta_orthopedics', '_r': 'room_ta_or202', 'name': 'Phòng mổ CXK.202', 'floor': 'Tầng 3', 'type': 'procedure', 'status': 'occupied', 'workingHours': '07:30 – 16:00'},

    {'_h': 'hosp_tam_anh', '_d': 'dept_ta_pediatrics', '_r': 'room_ta_p101', 'name': 'Phòng khám Nhi.101', 'floor': 'Tầng 1', 'type': 'examination', 'status': 'occupied', 'workingHours': '07:00 – 11:30'},
    {'_h': 'hosp_tam_anh', '_d': 'dept_ta_pediatrics', '_r': 'room_ta_p102', 'name': 'Phòng khám Nhi.102', 'floor': 'Tầng 1', 'type': 'examination', 'status': 'available', 'workingHours': '13:00 – 17:00'},
    {'_h': 'hosp_tam_anh', '_d': 'dept_ta_pediatrics', '_r': 'room_ta_p201', 'name': 'Phòng tiêm Nhi.201', 'floor': 'Tầng 2', 'type': 'procedure', 'status': 'available', 'workingHours': '07:30 – 11:00'},

    {'_h': 'hosp_tam_anh', '_d': 'dept_ta_gastro', '_r': 'room_ta_g101', 'name': 'Phòng nội soi TH.101', 'floor': 'Tầng 2', 'type': 'procedure', 'status': 'available', 'workingHours': '07:00 – 11:00'},
    {'_h': 'hosp_tam_anh', '_d': 'dept_ta_gastro', '_r': 'room_ta_g102', 'name': 'Phòng khám TH.102', 'floor': 'Tầng 2', 'type': 'examination', 'status': 'occupied', 'workingHours': '13:00 – 16:30'},
    {'_h': 'hosp_tam_anh', '_d': 'dept_ta_gastro', '_r': 'room_ta_g201', 'name': 'Phòng siêu âm TH.201', 'floor': 'Tầng 2', 'type': 'procedure', 'status': 'available', 'workingHours': '08:00 – 16:00'},
  ];

  // ── Doctor data ────────────────────────────────────────────────────────────
  final doctors = <Map<String, dynamic>>[
    // dept_cr_cardio
    {
      '_id': 'doc_cr_cardio_001',
      'name': 'GS.TS. Đặng Vạn Phước',
      'specialty': 'Tim mạch',
      'hospital': 'Bệnh viện Chợ Rẫy',
      'hospitalId': 'hosp_cho_ray',
      'departmentId': 'dept_cr_cardio',
      'imageUrl': '${avatarBase}11',
      'rating': 5.0,
      'totalReviews': 614,
      'experience': 35,
      'about': 'Giáo sư hàng đầu về tim mạch can thiệp, chuyên điều trị suy tim nặng và bệnh van tim phức tạp.',
      'clinicName': 'Khoa Tim Mạch – BV Chợ Rẫy',
      'location': 'Quận 5, TP.HCM',
      'availableDays': ['Thứ 2', 'Thứ 4', 'Thứ 6'],
      'availableTimeSlots': ['07:00', '08:00', '09:00', '10:00'],
      'phone': '028 3855 4137',
    },
    {
      '_id': 'doc_cr_cardio_002',
      'name': 'PGS.TS. Nguyễn Thị Bạch Yến',
      'specialty': 'Tim mạch',
      'hospital': 'Bệnh viện Chợ Rẫy',
      'hospitalId': 'hosp_cho_ray',
      'departmentId': 'dept_cr_cardio',
      'imageUrl': '${avatarBase}44',
      'rating': 4.8,
      'totalReviews': 387,
      'experience': 22,
      'about': 'Chuyên gia siêu âm tim nâng cao, điều trị van tim và tăng áp động mạch phổi.',
      'clinicName': 'Khoa Tim Mạch – BV Chợ Rẫy',
      'location': 'Quận 5, TP.HCM',
      'availableDays': ['Thứ 3', 'Thứ 5'],
      'availableTimeSlots': ['13:00', '14:00', '15:00'],
      'phone': '028 3855 4137',
    },
    {
      '_id': 'doc_cr_cardio_003',
      'name': 'TS. BS. Phạm Nguyễn Vinh',
      'specialty': 'Tim mạch can thiệp',
      'hospital': 'Bệnh viện Chợ Rẫy',
      'hospitalId': 'hosp_cho_ray',
      'departmentId': 'dept_cr_cardio',
      'imageUrl': '${avatarBase}33',
      'rating': 4.7,
      'totalReviews': 265,
      'experience': 18,
      'about': 'Chuyên về tim mạch can thiệp, đặt stent mạch vành và holter ECG theo dõi rối loạn nhịp.',
      'clinicName': 'Khoa Tim Mạch – BV Chợ Rẫy',
      'location': 'Quận 5, TP.HCM',
      'availableDays': ['Thứ 2', 'Thứ 3', 'Thứ 5', 'Thứ 7'],
      'availableTimeSlots': ['07:00', '08:00', '09:00'],
      'phone': '028 3855 4137',
    },

    // dept_cr_neuro
    {
      '_id': 'doc_cr_neuro_001',
      'name': 'PGS.TS. Lê Văn Thính',
      'specialty': 'Thần kinh',
      'hospital': 'Bệnh viện Chợ Rẫy',
      'hospitalId': 'hosp_cho_ray',
      'departmentId': 'dept_cr_neuro',
      'imageUrl': '${avatarBase}22',
      'rating': 4.9,
      'totalReviews': 489,
      'experience': 25,
      'about': 'Chuyên gia hàng đầu về thần kinh, điều trị đột quỵ và Parkinson với hơn 25 năm kinh nghiệm.',
      'clinicName': 'Khoa Nội Thần Kinh – BV Chợ Rẫy',
      'location': 'Quận 5, TP.HCM',
      'availableDays': ['Thứ 2', 'Thứ 3', 'Thứ 4'],
      'availableTimeSlots': ['07:00', '08:00', '09:00', '10:00'],
      'phone': '028 3855 4137',
    },
    {
      '_id': 'doc_cr_neuro_002',
      'name': 'TS. BS. Trần Ngọc Tài',
      'specialty': 'Đột quỵ não',
      'hospital': 'Bệnh viện Chợ Rẫy',
      'hospitalId': 'hosp_cho_ray',
      'departmentId': 'dept_cr_neuro',
      'imageUrl': '${avatarBase}55',
      'rating': 4.7,
      'totalReviews': 312,
      'experience': 18,
      'about': 'Điều trị đột quỵ não cấp tính, can thiệp mạch não và phục hồi chức năng sau đột quỵ.',
      'clinicName': 'Khoa Nội Thần Kinh – BV Chợ Rẫy',
      'location': 'Quận 5, TP.HCM',
      'availableDays': ['Thứ 4', 'Thứ 5', 'Thứ 6'],
      'availableTimeSlots': ['13:00', '14:00', '15:00'],
      'phone': '028 3855 4137',
    },

    // dept_cr_surgery
    {
      '_id': 'doc_cr_surgery_001',
      'name': 'GS.TS. Nguyễn Đình Hối',
      'specialty': 'Ngoại tiêu hóa',
      'hospital': 'Bệnh viện Chợ Rẫy',
      'hospitalId': 'hosp_cho_ray',
      'departmentId': 'dept_cr_surgery',
      'imageUrl': '${avatarBase}15',
      'rating': 4.9,
      'totalReviews': 521,
      'experience': 38,
      'about': 'Giáo sư phẫu thuật tiêu hóa hàng đầu, nội soi ổ bụng và ung thư đại trực tràng.',
      'clinicName': 'Khoa Ngoại Tổng Quát – BV Chợ Rẫy',
      'location': 'Quận 5, TP.HCM',
      'availableDays': ['Thứ 2', 'Thứ 4', 'Thứ 6'],
      'availableTimeSlots': ['07:30', '08:30', '09:30'],
      'phone': '028 3855 4137',
    },
    {
      '_id': 'doc_cr_surgery_002',
      'name': 'PGS.TS. Dương Văn Hải',
      'specialty': 'Ngoại nội soi',
      'hospital': 'Bệnh viện Chợ Rẫy',
      'hospitalId': 'hosp_cho_ray',
      'departmentId': 'dept_cr_surgery',
      'imageUrl': '${avatarBase}47',
      'rating': 4.7,
      'totalReviews': 298,
      'experience': 20,
      'about': 'Chuyên về phẫu thuật nội soi tuyến giáp, thoát vị và phẫu thuật ít xâm lấn đường tiêu hóa.',
      'clinicName': 'Khoa Ngoại Tổng Quát – BV Chợ Rẫy',
      'location': 'Quận 5, TP.HCM',
      'availableDays': ['Thứ 3', 'Thứ 5', 'Thứ 7'],
      'availableTimeSlots': ['13:00', '14:00', '15:00'],
      'phone': '028 3855 4137',
    },

    // dept_cr_emergency
    {
      '_id': 'doc_cr_emergency_001',
      'name': 'TS. BS. Phạm Văn Hưng',
      'specialty': 'Cấp cứu hồi sức',
      'hospital': 'Bệnh viện Chợ Rẫy',
      'hospitalId': 'hosp_cho_ray',
      'departmentId': 'dept_cr_emergency',
      'imageUrl': '${avatarBase}17',
      'rating': 4.8,
      'totalReviews': 520,
      'experience': 20,
      'about': 'Chuyên gia cấp cứu hồi sức tích cực, xử lý chấn thương nặng và ngộ độc cấp tính.',
      'clinicName': 'Khoa Cấp Cứu – BV Chợ Rẫy',
      'location': 'Quận 5, TP.HCM',
      'availableDays': ['Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6'],
      'availableTimeSlots': ['08:00', '12:00', '16:00'],
      'phone': '028 3855 4137',
    },
    {
      '_id': 'doc_cr_emergency_002',
      'name': 'BS.CK2 Nguyễn Thanh Hùng',
      'specialty': 'Cấp cứu nhi',
      'hospital': 'Bệnh viện Chợ Rẫy',
      'hospitalId': 'hosp_cho_ray',
      'departmentId': 'dept_cr_emergency',
      'imageUrl': '${avatarBase}28',
      'rating': 4.6,
      'totalReviews': 234,
      'experience': 15,
      'about': 'Cấp cứu nhi khoa, hồi sức sơ sinh và xử lý các ca cấp cứu phức tạp ở trẻ em.',
      'clinicName': 'Khoa Cấp Cứu – BV Chợ Rẫy',
      'location': 'Quận 5, TP.HCM',
      'availableDays': ['Thứ 2', 'Thứ 4', 'Thứ 6', 'Chủ nhật'],
      'availableTimeSlots': ['08:00', '14:00', '20:00'],
      'phone': '028 3855 4137',
    },

    // dept_fv_cardio
    {
      '_id': 'doc_fv_cardio_001',
      'name': 'GS.TS. Phạm Nguyễn Vinh',
      'specialty': 'Tim mạch',
      'hospital': 'Bệnh viện FV',
      'hospitalId': 'hosp_fv',
      'departmentId': 'dept_fv_cardio',
      'imageUrl': '${avatarBase}13',
      'rating': 5.0,
      'totalReviews': 576,
      'experience': 30,
      'about': 'Giám đốc Khoa Tim Mạch FV, chuyên can thiệp mạch vành phức tạp và điều trị suy tim tiến triển.',
      'clinicName': 'Khoa Tim Mạch – BV FV',
      'location': 'Quận 7, TP.HCM',
      'availableDays': ['Thứ 2', 'Thứ 4', 'Thứ 6'],
      'availableTimeSlots': ['08:00', '09:00', '10:00', '14:00'],
      'phone': '028 5411 3333',
    },
    {
      '_id': 'doc_fv_cardio_002',
      'name': 'TS. BS. Ngô Quý Châu',
      'specialty': 'Nội tim mạch',
      'hospital': 'Bệnh viện FV',
      'hospitalId': 'hosp_fv',
      'departmentId': 'dept_fv_cardio',
      'imageUrl': '${avatarBase}62',
      'rating': 4.8,
      'totalReviews': 312,
      'experience': 22,
      'about': 'Chuyên về nội tim mạch, siêu âm tim 3D và điều trị tăng áp động mạch phổi.',
      'clinicName': 'Khoa Tim Mạch – BV FV',
      'location': 'Quận 7, TP.HCM',
      'availableDays': ['Thứ 3', 'Thứ 5', 'Thứ 7'],
      'availableTimeSlots': ['08:00', '09:00', '10:00'],
      'phone': '028 5411 3333',
    },

    // dept_fv_emergency
    {
      '_id': 'doc_fv_emergency_001',
      'name': 'BS.CK2 Nguyễn Đức Công',
      'specialty': 'Cấp cứu – Hồi sức',
      'hospital': 'Bệnh viện FV',
      'hospitalId': 'hosp_fv',
      'departmentId': 'dept_fv_emergency',
      'imageUrl': '${avatarBase}27',
      'rating': 4.8,
      'totalReviews': 445,
      'experience': 18,
      'about': 'Cấp cứu và hồi sức tích cực tiêu chuẩn quốc tế, chuyên xử lý đa chấn thương và ngộ độc cấp.',
      'clinicName': 'Khoa Cấp Cứu & Hồi Sức – BV FV',
      'location': 'Quận 7, TP.HCM',
      'availableDays': ['Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7', 'Chủ nhật'],
      'availableTimeSlots': ['08:00', '12:00', '16:00', '20:00'],
      'phone': '028 5411 3333',
    },

    // dept_fv_ortho
    {
      '_id': 'doc_fv_ortho_001',
      'name': 'PGS.TS. Võ Thành Toàn',
      'specialty': 'Chỉnh hình cột sống',
      'hospital': 'Bệnh viện FV',
      'hospitalId': 'hosp_fv',
      'departmentId': 'dept_fv_ortho',
      'imageUrl': '${avatarBase}35',
      'rating': 4.9,
      'totalReviews': 398,
      'experience': 25,
      'about': 'Chuyên gia chỉnh hình cột sống, thoát vị đĩa đệm và phẫu thuật ít xâm lấn cột sống.',
      'clinicName': 'Khoa Chỉnh Hình & Cột Sống – BV FV',
      'location': 'Quận 7, TP.HCM',
      'availableDays': ['Thứ 2', 'Thứ 3', 'Thứ 4'],
      'availableTimeSlots': ['08:00', '09:00', '10:00'],
      'phone': '028 5411 3333',
    },
    {
      '_id': 'doc_fv_ortho_002',
      'name': 'TS. BS. Trần Đình Chiến',
      'specialty': 'Thay khớp háng/gối',
      'hospital': 'Bệnh viện FV',
      'hospitalId': 'hosp_fv',
      'departmentId': 'dept_fv_ortho',
      'imageUrl': '${avatarBase}52',
      'rating': 4.8,
      'totalReviews': 267,
      'experience': 18,
      'about': 'Chuyên về thay khớp háng và gối toàn phần, phục hồi chức năng sau phẫu thuật xương khớp.',
      'clinicName': 'Khoa Chỉnh Hình & Cột Sống – BV FV',
      'location': 'Quận 7, TP.HCM',
      'availableDays': ['Thứ 4', 'Thứ 5', 'Thứ 6'],
      'availableTimeSlots': ['09:00', '10:00', '11:00'],
      'phone': '028 5411 3333',
    },

    // dept_ta_cardio
    {
      '_id': 'doc_ta_cardio_001',
      'name': 'GS.TS. Nguyễn Lân Việt',
      'specialty': 'Tim mạch can thiệp',
      'hospital': 'Bệnh viện Tâm Anh TP.HCM',
      'hospitalId': 'hosp_tam_anh',
      'departmentId': 'dept_ta_cardio',
      'imageUrl': '${avatarBase}61',
      'rating': 5.0,
      'totalReviews': 714,
      'experience': 40,
      'about': 'Cố vấn chuyên môn tim mạch hàng đầu Việt Nam, chuyên can thiệp mạch vành và bệnh lý van tim phức tạp.',
      'clinicName': 'Trung tâm Tim Mạch – BV Tâm Anh',
      'location': 'TP. Thủ Đức, TP.HCM',
      'availableDays': ['Thứ 2', 'Thứ 5'],
      'availableTimeSlots': ['08:00', '09:00'],
      'phone': '028 7102 6789',
    },
    {
      '_id': 'doc_ta_cardio_002',
      'name': 'PGS.TS. Trương Thanh Hương',
      'specialty': 'Tim mạch',
      'hospital': 'Bệnh viện Tâm Anh TP.HCM',
      'hospitalId': 'hosp_tam_anh',
      'departmentId': 'dept_ta_cardio',
      'imageUrl': '${avatarBase}49',
      'rating': 4.9,
      'totalReviews': 487,
      'experience': 28,
      'about': 'Chuyên gia siêu âm tim nâng cao, điều trị tăng áp phổi và rối loạn nhịp tim.',
      'clinicName': 'Trung tâm Tim Mạch – BV Tâm Anh',
      'location': 'TP. Thủ Đức, TP.HCM',
      'availableDays': ['Thứ 3', 'Thứ 4', 'Thứ 6'],
      'availableTimeSlots': ['07:30', '08:30', '09:30', '10:30'],
      'phone': '028 7102 6789',
    },
    {
      '_id': 'doc_ta_cardio_003',
      'name': 'TS. BS. Phan Đình Phong',
      'specialty': 'Tim mạch can thiệp',
      'hospital': 'Bệnh viện Tâm Anh TP.HCM',
      'hospitalId': 'hosp_tam_anh',
      'departmentId': 'dept_ta_cardio',
      'imageUrl': '${avatarBase}38',
      'rating': 4.8,
      'totalReviews': 356,
      'experience': 20,
      'about': 'Chuyên can thiệp mạch vành, đặt máy tạo nhịp và điều trị hở van hai lá qua da.',
      'clinicName': 'Trung tâm Tim Mạch – BV Tâm Anh',
      'location': 'TP. Thủ Đức, TP.HCM',
      'availableDays': ['Thứ 2', 'Thứ 4', 'Thứ 7'],
      'availableTimeSlots': ['07:00', '08:00', '09:00'],
      'phone': '028 7102 6789',
    },

    // dept_ta_ivf
    {
      '_id': 'doc_ta_ivf_001',
      'name': 'PGS.TS. Vương Thị Ngọc Lan',
      'specialty': 'Hỗ trợ sinh sản',
      'hospital': 'Bệnh viện Tâm Anh TP.HCM',
      'hospitalId': 'hosp_tam_anh',
      'departmentId': 'dept_ta_ivf',
      'imageUrl': '${avatarBase}40',
      'rating': 4.9,
      'totalReviews': 582,
      'experience': 26,
      'about': 'Chuyên gia IVF hàng đầu Việt Nam, tỷ lệ thành công cao trên các ca IVF khó và bảo tồn noãn.',
      'clinicName': 'Trung tâm IVFMD – BV Tâm Anh',
      'location': 'TP. Thủ Đức, TP.HCM',
      'availableDays': ['Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6'],
      'availableTimeSlots': ['07:00', '08:00', '09:00', '10:00'],
      'phone': '028 7102 6789',
    },
    {
      '_id': 'doc_ta_ivf_002',
      'name': 'TS. BS. Giang Huỳnh Như',
      'specialty': 'IVF – Nội tiết sinh sản',
      'hospital': 'Bệnh viện Tâm Anh TP.HCM',
      'hospitalId': 'hosp_tam_anh',
      'departmentId': 'dept_ta_ivf',
      'imageUrl': '${avatarBase}57',
      'rating': 4.7,
      'totalReviews': 312,
      'experience': 18,
      'about': 'Nội tiết sinh sản và IVF, xét nghiệm di truyền tiền làm tổ, điều trị buồng trứng đa nang.',
      'clinicName': 'Trung tâm IVFMD – BV Tâm Anh',
      'location': 'TP. Thủ Đức, TP.HCM',
      'availableDays': ['Thứ 2', 'Thứ 3', 'Thứ 5'],
      'availableTimeSlots': ['07:30', '08:30', '09:30'],
      'phone': '028 7102 6789',
    },

    // dept_tudu_obstetrics
    {
      '_id': 'doc_tudu_obs_001',
      'name': 'GS.TS. Nguyễn Thị Ngọc Phượng',
      'specialty': 'Sản phụ khoa',
      'hospital': 'Bệnh viện Từ Dũ',
      'hospitalId': 'hosp_tu_du',
      'departmentId': 'dept_tudu_obstetrics',
      'imageUrl': '${avatarBase}39',
      'rating': 5.0,
      'totalReviews': 723,
      'experience': 40,
      'about': 'Giáo sư sản phụ khoa hàng đầu Việt Nam, thai kỳ nguy cơ cao và phẫu thuật phụ khoa phức tạp.',
      'clinicName': 'Khoa Sản Bệnh – BV Từ Dũ',
      'location': 'Quận 1, TP.HCM',
      'availableDays': ['Thứ 2', 'Thứ 4'],
      'availableTimeSlots': ['07:00', '08:00', '09:00'],
      'phone': '028 3839 5117',
    },
    {
      '_id': 'doc_tudu_obs_002',
      'name': 'PGS.TS. Vũ Thị Nhung',
      'specialty': 'Sản phụ khoa',
      'hospital': 'Bệnh viện Từ Dũ',
      'hospitalId': 'hosp_tu_du',
      'departmentId': 'dept_tudu_obstetrics',
      'imageUrl': '${avatarBase}67',
      'rating': 4.9,
      'totalReviews': 512,
      'experience': 30,
      'about': 'Chuyên về thai kỳ nguy cơ cao, đa thai, tiền sản giật và phẫu thuật bảo tồn tử cung.',
      'clinicName': 'Khoa Sản Bệnh – BV Từ Dũ',
      'location': 'Quận 1, TP.HCM',
      'availableDays': ['Thứ 3', 'Thứ 5'],
      'availableTimeSlots': ['07:00', '08:00', '09:00', '10:00'],
      'phone': '028 3839 5117',
    },
    {
      '_id': 'doc_tudu_obs_003',
      'name': 'TS. BS. Huỳnh Thị Thu Thủy',
      'specialty': 'Sản phụ khoa siêu âm',
      'hospital': 'Bệnh viện Từ Dũ',
      'hospitalId': 'hosp_tu_du',
      'departmentId': 'dept_tudu_obstetrics',
      'imageUrl': '${avatarBase}41',
      'rating': 4.7,
      'totalReviews': 334,
      'experience': 20,
      'about': 'Siêu âm thai 4D, chẩn đoán trước sinh, theo dõi thai kỳ nguy cơ cao và tim thai bất thường.',
      'clinicName': 'Khoa Sản Bệnh – BV Từ Dũ',
      'location': 'Quận 1, TP.HCM',
      'availableDays': ['Thứ 3', 'Thứ 5', 'Thứ 7'],
      'availableTimeSlots': ['07:30', '08:30', '09:30', '10:30'],
      'phone': '028 3839 5117',
    },

    // dept_tudu_ivf
    {
      '_id': 'doc_tudu_ivf_001',
      'name': 'PGS.TS. Hồ Mạnh Tường',
      'specialty': 'Hỗ trợ sinh sản',
      'hospital': 'Bệnh viện Từ Dũ',
      'hospitalId': 'hosp_tu_du',
      'departmentId': 'dept_tudu_ivf',
      'imageUrl': '${avatarBase}62',
      'rating': 4.9,
      'totalReviews': 556,
      'experience': 25,
      'about': 'Tiên phong IVF tại Việt Nam, chuyên điều trị vô sinh hiếm muộn nam và đông lạnh phôi.',
      'clinicName': 'Khoa Hỗ Trợ Sinh Sản – BV Từ Dũ',
      'location': 'Quận 1, TP.HCM',
      'availableDays': ['Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5'],
      'availableTimeSlots': ['07:00', '08:00', '09:00'],
      'phone': '028 3839 5117',
    },
    {
      '_id': 'doc_tudu_ivf_002',
      'name': 'TS. BS. Lê Vương Văn',
      'specialty': 'IVF',
      'hospital': 'Bệnh viện Từ Dũ',
      'hospitalId': 'hosp_tu_du',
      'departmentId': 'dept_tudu_ivf',
      'imageUrl': '${avatarBase}19',
      'rating': 4.7,
      'totalReviews': 278,
      'experience': 18,
      'about': 'Chuyên về kỹ thuật ICSI, nuôi cấy phôi và chẩn đoán di truyền tiền làm tổ.',
      'clinicName': 'Khoa Hỗ Trợ Sinh Sản – BV Từ Dũ',
      'location': 'Quận 1, TP.HCM',
      'availableDays': ['Thứ 2', 'Thứ 4', 'Thứ 6'],
      'availableTimeSlots': ['13:00', '14:00', '15:00'],
      'phone': '028 3839 5117',
    },

    // dept_dhyd_internal
    {
      '_id': 'doc_dhyd_int_001',
      'name': 'GS.TS. Nguyễn Thanh Hiệp',
      'specialty': 'Nội khoa',
      'hospital': 'Bệnh viện Đại học Y Dược TP.HCM',
      'hospitalId': 'hosp_dhyd_hcm',
      'departmentId': 'dept_dhyd_internal',
      'imageUrl': '${avatarBase}21',
      'rating': 4.9,
      'totalReviews': 461,
      'experience': 32,
      'about': 'Giáo sư nội khoa, chuyên điều trị bệnh nội tiết, mãn tính và nghiên cứu lâm sàng.',
      'clinicName': 'Khoa Nội Tổng Quát – BV ĐHYD',
      'location': 'Quận 5, TP.HCM',
      'availableDays': ['Thứ 2', 'Thứ 4', 'Thứ 6'],
      'availableTimeSlots': ['07:00', '08:00', '09:00', '10:00'],
      'phone': '028 3855 4269',
    },
    {
      '_id': 'doc_dhyd_int_002',
      'name': 'PGS.TS. Trần Ngọc Bích',
      'specialty': 'Nội tiết',
      'hospital': 'Bệnh viện Đại học Y Dược TP.HCM',
      'hospitalId': 'hosp_dhyd_hcm',
      'departmentId': 'dept_dhyd_internal',
      'imageUrl': '${avatarBase}35',
      'rating': 4.7,
      'totalReviews': 261,
      'experience': 22,
      'about': 'Điều trị đái tháo đường, tuyến giáp, bệnh thận mãn tính và hội chứng chuyển hóa.',
      'clinicName': 'Khoa Nội Tổng Quát – BV ĐHYD',
      'location': 'Quận 5, TP.HCM',
      'availableDays': ['Thứ 3', 'Thứ 5'],
      'availableTimeSlots': ['13:00', '14:00', '15:00'],
      'phone': '028 3855 4269',
    },

    // dept_dhyd_gastro
    {
      '_id': 'doc_dhyd_gastro_001',
      'name': 'GS.TS. Quách Trọng Đức',
      'specialty': 'Tiêu hóa – Nội soi',
      'hospital': 'Bệnh viện Đại học Y Dược TP.HCM',
      'hospitalId': 'hosp_dhyd_hcm',
      'departmentId': 'dept_dhyd_gastro',
      'imageUrl': '${avatarBase}25',
      'rating': 4.9,
      'totalReviews': 487,
      'experience': 30,
      'about': 'Chuyên gia nội soi tiêu hóa can thiệp, điều trị bệnh gan mật tụy và viêm loét dạ dày nặng.',
      'clinicName': 'Khoa Tiêu Hóa – BV ĐHYD',
      'location': 'Quận 5, TP.HCM',
      'availableDays': ['Thứ 2', 'Thứ 4', 'Thứ 6'],
      'availableTimeSlots': ['07:00', '08:00', '09:00'],
      'phone': '028 3855 4269',
    },
    {
      '_id': 'doc_dhyd_gastro_002',
      'name': 'TS. BS. Lê Thị Tuyết Hoa',
      'specialty': 'Gan mật tụy',
      'hospital': 'Bệnh viện Đại học Y Dược TP.HCM',
      'hospitalId': 'hosp_dhyd_hcm',
      'departmentId': 'dept_dhyd_gastro',
      'imageUrl': '${avatarBase}53',
      'rating': 4.7,
      'totalReviews': 215,
      'experience': 18,
      'about': 'Chuyên về bệnh lý gan mật tụy, viêm gan mãn tính, xơ gan và ung thư đường mật.',
      'clinicName': 'Khoa Tiêu Hóa – BV ĐHYD',
      'location': 'Quận 5, TP.HCM',
      'availableDays': ['Thứ 3', 'Thứ 5', 'Thứ 7'],
      'availableTimeSlots': ['07:30', '08:30', '09:30'],
      'phone': '028 3855 4269',
    },
  ];

  // ── Write departments and rooms ────────────────────────────────────────────
  var batch = db.batch();
  int opCount = 0;

  Future<void> flushIfNeeded() async {
    if (opCount >= 400) {
      await batch.commit();
      debugPrint('[HospitalSeeder] Flushed batch ($opCount ops)');
      batch = db.batch();
      opCount = 0;
    }
  }

  for (final dept in departments) {
    await flushIfNeeded();
    final hospId = dept['_hospId'] as String;
    final deptId = dept['_deptId'] as String;
    final data = Map<String, dynamic>.from(dept)
      ..remove('_hospId')
      ..remove('_deptId');
    data['id'] = deptId;
    batch.set(
      db.collection('hospitals').doc(hospId).collection('departments').doc(deptId),
      data,
      SetOptions(merge: true),
    );
    opCount++;
    deptCount++;
  }

  for (final room in rooms) {
    await flushIfNeeded();
    final hospId = room['_h'] as String;
    final deptId = room['_d'] as String;
    final roomId = room['_r'] as String;
    final data = Map<String, dynamic>.from(room)
      ..remove('_h')
      ..remove('_d')
      ..remove('_r');
    data['id'] = roomId;
    batch.set(
      db
          .collection('hospitals')
          .doc(hospId)
          .collection('departments')
          .doc(deptId)
          .collection('rooms')
          .doc(roomId),
      data,
      SetOptions(merge: true),
    );
    opCount++;
  }

  // ── Write doctors ──────────────────────────────────────────────────────────
  final docCol = db.collection('doctors');
  for (final d in doctors) {
    await flushIfNeeded();
    final docId = d['_id'] as String;
    final data = Map<String, dynamic>.from(d)..remove('_id');
    batch.set(docCol.doc(docId), data, SetOptions(merge: true));
    opCount++;
    doctorCount++;
  }

  if (opCount > 0) {
    await batch.commit();
  }

  debugPrint('[HospitalSeeder] forceSeed: $deptCount khoa, ${rooms.length} phòng, $doctorCount bác sĩ.');
  return '$deptCount khoa, $doctorCount bác sĩ đã được khởi tạo.';
}

Future<void> _seedDoctors(FirebaseFirestore db) async {
  final col = db.collection('doctors');

  // Guard
  final guard = await col.doc('doc_cr_cardio_001').get();
  if (guard.exists) {
    debugPrint('[HospitalSeeder] Doctors already seeded – skipping.');
    return;
  }

  const avatarBase = 'https://i.pravatar.cc/150?img=';

  final doctors = <Map<String, dynamic>>[
    // ── hosp_cho_ray / Khoa Tim Mạch ─────────────────────────────────────
    {
      '_id': 'doc_cr_cardio_001',
      'name': 'PGS.TS. Nguyễn Văn Minh',
      'specialty': 'Tim mạch',
      'hospital': 'Bệnh viện Chợ Rẫy',
      'hospitalId': 'hosp_cho_ray',
      'departmentId': 'dept_cr_cardio',
      'imageUrl': '${avatarBase}11',
      'rating': 4.9,
      'totalReviews': 312,
      'experience': 20,
      'about': 'Chuyên gia tim mạch can thiệp, đặt stent mạch vành và điều trị suy tim.',
      'clinicName': 'Khoa Tim Mạch – BV Chợ Rẫy',
      'location': 'Quận 5, TP.HCM',
      'availableDays': ['Thứ 2', 'Thứ 4', 'Thứ 6'],
      'availableTimeSlots': ['07:00', '08:00', '09:00', '10:00'],
      'phone': '028 3855 4137',
    },
    {
      '_id': 'doc_cr_cardio_002',
      'name': 'TS. Trần Thị Lan Anh',
      'specialty': 'Tim mạch',
      'hospital': 'Bệnh viện Chợ Rẫy',
      'hospitalId': 'hosp_cho_ray',
      'departmentId': 'dept_cr_cardio',
      'imageUrl': '${avatarBase}44',
      'rating': 4.7,
      'totalReviews': 198,
      'experience': 15,
      'about': 'Siêu âm tim, điều trị rối loạn nhịp và tăng huyết áp.',
      'clinicName': 'Khoa Tim Mạch – BV Chợ Rẫy',
      'location': 'Quận 5, TP.HCM',
      'availableDays': ['Thứ 3', 'Thứ 5'],
      'availableTimeSlots': ['13:00', '14:00', '15:00'],
      'phone': '028 3855 4137',
    },
    {
      '_id': 'doc_cr_cardio_003',
      'name': 'BS. Lê Quốc Hùng',
      'specialty': 'Tim mạch',
      'hospital': 'Bệnh viện Chợ Rẫy',
      'hospitalId': 'hosp_cho_ray',
      'departmentId': 'dept_cr_cardio',
      'imageUrl': '${avatarBase}33',
      'rating': 4.6,
      'totalReviews': 145,
      'experience': 10,
      'about': 'Điều trị bệnh mạch vành, đặt máy tạo nhịp tim và holter ECG.',
      'clinicName': 'Khoa Tim Mạch – BV Chợ Rẫy',
      'location': 'Quận 5, TP.HCM',
      'availableDays': ['Thứ 2', 'Thứ 3', 'Thứ 5', 'Thứ 7'],
      'availableTimeSlots': ['07:00', '08:00', '09:00'],
      'phone': '028 3855 4137',
    },
    // ── hosp_cho_ray / Khoa Ngoại ─────────────────────────────────────────
    {
      '_id': 'doc_cr_surgery_001',
      'name': 'GS.TS. Phạm Đức Huấn',
      'specialty': 'Ngoại khoa',
      'hospital': 'Bệnh viện Chợ Rẫy',
      'hospitalId': 'hosp_cho_ray',
      'departmentId': 'dept_cr_surgery',
      'imageUrl': '${avatarBase}15',
      'rating': 4.8,
      'totalReviews': 421,
      'experience': 28,
      'about': 'Phẫu thuật nội soi ổ bụng, tiêu hóa và phẫu thuật ung thư đại trực tràng.',
      'clinicName': 'Khoa Ngoại Tổng Quát – BV Chợ Rẫy',
      'location': 'Quận 5, TP.HCM',
      'availableDays': ['Thứ 2', 'Thứ 4', 'Thứ 6'],
      'availableTimeSlots': ['07:30', '08:30', '09:30'],
      'phone': '028 3855 4137',
    },
    {
      '_id': 'doc_cr_surgery_002',
      'name': 'ThS. Võ Thị Thu Hà',
      'specialty': 'Ngoại khoa',
      'hospital': 'Bệnh viện Chợ Rẫy',
      'hospitalId': 'hosp_cho_ray',
      'departmentId': 'dept_cr_surgery',
      'imageUrl': '${avatarBase}47',
      'rating': 4.5,
      'totalReviews': 167,
      'experience': 12,
      'about': 'Chuyên về phẫu thuật nội soi tuyến giáp, thoát vị và phẫu thuật đường tiêu hóa.',
      'clinicName': 'Khoa Ngoại Tổng Quát – BV Chợ Rẫy',
      'location': 'Quận 5, TP.HCM',
      'availableDays': ['Thứ 3', 'Thứ 5', 'Thứ 7'],
      'availableTimeSlots': ['13:00', '14:00', '15:00'],
      'phone': '028 3855 4137',
    },
    // ── hosp_cho_ray / Khoa Nội Thần Kinh ────────────────────────────────
    {
      '_id': 'doc_cr_neuro_001',
      'name': 'PGS.TS. Lê Văn Thính',
      'specialty': 'Thần kinh',
      'hospital': 'Bệnh viện Chợ Rẫy',
      'hospitalId': 'hosp_cho_ray',
      'departmentId': 'dept_cr_neuro',
      'imageUrl': '${avatarBase}22',
      'rating': 4.8,
      'totalReviews': 289,
      'experience': 22,
      'about': 'Chuyên gia đột quỵ não, can thiệp mạch não và điều trị Parkinson.',
      'clinicName': 'Khoa Nội Thần Kinh – BV Chợ Rẫy',
      'location': 'Quận 5, TP.HCM',
      'availableDays': ['Thứ 2', 'Thứ 3', 'Thứ 4'],
      'availableTimeSlots': ['07:00', '08:00', '09:00', '10:00'],
      'phone': '028 3855 4137',
    },
    {
      '_id': 'doc_cr_neuro_002',
      'name': 'BS. Nguyễn Thị Phương',
      'specialty': 'Thần kinh',
      'hospital': 'Bệnh viện Chợ Rẫy',
      'hospitalId': 'hosp_cho_ray',
      'departmentId': 'dept_cr_neuro',
      'imageUrl': '${avatarBase}55',
      'rating': 4.6,
      'totalReviews': 134,
      'experience': 9,
      'about': 'Điều trị đau đầu mãn tính, động kinh và bệnh lý ngoại biên.',
      'clinicName': 'Khoa Nội Thần Kinh – BV Chợ Rẫy',
      'location': 'Quận 5, TP.HCM',
      'availableDays': ['Thứ 4', 'Thứ 5', 'Thứ 6'],
      'availableTimeSlots': ['13:00', '14:00', '15:00'],
      'phone': '028 3855 4137',
    },
    // ── hosp_fv / Khoa Tim Mạch ──────────────────────────────────────────
    {
      '_id': 'doc_fv_cardio_001',
      'name': 'Dr. Laurent Dupont',
      'specialty': 'Tim mạch',
      'hospital': 'Bệnh viện FV',
      'hospitalId': 'hosp_fv',
      'departmentId': 'dept_fv_cardio',
      'imageUrl': '${avatarBase}13',
      'rating': 4.9,
      'totalReviews': 376,
      'experience': 25,
      'about': 'Interventional cardiologist. Expertise in coronary stenting, TAVI and heart failure management.',
      'clinicName': 'Cardiology – FV Hospital',
      'location': 'Quận 7, TP.HCM',
      'availableDays': ['Thứ 2', 'Thứ 4', 'Thứ 6'],
      'availableTimeSlots': ['08:00', '09:00', '10:00', '14:00'],
      'phone': '028 5411 3333',
    },
    {
      '_id': 'doc_fv_cardio_002',
      'name': 'TS. Hoàng Anh Tiến',
      'specialty': 'Tim mạch',
      'hospital': 'Bệnh viện FV',
      'hospitalId': 'hosp_fv',
      'departmentId': 'dept_fv_cardio',
      'imageUrl': '${avatarBase}28',
      'rating': 4.7,
      'totalReviews': 212,
      'experience': 16,
      'about': 'Chuyên về siêu âm tim 3D, theo dõi holter và điều trị rối loạn nhịp.',
      'clinicName': 'Khoa Tim Mạch – BV FV',
      'location': 'Quận 7, TP.HCM',
      'availableDays': ['Thứ 3', 'Thứ 5', 'Thứ 7'],
      'availableTimeSlots': ['08:00', '09:00', '10:00'],
      'phone': '028 5411 3333',
    },
    // ── hosp_fv / Khoa Cấp Cứu ───────────────────────────────────────────
    {
      '_id': 'doc_fv_emergency_001',
      'name': 'Dr. Mark Harrison',
      'specialty': 'Cấp cứu',
      'hospital': 'Bệnh viện FV',
      'hospitalId': 'hosp_fv',
      'departmentId': 'dept_fv_emergency',
      'imageUrl': '${avatarBase}17',
      'rating': 4.8,
      'totalReviews': 520,
      'experience': 18,
      'about': 'Emergency medicine specialist, trauma care and critical care management.',
      'clinicName': 'Emergency – FV Hospital',
      'location': 'Quận 7, TP.HCM',
      'availableDays': ['Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7', 'Chủ nhật'],
      'availableTimeSlots': ['08:00', '12:00', '16:00', '20:00'],
      'phone': '028 5411 3333',
    },
    // ── hosp_tam_anh / Khoa Tim Mạch ─────────────────────────────────────
    {
      '_id': 'doc_ta_cardio_001',
      'name': 'GS.TS. Nguyễn Lân Việt',
      'specialty': 'Tim mạch',
      'hospital': 'Bệnh viện Tâm Anh TP.HCM',
      'hospitalId': 'hosp_tam_anh',
      'departmentId': 'dept_ta_cardio',
      'imageUrl': '${avatarBase}61',
      'rating': 5.0,
      'totalReviews': 614,
      'experience': 35,
      'about': 'Cố vấn chuyên môn tim mạch hàng đầu Việt Nam, chuyên can thiệp mạch vành phức tạp.',
      'clinicName': 'Trung tâm Tim Mạch – BV Tâm Anh',
      'location': 'TP. Thủ Đức, TP.HCM',
      'availableDays': ['Thứ 2', 'Thứ 5'],
      'availableTimeSlots': ['08:00', '09:00'],
      'phone': '028 7102 6789',
    },
    {
      '_id': 'doc_ta_cardio_002',
      'name': 'PGS.TS. Trương Thanh Hương',
      'specialty': 'Tim mạch',
      'hospital': 'Bệnh viện Tâm Anh TP.HCM',
      'hospitalId': 'hosp_tam_anh',
      'departmentId': 'dept_ta_cardio',
      'imageUrl': '${avatarBase}49',
      'rating': 4.9,
      'totalReviews': 387,
      'experience': 26,
      'about': 'Chuyên gia siêu âm tim nâng cao, điều trị van tim và tăng áp động mạch phổi.',
      'clinicName': 'Trung tâm Tim Mạch – BV Tâm Anh',
      'location': 'TP. Thủ Đức, TP.HCM',
      'availableDays': ['Thứ 3', 'Thứ 4', 'Thứ 6'],
      'availableTimeSlots': ['07:30', '08:30', '09:30', '10:30'],
      'phone': '028 7102 6789',
    },
    // ── hosp_tam_anh / Khoa Hỗ Trợ Sinh Sản ─────────────────────────────
    {
      '_id': 'doc_ta_ivf_001',
      'name': 'PGS.TS. Vương Thị Ngọc Lan',
      'specialty': 'Hỗ trợ sinh sản',
      'hospital': 'Bệnh viện Tâm Anh TP.HCM',
      'hospitalId': 'hosp_tam_anh',
      'departmentId': 'dept_ta_ivf',
      'imageUrl': '${avatarBase}40',
      'rating': 4.9,
      'totalReviews': 482,
      'experience': 24,
      'about': 'Chuyên gia IVF hàng đầu Việt Nam, tỷ lệ thụ tinh thành công cao trên các ca khó.',
      'clinicName': 'IVFMD Tâm Anh – BV Tâm Anh',
      'location': 'TP. Thủ Đức, TP.HCM',
      'availableDays': ['Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6'],
      'availableTimeSlots': ['07:00', '08:00', '09:00', '10:00'],
      'phone': '028 7102 6789',
    },
    // ── hosp_tu_du / Khoa Sản ─────────────────────────────────────────────
    {
      '_id': 'doc_tudu_obs_001',
      'name': 'GS.TS. Nguyễn Thị Ngọc Phượng',
      'specialty': 'Sản phụ khoa',
      'hospital': 'Bệnh viện Từ Dũ',
      'hospitalId': 'hosp_tu_du',
      'departmentId': 'dept_tudu_obstetrics',
      'imageUrl': '${avatarBase}39',
      'rating': 4.9,
      'totalReviews': 723,
      'experience': 38,
      'about': 'Chuyên gia sản khoa hàng đầu, thai kỳ nguy cơ cao và phẫu thuật phụ khoa phức tạp.',
      'clinicName': 'Khoa Sản – BV Từ Dũ',
      'location': 'Quận 1, TP.HCM',
      'availableDays': ['Thứ 2', 'Thứ 4'],
      'availableTimeSlots': ['07:00', '08:00', '09:00'],
      'phone': '028 3839 5117',
    },
    {
      '_id': 'doc_tudu_obs_002',
      'name': 'TS. Huỳnh Thị Thu Thủy',
      'specialty': 'Sản phụ khoa',
      'hospital': 'Bệnh viện Từ Dũ',
      'hospitalId': 'hosp_tu_du',
      'departmentId': 'dept_tudu_obstetrics',
      'imageUrl': '${avatarBase}41',
      'rating': 4.7,
      'totalReviews': 334,
      'experience': 18,
      'about': 'Siêu âm thai 4D, chẩn đoán trước sinh, theo dõi thai kỳ nguy cơ cao.',
      'clinicName': 'Khoa Sản – BV Từ Dũ',
      'location': 'Quận 1, TP.HCM',
      'availableDays': ['Thứ 3', 'Thứ 5', 'Thứ 7'],
      'availableTimeSlots': ['07:30', '08:30', '09:30', '10:30'],
      'phone': '028 3839 5117',
    },
    // ── hosp_tu_du / Khoa IVF ─────────────────────────────────────────────
    {
      '_id': 'doc_tudu_ivf_001',
      'name': 'PGS.TS. Hồ Mạnh Tường',
      'specialty': 'Hỗ trợ sinh sản',
      'hospital': 'Bệnh viện Từ Dũ',
      'hospitalId': 'hosp_tu_du',
      'departmentId': 'dept_tudu_ivf',
      'imageUrl': '${avatarBase}62',
      'rating': 4.8,
      'totalReviews': 556,
      'experience': 22,
      'about': 'Tiên phong IVF tại Việt Nam, chuyên điều trị vô sinh hiếm muộn và đông lạnh phôi.',
      'clinicName': 'Trung tâm IVF – BV Từ Dũ',
      'location': 'Quận 1, TP.HCM',
      'availableDays': ['Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5'],
      'availableTimeSlots': ['07:00', '08:00', '09:00'],
      'phone': '028 3839 5117',
    },
    // ── hosp_dhyd_hcm / Khoa Nội Tổng Quát ──────────────────────────────
    {
      '_id': 'doc_dhyd_internal_001',
      'name': 'PGS.TS. Trần Ngọc Bích',
      'specialty': 'Nội khoa',
      'hospital': 'Bệnh viện Đại học Y Dược TP.HCM',
      'hospitalId': 'hosp_dhyd_hcm',
      'departmentId': 'dept_dhyd_internal',
      'imageUrl': '${avatarBase}35',
      'rating': 4.7,
      'totalReviews': 261,
      'experience': 19,
      'about': 'Điều trị bệnh nội khoa tổng quát, tiểu đường, tuyến giáp và bệnh phổi mãn tính.',
      'clinicName': 'Khoa Nội – BV Đại học Y Dược',
      'location': 'Quận 5, TP.HCM',
      'availableDays': ['Thứ 2', 'Thứ 4', 'Thứ 6'],
      'availableTimeSlots': ['07:00', '08:00', '09:00', '10:00'],
      'phone': '028 3855 4269',
    },
    {
      '_id': 'doc_dhyd_internal_002',
      'name': 'TS. Lý Thị Bạch Như',
      'specialty': 'Nội khoa',
      'hospital': 'Bệnh viện Đại học Y Dược TP.HCM',
      'hospitalId': 'hosp_dhyd_hcm',
      'departmentId': 'dept_dhyd_internal',
      'imageUrl': '${avatarBase}52',
      'rating': 4.6,
      'totalReviews': 178,
      'experience': 13,
      'about': 'Chuyên về bệnh lý thận, tăng huyết áp và hội chứng thận hư.',
      'clinicName': 'Khoa Nội – BV Đại học Y Dược',
      'location': 'Quận 5, TP.HCM',
      'availableDays': ['Thứ 3', 'Thứ 5'],
      'availableTimeSlots': ['13:00', '14:00', '15:00'],
      'phone': '028 3855 4269',
    },
  ];

  final batch = db.batch();
  for (final d in doctors) {
    final docId = d['_id'] as String;
    final data = Map<String, dynamic>.from(d)..remove('_id');
    batch.set(col.doc(docId), data, SetOptions(merge: true));
  }
  await batch.commit();
  debugPrint('[HospitalSeeder] Seeded ${doctors.length} doctors successfully.');
}
