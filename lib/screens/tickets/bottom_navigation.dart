import 'package:art_vibes1/profile/profile_screen.dart';
import 'package:art_vibes1/screens/tickets/ticket.dart';
import 'package:art_vibes1/tracking/tracking_screen.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart'; 

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onItemTapped;

  const CustomBottomNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        if (index == 0) {
          // Navigate to Home screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } else if (index == 1) {
          // Navigate to UpcomingPage
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) =>  TicketsScreen()),
          );
        } else if (index == 2) {
          // Navigate to TrackingScreen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const TrackingScreen()),
          );
        } else if (index == 3) {
          // Navigate to ProfileScreen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ProfileScreen()),
          );
        }
      },
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.confirmation_num_outlined),
          activeIcon: Icon(Icons.confirmation_num),
          label: 'Tickets',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.inventory_2_outlined),
          activeIcon: Icon(Icons.inventory_2),
          label: 'Box',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}
