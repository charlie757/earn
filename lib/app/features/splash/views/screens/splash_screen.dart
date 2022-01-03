import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:mny_champ/app/config/routes/app_pages.dart';
import 'package:mny_champ/app/constants/assets_constant.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  void initState() {
    super.initState();
    Future.delayed(
        const Duration(seconds: 5),
            () => _initialize());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 63, 136, 197),
      body: Center(
        child: Lottie.asset('images/inr_lotti.json'),
      ),
    );
  }

  void _initialize() {
    Firebase.initializeApp().then((value) {
      if (FirebaseAuth.instance.currentUser != null) {
        Get.offNamed(Routes.mainpage);
      } else {
        Get.offNamed(Routes.login);
      }
    });
  }
}