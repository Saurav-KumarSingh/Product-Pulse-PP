import 'package:flutter/material.dart';

class WelcomeView extends StatefulWidget {
  const WelcomeView({super.key});

  @override
  State<WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView> {
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          Image.asset(
            'assets/images/virtual/shape_bg.png',
            width: media.width,
            fit: BoxFit.cover,
          ),
          Image.asset(
            'assets/images/virtual/login_bg.png',
            width: media.width,
            fit: BoxFit.cover,
          ),
          Image.asset(
            'assets/images/virtual/Logo.png',
            width: media.width,
            height: media.width,
            // fit: BoxFit.cover,
          ),
        ],
      ),
    );
  }
}
