import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../core/constants/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({
    Key? key,
    required this.onComplete,
  }) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController(initialPage: 0);
  int currentIndex = 0;
  late AnimationController _backgroundController;
  late AnimationController _buttonController;
  late List<AnimationController> _pageAnimations;

  @override
  void initState() {
    super.initState();
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
    
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _pageAnimations = List.generate(
      3,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 800),
      )..forward(),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _backgroundController.dispose();
    _buttonController.dispose();
    for (var controller in _pageAnimations) {
      controller.dispose();
    }
    super.dispose();
  }

  List<Color> _getGradientForPage(int index) {
    switch (index) {
      case 0:
        return AppColors.oceanGradient;
      case 1:
        return AppColors.primaryGradient;
      case 2:
        return AppColors.sunsetGradient;
      default:
        return AppColors.primaryGradient;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _backgroundController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _getGradientForPage(currentIndex).map((color) {
                  return Color.lerp(
                    color,
                    color.withValues(alpha: 0.7),
                    (_backgroundController.value * 0.3).abs(),
                  )!;
                }).toList(),
              ),
            ),
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                SafeArea(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 20, right: 20),
                        child: Align(
                          alignment: Alignment.topRight,
                          child: InkWell(
                            onTap: () {
                              widget.onComplete();
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: const Text(
                                'Skip',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: PageView.builder(
                          onPageChanged: (int page) {
                            setState(() {
                              currentIndex = page;
                              _pageAnimations[page].forward();
                            });
                          },
                          controller: _pageController,
                          itemCount: 3,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return createPage(
                                image: 'assets/icons/shower-head.svg',
                                title: Constants.titleOne,
                                description: Constants.descriptionOne,
                                iconScale: 4.0,
                                iconHeight: 320,
                                imageColor: Colors.white,
                                animationController: _pageAnimations[0],
                              );
                            } else if (index == 1) {
                              return createPage(
                                image: 'assets/icons/sprout.svg',
                                title: Constants.titleTwo,
                                description: Constants.descriptionTwo,
                                iconScale: 4.0,
                                iconHeight: 320,
                                imageColor: Colors.white,
                                animationController: _pageAnimations[1],
                              );
                            } else {
                              return createPage(
                                image: 'assets/images/people_planting.png',
                                title: Constants.titleThree,
                                description: Constants.descriptionThree,
                                imageScale: 1.6,
                                imageHeight: 450,
                                imageColor: Colors.white,
                                animationController: _pageAnimations[2],
                              );
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 80,
                  left: 30,
                  child: Row(
                    children: _buildIndicator(),
                  ),
                ),
                Positioned(
                  bottom: 50,
                  right: 30,
                  child: GestureDetector(
                    onTapDown: (_) => _buttonController.forward(),
                    onTapUp: (_) {
                      _buttonController.reverse();
                      setState(() {
                        if (currentIndex < 2) {
                          currentIndex++;
                          if (currentIndex < 3) {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOutCubic,
                            );
                          }
                        } else {
                          widget.onComplete();
                        }
                      });
                    },
                    onTapCancel: () => _buttonController.reverse(),
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 1.0, end: 0.9).animate(
                        CurvedAnimation(
                          parent: _buttonController,
                          curve: Curves.easeInOut,
                        ),
                      ),
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white,
                              Colors.white.withValues(alpha: 0.9),
                            ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_forward_ios,
                          size: 24,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  //Extra Widgets

  //Create the indicator decorations widget
  Widget _indicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
      height: 8.0,
      width: isActive ? 32 : 8,
      margin: const EdgeInsets.only(right: 8.0),
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(4),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.5),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
    );
  }

//Create the indicator list
  List<Widget> _buildIndicator() {
    List<Widget> indicators = [];

    for (int i = 0; i < 3; i++) {
      if (currentIndex == i) {
        indicators.add(_indicator(true));
      } else {
        indicators.add(_indicator(false));
      }
    }

    return indicators;
  }
}

class createPage extends StatelessWidget {
  final String image;
  final String title;
  final String description;
  final double iconScale;
  final double iconHeight;
  final double imageScale;
  final double imageHeight;
  final double imageToTitleSpacing;
  final Color? imageColor;
  final AnimationController? animationController;

  const createPage({
    Key? key,
    required this.image,
    required this.title,
    required this.description,
    this.iconScale = 3.2,
    this.iconHeight = 300,
    this.imageScale = 3.5,
    this.imageHeight = 280,
    this.imageToTitleSpacing = 60,
    this.imageColor,
    this.animationController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (animationController == null) {
      return _buildContent();
    }

    return AnimatedBuilder(
      animation: animationController!,
      builder: (context, child) {
        final imageAnimation = CurvedAnimation(
          parent: animationController!,
          curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
        );
        final titleAnimation = CurvedAnimation(
          parent: animationController!,
          curve: const Interval(0.4, 0.8, curve: Curves.easeOutCubic),
        );
        final descriptionAnimation = CurvedAnimation(
          parent: animationController!,
          curve: const Interval(0.6, 1.0, curve: Curves.easeOutCubic),
        );

        return SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.only(
              left: 50,
              right: 50,
              bottom: 80,
              top: 20,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FadeTransition(
                  opacity: imageAnimation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.3),
                      end: Offset.zero,
                    ).animate(imageAnimation),
                    child: Transform.scale(
                      scale: Tween<double>(begin: 0.8, end: 1.0)
                          .animate(imageAnimation)
                          .value,
                      child: SizedBox(
                        height: _getContainerHeight(),
                        child: _buildImage(),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: imageToTitleSpacing),
                FadeTransition(
                  opacity: titleAnimation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.2),
                      end: Offset.zero,
                    ).animate(titleAnimation),
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black26,
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                FadeTransition(
                  opacity: descriptionAnimation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.2),
                      end: Offset.zero,
                    ).animate(descriptionAnimation),
                    child: Text(
                      description,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withValues(alpha: 0.9),
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.only(
          left: 50,
          right: 50,
          bottom: 80,
          top: 20,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: _getContainerHeight(),
              child: _buildImage(),
            ),
            SizedBox(height: imageToTitleSpacing),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w400,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  double _getContainerHeight() {
    final isSvg = image.toLowerCase().endsWith('.svg');
    return isSvg ? iconHeight : imageHeight;
  }

  Widget _buildImage() {
    final isSvg = image.toLowerCase().endsWith('.svg');
    final imageWidget = isSvg
        ? SvgPicture.asset(
            image,
            fit: BoxFit.contain,
            colorFilter: imageColor != null
                ? ColorFilter.mode(imageColor!, BlendMode.srcIn)
                : null,
          )
        : Image.asset(
            image,
            fit: BoxFit.contain,
          );
    
    final scale = isSvg ? iconScale : imageScale;
    return Transform.scale(
      scale: scale,
      child: imageWidget,
    );
  }
}

class Constants {
  static const Color primaryColor = Color(0xFF4CAF50);
  static const String titleOne = 'Never Forget a Watering.';
  static const String descriptionOne =
      'Stop guessing. Get reliable, on-time reminders for every plant in your collection.';
  static const String titleTwo = 'Keep Your Plants Thriving';
  static const String descriptionTwo =
      'Track watering schedules and get care reminders tailored to each plant.';

  static const String titleThree = 'Protect Your Green Family.';
  static const String descriptionThree =
      'Sign up to sync your entire collection securely across all your devices.';
}