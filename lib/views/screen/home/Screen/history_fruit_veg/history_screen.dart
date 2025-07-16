import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatelessWidget {
  final List<Map<String, dynamic>> history;
  const HistoryScreen({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan History'),
        backgroundColor: Colors.green,
      ),
      body:
          history.isEmpty
              ? const Center(child: Text('No scans yet.'))
              : ListView.builder(
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final item = history[index];
                  final image = item['image'] as File;
                  final itemName = item['item'] ?? "unknown";
                  final time = item['time'] as DateTime;
                  final nutrition = item['nutrition'] as Map<String, String>;

                  return Card(
                    margin: const EdgeInsets.all(8),
                    child: ListTile(
                      leading: Image.file(
                        image,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                      title: Text(itemName.toString().toUpperCase()),
                      subtitle: Text(
                        DateFormat('yyyy-MM-dd – HH:mm').format(time),
                      ),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder:
                              (_) => AlertDialog(
                                title: Text("Nutrition for $itemName"),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children:
                                      nutrition.entries
                                          .map(
                                            (e) => ListTile(
                                              title: Text(e.key),
                                              trailing: Text(e.value),
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
