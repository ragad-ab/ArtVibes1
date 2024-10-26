import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Import for date formatting
import 'package:url_launcher/url_launcher.dart'; // Import to handle launching URLs

class AppointmentDetails extends StatelessWidget {
  final Map<String, dynamic> eventData;

  AppointmentDetails({required this.eventData});

  // Function to handle link opening
  void _launchURL() async {
    final url = eventData['link'] ?? '';
    if (url.isNotEmpty && await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Convert Firestore Timestamp to DateTime
    Timestamp timestamp = eventData['date'];
    DateTime eventDate = timestamp.toDate();

    // Format the DateTime into a readable string
    String formattedDate = DateFormat('dd/MM/yyyy, h:mm a').format(eventDate);

    return Scaffold(
      appBar: AppBar(
        title: Text('Appointment Details'),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        // Custom back button with an orange circular background
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFFF7043), // Orange background
              ),
              child: Icon(Icons.arrow_back,
                  color: Colors.white), // White arrow icon
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event image
            ClipRRect(
              borderRadius: BorderRadius.circular(15.0),
              child: Image.asset(
                eventData["image"] ?? 'assets/images/placeholder.png',
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              eventData["title"] ?? 'No Title',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(
              eventData["type"] ?? 'No Type',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 16.0),
            Text(
              'Price: ${eventData["price"]} ${eventData["currency"] ?? "SAR"}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8.0),
            Text(
              'City: ${eventData["city"]}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16.0),
            GestureDetector(
              onTap: _launchURL,
              child: Text(
                'Go: Gallery Website',
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.blue,
                    decoration: TextDecoration.underline),
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Status: ${eventData["status"]}',
              style: TextStyle(
                  fontSize: 16,
                  color: eventData["status"] == "Upcoming"
                      ? Colors.green
                      : Colors.red),
            ),
            SizedBox(height: 16.0),
            Text(
              'Date & Time: $formattedDate',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_number), // Ticket icon
            label: 'Tickets',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory), // Box or shipping icon
            label: 'Box',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: 1, // Keep Tickets tab selected here
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          // Add navigation logic for AppointmentDetails bottom navigation
        },
      ),
    );
  }
}
