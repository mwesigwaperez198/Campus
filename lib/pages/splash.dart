import 'package:flutter/material.dart';
import 'dart:async';

class SplashPage extends StatefulWidget {
  final Widget child;
  const SplashPage({super.key, required this.child});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 4), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => widget.child),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/Novara logo.jpeg',
              width: 300,
            ),
            const SizedBox(height: 20),
            const Text(
              "Shaping a new era of tech in Uganda",
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF4A5568),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
