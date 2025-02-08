import 'dart:async';
import 'package:flutter/material.dart';
import './landingScreen.dart';
import '../utils/helper.dart';
    
class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  Timer? _timer;
  @override
  void initState() {
    // TODO: implement initState
    _timer = Timer(Duration(seconds: 5), () {
      Navigator.of(context).pushReplacementNamed(LandingScreen.routeName);
    });
    super.initState();
  }

  @override
  // void dispose() {
  //   // TODO: implement dispose
  //   _timer.cancel();
  //   super.dispose();
  // }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: Helper.getScreenHeight(context),
        width: Helper.getScreenWidth(context),
        child: Stack(
          children: [
            Container(
              height: double.infinity,
              width : double.infinity,
              child: Image.asset(
                Helper.getAssetName("splashbg.png", "virtual"),
                fit: BoxFit.fill,
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Image.asset(
                Helper.getAssetName("logoname.png", "logos"),
              ),
            )
          ],
        ),
      ),
    );
  }
}

    