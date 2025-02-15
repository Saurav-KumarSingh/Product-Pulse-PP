import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:product_pulse/screens/chabotScreen.dart';
import 'package:product_pulse/screens/productScreen.dart';
import 'firebase_options.dart';
import 'screens/splashScreen.dart';
import 'screens/landingScreen.dart';
import 'screens/loginScreen.dart';
import 'screens/signUpScreen.dart';
import 'screens/forgetPwScreen.dart';
import 'const/colors.dart';
import 'screens/sendOtpScreen.dart';
import 'screens/newPwScreen.dart';
import 'screens/introScreen.dart';
import 'screens/homeScreen.dart';
import 'screens/profileScreen.dart';
import 'screens/notificationScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        fontFamily: "Metropolis",
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        primarySwatch: Colors.red,
        textTheme: const TextTheme(
          bodySmall: TextStyle(
            color: AppColor.orange,
            fontSize: 12,
          ),
          bodyMedium: TextStyle(
            color: AppColor.secondary,
          ),
          titleLarge: TextStyle(
            color: AppColor.primary,
            fontSize: 25,
          ),
          headlineSmall: TextStyle(
            color: AppColor.primary,
            fontWeight: FontWeight.normal,
            fontSize: 25,
          ),
          headlineLarge: TextStyle(
            color: AppColor.secondary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(
              AppColor.orange,
            ),
            foregroundColor: MaterialStateProperty.all(Colors.white),
            shape: MaterialStateProperty.all(
              const StadiumBorder(),
            ),
            elevation: MaterialStateProperty.all(0),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all(AppColor.orange),
          ),
        ),
      ),
      home: Splashscreen(),
      routes: {
        LandingScreen.routeName: (context) => const LandingScreen(),
        LoginScreen.routeName: (context) => const LoginScreen(),
        SignUpScreen.routeName: (context) => const SignUpScreen(),
        ForgetPwScreen.routeName: (context) => const ForgetPwScreen(),
        SendOtpScreen.routeName: (context) => const SendOtpScreen(),
        NewPwScreen.routeName: (context) => const NewPwScreen(),
        IntroScreen.routeName: (context) => const IntroScreen(),
        HomeScreen.routeName: (context) =>  HomeScreen(),
        ProfileScreen.routeName: (context) =>  ProfileScreen(),
        ProductOfferScreen.routeName:(context)=>ProductOfferScreen(),
        ChatScreen.routeName:(context)=>ChatScreen(),
        NotificationScreen.routeName:(context)=>NotificationScreen(),
      },
    );
  }
}