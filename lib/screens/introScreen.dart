import 'package:flutter/material.dart';
import '../const/colors.dart';
import '../utils/helper.dart';
import 'homeScreen.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});
  static const routeName = "/introScreen";

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {

  var _controller;
  var count;

  @override
  void initState() {
    // TODO: implement initState
    _controller = new PageController();
    count = 0;
    super.initState();
  }


  final List<Map<String, String>> _pages = [
    {
      "image" : "welocmeintro.png",
      "title" : "Welcome to Product Pulse",
      "desc" : "Product Pulse helps you track and manage product expiry dates effortlessly."
    },
    {
      "image" : "vector1.png",
      "title" : "Manage Your Products",
      "desc" : "Never forget expiry dates! Product Pulse tracks and reminds you, ensuring nothing goes to waste."
    },

    {
      "image" : "scan.png",
      "title" : "Effortless Expiry Tracking",
      "desc" : "Managing expiry dates has never been this easy! Simply scan, store, and receive automatic notifications before your items go bad."
    },
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: Helper.getScreenHeight(context),
        width: Helper.getScreenWidth(context),
        child: SafeArea(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 30),
            child: Column(
              children: [
                Container(
                  height: 400,
                  width: double.infinity,
                  child: PageView.builder(
                    controller: _controller,
                    onPageChanged: (value) {
                      setState(() {
                        count = value;
                      });
                    },
                    itemBuilder: (context, index) {
                        return Image.asset(Helper.getAssetName(
                            _pages[index]["image"]!, "virtual"
                        )
                        );
                      },
                      itemCount: _pages.length,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 5,
                      backgroundColor: count == 0 ? AppColor.orange : AppColor.placeholderbg,
                    ),
                    SizedBox(width: 5,),
                    CircleAvatar(
                      radius: 5,
                      backgroundColor: count == 1 ? AppColor.orange : AppColor.placeholderbg,
                    ),
                    SizedBox(width: 5,),
                    CircleAvatar(
                      radius: 5,
                      backgroundColor: count == 2 ? AppColor.orange : AppColor.placeholderbg,
                    ),
                  ],
                ),
                SizedBox(height: 30,),
                Text(_pages[count]["title"]!, style: Helper.getTheme(context).titleLarge,),
                SizedBox(height: 30,),
                Text(_pages[count]["desc"]!, textAlign: TextAlign.center,),
                SizedBox(height: 30,),
                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
                    },
                    child: Text("Next"),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
