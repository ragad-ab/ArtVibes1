import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:art_vibes1/screens/tickets/home_Screen.dart';
import 'package:art_vibes1/profile/profile_screen.dart';
import 'package:art_vibes1/screens/tickets/bottom_navigation.dart';

class LicenseUploadScreen extends StatefulWidget {
  const LicenseUploadScreen({Key? key}) : super(key: key);

  @override
  _LicenseUploadScreenState createState() => _LicenseUploadScreenState();
}

class _LicenseUploadScreenState extends State<LicenseUploadScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  File? _selectedFile;
  bool _isUploading = false;
  String? _submissionStatus;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _checkLicenseStatus();
  }

  Future<void> _checkLicenseStatus() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    final querySnapshot = await _firestore
        .collection('licenses')
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
        _selectedFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadLicense() async {
    if (_submissionStatus == 'pending') {
      _showAlreadySubmittedDialog();
      return;
    }

    setState(() => _isUploading = true);
    User? user = _auth.currentUser;

    if (user != null && _selectedFile != null) {
      try {
        // Upload file to Firebase Storage
        String fileName =
            'licenses/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.png';
        UploadTask uploadTask = _storage.ref(fileName).putFile(_selectedFile!);
        TaskSnapshot snapshot = await uploadTask;
        String downloadUrl = await snapshot.ref.getDownloadURL();

        // Store the file URL in Firestore with a status of "pending"
        await _firestore.collection('licenses').doc(user.uid).set({
          'artistId': user.uid,
          'artistName': user.displayName ?? 'Artist',
          'email': user.email,
          'fileUrl': downloadUrl,
          'status': 'pending',
          'timestamp': FieldValue.serverTimestamp(),
        });

        setState(() {
          _submissionStatus = 'pending';
        });

        _showSubmissionSuccessDialog();
      } catch (e) {
        _showError('Upload failed: $e');
      }
    } else {
      _showError('Please select a file to upload.');
    }

    setState(() => _isUploading = false);
  }

  void _showAlreadySubmittedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Submission Pending"),
          content: const Text(
              "You have already submitted. Please wait until approved."),
          actions: [
            TextButton(
              child: const Text("OK"),
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
          title: const Text("License Submitted"),
          content:
              const Text("Your license has been submitted for admin approval."),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Return to the previous screen
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
          const HomeScreen(),
          const LicenseUploadScreen(),
          const ProfileScreen(),
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
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFFF7043),
            ),
            padding: const EdgeInsets.all(8.0),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Image.asset(
          'assets/images/Art_vibes_Logo.png',
          height: 80,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Upload License',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              _submissionStatus == 'pending'
                  ? 'Your license is pending approval.'
                  : 'Please upload your license file for admin approval.',
              style: const TextStyle(color: Colors.grey, fontSize: 16),
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
                child: _selectedFile == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.cloud_upload,
                              color: Colors.grey, size: 40),
                          SizedBox(height: 10),
                          Text('Choose a file or drag & drop it here',
                              style: TextStyle(color: Colors.grey)),
                          SizedBox(height: 5),
                          Text('PDF or image files',
                              style: TextStyle(color: Colors.grey)),
                        ],
                      )
                    : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          _selectedFile!.path.split('/').last,
                          style: const TextStyle(color: Colors.black87),
                          textAlign: TextAlign.center,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isUploading ? null : _uploadLicense,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF008080),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isUploading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        _submissionStatus == 'pending'
                            ? 'Pending'
                            : 'Submit License',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 18),
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
