import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'appointment_details.dart';

class UpcomingPage extends StatefulWidget {
  @override
  _UpcomingPageState createState() => _UpcomingPageState();
}

class _UpcomingPageState extends State<UpcomingPage> {
  int _selectedIndex = 1; // Default to the "Tickets" tab (index 1)

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Add navigation logic here if you want to switch to different pages
    switch (index) {
      case 0:
        // Navigate to Home Page (Add Navigation)
        break;
      case 1:
        // Stay on Tickets Page (Do nothing, we are already here)
        break;
      case 2:
        // Navigate to Box Page (Add Navigation)
        break;
      case 3:
        // Navigate to Profile Page (Add Navigation)
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Two tabs: History and Upcoming
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/Art_vibes_Logo.png', // Adjust logo size here
                height: 60, // Make the logo bigger
              ),
            ],
          ),
          backgroundColor: Colors.white,
          bottom: TabBar(
            labelColor:
                Color(0xFFFF7043), // Orange label color for the selected tab
            indicatorColor: Color(0xFFFF7043), // Orange underline
            unselectedLabelColor: Colors.grey, // Color for unselected tab
            tabs: [
              Tab(text: "History"),
              Tab(text: "Upcoming"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            HistoryPage(), // Page for History events
            UpcomingEventsPage(), // Page for Upcoming events
          ],
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
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.black, // Set black for the selected icon
          unselectedItemColor: Colors.grey, // Grey for unselected icons
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}

class HistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('tickets')
          .where('status', isEqualTo: 'Past') // Filter for past events
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No past events found.'));
        }

        final events = snapshot.data!.docs;

        return ListView.builder(
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index].data() as Map<String, dynamic>;
            return EventCard(event: event);
          },
        );
      },
    );
  }
}

class UpcomingEventsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('tickets')
          .where('status', isEqualTo: 'Upcoming') // Filter for upcoming events
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No upcoming events found.'));
        }

        final events = snapshot.data!.docs;

        return ListView.builder(
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index].data() as Map<String, dynamic>;
            return EventCard(event: event);
          },
        );
      },
    );
  }
}

class EventCard extends StatelessWidget {
  final Map<String, dynamic> event;

  EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    DateTime dateTime = (event['date'] as Timestamp).toDate();
    String formattedDate = DateFormat('dd/MM/yyyy, h:mm a').format(dateTime);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 3,
      margin: EdgeInsets.symmetric(
          vertical: 15, horizontal: 16), // Add more space between cards
      child: ListTile(
        contentPadding: EdgeInsets.all(10.0), // Increase the padding
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(
            event['image'], // Local asset path for the image
            width: 70,
            height: 70,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(
          event['title'],
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Date: $formattedDate'),
        trailing: Container(
          padding: EdgeInsets.all(6.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF008080), // Teal color for the arrow background
          ),
          child: Icon(
            Icons.arrow_forward,
            color: Colors.white,
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AppointmentDetails(eventData: event),
            ),
          );
        },
      ),
    );
  }
}
