import 'package:flutter/material.dart';

class GalleryDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> galleryData;

  const GalleryDetailsScreen({required this.galleryData, Key? key})
      : super(key: key);

  @override
  _GalleryDetailsScreenState createState() => _GalleryDetailsScreenState();
}

class _GalleryDetailsScreenState extends State<GalleryDetailsScreen> {
  int _selectedIndex = 0; // Default to "Home" tab

  // Handle bottom navigation tap
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigation to respective pages
    if (index == 0) {
      // Stay on Home (GalleryListScreen)
      Navigator.pop(context); // Go back to GalleryListScreen
    } else if (index == 1) {
      // Navigate to Upcoming Page
      Navigator.pushNamed(
          context, '/upcoming'); // Assuming you have a named route
    } else if (index == 2) {
      // Placeholder for Box Page (if implemented)
    } else if (index == 3) {
      // Placeholder for Profile Page (if implemented)
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.galleryData;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8.0),
          decoration: const BoxDecoration(
            color: Colors.orange,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: const Text(
          'Gallery Details',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildImage(data['image'] ?? 'assets/images/placeholder.png'),
            const SizedBox(height: 16.0),
            Text(
              data['name'] ?? 'No Name',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Text(
              data['description'] ?? 'No Description Available',
              style: const TextStyle(fontSize: 16),
            ),
            // Add more content here...
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
            icon: Icon(Icons.inventory), // Box or inventory icon
            label: 'Box',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget buildImage(String imageUrl) {
    return Image.network(
      imageUrl,
      height: 200,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return const Text('Image not found');
      },
    );
  }
}
