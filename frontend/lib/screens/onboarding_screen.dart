import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({
    Key? key,
    required this.onComplete,
  }) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController(initialPage: 0);
  int currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20, top: 20),
            child: InkWell(
              onTap: () {
                widget.onComplete();
              },
              child: const Text(
                'Skip',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          )
        ],
      ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView(
  onPageChanged: (int page) {
    setState(() {
      currentIndex = page;
    });
  },
  controller: _pageController,
  children: [
    createPage(
      image: 'assets/icons/shower-head.svg',
      title: Constants.titleOne,
      description: Constants.descriptionOne,
      iconScale: 4.0, // Increase to make SVG larger, decrease to make smaller
      iconHeight: 320, // Increase to give more space, decrease for less space
      imageColor: Constants.primaryColor,
    ),
    createPage(
      image: 'assets/icons/sprout.svg',
      title: Constants.titleTwo,
      description: Constants.descriptionTwo,
      iconScale: 4.0, // Same adjustment for second SVG
      iconHeight: 320, // Same adjustment for second SVG
      imageColor: Constants.primaryColor,
    ),
    createPage(
      image: 'assets/images/people_planting.png',
      title: Constants.titleThree,
      description: Constants.descriptionThree,
      imageScale: 1.6, // Increase to make image larger, decrease to make smaller
      imageHeight: 450, // Increase to give more space, decrease for less space
      imageColor: Constants.primaryColor,
    ),
  ],
),
          Positioned(
            bottom: 80,
            left: 30,
            child: Row(
              children: _buildIndicator(),
            ),
          ),
          Positioned(
            bottom: 60,
            right: 30,
            child: Container(
              child: IconButton(
                  onPressed: () {
                    setState(() {
                      if (currentIndex < 2) {
                        currentIndex++;
                        if (currentIndex < 3) {
                          _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeIn);
                        }
                      } else {
                        widget.onComplete();
                      }
                    });
                  },
                  icon: const Icon(
                    Icons.arrow_forward_ios,
                    size: 24,
                    color: Colors.white,
                  )),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Constants.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  //Extra Widgets

  //Create the indicator decorations widget
  Widget _indicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 10.0,
      width: isActive ? 20 : 8,
      margin: const EdgeInsets.only(right: 5.0),
      decoration: BoxDecoration(
        color: Constants.primaryColor,
        borderRadius: BorderRadius.circular(5),
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
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 50, right: 50, bottom: 80),
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
            style: TextStyle(
              color: Constants.primaryColor,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20), // This stays the same - spacing between title and description
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w400,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 20),
        ],
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