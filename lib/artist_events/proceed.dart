import 'package:art_vibes1/artist_events/events_detail_screen.dart';
import 'package:art_vibes1/profile/profile_screen.dart';
import 'package:art_vibes1/screens/tickets/Cart_Screen.dart';
import 'package:art_vibes1/screens/tickets/bottom_navigation.dart';
import 'package:art_vibes1/screens/tickets/home_Screen.dart';
import 'package:art_vibes1/screens/tickets/ticket.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class EventDetailsProceedScreen extends StatefulWidget {
  final Map<String, dynamic> event;

  EventDetailsProceedScreen({required this.event});

  @override
  _EventDetailsProceedScreenState createState() => _EventDetailsProceedScreenState();
}

class _EventDetailsProceedScreenState extends State<EventDetailsProceedScreen> {
  int _currentIndex = 0; // Default to home

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => [
          HomeScreen(),
          CartScreen(),
          TicketsScreen(),
          ProfileScreen(),
        ][index],
      ),
    );
  }

  void _showPaymentConfirmation() {
    // Add the event to the TicketsScreen list
    CartScreen.ticketList.add(widget.event); 

    // Remove the event from the CartScreen list
    EventDetailsScreen.cartList.remove(widget.event);

    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Payment Successful"),
          content: Text("You have successfully bought the ticket. It is now in the Tickets section."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => TicketsScreen()));
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openMap() async {
    final location = widget.event['location'];
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
    final eventName = widget.event['eventName'] ?? 'Unnamed Event';
    final price = widget.event['price'] ?? 'Free';
    final selectedDate = widget.event['selectedDate'] != null
        ? DateFormat('MMM dd, yyyy').format(DateTime.parse(widget.event['selectedDate']))
        : 'Date not selected';

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
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Text("Logo not found", style: TextStyle(fontSize: 18, color: Colors.red));
                  },
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Event Details",
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
              Text(eventName, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text("Date: $selectedDate"),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _openMap,
                child: Text(
                  "View on Google Maps",
                  style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                ),
              ),
              const SizedBox(height: 8),
              Text("Price: $price"),
              Spacer(),
              Center(
                child: ElevatedButton(
                  onPressed: _showPaymentConfirmation,
                  child: const Text("Pay", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFF7043),
                    minimumSize: const Size(double.infinity, 50),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
