import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:art_vibes1/screens/tickets/bottom_navigation.dart';
import 'package:art_vibes1/screens/tickets/home_Screen.dart';
import 'package:art_vibes1/profile/profile_screen.dart';

class CreateEventScreen extends StatefulWidget {
  final bool isArtist;

  CreateEventScreen({required this.isArtist});

  @override
  _CreateEventScreenState createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  File? _eventImage;
  String _eventName = '';
  String _description = '';
  String _price = '';
  DateTimeRange? _eventDateRange;
  List<DateTime> _availableBookingDates = [];
  // ignore: prefer_final_fields, unused_field
  String _location = 'Add Location';
  String _address = ''; // Manual address entry
  int _currentIndex = 0;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickEventImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _eventImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _selectEventDateRange() async {
    final DateTimeRange? pickedDateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDateRange != null) {
      setState(() {
        _eventDateRange = pickedDateRange;
      });
    }
  }

  void _addAvailableBookingDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        _availableBookingDates.add(pickedDate);
      });
    }
  }

  Future<void> _createEvent() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    try {
      String? imageUrl;
      if (_eventImage != null) {
        // Upload image to Firebase Storage
        String fileName = 'event_images/${DateTime.now().millisecondsSinceEpoch}.png';
        UploadTask uploadTask = FirebaseStorage.instance.ref().child(fileName).putFile(_eventImage!);
        TaskSnapshot snapshot = await uploadTask;
        imageUrl = await snapshot.ref.getDownloadURL();
      }

      // Save event data to Firestore with the image URL
      await _firestore.collection('events').add({
        'artistId': user.uid,
        'eventName': _eventName,
        'description': _description,
        'price': _price,
        'eventDateRange': _eventDateRange != null
            ? '${_eventDateRange!.start} - ${_eventDateRange!.end}'
            : null,
        'availableBookingDates': _availableBookingDates
            .map((date) => date.toIso8601String())
            .toList(),
        'location': _address, // Using the manually entered address
        'image': imageUrl, // Save the download URL
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Event created successfully!")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to create event: $e")),
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => [
          const HomeScreen(),
          CreateEventScreen(isArtist: widget.isArtist),
          const ProfileScreen(),
        ][index],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120.0),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: Container(
            margin: const EdgeInsets.all(8.0),
            decoration: const BoxDecoration(
              color: Color(0xFFFF7043),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          flexibleSpace: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Image.asset(
                  'assets/images/Art_vibes_Logo.png',
                  height: 80,
                  errorBuilder: (context, error, stackTrace) {
                    return const Text('Logo not found');
                  },
                ),
              ),
              const SizedBox(height: 4.0),
              const Text(
                "Event Creation",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          centerTitle: true,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Event Image Picker
            Container(
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: GestureDetector(
                onTap: _pickEventImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _eventImage == null
                      ? const Center(child: Text("Tap to select an image"))
                      : Image.file(
                          _eventImage!,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Event Name Field
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: TextField(
                onChanged: (value) => _eventName = value,
                decoration: const InputDecoration(
                  labelText: 'Event Name',
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Description Field
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: TextField(
                onChanged: (value) => _description = value,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Price Field
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: TextField(
                onChanged: (value) => _price = value,
                decoration: const InputDecoration(
                  labelText: 'Price',
                  border: InputBorder.none,
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(height: 16),
            // Event Date Range
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: ElevatedButton(
                onPressed: _selectEventDateRange,
                child: const Text("Select Event Date Range"),
              ),
            ),
            if (_eventDateRange != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  "Event Dates: ${_eventDateRange!.start.toLocal()} - ${_eventDateRange!.end.toLocal()}",
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            const SizedBox(height: 16),
            // Available Booking Dates
            Text(
              "Available Booking Dates",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: ElevatedButton(
                onPressed: _addAvailableBookingDate,
                child: const Text("Add Available Date"),
              ),
            ),
            for (var date in _availableBookingDates)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(
                  date.toLocal().toString().split(' ')[0],
                  style: const TextStyle(color: Colors.black),
                ),
              ),
            const SizedBox(height: 16),
            // Manual Location Entry
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: TextField(
                onChanged: (value) => _address = value,
                decoration: const InputDecoration(
                  labelText: 'Enter Address',
                  prefixIcon: Icon(Icons.location_on),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Create Event Button
            ElevatedButton(
              onPressed: _createEvent,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF7043),
                minimumSize: const Size(double.infinity, 50),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Create Event",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
