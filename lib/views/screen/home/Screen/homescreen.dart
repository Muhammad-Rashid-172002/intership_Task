import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
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

  final Map<String, Map<String, String>> nutritionInfo = {
    "carrot": {
      "RS": "100",
      "Vitamin B": "214% of the RDI",
      "Calories": "41",
      "Vitamin A": "334% of the RDI",
      "Sugar": "4.7g",
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

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );

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
                ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: SpinKitFadingCircle(color: Colors.white, size: 24.0),
                )
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
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "3000",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Calories Remaining",
                          style: TextStyle(fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 60,
                              height: 60,
                              child: CircularProgressIndicator(
                                value: 0.8,
                                backgroundColor: Colors.grey[300],
                                strokeWidth: 6,
                                valueColor: const AlwaysStoppedAnimation(
                                  Colors.black,
                                ),
                              ),
                            ),
                            const Icon(Icons.local_fire_department, size: 24),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Card(
                      margin: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 16,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  '180 g',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  'Carbs left',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                            CircleAvatar(
                              backgroundColor: Colors.grey[200],
                              child: Icon(Icons.rice_bowl, color: Colors.brown),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Card(
                      margin: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 16,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  '177 g',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  'Protein left',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                            CircleAvatar(
                              backgroundColor: Colors.grey[200],
                              child: Icon(Icons.egg, color: Colors.brown),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
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
                              key == "RS"
                                  ? TextButton(
                                    onPressed: () {
                                      showModalBottomSheet(
                                        context: context,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(20),
                                          ),
                                        ),
                                        isScrollControlled: true,
                                        builder:
                                            (context) =>
                                                const PaymentBottomSheet(),
                                      );
                                    },
                                    child: Text(
                                      value ?? '',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  )
                                  : Text(
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
            )
          else
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
