import 'dart:async';
import 'package:flutter/material.dart';

class IdleSessionManager {
  final Duration timeout;
  final VoidCallback onTimeout;
  Timer? _timer;

  IdleSessionManager({
    required this.timeout,
    required this.onTimeout,
  });

  /// Bắt đầu đếm ngược
  void start() {
    _stopTimer();
    _timer = Timer(timeout, onTimeout);
  }

  /// Reset lại thời gian đếm ngược (gọi mỗi khi có tương tác)
  void reset() {
    start();
  }

  /// Dừng đếm ngược hoàn toàn
  void dispose() {
    _stopTimer();
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }
}

/// Widget bọc ngoài để lắng nghe mọi tương tác của người dùng
class IdleDetector extends StatelessWidget {
  final IdleSessionManager manager;
  final Widget child;

  const IdleDetector({
    super.key,
    required this.manager,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => manager.reset(),
      onPanDown: (_) => manager.reset(),
      onScaleStart: (_) => manager.reset(),
      child: child,
    );
  }
}
