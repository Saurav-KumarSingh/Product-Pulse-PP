import 'package:flutter/material.dart';
import '../const/colors.dart';

class CustomTextInput extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final bool enabled; // Add enabled parameter

  const CustomTextInput({
    super.key,
    required this.hintText,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.enabled = true, // Default to true (enabled)
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: ShapeDecoration(
        color: AppColor.placeholderbg,
        shape: StadiumBorder(),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        enabled: enabled, // Use the enabled parameter here
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: TextStyle(
            color: enabled ? AppColor.placeholder : Colors.grey, // Grey out the hint if disabled
          ),
          contentPadding: EdgeInsets.only(left: 40),
        ),
      ),
    );
  }
}
