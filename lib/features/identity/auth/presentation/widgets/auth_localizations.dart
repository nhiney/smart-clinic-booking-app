class AuthLocalizations {
  final bool isEnglish;

  AuthLocalizations(this.isEnglish);

  // General
  String get signUpTitle => isEnglish ? "Join ICare" : "Tham gia ICare";
  String get patientRole => isEnglish ? "Patient" : "Bệnh nhân";
  String get doctorRole => isEnglish ? "Doctor / Partner" : "Bác sĩ / Đối tác";
  String get roleSelectionLabel => isEnglish ? "I am registering as a:" : "Tôi đăng ký với vai trò:";
  
  // Terms & Conditions (Split for RichText styling)
  String get termsAgreementPrefix => isEnglish ? "I agree to the " : "Tôi đồng ý với ";
  String get termsAgreementLink => isEnglish ? "Terms of Use and Privacy Policy" : "Điều khoản sử dụng và Chính sách bảo mật";
  
  String get submitButton => isEnglish ? "Create Account" : "Tạo tài khoản";
  String get loading => isEnglish ? "Processing..." : "Đang xử lý...";

  // Patient Form
  String get fullNameLabel => isEnglish ? "Full Name" : "Họ và tên";
  String get fullNameHint => isEnglish ? "Enter your full name" : "Nhập họ và tên của bạn";
  String get phoneLabel => isEnglish ? "Phone Number" : "Số điện thoại";
  String get phoneHint => isEnglish ? "Enter your phone number" : "Nhập số điện thoại của bạn";

  // Doctor Form
  String get emailLabel => isEnglish ? "Professional Email" : "Email công việc";
  String get emailHint => isEnglish ? "doctor@hospital.com" : "bacsi@benhvien.com";
  String get passwordLabel => isEnglish ? "Password" : "Mật khẩu";
  String get hospitalLabel => isEnglish ? "Target Hospital" : "Bệnh viện công tác";
  String get idUploadLabel => isEnglish ? "Upload National ID" : "Tải lên CCCD/Hộ chiếu";
  String get degreeUploadLabel => isEnglish ? "Upload Medical Degree" : "Tải lên Bằng y khoa";
  
  // Validation
  String get requiredField => isEnglish ? "This field is required" : "Trường này là bắt buộc";
  String get invalidEmail => isEnglish ? "Invalid email address" : "Email không hợp lệ";
  String get passwordShort => isEnglish ? "Password too short" : "Mật khẩu quá ngắn";
  String get mustAcceptTerms => isEnglish ? "Please accept terms and conditions" : "Vui lòng chấp nhận điều khoản";
}
