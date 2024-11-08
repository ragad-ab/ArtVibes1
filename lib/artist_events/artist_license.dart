import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LicenseUploadScreen extends StatefulWidget {
  @override
  _LicenseUploadScreenState createState() => _LicenseUploadScreenState();
}

class _LicenseUploadScreenState extends State<LicenseUploadScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isUploading = false;

  Future<void> _uploadLicense() async {
    setState(() => _isUploading = true);

    try {
      User? user = _auth.currentUser;

      if (user != null) {
        await _firestore.collection('licenses').doc(user.uid).set({
          'artistName': user.displayName ?? "Unnamed Artist",
          'status': 'pending',
          'timestamp': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('License uploaded. Waiting for approval.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading license: $e')),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload License')),
      body: Center(
        child: _isUploading
            ? CircularProgressIndicator()
            : ElevatedButton(
                onPressed: _uploadLicense,
                child: const Text('Upload License'),
              ),
      ),
    );
  }
}
