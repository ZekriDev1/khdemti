import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/theme.dart';

class PromoCarouselSlider extends StatefulWidget {
  final List<PromoCard> promos;
  
  const PromoCarouselSlider({
    super.key,
    required this.promos,
  });

  @override
  State<PromoCarouselSlider> createState() => _PromoCarouselSliderState();
}

class _PromoCarouselSliderState extends State<PromoCarouselSlider> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
    _pageController.addListener(() {
      int next = _pageController.page!.round();
      if (_currentPage != next) {
        setState(() => _currentPage = next);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            itemCount: widget.promos.length,
            itemBuilder: (context, index) {
              final promo = widget.promos[index];
              final isActive = index == _currentPage;
              
              return AnimatedContainer(
                duration: 300.ms,
                curve: Curves.easeOut,
                margin: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: isActive ? 0 : 12,
                ),
                child: GestureDetector(
                  onTap: promo.onTap,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: promo.gradient,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: promo.gradient.colors.first.withOpacity(0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              )
                            ]
                          : [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              )
                            ],
                    ),
                    child: Stack(
                      children: [
                        // Background Icon
                        Positioned(
                          right: -30,
                          bottom: -30,
                          child: Icon(
                            promo.icon,
                            size: 160,
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        
                        // Content
                        Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.25),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  promo.badge,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                              
                              const Spacer(),
                              
                              // Title
                              Text(
                                promo.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                  height: 1.0,
                                ),
                              ),
                              
                              const SizedBox(height: 4),
                              
                              // Subtitle
                              Text(
                                promo.subtitle,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Page Indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.promos.length,
            (index) => AnimatedContainer(
              duration: 300.ms,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentPage == index ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? AppTheme.primaryRedDark
                    : Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class PromoCard {
  final String badge;
  final String title;
  final String subtitle;
  final Gradient gradient;
  final IconData icon;
  final VoidCallback? onTap;

  PromoCard({
    required this.badge,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.icon,
    this.onTap,
  });
}
