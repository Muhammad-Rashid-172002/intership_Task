import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:intership_task/views/screen/home/Screen/stripe_payment/stripe_payment.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  File? _image;
  String? _detectedFruit;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  //  Nutrition info includes RS now
  final Map<String, Map<String, String>> nutritionInfo = {
    "carrot": {
      "Calories": "41",
      "Vitamin A": "334% of the RDI",
      "Vitamin K": "16% of the RDI",
      "Fiber": "2.8g",
      "Potassium": "7% of the RDI",
      "Carbohydrates": "9.6g",
      "Sugar": "4.7g",
      "Protein": "0.9g",
      "Fat": "0.2g",
      "RS": "100",
    },
  };

  @override
  void initState() {
    super.initState();
    _setupNotifications();
  }

  void _setupNotifications() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    await messaging.requestPermission();

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const androidSettings = AndroidInitializationSettings(
      'assets/app_icon/unnamed.png',
    );
    const initSettings = InitializationSettings(android: androidSettings);

    await flutterLocalNotificationsPlugin.initialize(initSettings);

    print('Notifications initialized');
  }

  Future<void> _pickImage() async {
    setState(() => _isLoading = true);

    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.camera);

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
          _detectedFruit = "carrot"; // Simulated detection
        });

        print('Image picked: ${pickedFile.path}');
        print('Detected fruit: carrot');

        flutterLocalNotificationsPlugin.show(
          1,
          'Scan Result',
          'You scanned a Carrot!',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'default_channel',
              'Default',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
        );
      } else {
        print('No image selected');
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final nutrition =
        _detectedFruit != null ? nutritionInfo[_detectedFruit!] : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('NutriScan'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isLoading ? null : _pickImage,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        tooltip: 'Pick Image',
        heroTag: 'pickImageButton',
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child:
            _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Icon(Icons.camera_alt),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 7,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemBuilder: (context, index) {
                final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                final today = DateTime.now().weekday; // 1 = Mon, ..., 7 = Sun

                final isToday = (index + 1) == today;

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isToday ? Colors.blue : Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      days[index],
                      style: TextStyle(
                        color: isToday ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          if (_image != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(_image!, height: 200),
              ),
            ),
          const SizedBox(height: 16),
          if (nutrition != null)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: nutrition.length,
                      itemBuilder: (context, index) {
                        final key = nutrition.keys.elementAt(index);
                        final value = nutrition[key];

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                key,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                              if (key == "RS")
                                Row(
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) =>
                                                    const StripePaymentscreen(
                                                      key: Key(
                                                        'stripe_payment_screen',
                                                      ),
                                                    ),
                                          ),
                                        );
                                        print("RS 100 button pressed");
                                      },
                                      child: Text(
                                        value ?? '',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  ],
                                )
                              else
                                Text(
                                  value ?? '',
                                  style: const TextStyle(fontSize: 16),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          if (nutrition == null)
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                'Capture a food image to see its nutrition information.',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ),
        ],
      ),
    );
  }
}
