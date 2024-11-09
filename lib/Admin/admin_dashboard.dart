import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:art_vibes1/signup/login/Auth_Screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late Stream<QuerySnapshot> _pendingPortfoliosStream;
  late Stream<QuerySnapshot> _pendingLicensesStream;

  @override
  void initState() {
    super.initState();
    _pendingPortfoliosStream = _firestore
        .collection('portfolios')
        .where('status', isEqualTo: 'pending')
        .snapshots();
    _pendingLicensesStream = _firestore
        .collection('licenses')
        .where('status', isEqualTo: 'pending')
        .snapshots();
  }

  void _viewFile(String fileUrl, String type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FileViewerScreen(fileUrl: fileUrl, type: type),
      ),
    );
  }

  void _logOut(BuildContext context) async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => AuthScreen()),
    );
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
        title: Column(
          children: [
            const SizedBox(height: 20),
            Image.asset(
              'assets/images/Art_vibes_Logo.png',
              height: 60,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 8),
            const Text(
              "Admin Dashboard",
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
            _buildPendingItemsList(_pendingPortfoliosStream, 'portfolio'),
            const SizedBox(height: 20),
            _buildSectionTitle('Pending Licenses'),
            _buildPendingItemsList(_pendingLicensesStream, 'license'),
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

  Widget _buildPendingItemsList(Stream<QuerySnapshot> stream, String type) {
    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final documents = snapshot.data!.docs;
        if (documents.isEmpty) {
          return const Center(child: Text("No pending items."));
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: documents.length,
          itemBuilder: (context, index) {
            var data = documents[index].data() as Map<String, dynamic>;
            String artistName = data['artistName'] ?? 'Unnamed Artist';
            String email = data['email'] ?? 'No Email Provided';
            String itemId = documents[index].id;
            String artistId = data['artistId'];
            String? fileUrl = data['fileUrl']; // URL from Firebase Storage

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              elevation: 3,
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
                          _updateStatus(itemId, artistId, 'approved', type),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text("Approve",
                          style: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () =>
                          _updateStatus(itemId, artistId, 'rejected', type),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF7043),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text("Reject",
                          style: TextStyle(color: Colors.white)),
                    ),
                    if (fileUrl != null)
                      IconButton(
                        icon: const Icon(Icons.open_in_new),
                        color: Colors.blueAccent,
                        onPressed: () => _viewFile(fileUrl, type),
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
      String itemId, String artistId, String status, String type) async {
    String collectionName = type == 'portfolio' ? 'portfolios' : 'licenses';
    await _firestore.collection(collectionName).doc(itemId).update({
      'status': status,
    });

    if (type == 'portfolio' && status == 'approved') {
      await _firestore.collection('users').doc(artistId).update({
        'role': 'artist',
      });
    }
  }
}

class FileViewerScreen extends StatelessWidget {
  final String fileUrl;
  final String type;

  const FileViewerScreen({required this.fileUrl, required this.type, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100.0),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              Container(
                margin: const EdgeInsets.all(8.0),
                decoration: const BoxDecoration(
                  color: Color(0xFFFF7043),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const Spacer(),
              Text(
                type == 'portfolio' ? "Portfolio File" : "License File",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
      body: Center(
        child: Image.network(
          fileUrl,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const Text('Failed to load image from URL');
          },
        ),
      ),
    );
  }
}
