import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intership_task/views/screen/home/Screen/stripe_payment/stripe_payment.dart';
import 'package:intl/intl.dart';
import 'history_fruit_veg/history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _image;
  String? _detectedItem;
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();
  final Map<String, String> _nutritionData = {};
  final List<Map<String, dynamic>> _history = [];

  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  final Map<String, Map<String, String>> localNutritionData = {
    "apple": {
      "Calories": "95",
      "Fiber": "4 g",
      "Vitamin C": "14 %",
      "Price per Kg": "200 PKR",
    },
  };

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    await flutterLocalNotificationsPlugin.initialize(initSettings);

    const channel = AndroidNotificationChannel(
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

      final image = File(pickedFile.path);
      final detectedItem = detectFruitFromImage(image);
      final nutrition = localNutritionData[detectedItem] ?? {};

      final scan = {
        "image": image,
        "item": detectedItem,
        "time": DateTime.now(),
        "nutrition": nutrition,
      };

      setState(() {
        _image = image;
        _detectedItem = detectedItem;
        _nutritionData
          ..clear()
          ..addAll(nutrition);
        _history.add(scan);
      });

      flutterLocalNotificationsPlugin.show(
        0,
        'Scan Complete',
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error while scanning: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String detectFruitFromImage(File _) => 'apple';

  void _goToHistoryScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => HistoryScreen(history: _history)),
    );
  }

  void _goToPaymentScreen() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const PaymentBottomSheet(),
    );
  }

  Widget _buildMacroCard({
    required String label,
    required String value,
    required IconData icon,
  }) {
    // Extract numeric value from string like "177 g"
    final numericValue = int.tryParse(value.split(' ').first) ?? 0;

    // Determine color based on thresholds
    Color iconColor;
    if (numericValue > 150) {
      iconColor = Colors.orange;
    } else if (numericValue > 100) {
      iconColor = Colors.green;
    } else {
      iconColor = Colors.red;
    }

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white, width: 1.4),
      ),
      child: Row(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: Colors.white),
          ),
          const Spacer(),
          Icon(icon, size: 20, color: iconColor),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final weekDays = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    final today = DateTime.now().weekday;

    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
        title: const Text('NutriScan', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            onPressed: _goToHistoryScreen,
            icon: const Icon(Icons.history, color: Colors.white),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.tealAccent,
        onPressed: _isLoading ? null : _pickImage,
        child:
            _isLoading
                ? const SpinKitFadingCircle(color: Colors.white, size: 28)
                : const Icon(Icons.camera_alt),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Weekday Pills
            Card(
              margin: const EdgeInsets.only(bottom: 20),
              color: Colors.grey[850],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Colors.white, width: 2),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('MMMM yyyy').format(DateTime.now()),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(7, (index) {
                        final today = DateTime.now();
                        final startOfWeek = today.subtract(
                          Duration(days: today.weekday - 1),
                        );
                        final currentDay = startOfWeek.add(
                          Duration(days: index),
                        );
                        final daysOfWeek = [
                          'Mon',
                          'Tue',
                          'Wed',
                          'Thu',
                          'Fri',
                          'Sat',
                          'Sun',
                        ];
                        final isToday =
                            today.day == currentDay.day &&
                            today.month == currentDay.month &&
                            today.year == currentDay.year;

                        if (isToday) {
                          // Highlight entire container for today
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.tealAccent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  daysOfWeek[index],
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${currentDay.day}',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else {
                          // Default style for other days
                          return Column(
                            children: [
                              Text(
                                daysOfWeek[index],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${currentDay.day}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          );
                        }
                      }),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 22),

            // Calories & Macros
            Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      children: const [
                        Text(
                          '3000',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Calories Remaining',
                          style: TextStyle(fontSize: 13, color: Colors.white),
                        ),
                        SizedBox(height: 12),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 64,
                              height: 64,
                              child: CircularProgressIndicator(
                                value: 0.75,
                                strokeWidth: 6,
                                color: Colors.tealAccent,
                              ),
                            ),
                            Icon(
                              Icons.local_fire_department,
                              size: 28,
                              color: Colors.tealAccent,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      _buildMacroCard(
                        label: 'Protein left',
                        value: '177 g',
                        icon: Icons.check_circle,
                      ),
                      const SizedBox(height: 10),
                      _buildMacroCard(
                        label: 'Carbs left',
                        value: '180 g',
                        icon: Icons.egg,
                      ),
                      const SizedBox(height: 10),
                      _buildMacroCard(
                        label: 'Fat left',
                        value: '85 g',
                        icon: Icons.favorite,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            if (_image != null)
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _image!,
                            height: 160,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Detected: $_detectedItem',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...[
                          'Calories',
                          'Fiber',
                          'Vitamin C',
                          'Price per Kg',
                        ].map((key) {
                          if (!_nutritionData.containsKey(key)) {
                            return const SizedBox.shrink();
                          }
                          return ListTile(
                            title: Text(
                              key,
                              style: const TextStyle(color: Colors.white),
                            ),
                            trailing: Text(
                              _nutritionData[key]!,
                              style:
                                  key == 'Price per Kg'
                                      ? const TextStyle(
                                        color: Colors.tealAccent,
                                        decoration: TextDecoration.underline,
                                      )
                                      : const TextStyle(color: Colors.white),
                            ),
                            onTap:
                                key == 'Price per Kg'
                                    ? _goToPaymentScreen
                                    : null,
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),

            if (_image == null && _history.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Text(
                    'Nothing yet – scan an item to begin!',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
