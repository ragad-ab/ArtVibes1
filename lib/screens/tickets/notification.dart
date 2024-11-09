import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:art_vibes1/profile/profile_screen.dart';
import 'package:art_vibes1/screens/tickets/bottom_navigation.dart';
import 'package:art_vibes1/screens/tickets/home_Screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _currentIndex = 0;

  void _deleteNotification(String docId) {
    _firestore.collection('notifications').doc(docId).delete();
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
          const NotificationScreen(),
          const ProfileScreen(),
        ][index],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final User? user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: Container(
          margin: const EdgeInsets.all(8.0),
          decoration: const BoxDecoration(
            color: Color(0xFFFF7043), // Orange background
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: Column(
          children: [
            const SizedBox(height: 50),
            Image.asset(
              'assets/images/Art_vibes_Logo.png',
              height: 80,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 50),
            const Text(
              'Notifications',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
      body: user == null
          ? const Center(child: Text("Please log in to view notifications."))
          : Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('notifications')
                    .where('userId', isEqualTo: user.uid)
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                        child: Text("No notifications available."));
                  }

                  final notifications = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      var notification = notifications[index];
                      var notificationData =
                          notification.data() as Map<String, dynamic>;

                      return Dismissible(
                        key: Key(notification.id),
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) {
                          _deleteNotification(notification.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Notification dismissed')),
                          );
                        },
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        child: ListTile(
                          title: Text(
                            notificationData['title'] ?? 'No Title',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          subtitle: Text(
                            notificationData['body'] ?? 'No Details',
                            style: const TextStyle(color: Colors.black54),
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Color(0xFFFF7043),
                            ),
                            onPressed: () {
                              _deleteNotification(notification.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Notification dismissed')),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
