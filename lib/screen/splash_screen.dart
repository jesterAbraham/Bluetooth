import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial_example/MainPage.dart';
import 'package:flutter_bluetooth_serial_example/screen/intro_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashView extends StatefulWidget {
  const SplashView({Key? key}) : super(key: key);

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  Future<void> callBackIntro() async {
    log("------------------------------------------");
    final pref = await SharedPreferences.getInstance();
    Timer(
      Duration(seconds: 2),
      () => pref.getBool("intro") ?? false
          ? Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) {
                  return MainPage();
                },
              ),
            )
          : Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) {
                  return IntroScreen();
                },
              ),
            ),
    );
  }

  @override
  void initState() {
    callBackIntro();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xff000000),
              Color(0xFF141414),
              Color(0xff000000),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo.png',
              width: 120,
              height: 120,
            ),
            SizedBox(height: 25),
            Text(
              'Bluetooth Device Manager',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
