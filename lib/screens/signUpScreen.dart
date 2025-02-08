import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/helper.dart';
import '../widgets/customTextInput.dart';
import 'loginScreen.dart';
import '../const/colors.dart';
import 'introScreen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  static const routeName = "/signupPage";

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  void _signUp() async {
    String name = _nameController.text.trim();
    String email = _emailController.text.trim();
    String mobile = _mobileController.text.trim();
    String address = _addressController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    if (name.isEmpty || email.isEmpty || mobile.isEmpty || address.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please fill all fields")));
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Passwords do not match")));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Firebase Authentication (Signup)
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Store User Data in Firestore
      await _firestore.collection("users").doc(userCredential.user!.uid).set({
        "name": name,
        "email": email,
        "mobile": mobile,
        "address": address,
        "uid": userCredential.user!.uid,
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Signup Successful!"),backgroundColor: Colors.green,));
      Navigator.of(context).pushReplacementNamed(IntroScreen.routeName);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: Helper.getScreenWidth(context),
          height: Helper.getScreenHeight(context),
          child: SafeArea(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Column(
                children: [
                  Text("Sign Up", style: Helper.getTheme(context).titleLarge),
                  SizedBox(height: 10),
                  Text("Add your details to sign up"),
                  Spacer(flex: 2),
                  CustomTextInput(controller: _nameController, hintText: "Name"),
                  Spacer(),
                  CustomTextInput(controller: _emailController, hintText: "Email", keyboardType: TextInputType.emailAddress),
                  Spacer(),
                  CustomTextInput(controller: _mobileController, hintText: "Mobile No", keyboardType: TextInputType.phone),
                  Spacer(),
                  CustomTextInput(controller: _addressController, hintText: "Address"),
                  Spacer(),
                  CustomTextInput(controller: _passwordController, hintText: "Password", obscureText: true),
                  Spacer(),
                  CustomTextInput(controller: _confirmPasswordController, hintText: "Confirm Password", obscureText: true),
                  Spacer(),
                  SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _signUp,
                      child: _isLoading ? CircularProgressIndicator(color: Colors.white) : Text("Sign Up"),
                    ),
                  ),
                  Spacer(flex: 3),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Already have an Account?"),
                      SizedBox(width: 5),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
                        },
                        child: Text("Login", style: TextStyle(color: AppColor.orange, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
