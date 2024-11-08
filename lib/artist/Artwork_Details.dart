import 'package:art_vibes1/screens/tickets/bottom_navigation.dart';
import 'package:flutter/material.dart';

class ArtworkDetailScreen extends StatefulWidget {
  final Map<String, dynamic> artwork;
  final String artistName;

  const ArtworkDetailScreen({
    Key? key,
    required this.artwork,
    required this.artistName,
  }) : super(key: key);

  @override
  _ArtworkDetailScreenState createState() => _ArtworkDetailScreenState();
}

class _ArtworkDetailScreenState extends State<ArtworkDetailScreen> {
  int _currentIndex = 0; // Default index set to Home

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    // Handle navigation based on the index
    if (index == 0) {
      Navigator.pushNamed(context, '/home');
    } else if (index == 1) {
      Navigator.pushNamed(context, '/tickets');
    } else if (index == 2) {
      Navigator.pushNamed(context, '/box');
    } else if (index == 3) {
      Navigator.pushNamed(context, '/profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.artwork['title']),
        backgroundColor: const Color(0xFF008080), // Teal color
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Image.network(
                widget.artwork['imageUrl'],
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.broken_image, size: 50),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              widget.artwork['title'],
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF008080), // Teal color
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Artist: ${widget.artistName}',
              style: const TextStyle(color: Color(0xFF008080)), // Teal color
            ),
            const SizedBox(height: 8.0),
            Text(
              'Price: ${widget.artwork['price']} SAR',
              style: const TextStyle(color: Color(0xFFFF7043)), // Orange color
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF7043), // Orange color
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                // Add to cart logic here
              },
              child: const Text(
                'Add To Cart',
                style: TextStyle(color: Colors.white),
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
}
