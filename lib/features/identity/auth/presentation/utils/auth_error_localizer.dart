import 'package:flutter/material.dart';

String localizeAuthError(BuildContext context, String? rawError, {String? fallback}) {
  final message = (rawError ?? '').trim();
  final lang = Localizations.localeOf(context).languageCode;

  String tr(String vi, String en, String ja, String ko, String zh) {
    switch (lang) {
      case 'en':
        return en;
      case 'ja':
        return ja;
      case 'ko':
        return ko;
      case 'zh':
        return zh;
      default:
        return vi;
    }
  }

  if (message.isEmpty) {
    return fallback ??
        tr('Đã có lỗi xảy ra.', 'An error occurred.', 'エラーが発生しました。', '오류가 발생했습니다.', '发生错误。');
  }

  final lower = message.toLowerCase();
  if (lower.contains('wrong-password') || lower.contains('sai mật khẩu')) {
    return tr('Sai mật khẩu', 'Wrong password', 'パスワードが間違っています', '비밀번호가 올바르지 않습니다', '密码错误');
  }
  if (lower.contains('user-not-found') || lower.contains('không tìm thấy tài khoản')) {
    return tr('Không tìm thấy tài khoản', 'Account not found', 'アカウントが見つかりません', '계정을 찾을 수 없습니다', '未找到账号');
  }
  if (lower.contains('invalid-credential') || lower.contains('không đúng')) {
    return tr(
      'Thông tin đăng nhập không đúng',
      'Invalid credentials',
      '認証情報が正しくありません',
      '로그인 정보가 올바르지 않습니다',
      '登录信息不正确',
    );
  }
  if (lower.contains('too-many-requests')) {
    return tr('Quá nhiều yêu cầu, vui lòng thử lại sau', 'Too many requests, please try again later', 'リクエストが多すぎます。しばらくしてから再試行してください', '요청이 너무 많습니다. 나중에 다시 시도하세요', '请求过多，请稍后再试');
  }
  if (lower.contains('network-request-failed') || lower.contains('kết nối mạng')) {
    return tr('Lỗi kết nối mạng', 'Network connection error', 'ネットワーク接続エラー', '네트워크 연결 오류', '网络连接错误');
  }
  if (lower.contains('expired') || lower.contains('hết hạn')) {
    return tr('Mã đã hết hạn', 'Code has expired', 'コードの有効期限が切れています', '코드가 만료되었습니다', '代码已过期');
  }
  if (lower.contains('otp') || lower.contains('verification-code')) {
    return tr('Mã OTP không hợp lệ', 'Invalid OTP code', '無効なOTPコードです', '유효하지 않은 OTP 코드입니다', 'OTP验证码无效');
  }
  if (lower.contains('permission-denied') || lower.contains('không có quyền')) {
    return tr('Bạn không có quyền thực hiện thao tác này', 'You do not have permission to perform this action', 'この操作を実行する権限がありません', '이 작업을 수행할 권한이 없습니다', '您没有权限执行此操作');
  }
  if (lower.contains('qr') && (lower.contains('invalid') || lower.contains('not found'))) {
    return tr('Mã QR không hợp lệ', 'Invalid QR code', '無効なQRコードです', '유효하지 않은 QR 코드입니다', '二维码无效');
  }

  return message;
}
