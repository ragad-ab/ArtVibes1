import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventCreationScreen extends StatefulWidget {
  @override
  _EventCreationScreenState createState() => _EventCreationScreenState();
}

class _EventCreationScreenState extends State<EventCreationScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _websiteController = TextEditingController();
  final _locationController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();

  Future<void> _submitEvent() async {
    FirebaseFirestore.instance.collection('events').add({
      'name': _nameController.text,
      'description': _descriptionController.text,
      'website': _websiteController.text,
      'location': _locationController.text,
      'date': _dateController.text,
      'time': _timeController.text,
      'status': 'active',
      'image': 'assets/images/event.png', // Placeholder image
      'artistId': 'current_artist_id', // Replace with artist ID
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Create Event")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Event Name')),
            TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description')),
            TextField(
                controller: _websiteController,
                decoration: InputDecoration(labelText: 'Website')),
            TextField(
                controller: _locationController,
                decoration: InputDecoration(labelText: 'Location')),
            TextField(
                controller: _dateController,
                decoration: InputDecoration(labelText: 'Date')),
            TextField(
                controller: _timeController,
                decoration: InputDecoration(labelText: 'Time')),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: _submitEvent, child: Text("Create Event")),
          ],
        ),
      ),
    );
  }
}
