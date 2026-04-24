import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_clinic_booking/core/extensions/context_extension.dart';
import 'package:smart_clinic_booking/core/widgets/app_button.dart';

class PendingApprovalScreen extends StatelessWidget {
  const PendingApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: Padding(
        padding: EdgeInsets.all(context.spacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.hourglass_empty_rounded,
                size: 100,
                color: Colors.orange,
              ),
            ),
            SizedBox(height: context.spacing.xxl),
            Text(
              'Đang chờ phê duyệt',
              style: context.textStyles.heading2,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.spacing.m),
            Text(
              'Tài khoản của bạn đang được quản trị viên kiểm tra thông tin. Quá trình này thường mất từ 24-48 giờ làm việc.',
              style: context.textStyles.body.copyWith(color: context.colors.textSecondary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.spacing.xxl),
            AppButton(
              text: 'Liên hệ hỗ trợ',
              onPressed: () => context.push('/support'),
            ),
            TextButton(
              onPressed: () => context.go('/login'),
              child: Text(
                'Quay lại Đăng nhập',
                style: TextStyle(color: context.colors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ForbiddenScreen extends StatelessWidget {
  const ForbiddenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: Padding(
        padding: EdgeInsets.all(context.spacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: context.colors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.gpp_bad_rounded,
                size: 100,
                color: context.colors.error,
              ),
            ),
            SizedBox(height: context.spacing.xxl),
            Text(
              'Truy cập bị từ chối',
              style: context.textStyles.heading2,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.spacing.m),
            Text(
              'Bạn không có quyền truy cập vào trang này. Nếu bạn cho rằng đây là một lỗi, vui lòng liên hệ với bộ phận kỹ thuật.',
              style: context.textStyles.body.copyWith(color: context.colors.textSecondary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.spacing.xxl),
            AppButton(
              text: 'Về trang chủ',
              onPressed: () => context.go('/home'),
            ),
          ],
        ),
      ),
    );
  }
}
