import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent, // transparent to let the blue background show
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: Logo and Hospital Name
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                // A placeholder for the UMC logo
                child: const Icon(Icons.health_and_safety_outlined, color: Color(0xFF0D62A2), size: 30),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Bệnh viện Đại học Y Dược TP. Hồ Chí Minh',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF0D62A2),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Title
          const Text(
            'UMC Care',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0D62A2),
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Ứng dụng dành cho Người bệnh',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF0D62A2).withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
