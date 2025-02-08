import 'package:flutter/material.dart';
import 'welcome_view.dart';

class StartupView extends StatefulWidget {
  const StartupView({super.key});

  @override
  State<StartupView> createState() => _StartupViewState();
}

class _StartupViewState extends State<StartupView> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    goWelcomePage();
  }

  void goWelcomePage() async{
      await Future.delayed(const Duration(seconds: 1));
      Navigator.push(context, MaterialPageRoute(builder: (context) => const WelcomeView()));
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            "assets/images/virtual/splashbg.png",
            width: media.width,
            height: media.height,
            fit: BoxFit.cover,
          ),
          Image.asset(
            "assets/images/virtual/Logo.png",
            width: media.width*0.7,
            height: media.width*0.7,
          ),
        ],
      ),
    );
  }
}
