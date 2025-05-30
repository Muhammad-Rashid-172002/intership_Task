import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  File? _image;
  List<ImageLabel> _labels = [];
  bool _isScanning = false;
  final ImagePicker _picker = ImagePicker();

  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  final Map<String, Map<String, String>> nutritionInfo = {
    "banana": {
      "Calories": "105",
      "Vitamin C": "17% of the RDI",
      "Vitamin B6": "22% of the RDI",
      "Potassium": "12% of the RDI",
    },
    "carrot": {
      "Calories": "41",
      "Vitamin A": "334% of the RDI",
      "Vitamin K": "16% of the RDI",
      "Fiber": "2.8g",
    },
    "apple": {
      "Calories": "95",
      "Vitamin C": "14% of the RDI",
      "Fiber": "4g",
      "Potassium": "6% of the RDI",
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
      '@mipmap/ic_launcher',
    );
    const initSettings = InitializationSettings(android: androidSettings);

    await flutterLocalNotificationsPlugin.initialize(initSettings);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'default_channel',
              'Default',
              importance: Importance.high,
              priority: Priority.high,
            ),
          ),
        );
      }
    });
  }

  Future<void> _scanImage() async {
    setState(() {
      _isScanning = true;
      _labels = [];
    });

    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.camera);

      if (pickedFile == null) {
        setState(() => _isScanning = false);
        return;
      }

      final inputImage = InputImage.fromFilePath(pickedFile.path);
      final imageLabeler = ImageLabeler(
        options: ImageLabelerOptions(confidenceThreshold: 0.5),
      );
      final labels = await imageLabeler.processImage(inputImage);
      await imageLabeler.close();

      setState(() {
        _image = File(pickedFile.path);
        _labels = labels;
        _isScanning = false;
      });

      // 🔔 Send notification with labels
      if (_labels.isNotEmpty) {
        final labelNames = _labels.map((l) => l.label).join(', ');
        flutterLocalNotificationsPlugin.show(
          0,
          'Scan Complete',
          'You scanned: $labelNames',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'default_channel',
              'Default',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => _isScanning = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error scanning image: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NutriScan'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isScanning ? null : _scanImage,
        backgroundColor: Colors.blue,
        child:
            _isScanning
                ? const CircularProgressIndicator(color: Colors.white)
                : const Icon(Icons.camera_alt),
      ),
      body: Column(
        children: [
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
          if (_labels.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: _labels.length,
                itemBuilder: (context, index) {
                  final label = _labels[index];
                  final food = label.label.toLowerCase();
                  final nutrition = nutritionInfo[food];

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label.label,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Confidence: ${(label.confidence * 100).toStringAsFixed(1)}%',
                          ),
                          const SizedBox(height: 8),
                          if (nutrition != null) ...[
                            const Text(
                              'Nutrition Info:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            ...nutrition.entries.map(
                              (e) => Text('${e.key}: ${e.value}'),
                            ),
                          ] else
                            const Text("No nutrition info available."),
                        ],
                      ),
                    ),
                  );
                },
              ),
            )
          else if (!_isScanning)
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                'Scan a fruit or vegetable to see nutrition information.',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ),
        ],
      ),
    );
  }
}
