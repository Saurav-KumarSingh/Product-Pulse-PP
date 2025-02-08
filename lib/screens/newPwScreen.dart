import 'package:flutter/material.dart';
import '../utils/helper.dart';
import '../widgets/customTextInput.dart';
import 'introScreen.dart';

class NewPwScreen extends StatelessWidget {
  const NewPwScreen({super.key});
  static const routeName = "/newPwPage";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            children: [
              Text(
                "New Password",
                style: Helper.getTheme(context).titleLarge,
              ),
              SizedBox(height: 10,),
              Text("Please enter your new password"),
              SizedBox(height: 50,),
              CustomTextInput(hintText: "New Password"),
              SizedBox(height: 30,),
              CustomTextInput(hintText: "Confirm Pssword"),
              SizedBox(height: 30,),
              SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (){
                    Navigator.of(context).pushReplacementNamed(IntroScreen.routeName);
                  },
                  child: Text("Next"),
                )
              )
            ],
          ),
        ),
      )
    );
  }
}
