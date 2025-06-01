import 'package:flutter/material.dart';
import 'package:intership_task/views/screen/auth_model/Google_auth_screen.dart';
import 'package:lottie/lottie.dart';

class Congratsscreen extends StatefulWidget {
  const Congratsscreen({super.key});

  @override
  State<Congratsscreen> createState() => _CongratsscreenState();
}

class _CongratsscreenState extends State<Congratsscreen> {
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Congratulations'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/animation assets/congrats.json',
              width: 200,
              height: 200,
            ),
            SizedBox(height: 120),
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
                    'We are committed to ensuring that your personal information remains safeand confidential.!',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ),
            SizedBox(height: 180),
            ElevatedButton(
              onPressed:
                  _isLoading
                      ? null
                      : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const GoogleAuthScreen(),
                          ),
                        );
                        setState(() {
                          _isLoading = true;
                        });
                      },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                minimumSize: const Size(300, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child:
                  _isLoading
                      ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                      : const Text(
                        'Next',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
