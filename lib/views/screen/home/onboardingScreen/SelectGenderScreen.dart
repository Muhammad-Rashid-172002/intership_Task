import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intership_task/views/screen/home/onboardingScreen/Hight&WeightScreen.dart';

class Selectgenderscreen extends StatefulWidget {
  const Selectgenderscreen({super.key});

  @override
  State<Selectgenderscreen> createState() => _SelectgenderscreenState();
}

class _SelectgenderscreenState extends State<Selectgenderscreen> {
  bool _isLoading = false;
  String? selectedGender;

  void selectGender(String gender) {
    setState(() {
      selectedGender = gender;
    });
  }

  Widget genderOption(String gender) {
    bool _isLoading = false;
    bool isSelected = selectedGender == gender;
    return GestureDetector(
      onTap: () => selectGender(gender),
      child: Container(
        width: 300,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: isSelected ? Colors.blue : Colors.transparent,
          border: Border.all(color: Colors.black, width: 2),
        ),
        alignment: Alignment.center,
        child: Text(
          gender,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Future<void> saveGenderToFirebase(String gender) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      print("Saving gender for user -----> ${user.uid}");
      try {
        await FirebaseFirestore.instance.collection('Users').doc(user.uid).set({
          'gender': gender,
        }, SetOptions(merge: true));

        print("Gender saved ------> $gender");
      } catch (e) {
        print("Error saving gender -----> $e");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save gender: $e')));
      }
    } else {
      print("No user logged in");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('User is not logged in')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Gender'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Select Your Gender',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'This step ensures that your\nnutrition plan is tailored just for you.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ),
            const SizedBox(height: 100),

            // Gender Options
            genderOption('Male'),
            const SizedBox(height: 20),
            genderOption('Female'),
            const SizedBox(height: 20),
            genderOption('Other'),
            const SizedBox(height: 200),

            _isLoading
                ? const SpinKitFadingCircle(color: Colors.blue, size: 40.0)
                : ElevatedButton(
                  onPressed: () async {
                    if (selectedGender != null) {
                      setState(() {
                        _isLoading = true;
                      });

                      await saveGenderToFirebase(selectedGender!);

                      setState(() {
                        _isLoading = false;
                      });

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => Hightweightscreen(
                                selectedGender: selectedGender!,
                              ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select a gender')),
                      );
                    }
                  },
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
