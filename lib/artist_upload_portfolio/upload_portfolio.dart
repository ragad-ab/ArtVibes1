import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:art_vibes1/screens/tickets/bottom_navigation.dart';
import 'package:art_vibes1/screens/tickets/home_Screen.dart';
import 'package:art_vibes1/profile/profile_screen.dart';

class PortfolioUploadScreen extends StatefulWidget {
  const PortfolioUploadScreen({Key? key}) : super(key: key);

  @override
  _PortfolioUploadScreenState createState() => _PortfolioUploadScreenState();
}

class _PortfolioUploadScreenState extends State<PortfolioUploadScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<File> _portfolioFiles = [];
  bool _isUploading = false;
  String? _submissionStatus;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _checkPortfolioStatus();
  }

  Future<void> _checkPortfolioStatus() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    final querySnapshot = await _firestore
        .collection('portfolios')
        .where('artistId', isEqualTo: user.uid)
        .where('status', isEqualTo: 'pending')
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      setState(() {
        _submissionStatus = 'pending';
      });
    }
  }

  Future<void> _pickFile() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _portfolioFiles.add(File(pickedFile.path));
      });
    }
  }

  Future<void> _uploadPortfolio() async {
    if (_submissionStatus == 'pending') {
      _showAlreadySubmittedDialog();
      return;
    }

    setState(() => _isUploading = true);
    User? user = _auth.currentUser;

    if (user != null) {
      try {
        await _firestore.collection('portfolios').add({
          'artistId': user.uid,
          'artistName': user.displayName ?? 'Artist',
          'email': user.email,
          'files': _portfolioFiles.map((file) => file.path).toList(),
          'status': 'pending',
          'createdAt': FieldValue.serverTimestamp(),
        });

        setState(() {
          _submissionStatus = 'pending';
        });

        _showSubmissionSuccessDialog();
      } catch (e) {
        _showError('Upload failed: $e');
      }
    } else {
      _showError('No authenticated user. Please log in.');
    }

    setState(() => _isUploading = false);
  }

  void _showAlreadySubmittedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Submission Pending"),
          content:
              Text("You have already submitted. Please wait until approved."),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _showSubmissionSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Portfolio Submitted"),
          content: Text("Your portfolio has been submitted for approval."),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
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
          PortfolioUploadScreen(),
          ProfileScreen(),
        ][index],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFFF7043),
            ),
            padding: EdgeInsets.all(8.0),
            child: Icon(Icons.arrow_back, color: Colors.white),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Image.asset(
                'assets/images/Art_vibes_Logo.png',
                height: 100,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Upload Portfolio',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              _submissionStatus == 'pending'
                  ? 'Your portfolio is pending approval.'
                  : 'Please upload your portfolio files for admin approval.',
              style: TextStyle(color: Colors.grey, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _pickFile,
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _portfolioFiles.isEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cloud_upload,
                              color: Colors.grey, size: 40),
                          const SizedBox(height: 10),
                          Text('Choose a file or drag & drop it here',
                              style: TextStyle(color: Colors.grey)),
                          const SizedBox(height: 5),
                          Text('PDF or image files',
                              style: TextStyle(color: Colors.grey)),
                        ],
                      )
                    : ListView.builder(
                        itemCount: _portfolioFiles.length,
                        itemBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child:
                              Text(_portfolioFiles[index].path.split('/').last),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isUploading ? null : _uploadPortfolio,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF008080),
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isUploading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        _submissionStatus == 'pending'
                            ? 'Pending'
                            : 'Submit Portfolio',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
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
