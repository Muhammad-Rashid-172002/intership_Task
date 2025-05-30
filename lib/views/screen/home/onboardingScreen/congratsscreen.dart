import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class Congratsscreen extends StatefulWidget {
  const Congratsscreen({super.key});

  @override
  State<Congratsscreen> createState() => _CongratsscreenState();
}

class _CongratsscreenState extends State<Congratsscreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/animation assets/congrats.json',
              width: 200,
              height: 200,
            ),
            SizedBox(height: 20),
            Text(
              'Thank You\n we appreciate your \n for trusting us!',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            SizedBox(height: 20),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text:
                    'We are committed to ensuring thatyour personal information remains safeand confidential.!',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ),
            SizedBox(height: 150),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                minimumSize: const Size(300, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Next',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
