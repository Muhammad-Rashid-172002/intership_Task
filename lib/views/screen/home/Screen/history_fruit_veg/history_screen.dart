import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatelessWidget {
  final List<Map<String, dynamic>> history;
  const HistoryScreen({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      appBar: AppBar(
        title: const Text(
          'Scan History',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body:
          history.isEmpty
              ? const Center(
                child: Text(
                  'No scans yet.',
                  style: TextStyle(color: Colors.white),
                ),
              )
              : ListView.builder(
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final item = history[index];
                  final image = item['image'] as File;
                  final itemName = item['item'] ?? "unknown";
                  final time = item['time'] as DateTime;
                  final nutrition = item['nutrition'] as Map<String, String>;

                  return Card(
                    color: Colors.grey[850],
                    margin: const EdgeInsets.all(8),
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(
                        color: Colors.white, // White border line
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: Image.file(
                        image,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                      title: Text(
                        itemName.toString().toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                        ), // White text
                      ),
                      subtitle: Text(
                        DateFormat('yyyy-MM-dd – HH:mm').format(time),
                        style: const TextStyle(
                          color: Colors.white70,
                        ), // Slightly lighter white
                      ),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder:
                              (_) => AlertDialog(
                                backgroundColor: Colors.blueGrey[800],

                                title: Text(
                                  "Nutrition for $itemName",
                                  style: const TextStyle(color: Colors.white),
                                ),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children:
                                      nutrition.entries
                                          .map(
                                            (e) => ListTile(
                                              title: Text(
                                                e.key,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                              trailing: Text(
                                                e.value,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                ),
                              ),
                        );
                      },
                    ),
                  );
                },
              ),
    );
  }
}
