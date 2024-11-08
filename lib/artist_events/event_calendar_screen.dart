import 'package:art_vibes1/artist_events/event_creation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventCalendarScreen extends StatelessWidget {
  final bool isArtistWithLicense; // Pass based on the artist's license status

  EventCalendarScreen({required this.isArtistWithLicense});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Events Calendar'),
        actions: [
          if (isArtistWithLicense)
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EventCreationScreen()),
                );
              },
            ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('events').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final events = snapshot.data?.docs ?? [];
          if (events.isEmpty) {
            return Center(child: Text("No events available"));
          }

          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return ListTile(
                title: Text(event['name']),
                subtitle: Text(event['description']),
                onTap: () {
                  // Navigate to Event Detail or Ticket Purchase screen
                },
              );
            },
          );
        },
      ),
    );
  }
}
