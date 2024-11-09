import 'package:art_vibes1/artist_events/EventDetialView.dart';
import 'package:art_vibes1/screens/tickets/Cart_Screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:art_vibes1/screens/tickets/bottom_navigation.dart';
import 'package:art_vibes1/screens/tickets/home_Screen.dart';
import 'package:art_vibes1/profile/profile_screen.dart';

class TicketsScreen extends StatefulWidget {
  @override
  _TicketsScreenState createState() => _TicketsScreenState();
}

class _TicketsScreenState extends State<TicketsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final currentDate = DateTime.now();
  int _currentIndex = 1; // Default to Tickets tab in the bottom navigation

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatDate(String date) {
    final eventDate = DateTime.parse(date);
    return DateFormat('d/M/yyyy').format(eventDate);
  }

  String _formatTime(String date) {
    final eventDate = DateTime.parse(date);
    return DateFormat('h:mm a').format(eventDate);
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
          TicketsScreen(),
          CartScreen(),
          ProfileScreen(),
        ][index],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final upcomingTickets = CartScreen.ticketList.where((ticket) {
      final eventDate = DateTime.parse(ticket['selectedDate'] ?? ticket['eventDateRange'].split(" - ")[0]);
      return eventDate.isAfter(currentDate);
    }).toList();

    final historyTickets = CartScreen.ticketList.where((ticket) {
      final eventDate = DateTime.parse(ticket['selectedDate'] ?? ticket['eventDateRange'].split(" - ")[0]);
      return eventDate.isBefore(currentDate);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: Container(
          margin: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Color(0xFFFF7043), // Orange background
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white), // White arrow
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: Image.asset(
          'assets/images/Art_vibes_Logo.png', // Make sure this path is correct
          height: 80,
          fit: BoxFit.contain,
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Color(0xFFFF7043), // Orange color
          tabs: const [
            Tab(text: "History"),
            Tab(text: "Upcoming"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTicketList(historyTickets, "No history tickets."),
          _buildTicketList(upcomingTickets, "No upcoming tickets."),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  Widget _buildTicketList(List<Map<String, dynamic>> tickets, String emptyMessage) {
    return tickets.isNotEmpty
        ? ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              final ticket = tickets[index];
              final date = _formatDate(ticket['selectedDate'] ?? ticket['eventDateRange']);
              final time = _formatTime(ticket['selectedDate'] ?? ticket['eventDateRange']);
              final eventName = ticket['eventName'] ?? 'Unnamed Event';

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(8.0),
                  title: Text(
                    eventName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold, // Make the event title bold
                    ),
                  ),
                  subtitle: Text("Date & Time: $date $time\nLocation: View on Google Maps"),
                  trailing: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(0xFF008080), // Orange background
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_forward_ios, color: Colors.white), // White arrow
                  ),
                  onTap: () {
                    // Navigate to event details screen with full details of the event
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EventDetailsViewScreen(eventData: ticket, event: {},),
                      ),
                    );
                  },
                ),
              );
            },
          )
        : Center(child: Text(emptyMessage));
  }
}
