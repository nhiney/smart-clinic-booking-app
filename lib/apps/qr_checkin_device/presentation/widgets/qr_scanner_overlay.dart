import 'package:flutter/material.dart';

class QRScannerOverlay extends StatelessWidget {
  const QRScannerOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scanAreaSize = size.width * 0.6;

    return Stack(
      children: [
        // 1. Lớp phủ làm mờ xung quanh
        ColorFiltered(
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.7),
            BlendMode.srcOut,
          ),
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Container(
                  height: scanAreaSize,
                  width: scanAreaSize,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // 2. Khung viền và Hiệu ứng quét
        Center(
          child: Container(
            height: scanAreaSize,
            width: scanAreaSize,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blueAccent, width: 4),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const _ScanningLine(),
          ),
        ),

        // 3. Hướng dẫn
        Positioned(
          top: size.height * 0.7,
          left: 0,
          right: 0,
          child: const Column(
            children: [
              Text(
                'VUI LÒNG ĐƯA MÃ QR VÀO KHUNG',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12),
              Text(
                'Giữ mã QR cách camera khoảng 15-20cm',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ScanningLine extends StatefulWidget {
  const _ScanningLine();

  @override
  State<_ScanningLine> createState() => _ScanningLineState();
}

class _ScanningLineState extends State<_ScanningLine> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Align(
          alignment: Alignment(0, (_controller.value * 2) - 1),
          child: Container(
            height: 2,
            width: double.infinity,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.blueAccent.withOpacity(0.5),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
              gradient: LinearGradient(
                colors: [
                  Colors.blueAccent.withOpacity(0.1),
                  Colors.blueAccent,
                  Colors.blueAccent.withOpacity(0.1),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
