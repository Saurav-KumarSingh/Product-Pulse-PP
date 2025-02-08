import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/helper.dart';
import '../const/colors.dart';
import '../screens/scan_screen.dart';

class CustomNavBar extends StatefulWidget {
  const CustomNavBar({super.key});

  @override
  State<CustomNavBar> createState() => _CustomNavBarState();
}

class _CustomNavBarState extends State<CustomNavBar> {
  int _selectedIndex = 0; // Track the selected index

  // Map routes to their corresponding indices
  final Map<String, int> _routeToIndex = {
    '/homePage': 0,
    '/offerPage': 1,
    '/profilePage': 2,
    '/chatbot': 3,
  };

  // PageStorageBucket to maintain the state of each screen
  final PageStorageBucket _bucket = PageStorageBucket();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Update the selected index based on the current route
    _updateSelectedIndex();
  }

  void _updateSelectedIndex() {
    final String currentRoute = ModalRoute.of(context)?.settings.name ?? '/homePage';
    setState(() {
      _selectedIndex = _routeToIndex[currentRoute] ?? 0;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update the selected index
    });
    // Navigate to the corresponding screen
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/homePage');
        break;
      case 1:
        Navigator.pushNamed(context, '/offerPage');
        break;
      case 2:
        Navigator.pushNamed(context, '/profilePage');
        break;
      case 3:
        Navigator.pushNamed(context, '/chatbot');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      width: Helper.getScreenWidth(context),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: Helper.getScreenWidth(context),
              padding: const EdgeInsets.only(bottom: 10),
              child: Image.asset(
                Helper.getAssetName("bottom_nav_shadow.png", "virtual"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: Helper.getScreenWidth(context),
              child: Image.asset(
                Helper.getAssetName("bottom_nav_shape.png", "virtual"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: Helper.getScreenWidth(context),
              height: 80,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildNavItem(0, "home.png"),
                  _buildNavItem(1, "bag.png"),
                  const SizedBox(width: 35), // Spacer for the FAB
                  _buildNavItem(2, "user.png"),
                  _buildNavItem(3, "bot.png"),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              height: 70,
              width: 70,
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ScanScreen(source: ImageSource.camera),
                      ),
                      );
                },
                backgroundColor: AppColor.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
                child: const Icon(
                  Icons.qr_code_scanner_outlined,
                  color: Colors.white,
                  size: 40,

                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, String iconName) {
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 23,
            height: 23,
            child: Image.asset(
              Helper.getAssetName(iconName, "virtual"),
              fit: BoxFit.cover,
              color: _selectedIndex == index ? AppColor.orange : Colors.grey, // Change color based on selection
            ),
          ),

        ],
      ),
    );
  }
}