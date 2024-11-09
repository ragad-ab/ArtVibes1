import 'package:art_vibes1/profile/profile_screen.dart';
import 'package:art_vibes1/screens/tickets/Cart_Screen.dart';
import 'package:art_vibes1/screens/tickets/bottom_navigation.dart';
import 'package:art_vibes1/screens/tickets/home_Screen.dart';
import 'package:art_vibes1/screens/tickets/ticket.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class EventDetailsViewScreen extends StatelessWidget {
  final Map<String, dynamic> eventData;

  EventDetailsViewScreen({required this.eventData, required Map event});

  Future<void> _openMap() async {
    final location = eventData['location'];
    if (location != null && location is String) {
      final googleMapsUrl = "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(location)}";
      if (await canLaunch(googleMapsUrl)) {
        await launch(googleMapsUrl);
      } else {
        throw 'Could not open the map.';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventName = eventData['eventName'] ?? 'Unnamed Event';
    final price = eventData['price'] ?? '50 SAR'; // Default to 50 SAR
    final selectedDate = eventData['selectedDate'] != null
        ? DateFormat('MMM dd, yyyy').format(DateTime.parse(eventData['selectedDate']))
        : 'Date not selected';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Image.asset(
          'assets/images/Art_vibes_Logo.png',
          height: 60,
          fit: BoxFit.contain,
        ),
        leading: Container(
          margin: const EdgeInsets.all(8.0),
          decoration: const BoxDecoration(
            color: Color(0xFFFF7043), // Orange background
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white), // White arrow
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                eventName,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.calendar_today, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text("Date: $selectedDate", style: TextStyle(fontSize: 16)),
                ],
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _openMap,
                child: Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.blue[700]),
                    const SizedBox(width: 8),
                    Text(
                      "View on Google Maps",
                      style: TextStyle(color: Colors.blue, fontSize: 16, decoration: TextDecoration.underline),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.attach_money, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text("Price: $price", style: TextStyle(fontSize: 16)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 8),
                  Text("Status: Paid", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 1, // Setting Tickets tab as the default
        onItemTapped: (index) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => [
                HomeScreen(),
                TicketsScreen(),
                CartScreen(),
                ProfileScreen(),
              ][index],
            ),
          );
        },
      ),
    );
  }
}
