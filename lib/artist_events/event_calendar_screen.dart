import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:art_vibes1/screens/tickets/bottom_navigation.dart';
import 'package:art_vibes1/screens/tickets/home_Screen.dart';
import 'package:art_vibes1/profile/profile_screen.dart';
import 'package:art_vibes1/artist_events/artist_license.dart';
import 'package:art_vibes1/artist_events/event_creation.dart';
import 'package:art_vibes1/artist_events/events_detail_screen.dart';

class EventCalendarScreen extends StatefulWidget {
  final bool isArtist;

  EventCalendarScreen({required this.isArtist, required bool isArtistWithLicense});

  @override
  _EventCalendarScreenState createState() => _EventCalendarScreenState();
}

class _EventCalendarScreenState extends State<EventCalendarScreen> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  List<DocumentSnapshot> _allEvents = [];
  List<DocumentSnapshot> _filteredEvents = [];

  @override
  void initState() {
    super.initState();
    _fetchEvents();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _filteredEvents = _allEvents
          .where((event) => (event['eventName'] as String)
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()))
          .toList();
    });
  }

  Future<void> _fetchEvents() async {
    FirebaseFirestore.instance.collection('events').snapshots().listen((snapshot) {
      setState(() {
        _allEvents = snapshot.docs;
        _filteredEvents = _allEvents;
      });
    });
  }

  Future<bool> _checkLicenseStatus() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    DocumentSnapshot licenseDoc = await FirebaseFirestore.instance
        .collection('licenses')
        .doc(user.uid)
        .get();

    return licenseDoc.exists && licenseDoc['status'] == 'approved';
  }

  void _promptLicenseUpload(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LicenseUploadScreen()),
    );
  }

  void _navigateToEventCreation(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateEventScreen(isArtist: true)),
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
          const HomeScreen(),
          EventCalendarScreen(isArtist: widget.isArtist, isArtistWithLicense: true),
          const ProfileScreen(),
        ][index],
      ),
    );
  }

  Widget _buildEventImage(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return Container(
        height: 200,
        color: Colors.grey[300],
        child: const Center(child: Icon(Icons.image, size: 100)),
      );
    }

    if (Uri.parse(imagePath).isAbsolute) {
      return Image.network(
        imagePath,
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey[300],
          height: 200,
          child: const Center(child: Icon(Icons.broken_image, size: 100)),
        ),
      );
    } else {
      return Image.file(
        File(imagePath),
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey[300],
          height: 200,
          child: const Center(child: Icon(Icons.broken_image, size: 100)),
        ),
      );
    }
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
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Events Calendar",
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search events...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: _filteredEvents.isEmpty
                ? const Center(child: Text("No events available"))
                : ListView.builder(
                    itemCount: _filteredEvents.length,
                    itemBuilder: (context, index) {
                      final event = _filteredEvents[index];
                      final eventData = event.data() as Map<String, dynamic>;
                      final eventName = eventData['eventName'] ?? 'Unnamed Event';
                      final imagePath = eventData['image'];

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EventDetailsScreen(eventData: eventData, event: {}),
                            ),
                          );
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  topRight: Radius.circular(16),
                                ),
                                child: _buildEventImage(imagePath),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      eventName,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Container(
                                      height: 36,
                                      width: 36,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF008080),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.arrow_forward,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: widget.isArtist
          ? FutureBuilder<bool>(
              future: _checkLicenseStatus(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                final hasLicense = snapshot.data ?? false;
                return FloatingActionButton(
                  backgroundColor: const Color(0xFF008080),
                  child: const Icon(Icons.add, color: Colors.white),
                  onPressed: () {
                    if (hasLicense) {
                      _navigateToEventCreation(context);
                    } else {
                      _promptLicenseUpload(context);
                    }
                  },
                );
              },
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
