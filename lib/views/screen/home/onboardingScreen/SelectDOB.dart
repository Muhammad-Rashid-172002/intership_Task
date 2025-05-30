import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intership_task/views/screen/home/onboardingScreen/congratsscreen.dart';

class Selectdob extends StatefulWidget {
  final String selectedGender;
  final String height;
  final String weight;

  const Selectdob({
    super.key,
    required this.selectedGender,
    required this.height,
    required this.weight,
  });

  @override
  State<Selectdob> createState() => _SelectdobState();
}

class _SelectdobState extends State<Selectdob> {
  int selectedDay = 15;
  int selectedMonth = 5;
  int selectedYear = 2000;

  Widget _buildPicker({
    required List<String> items,
    required int selectedIndex,
    required ValueChanged<int> onSelectedItemChanged,
  }) {
    return SizedBox(
      height: 120,
      width: 80,
      child: ListWheelScrollView.useDelegate(
        itemExtent: 40,
        physics: const FixedExtentScrollPhysics(),
        controller: FixedExtentScrollController(initialItem: selectedIndex),
        onSelectedItemChanged: onSelectedItemChanged,
        childDelegate: ListWheelChildBuilderDelegate(
          builder: (context, index) {
            if (index < 0 || index >= items.length) return null;
            return Center(
              child: Text(
                items[index],
                style: TextStyle(
                  fontSize: 20,
                  color: index == selectedIndex ? Colors.blue : Colors.black54,
                  fontWeight:
                      index == selectedIndex
                          ? FontWeight.bold
                          : FontWeight.normal,
                ),
              ),
            );
          },
          childCount: items.length,
        ),
      ),
    );
  }

  // ✅ Save DOB + previous info to Firestore
  Future<void> saveUserInfoToFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final dob =
          "$selectedDay-${selectedMonth.toString().padLeft(2, '0')}-$selectedYear";

      try {
        await FirebaseFirestore.instance.collection('Users').doc(user.uid).set({
          'gender': widget.selectedGender,
          'height': widget.height,
          'weight': widget.weight,
          'DOB': dob,
        }, SetOptions(merge: true));

        print("Saved to Firestore:");
        print("Gender: ${widget.selectedGender}");
        print("Height: ${widget.height}");
        print("Weight: ${widget.weight}");
        print("DOB: $dob");

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("DOB saved successfully")));

        // Go to next screen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Congratsscreen()),
        );
      } catch (e) {
        print("Error saving DOB: $e");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error saving DOB")));
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("User not signed in")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Date of Birth"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 50),
          const Text(
            'What is Your Date of Birth?',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              text:
                  'This activity level helps you to tailor your fitness insights!',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ),
          const SizedBox(height: 100),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Day Picker
              Container(
                width: 100,
                margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 6),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'Day',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    _buildPicker(
                      items: List.generate(31, (i) => "${i + 1}"),
                      selectedIndex: selectedDay - 1,
                      onSelectedItemChanged: (i) {
                        setState(() => selectedDay = i + 1);
                      },
                    ),
                  ],
                ),
              ),

              // Month Picker
              Container(
                width: 100,
                margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 6),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'Month',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    _buildPicker(
                      items: const [
                        "Jan",
                        "Feb",
                        "Mar",
                        "Apr",
                        "May",
                        "Jun",
                        "Jul",
                        "Aug",
                        "Sep",
                        "Oct",
                        "Nov",
                        "Dec",
                      ],
                      selectedIndex: selectedMonth - 1,
                      onSelectedItemChanged: (i) {
                        setState(() => selectedMonth = i + 1);
                      },
                    ),
                  ],
                ),
              ),

              // Year Picker
              Container(
                width: 100,
                margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 6),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'Year',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    _buildPicker(
                      items: List.generate(100, (i) => "${2025 - i}"),
                      selectedIndex: 2025 - selectedYear,
                      onSelectedItemChanged: (i) {
                        setState(() => selectedYear = 2025 - i);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 200),
          ElevatedButton(
            onPressed: () async {
              await saveUserInfoToFirebase();
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
    );
  }
}
