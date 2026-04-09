import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/storage/app_storage.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;
  final slides = const [
    ('Meet Aisod 3A', 'A powerful AI assistant built for everyone. Ask anything, get instant answers.'),
    ('Works Offline Too', 'No internet? No problem. Aisod 3A 0.1 runs fully on your device.'),
    ('Your Chats, Private', 'Your conversations are secure and always available, online or off.'),
  ];

  @override
  void initState() {
    super.initState();
    AppStorage.setHasLaunched();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => context.go('/login'),
                child: const Text('Skip', style: TextStyle(color: Colors.grey)),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: slides.length,
                onPageChanged: (value) => setState(() => _index = value),
                itemBuilder: (_, i) => Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.bgSecondary, borderRadius: BorderRadius.circular(12))),
                      const SizedBox(height: 16),
                      Text(slides[i].$1, style: const TextStyle(fontFamily: 'PlayfairDisplay', fontSize: 22, color: AppColors.textPrimary)),
                      const SizedBox(height: 10),
                      Text(slides[i].$2, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'DMSans', color: Colors.grey)),
                    ],
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(slides.length, (i) => Container(
                width: i == _index ? 16 : 6,
                height: 6,
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: i == _index ? AppColors.accent : AppColors.border,
                  borderRadius: BorderRadius.circular(3),
                ),
              )),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: AppButton(
                label: _index == slides.length - 1 ? 'Get Started' : 'Next',
                onPressed: () {
                  if (_index == slides.length - 1) {
                    context.go('/signup');
                  } else {
                    _controller.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
