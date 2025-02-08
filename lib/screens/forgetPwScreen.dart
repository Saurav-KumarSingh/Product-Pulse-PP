import 'package:flutter/material.dart';
import '../utils/helper.dart';
import '../widgets/customTextInput.dart';
import 'sendOtpScreen.dart';

class ForgetPwScreen extends StatelessWidget {
  const ForgetPwScreen({super.key});
  static const routeName = "/forgetPasswordPage";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: Helper.getScreenHeight(context),
        width: Helper.getScreenWidth(context),
        child: SafeArea(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Column(
              children: [
                Text(
                  "Reset Password",
                  style: Helper.getTheme(context).titleLarge,
                ),
                const SizedBox(height: 10,),
                Text("Please enter your email to receive a link to  create a new password via email", textAlign: TextAlign.center,),
                SizedBox(height: 60,),
                CustomTextInput(hintText: "Email"),
                SizedBox(height: 40,),
                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (){
                      Navigator.of(context).pushReplacementNamed(SendOtpScreen.routeName);
                    },
                    child: Text("Send"),
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
