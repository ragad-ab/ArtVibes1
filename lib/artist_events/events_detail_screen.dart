import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventDetailsScreen extends StatelessWidget {
  final DocumentSnapshot eventData;

  const EventDetailsScreen({Key? key, required this.eventData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Access event data fields from `eventData`
    final String name = eventData['name'] ?? 'No Name';
    final String description = eventData['description'] ?? 'No Description';
    final String location = eventData['location'] ?? 'No Location';
    final Timestamp dateTimestamp = eventData['date'];
    final DateTime date = dateTimestamp.toDate();

    return Scaffold(
      appBar: AppBar(
        title: Text(name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Date: ${date.toLocal().toString().split(' ')[0]}',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Text(
              description,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Text(
              'Location: $location',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
