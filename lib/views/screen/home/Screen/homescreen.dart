import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intership_task/views/screen/home/fruit_veg_data/data.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  File? _image;
  String? _detectedItem;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();
  final Map<String, String> _nutritionData = {};

  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    _setupNotifications();
  }

  Future<void> _setupNotifications() async {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initSettings = InitializationSettings(android: androidSettings);
    await flutterLocalNotificationsPlugin.initialize(initSettings);

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'default_channel',
      'Default Channel',
      importance: Importance.high,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  Future<void> _pickImage() async {
    setState(() => _isLoading = true);

    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.camera);
      if (pickedFile == null) return;

      _image = File(pickedFile.path);
      _detectedItem = detectFruitFromImage(_image!);

      setState(() {
        _nutritionData.clear();
        _nutritionData.addAll(localNutritionData[_detectedItem!] ?? {});
      });

      flutterLocalNotificationsPlugin.show(
        0,
        'Scan Result',
        'You scanned a $_detectedItem!',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'default_channel',
            'Default Channel',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
      );
    } catch (e) {
      print('Image pick error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NutriScan')),
      floatingActionButton: FloatingActionButton(
        onPressed: _isLoading ? null : _pickImage,
        child:
            _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Icon(Icons.camera_alt),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            _image == null
                ? const Center(
                  child: Text('Tap the camera to scan a fruit or vegetable.'),
                )
                : Column(
                  children: [
                    Image.file(_image!, height: 200),
                    const SizedBox(height: 20),
                    if (_detectedItem != null)
                      Text(
                        'Detected: $_detectedItem',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    const SizedBox(height: 10),
                    if (_nutritionData.isNotEmpty)
                      Expanded(
                        child: ListView.builder(
                          itemCount: _nutritionData.length,
                          itemBuilder: (context, index) {
                            final key = _nutritionData.keys.elementAt(index);
                            return ListTile(
                              title: Text(key),
                              trailing: Text(_nutritionData[key]! ?? ''),
                            );
                          },
                        ),
                      ),
                  ],
                ),
      ),
    );
  }
}

String detectFruitFromImage(File image) {
  final path = image.path.toLowerCase();
  if (path.contains("assets/assets images/images (2).jpeg")) return "apple";
  if (path.contains("assets/assets images/images (1).jpeg")) return "banana";
  if (path.contains("assets/assets images/images.jpeg")) return "potato";
  return "unknown";
} //  detection based on filename
