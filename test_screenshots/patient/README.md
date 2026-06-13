# Ảnh test tính năng — Vai trò BỆNH NHÂN

Bộ ảnh chụp tự động từng bước (iPhone 16 Pro simulator) bằng integration test:
`integration_test/patient_features_test.dart`.

Tài khoản test: SĐT `0912345678` · mật khẩu `Icare@123`.

## 01. Đăng nhập (test nhập sai & nhập đúng)
| Ảnh | Mô tả |
|---|---|
| 01_01_man_hinh_chao_onboarding | Màn hình chào |
| 01_02_man_hinh_dang_nhap | Màn hình đăng nhập |
| 01_03_nhap_sdt_sai_dinh_dang | Nhập SĐT sai định dạng (`123`) |
| 01_04_bao_loi_sdt_khong_hop_le | **Báo lỗi: "Số điện thoại Việt Nam không hợp lệ"** |
| 01_05_nhap_dung_sdt_sai_mat_khau | SĐT đúng + mật khẩu sai |
| 01_06_bao_loi_sai_mat_khau | **Báo lỗi: "Thông tin đăng nhập không đúng"** |
| 01_07_nhap_dung_thong_tin | Nhập đúng SĐT + mật khẩu |
| 01_08_dang_nhap_thanh_cong_trang_chu | **Đăng nhập thành công → vào trang chủ** |

## 02. Trang chủ
| Ảnh | Mô tả |
|---|---|
| 02_01_trang_chu_dau_trang | Đầu trang chủ |
| 02_02_trang_chu_tien_ich_nhanh | Khu tiện ích nhanh |
| 02_03_trang_chu_keo_xuong | Cuộn giữa trang |
| 02_04_trang_chu_cuoi_trang | Cuối trang chủ |

## 03. Tìm bác sĩ + tìm kiếm
| Ảnh | Mô tả |
|---|---|
| 03_01_man_tim_bac_si | Danh sách bác sĩ (19 bác sĩ thật từ Firestore) |
| 03_02_nhap_tu_khoa_Nguyen | Tìm từ khóa "Nguyễn" |
| 03_03_tim_kiem_khong_co_ket_qua | **Tìm từ khóa không tồn tại → "Không tìm thấy bác sĩ phù hợp"** |
| 03_04_xoa_tim_kiem_hien_lai_danh_sach | Xóa tìm kiếm → hiện lại danh sách |

## 04. Đặt lịch khám (flow đầy đủ)
| Ảnh | Mô tả |
|---|---|
| 04_01_ho_so_bac_si_tab_dat_lich | Hồ sơ bác sĩ — tab Đặt lịch |
| 04_02_danh_sach_khung_gio | Danh sách khung giờ (slot trống/hết) |
| 04_03_da_chon_gio_kham | Đã chọn giờ 09:30 |
| 04_04_dat_kham_thanh_cong | Bấm xác nhận đặt khám |
| 04_05_man_xac_nhan_dat_kham | **"Đã đặt lịch khám!" + mã QR phiếu khám** |

## 05. Lịch hẹn của tôi
| Ảnh | Mô tả |
|---|---|
| 05_01_danh_sach_lich_hen | Lịch hẹn (tab Sắp tới / Hoàn thành / Đã hủy) |
| 05_02_lich_hen_keo_xuong | Cuộn danh sách lịch hẹn |
| 05_03_lich_hen_giao_dien_icare | Giao diện lịch hẹn iCare |

## 06–07. Hồ sơ, gia đình, thông báo & các tính năng khác
| Ảnh | Mô tả |
|---|---|
| 06_01_ho_so_ca_nhan | Hồ sơ cá nhân |
| 06_02_ho_so_gia_dinh | Hồ sơ gia đình |
| 06_03_thong_bao | Thông báo |
| 07_01_ho_so_y_te | Hồ sơ y tế |
| 07_02_don_thuoc | Đơn thuốc |
| 07_03_lich_uong_thuoc | Lịch uống thuốc |
| 07_04_hoa_don | Hóa đơn |
| 07_05_bao_hiem | Bảo hiểm |
| 07_06_dich_vu | Dịch vụ |
| 07_07_ho_tro | Hỗ trợ |
| 07_08_tin_tuc_suc_khoe | Tin tức sức khỏe |

