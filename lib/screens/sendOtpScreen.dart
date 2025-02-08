import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import '../utils/helper.dart';
import '../const/colors.dart';
import 'newPwScreen.dart';

class SendOtpScreen extends StatefulWidget {

  const SendOtpScreen({super.key});
  static const routeName = "/sendOtpPage";

  @override
  State<SendOtpScreen> createState() => _SendOtpScreenState();
}

class _SendOtpScreenState extends State<SendOtpScreen> {
  GlobalKey<FormState> formkey = GlobalKey<FormState>();

  String validPin = "1234";
  final TextEditingController _pinController = TextEditingController();
  String? errorText;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 60,
      height: 60,
      textStyle: TextStyle(
        color: Colors.black,
        fontSize: 25,
      ),
      decoration: BoxDecoration(
        color: AppColor.placeholderbg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.transparent)
      )
    );

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
                  "We have sent an OTP to your Mobile",
                  style: Helper.getTheme(context).titleLarge,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10,),
                Text("Please check your mobile number 071*****12 continue to reset your password", textAlign: TextAlign.center,),
                SizedBox(height: 50,),
                Form(
                  key: formkey,
                  child: Column(
                    children: [
                      Pinput(
                        length: 4,
                        controller: _pinController,
                        defaultPinTheme: defaultPinTheme,
                        focusedPinTheme: defaultPinTheme.copyWith(
                          decoration: defaultPinTheme.decoration?.copyWith(
                            border: Border.all(color: AppColor.orange)
                          )
                        ),
                        errorText: errorText,
                      ),
                      if (errorText != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            errorText!,
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      SizedBox(height: 50,),
                      SizedBox(
                        height: 50,
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            String enteredPin = _pinController.text;
                            if(enteredPin == validPin){
                              setState(() {
                                errorText = null;
                              });
                              print("Success : $enteredPin");
                              Navigator.of(context).pushReplacementNamed(NewPwScreen.routeName);
                            } else {
                              setState(() {
                                errorText = "Pin is Incorrect";
                              });
                            }
                          },
                          child: Text("Next"),
                        ),
                      ),
                      SizedBox(height: 40,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Don't Receive?"),
                          SizedBox(width: 5,),
                          GestureDetector(
                            onTap: (){},
                            child: Text("Click Here", style: TextStyle(color: AppColor.orange, fontWeight: FontWeight.w600),),
                          )
                        ],
                      )
                    ],
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
