import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../../../core/theme/app_colors.dart';

class BannerWidget extends StatefulWidget {
  const BannerWidget({super.key});

  @override
  State<BannerWidget> createState() => _BannerWidgetState();
}

class _BannerWidgetState extends State<BannerWidget> {
  int _currentIndex = 0;

  // Placeholder banners - replace with actual ads or banners
  final List<Widget> _banners = [
    _BannerItem(
      title: 'Welcome to Arzan',
      subtitle: 'Share and discover promo codes',
      color: AppColors.primaryYellow,
    ),
    _BannerItem(
      title: 'Get Started',
      subtitle: 'Post your first promo code',
      color: AppColors.accentOrange,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 180,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 5),
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        autoPlayCurve: Curves.fastOutSlowIn,
        enlargeCenterPage: false,
        viewportFraction: 1.0,
        onPageChanged: (index, reason) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      items: _banners.map((banner) => banner).toList(),
    );
  }
}

class _BannerItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;

  const _BannerItem({
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.black,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.black.withOpacity(0.8),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
