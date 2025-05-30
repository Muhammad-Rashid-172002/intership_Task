import 'package:flutter/material.dart';
import 'package:intership_task/views/screen/home/onboardingScreen/SelectDOB.dart';

class Hightweightscreen extends StatefulWidget {
  final String selectedGender;

  const Hightweightscreen({super.key, required this.selectedGender});

  @override
  State<Hightweightscreen> createState() => _HightweightscreenState();
}

class _HightweightscreenState extends State<Hightweightscreen> {
  int selectedFeet = 5;
  int selectedInches = 9;
  int selectedWeight = 119;
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
        physics: FixedExtentScrollPhysics(),
        onSelectedItemChanged: onSelectedItemChanged,
        controller: FixedExtentScrollController(initialItem: selectedIndex),
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
        title: const Text('Height & Weight'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Height & Weight',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 20),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text:
                    'This activity level helps you to tailor your fitness insights!',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ),
            SizedBox(height: 100),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Height Picker Container
                SizedBox(
                  width: 226,

                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 12,
                    ),
                    padding: const EdgeInsets.all(16),
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
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Height',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _buildPicker(
                              items: List.generate(8, (i) => "${i + 1} ft"),
                              selectedIndex: selectedFeet - 1,
                              onSelectedItemChanged: (i) {
                                setState(() => selectedFeet = i + 1);
                              },
                            ),
                            const SizedBox(width: 10),
                            _buildPicker(
                              items: List.generate(12, (i) => "$i in"),
                              selectedIndex: selectedInches,
                              onSelectedItemChanged: (i) {
                                setState(() => selectedInches = i);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Weight Picker Container
                SizedBox(
                  width: 130,

                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 12,
                    ),
                    padding: const EdgeInsets.all(16),
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
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Weight',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildPicker(
                          items: List.generate(
                            201,
                            (i) => "${i + 50}",
                          ), // 50 to 250 lbs
                          selectedIndex: selectedWeight - 50,
                          onSelectedItemChanged: (i) {
                            setState(() => selectedWeight = i + 50);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 150),
            // Elevated Button
            ElevatedButton(
              onPressed: () {
                if (widget.selectedGender.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => Selectdob(
                            selectedGender: widget.selectedGender,
                            height: "$selectedFeet ft $selectedInches in",
                            weight: "$selectedWeight lbs",
                          ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please select a Hight & Weight')),
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
