import 'package:art_vibes1/profile/profile_screen.dart';
import 'package:art_vibes1/screens/tickets/ticket.dart';
import 'package:art_vibes1/tracking/tracking_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Import for date formatting
import 'package:url_launcher/url_launcher.dart'; // Import to handle launching URLs
import 'home_screen.dart'; // Import HomeScreen

class AppointmentDetails extends StatelessWidget {
  final Map<String, dynamic> eventData;

  const AppointmentDetails({Key? key, required this.eventData})
      : super(key: key);

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
        title: const Text('Appointment Details'),
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
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFFF7043), // Orange background
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white),
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
            const SizedBox(height: 16.0),
            Text(
              eventData["title"] ?? 'No Title',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Text(
              eventData["type"] ?? 'No Type',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16.0),
            Text(
              'Price: ${eventData["price"]} ${eventData["currency"] ?? "SAR"}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8.0),
            Text(
              'City: ${eventData["city"]}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16.0),
            GestureDetector(
              onTap: _launchURL,
              child: const Text(
                'Go: Gallery Website',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              'Status: ${eventData["status"]}',
              style: TextStyle(
                fontSize: 16,
                color: eventData["status"] == "Upcoming"
                    ? Colors.green
                    : Colors.red,
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              'Date & Time: $formattedDate',
              style: const TextStyle(fontSize: 16),
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
            icon: Icon(Icons.confirmation_number),
            label: 'Tickets',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2),
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
          // Handle navigation based on the index
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) =>  TicketsScreen()),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const TrackingScreen()),
            );
          } else if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          }
        },
      ),
    );
  }
}
