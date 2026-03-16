import 'package:flutter/material.dart';
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
      Navigator.pushReplacement(
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
    Navigator.pushReplacement(
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
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          slides[index]["image"]!,
                          height: 280,
                        ),
                        const SizedBox(height: 30),
                        Text(
                          slides[index]["title"]!,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 15),
                        Text(
                          slides[index]["desc"]!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        )
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