# PHẦN 2 — bổ sung (file `integration_test/patient_features_part2_test.dart`)

## 08. Đăng ký + Điều khoản + OTP
| Ảnh | Mô tả |
|---|---|
| 08_01_man_dang_ky | Màn đăng ký tài khoản |
| 08_02_dien_thong_tin_dang_ky | Điền họ tên + SĐT |
| 08_03_bao_loi_chua_dong_y_dieu_khoan | **Bấm đăng ký khi chưa tick điều khoản → "You must accept the terms and conditions"** |
| 08_04_man_dieu_khoan_su_dung | Màn điều khoản sử dụng |
| 08_05_dieu_khoan_keo_xuong | Cuộn xem thêm điều khoản |
| 08_06_da_tick_dong_y_dieu_khoan | Đã tick đồng ý điều khoản |
| 08_07_man_nhap_ma_otp | **Màn nhập mã OTP (6 ô)** |
| 08_08_da_nhap_ma_otp | Đã nhập mã OTP 6 số |

## 09. Quên / Tạo mật khẩu
| Ảnh | Mô tả |
|---|---|
| 09_01_man_quen_mat_khau | Màn quên mật khẩu |
| 09_02_nhap_sdt_quen_mat_khau | Nhập SĐT để gửi OTP |
| 09_03_man_tao_mat_khau | Màn tạo mật khẩu mới |
| 09_04_da_nhap_mat_khau_moi | Đã nhập mật khẩu + xác nhận |

## 10. QR login / Staff login
| Ảnh | Mô tả |
|---|---|
| 10_01_dang_nhap_quet_ma_qr | **Đăng nhập bằng quét mã QR (camera + dán token + chọn ảnh)** |
| 10_02_ma_qr_tai_khoan | Mã QR tài khoản |
| 10_03_dang_nhap_nhan_vien | Đăng nhập nhân viên (staff) |

## 11. Trợ lý giọng nói (Voice AI)
| Ảnh | Mô tả |
|---|---|
| 11_01_man_voice_ai_tro_ly_giong_noi | Màn trợ lý giọng nói + nút mic |
| 11_02_popup_dat_lich_bang_giong_noi | **Popup "Xác nhận đặt lịch" nhận dạng từ giọng nói (chuyên khoa/ngày/giờ)** |

## 12. Các màn tính năng còn lại
| Ảnh | Mô tả |
|---|---|
| 12_01_kham_truc_tuyen | Khám trực tuyến |
| 12_02_cap_cuu_sos | Cấp cứu SOS |
| 12_03_ket_qua_xet_nghiem | Kết quả xét nghiệm |
| 12_04_lich_su_kham | Lịch sử khám |
| 12_05_quan_ly_thuoc | Quản lý thuốc |
| 12_06_ban_do | Bản đồ |
| 12_07_danh_sach_benh_vien | Danh sách bệnh viện |
| 12_08_lich_su_giao_dich | Lịch sử giao dịch |
| 12_09_thanh_toan | Thanh toán |
| 12_10_hoa_don_chi_tiet | Hóa đơn chi tiết |
| 12_11_thu_vien_suc_khoe | Thư viện sức khỏe |
| 12_12_bang_gia_dich_vu | Bảng giá dịch vụ |
| 12_13_khao_sat | Khảo sát |
| 12_14_lien_he | Liên hệ |
| 12_15_chatbot_ho_tro | Chatbot hỗ trợ |
| 12_16_cau_hoi_thuong_gap | Câu hỏi thường gặp (FAQ) |
| 12_17_yeu_cau_ho_tro | Yêu cầu hỗ trợ (tickets) |
| 12_18_cai_dat_nhac_nho | Cài đặt nhắc nhở |
| 12_19_chi_tiet_ho_so | Chi tiết hồ sơ |

