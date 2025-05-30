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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Date of Birth"),
        backgroundColor: Colors.blue,
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
                  'This activity level helps you to tailoryour fitness insights!',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ),
          SizedBox(height: 100),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Day Container
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

              // Month Container
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
                      items: [
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

              // Year Container
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
          //Elevated Button
          ElevatedButton(
            onPressed: () {
              final dob =
                  "$selectedDay-${selectedMonth.toString().padLeft(2, '0')}-$selectedYear";
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text("DOB Selected: $dob")));
              // You can pass `dob` to the next screen if needed
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Congratsscreen()),
              );
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
