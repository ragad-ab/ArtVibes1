import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Import your screens
import 'package:art_vibes1/artist/Artist_List_Screen.dart';
import 'package:art_vibes1/artist_events/event_calendar_screen.dart';
import 'package:art_vibes1/artist_events/artist_license.dart';
import 'package:art_vibes1/gallery_museum/gallery_list.dart';
import 'package:art_vibes1/profile/profile_screen.dart';
import 'package:art_vibes1/screens/tickets/bottom_navigation.dart';
import 'package:art_vibes1/screens/tickets/notification.dart';
import 'package:art_vibes1/screens/tickets/ticket.dart';
import 'package:art_vibes1/signup/login/Auth_Screen.dart';
import 'package:art_vibes1/tracking/tracking_screen.dart';
import 'package:art_vibes1/artist_upload_portfolio/upload_portfolio.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  int _currentIndex = 0;
  // ignore: unused_field
  String? _userName;
  // ignore: unused_field
  int _unreadNotificationCount = 0;

  final List<Widget> _screens = [
    const HomeContent(),
    TicketsScreen(),
    const TrackingScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _initializeFCM();
    _fetchUserName();
    _fetchUnreadNotificationsCount();
  }

  Future<void> _initializeFCM() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showLocalNotification(
        message.notification?.title,
        message.notification?.body,
      );
      if (_auth.currentUser != null) {
        _saveNotificationToFirestore(message);
      }
    });
  }

  Future<void> _showLocalNotification(String? title, String? body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  Future<void> _saveNotificationToFirestore(RemoteMessage message) async {
    final String? messageId = message.messageId;

    if (messageId != null && _auth.currentUser != null) {
      final existingNotification = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: _auth.currentUser!.uid)
          .where('messageId', isEqualTo: messageId)
          .get();

      if (existingNotification.docs.isEmpty) {
        await _firestore.collection('notifications').add({
          'userId': _auth.currentUser!.uid,
          'title': message.notification?.title,
          'body': message.notification?.body,
          'timestamp': FieldValue.serverTimestamp(),
          'status': 'unread',
          'messageId': messageId,
        });
      }
    }
  }

  void _fetchUnreadNotificationsCount() {
    _firestore
        .collection('notifications')
        .where('userId', isEqualTo: _auth.currentUser?.uid)
        .where('status', isEqualTo: 'unread')
        .snapshots()
        .listen((snapshot) {
      setState(() {
        _unreadNotificationCount = snapshot.docs.length;
      });
    });
  }

  Future<void> _fetchUserName() async {
    User? user = _auth.currentUser;
    if (user != null) {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          _userName = userDoc.data()?['name'] ?? 'User';
        });
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({Key? key}) : super(key: key);

  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _userName;
  bool _isArtist = false;

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  Future<void> _fetchUserInfo() async {
    User? user = _auth.currentUser;
    if (user != null) {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          _userName = userDoc.data()?['name'] ?? 'User';
          _isArtist = userDoc.data()?['role'] == 'artist';
        });
      }
    }
  }

  Future<void> _checkLicenseAndNavigate(BuildContext context) async {
    final user = _auth.currentUser;
    if (user == null) return;

    DocumentSnapshot licenseDoc =
        await _firestore.collection('licenses').doc(user.uid).get();

    if (licenseDoc.exists && licenseDoc['status'] == 'approved') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EventCalendarScreen(
            isArtist: true,
            isArtistWithLicense: true,
          ),
        ),
      );
    } else if (_isArtist) {
      // Only direct artists to LicenseUploadScreen if they lack an approved license
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LicenseUploadScreen()),
      );
    } else {
      // Redirect clients directly to EventCalendarScreen without license check
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EventCalendarScreen(
            isArtist: false,
            isArtistWithLicense: false,
          ),
        ),
      );
    }
  }

  void _logOut(BuildContext context) async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => AuthScreen()),
    );
  }

  void _openNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NotificationScreen()),
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
          centerTitle: true,
          leading: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'Logout') _logOut(context);
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem<String>(
                  value: 'Logout',
                  child: Text('Log Out'),
                ),
              ],
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFF008080),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
          flexibleSpace: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Image.asset(
                  'assets/images/Art_vibes_Logo.png',
                  height: 80,
                  errorBuilder: (context, error, stackTrace) {
                    return const Text('Logo not found');
                  },
                ),
              ),
              const SizedBox(height: 4.0),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('notifications')
                    .where('userId', isEqualTo: _auth.currentUser?.uid)
                    .where('status', isEqualTo: 'unread')
                    .snapshots(),
                builder: (context, snapshot) {
                  int unreadCount =
                      snapshot.hasData ? snapshot.data!.docs.length : 0;

                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications,
                            color: Colors.black, size: 28),
                        onPressed: _openNotifications,
                      ),
                      if (unreadCount > 0)
                        Positioned(
                          right: 0,
                          top: -2,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFF7043),
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 20,
                              minHeight: 20,
                            ),
                            child: Center(
                              child: Text(
                                '$unreadCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, ${_userName ?? "User"}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8.0),
            const Text(
              'What Do You Want To Do Today?',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 24.0),
            if (!_isArtist)
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PortfolioUploadScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF7043),
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.upgrade, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Become an Artist',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24.0),
            Expanded(
              child: ListView(
                children: [
                  _buildSectionCard(
                    context,
                    'Events Calendar',
                    'assets/images/image14.png',
                    () => _checkLicenseAndNavigate(context),
                  ),
                  _buildSectionCard(
                    context,
                    'Galleries and Museums',
                    'assets/images/image15.png',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const GalleryListScreen(),
                        ),
                      );
                    },
                  ),
                  _buildSectionCard(
                    context,
                    'Artwork Marketplace',
                    'assets/images/image16.png',
                    () {},
                  ),
                  _buildSectionCard(
                    context,
                    'Communities',
                    'assets/images/image17.png',
                    () {},
                  ),
                  _buildSectionCard(
                    context,
                    'Artists',
                    'assets/images/image18.png',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ArtistListScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(BuildContext context, String title, String imagePath,
      VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.4),
              BlendMode.darken,
            ),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
