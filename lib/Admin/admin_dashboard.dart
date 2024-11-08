import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
//this

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late Stream<QuerySnapshot> _pendingPortfoliosStream;

  @override
  void initState() {
    super.initState();
    _pendingPortfoliosStream = _firestore
        .collection('portfolios')
        .where('status', isEqualTo: 'pending')
        .snapshots();
  }

  void _viewPortfolioFile(String filePath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PortfolioViewerScreen(filePath: filePath),
      ),
    );
  }

  void _logOut(BuildContext context) async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(
        context, '/login'); // Adjust route if necessary
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
                color: Color(0xFF008080), // Blue color
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white, // White profile icon
                size: 24,
              ),
            ),
          ),
        ),
        title: Column(
          children: [
            const SizedBox(height: 40),
            Image.asset(
              'assets/images/Art_vibes_Logo.png',
              height: 80,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 8),
            const Text(
              "Pending Portfolios",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildSectionTitle('Pending Portfolios'),
            _buildPendingItemsList(_pendingPortfoliosStream),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildPendingItemsList(Stream<QuerySnapshot> stream) {
    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var data =
                snapshot.data!.docs[index].data() as Map<String, dynamic>;
            String artistName = data['artistName'] ?? 'Unnamed Artist';
            String email = data['email'] ?? 'No Email Provided';
            String portfolioId = snapshot.data!.docs[index].id;
            String artistId = data['artistId'];
            String filePath = data['files'][0];

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 5),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                title: Text(
                  artistName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('Email: $email'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: () =>
                          _updateStatus(portfolioId, artistId, 'approved'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                      ),
                      child: const Text("Approve"),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () =>
                          _updateStatus(portfolioId, artistId, 'rejected'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF7043),
                      ),
                      child: const Text("Reject"),
                    ),
                    IconButton(
                      icon: const Icon(Icons.open_in_new),
                      onPressed: () => _viewPortfolioFile(filePath),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _updateStatus(
      String portfolioId, String artistId, String status) async {
    await _firestore.collection('portfolios').doc(portfolioId).update({
      'status': status,
    });

    if (status == 'approved') {
      await _firestore.collection('users').doc(artistId).update({
        'role': 'artist',
      });
    }
  }
}

class PortfolioViewerScreen extends StatelessWidget {
  final String filePath;

  const PortfolioViewerScreen({required this.filePath, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120.0),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            "Portfolio File",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ),
      body: Center(
        child: Image.file(
          File(filePath),
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Text('Failed to load file: $filePath');
          },
        ),
      ),
    );
  }
}
