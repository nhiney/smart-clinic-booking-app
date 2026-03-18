import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController controller = PageController();
  int currentIndex = 0;

  final slides = [
    {
      "title": "Chăm sóc sức khỏe thông minh",
      "desc": "Đặt lịch khám nhanh chóng và dễ dàng",
      "image": "assets/images/doctor1.png"
    },
    {
      "title": "Tư vấn cùng chuyên gia",
      "desc": "Kết nối bác sĩ mọi lúc mọi nơi",
      "image": "assets/images/doctor2.png"
    },
    {
      "title": "Quản lý hồ sơ y tế",
      "desc": "Theo dõi lịch sử khám bệnh",
      "image": "assets/images/doctor3.png"
    }
  ];

  void next() {
    if (currentIndex == slides.length - 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
      );
    } else {
      controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.ease,
      );
    }
  }

  void back() {
    if (currentIndex > 0) {
      controller.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.ease,
      );
    } else {
      Navigator.pop(context);
    }
  }

  void skip() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            /// HEADER (BACK + SKIP)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    onPressed: back,
                  ),
                  TextButton(
                    onPressed: skip,
                    child: const Text(
                      "Skip",
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                ],
              ),
            ),

            /// HOSPITAL INFO
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  Text(
                    "BỆNH VIỆN ĐA KHOA QUỐC TẾ",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 6),
                  Text(
                    "INTERNATIONAL GENERAL HOSPITAL",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                      letterSpacing: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 6),
                  Text(
                    "Tận tâm chăm sóc - Sức khỏe vươn xa",
                    style: TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            /// PAGE VIEW
            Expanded(
              child: PageView.builder(
                controller: controller,
                itemCount: slides.length,
                onPageChanged: (index) {
                  setState(() {
                    currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Image.asset(
                              slides[index]["image"]!,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.local_hospital,
                                size: 100,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          slides[index]["title"]!,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          slides[index]["desc"]!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  );
                },
              ),
            ),

            /// INDICATOR
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                slides.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.all(4),
                  width: currentIndex == index ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: currentIndex == index ? Colors.blue : Colors.grey,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// NEXT BUTTON
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    currentIndex == slides.length - 1 ? "Bắt đầu" : "Tiếp tục",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
