import 'package:art_vibes1/artist_events/events_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:art_vibes1/profile/profile_screen.dart';
import 'package:art_vibes1/screens/tickets/home_Screen.dart';
import 'package:art_vibes1/screens/tickets/ticket.dart';
import 'package:art_vibes1/screens/tickets/bottom_navigation.dart';
import 'package:art_vibes1/artist_events/proceed.dart';

class CartScreen extends StatefulWidget {
  static List<Map<String, dynamic>> ticketList = []; // To store confirmed tickets

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  int _currentIndex = 0; // Set default index to 0 for Home

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

  void _removeEventFromCart(int index) {
    setState(() {
      EventDetailsScreen.cartList.removeAt(index); // Remove the event from the cart list
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Event removed from cart.")),
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
                  'assets/images/Art_vibes_Logo.png', // Ensure this path is correct in pubspec.yaml
                  height: 80,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Text("Logo not found", style: TextStyle(fontSize: 18, color: Colors.red));
                  },
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Cart",
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
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: EventDetailsScreen.cartList.length,
        itemBuilder: (context, index) {
          final event = EventDetailsScreen.cartList[index];
          final selectedDate = event['selectedDate'] != null
              ? DateFormat('MMM dd, yyyy').format(DateTime.parse(event['selectedDate']))
              : 'Date not selected';

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event['eventName'] ?? 'Unnamed Event', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text("Date: $selectedDate"),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => EventDetailsProceedScreen(event: event)),
                          );
                        },
                        child: const Text("Proceed", style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF008080),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _removeEventFromCart(index); // Call to remove the event
                        },
                        child: const Text("Delete", style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
