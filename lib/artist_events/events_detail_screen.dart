import 'package:art_vibes1/profile/profile_screen.dart';
import 'package:art_vibes1/screens/tickets/Cart_Screen.dart';
import 'package:art_vibes1/screens/tickets/bottom_navigation.dart';
import 'package:art_vibes1/screens/tickets/home_Screen.dart';
import 'package:art_vibes1/screens/tickets/ticket.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class EventDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> eventData;
  static List<Map<String, dynamic>> cartList = []; // Cart list to store events

  EventDetailsScreen({required this.eventData, required Map event});

  @override
  _EventDetailsScreenState createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  String? selectedDate;
  int _currentIndex = 0;

  Future<void> _openMap() async {
    final location = widget.eventData['location'];
    if (location != null && location is String) {
      final googleMapsUrl =
          "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(location)}";
      if (await canLaunch(googleMapsUrl)) {
        await launch(googleMapsUrl);
      } else {
        throw 'Could not open the map.';
      }
    }
  }

  Future<void> _addToCart() async {
    final eventWithDate = {
      ...widget.eventData,
      'selectedDate': selectedDate,
    };
    setState(() {
      EventDetailsScreen.cartList.add(eventWithDate);
    });
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Added to Cart"),
          content: Text("Ticket has been added to the cart."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

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

  @override
  Widget build(BuildContext context) {
    final eventName = widget.eventData['eventName'] ?? 'Unnamed Event';
    final description =
        widget.eventData['description'] ?? 'No description available';
    final price = widget.eventData['price'] ?? 'Free';
    final eventDateRange =
        widget.eventData['eventDateRange'] ?? 'No dates available';
    final imageUrl = widget.eventData['image'];
    final availableDates =
        widget.eventData['availableBookingDates'] as List<dynamic>? ?? [];

    String formattedEventDateRange = _formatEventDateRange(eventDateRange);

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
          actions: [
            Stack(
              children: [
                Container(
                  margin: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Color(0xFF008080),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.shopping_cart,
                        color: Colors.white, size: 20),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CartScreen()),
                      );
                    },
                  ),
                ),
                if (EventDetailsScreen.cartList.isNotEmpty)
                  Positioned(
                    right: 4,
                    top: 4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Color(0xFFFF7043),
                        shape: BoxShape.circle,
                      ),
                      constraints: BoxConstraints(
                        minWidth: 20,
                        minHeight: 20,
                      ),
                      child: Center(
                        child: Text(
                          '${EventDetailsScreen.cartList.length}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
          flexibleSpace: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Image.asset(
                  'assets/images/Art_vibes_Logo.png',
                  height: 80,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Text("Logo not found",
                        style: TextStyle(fontSize: 18, color: Colors.red));
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl != null)
              Image.network(
                imageUrl,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: Center(child: Icon(Icons.broken_image, size: 100)),
                  );
                },
              )
            else
              Container(
                height: 200,
                color: Colors.grey[300],
                child: Center(child: Icon(Icons.image, size: 100)),
              ),
            const SizedBox(height: 16),
            Text(eventName,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(description),
            const SizedBox(height: 16),
            Text("Price: $price",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Event Dates: $formattedEventDateRange"),
            const SizedBox(height: 16),
            if (widget.eventData['location'] != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Event Location:",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  GestureDetector(
                    onTap: _openMap,
                    child: Text(
                      "View on Google Maps",
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              )
            else
              const Text(
                "Location data not available or is incorrectly formatted.",
                style: TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 16),
            if (availableDates.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Select Available Date:",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButton<String>(
                    value: selectedDate,
                    hint: const Text("Choose a date"),
                    isExpanded: true,
                    items: availableDates.map((date) {
                      final formattedDate = DateFormat('MMM dd, yyyy')
                          .format(DateTime.parse(date));
                      return DropdownMenuItem<String>(
                        value: date,
                        child: Text(formattedDate),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedDate = value;
                      });
                    },
                  ),
                ],
              ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: selectedDate != null ? _addToCart : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFF7043),
                  minimumSize: const Size(double.infinity, 50),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Buy Ticket",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
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

  String _formatEventDateRange(String eventDateRange) {
    try {
      final dates = eventDateRange.split(" - ");
      if (dates.length == 2) {
        final startDate = DateTime.parse(dates[0]);
        final endDate = DateTime.parse(dates[1]);
        return "${DateFormat('MMM dd, yyyy').format(startDate)} - ${DateFormat('MMM dd, yyyy').format(endDate)}";
      }
    } catch (e) {
      print("Error parsing date range: $e");
    }
    return eventDateRange; // Fallback to raw string if parsing fails
  }
}