# PHẦN 3 — SEED DỮ LIỆU MẪU + VOICE ĐẶT LỊCH KĨ (file `integration_test/patient_seed_and_voice_test.dart`)

Tạo dữ liệu mẫu Firestore cho đúng uid bệnh nhân (ghi bằng tài khoản admin để đủ
quyền), rồi chụp lại các màn trước đây trống. Đã deploy thêm composite index
(`backend/firestore.indexes.json`) cho các query `where + orderBy`.

## 13. Các màn đã có DỮ LIỆU mẫu
| Ảnh | Mô tả |
|---|---|
| 13_01_lich_hen_co_du_lieu | Lịch hẹn (5 lịch: sắp tới/hoàn thành/đã hủy) |
| 13_02_don_thuoc_co_du_lieu | Đơn thuốc (3 đơn: tăng huyết áp, viêm da, viêm họng) |
| 13_03_ho_so_y_te_co_du_lieu | Hồ sơ y tế (3 hồ sơ khám) |
| 13_04_quan_ly_thuoc_co_du_lieu | Theo dõi thuốc (3 thuốc + tuân thủ 85%) |
| 13_05_lich_uong_thuoc_co_du_lieu | Lịch uống thuốc (intakes 7 ngày) |
| 13_06_thong_bao_co_du_lieu | Thông báo (6 thông báo) |
| 13_07_hoa_don_co_du_lieu | Hóa đơn (3 hóa đơn) |
| 13_08_giao_dich_co_du_lieu | Giao dịch (3 giao dịch VNPay/MoMo/Stripe) |

## 14. Voice đặt lịch — 6 kịch bản (nói → phân tích ý định → popup)
| Ảnh | Mô tả |
|---|---|
| 14_01_voice_man_chinh | Màn trợ lý giọng nói |
| 14_02_kb1_phan_tich_hoi_thoai | KB1: hội thoại sau khi "nói" |
| 14_03_kb1_popup_nhi_khoa_sang | **KB1: "Đặt lịch khám nhi khoa ngày mai buổi sáng" → popup** |
| 14_04_kb2_popup_da_lieu_chieu | KB2: "Đặt lịch khám da liễu chiều mai" → popup |
| 14_05_kb3_AI_hoi_lai_chuyen_khoa | KB3: thiếu chuyên khoa → AI hỏi lại |
| 14_06_kb4_context_popup_noi_khoa | **KB4: trả lời "Nội khoa" (ngữ cảnh đa lượt) → popup** |
| 14_07_kb4_nhap_trieu_chung_trong_popup | KB4: nhập triệu chứng trong popup |
| 14_08_kb5_hoi_gio_lam_viec | KB5: "Phòng khám làm việc mấy giờ" → trả lời |
| 14_09_kb6_huy_lich | KB6: "Hủy lịch khám" → trả lời |

---
## Ghi chú kỹ thuật
- Ảnh phần 3 chụp bằng `xcrun simctl io screenshot` (binding.takeScreenshot trên
  iOS trả frame trắng khi app bận).
- Đã deploy composite index Firestore: chạy `firebase deploy --only
  firestore:indexes` trong `backend/` nếu cần lại.
- Hook test `AssistantNotifier.injectTranscript()` mô phỏng "nói" qua pipeline thật.

## Cách chạy lại
```
# Phần 1 (flow chính)
flutter drive --driver=test_driver/integration_test.dart \
  --target=integration_test/patient_features_test.dart -d <device-id>

# Phần 2 (đăng ký, OTP, QR, voice, các màn còn lại)
flutter drive --driver=test_driver/integration_test.dart \
  --target=integration_test/patient_features_part2_test.dart -d <device-id>

# Phần 3 (seed dữ liệu + voice kĩ) — cần vòng chụp xcrun chạy song song
flutter drive --driver=test_driver/integration_test.dart \
  --target=integration_test/patient_seed_and_voice_test.dart -d <device-id>
```
