import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intership_task/views/screen/home/Screen/stripe_payment/stripe_payment.dart';
import 'history_fruit_veg/history_screen.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

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
    _setupNotifications();
  }

  Future<void> _setupNotifications() async {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const init = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await flutterLocalNotificationsPlugin.initialize(init);
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
      final picked = await _picker.pickImage(source: ImageSource.camera);
      if (picked == null) return;

      _image = File(picked.path);
      _detectedItem = detectFruitFromImage(_image!);

      final scan = {
        "image": _image,
        "item": _detectedItem,
        "time": DateTime.now(),
        "nutrition": localNutritionData[_detectedItem!] ?? {},
      };

      setState(() {
        _nutritionData
          ..clear()
          ..addAll(scan['nutrition'] as Map<String, String>);
        _history.add(scan);
      });

      flutterLocalNotificationsPlugin.show(
        0,
        'Scan Result',
        'You scanned an $_detectedItem!',
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
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String detectFruitFromImage(File _) => 'apple';

  void _goToHistoryScreen() => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => HistoryScreen(history: _history)),
  );

  void _goToPaymentScreen() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const PaymentBottomSheet(),
    );
  }

  Widget _macroCard({
    required String label,
    required String value,
    required IconData icon,
    Color? iconColor,
  }) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1.4),
      ),
      child: Row(
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
          const Spacer(),
          Icon(icon, size: 20, color: iconColor ?? Colors.grey),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now().weekday;
    final weekDays = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('NutriScan'),
        actions: [
          IconButton(
            onPressed: _goToHistoryScreen,
            icon: const Icon(Icons.history),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: _isLoading ? null : _pickImage,
        child:
            _isLoading
                ? const SpinKitFadingCircle(color: Colors.white)
                : const Icon(Icons.camera_alt),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: weekDays.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final isToday = (index + 1) == today;
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        weekDays[index],
                        style: TextStyle(
                          color: isToday ? Colors.white : Colors.white70,
                          fontWeight:
                              isToday ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 22),
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
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          '3000',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Calories Remaining',
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                        const SizedBox(height: 12),
                        Stack(
                          alignment: Alignment.center,
                          children: const [
                            SizedBox(
                              width: 64,
                              height: 64,
                              child: CircularProgressIndicator(
                                value: .75,
                                strokeWidth: 6,
                              ),
                            ),
                            Icon(Icons.local_fire_department, size: 28),
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
                      _macroCard(
                        label: 'Protein left',
                        value: '177 g',
                        icon: Icons.check_circle,
                        iconColor: Colors.orange,
                      ),
                      const SizedBox(height: 10),
                      _macroCard(
                        label: 'Carbs left',
                        value: '180 g',
                        icon: Icons.egg,
                        iconColor: Colors.orange,
                      ),
                      const SizedBox(height: 10),
                      _macroCard(
                        label: 'Fat left',
                        value: '85 g',
                        icon: Icons.favorite,
                        iconColor: Colors.pink,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            if (_image != null) ...[
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(14),
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
                      'Detected: ${_detectedItem ?? ''}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...['Calories', 'Fiber', 'Vitamin C', 'Price per Kg'].map((
                      key,
                    ) {
                      if (!_nutritionData.containsKey(key))
                        return const SizedBox();
                      return ListTile(
                        title: Text(key),
                        trailing: Text(
                          _nutritionData[key]!,
                          style:
                              key == 'Price per Kg'
                                  ? const TextStyle(
                                    decoration: TextDecoration.underline,
                                    color: Colors.blue,
                                  )
                                  : null,
                        ),
                        onTap:
                            key == 'Price per Kg' ? _goToPaymentScreen : null,
                      );
                    }),
                  ],
                ),
              ),
            ],
            if (_image == null && _history.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Text(
                    'Nothing yet – scan an item to begin!',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
