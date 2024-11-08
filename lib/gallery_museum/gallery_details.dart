import 'package:art_vibes1/screens/tickets/bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class GalleryDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> galleryData;

  const GalleryDetailsScreen({required this.galleryData, Key? key})
      : super(key: key);

  @override
  _GalleryDetailsScreenState createState() => _GalleryDetailsScreenState();
}

class _GalleryDetailsScreenState extends State<GalleryDetailsScreen> {
  // ignore: unused_field
  GoogleMapController? _mapController;
  LatLng? _location;
  String? selectedTime;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  void _initializeLocation() {
    final locationData = widget.galleryData['location'];
    if (locationData != null &&
        locationData['lat'] != null &&
        locationData['lng'] != null) {
      final lat = double.tryParse(locationData['lat'].toString());
      final lng = double.tryParse(locationData['lng'].toString());
      if (lat != null && lng != null) {
        setState(() {
          _location = LatLng(lat, lng);
        });
      } else {
        debugPrint('Invalid latitude or longitude data.');
      }
    } else {
      debugPrint('Location data not found or incomplete.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.galleryData;
    if (data.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('No Data'),
        ),
        body: const Center(
          child: Text('No details available.'),
        ),
      );
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120.0), // Adjusted app bar height
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: Container(
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
          flexibleSpace: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Adjusted alignment
            children: [
              Center(
                child: Image.asset(
                  'assets/images/Art_vibes_Logo.png',
                  height: 80, // Increased logo size to 80
                  errorBuilder: (context, error, stackTrace) {
                    return const Text('Logo not found');
                  },
                ),
              ),
              const SizedBox(height: 8.0), // Add space below the logo
            ],
          ),
          centerTitle: true,
        ),
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
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                final url = data['website'];
                if (url != null && await canLaunch(url)) {
                  await launch(url);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cannot open the website')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: const Text(
                'Visit Website',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              'Location: ${data['location']?['city'] ?? 'Unknown'}, Saudi Arabia',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Lat: ${data['location']?['lat'] ?? 'N/A'}, Lng: ${data['location']?['lng'] ?? 'N/A'}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16.0),
            _location != null
                ? Container(
                    height: 200,
                    width: double.infinity,
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: _location!,
                        zoom: 14.0,
                      ),
                      markers: {
                        Marker(
                          markerId: const MarkerId('eventLocation'),
                          position: _location!,
                        ),
                      },
                      onMapCreated: (GoogleMapController controller) {
                        _mapController = controller;
                      },
                    ),
                  )
                : const Text(
                    'Location data not available',
                    style: TextStyle(color: Colors.red),
                  ),
            const SizedBox(height: 16.0),
            const Text(
              'Working Hours:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ..._buildWorkingHours(data['workingHours']),
            const SizedBox(height: 16.0),
            const Text(
              'Available Appointments:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            DropdownButton<String>(
              hint: const Text('Select a time'),
              value: selectedTime,
              onChanged: (String? newValue) {
                setState(() {
                  selectedTime = newValue;
                });
              },
              items: _buildAppointmentItems(data['appointments']),
            ),
            if (selectedTime != null) ...[
              const SizedBox(height: 8.0),
              Text('Selected: $selectedTime'),
            ],
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                if (selectedTime != null) {
                  _showSuccessDialog();
                } else {
                  _showErrorDialog();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFF7043),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                'Buy Ticket',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 0, // Set index for Gallery Details screen
        onItemTapped: (index) {
          if (index == 0) {
            Navigator.pushNamed(context, '/home');
          } else if (index == 1) {
            Navigator.pushNamed(context, '/tickets');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/box');
          } else if (index == 3) {
            Navigator.pushNamed(context, '/profile');
          }
        },
      ),
    );
  }

  Widget buildImage(String imageUrl) {
    return Image.asset(
      imageUrl,
      height: 200,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return const Text('Image not found');
      },
    );
  }

  List<Widget> _buildWorkingHours(Map<String, dynamic>? workingHours) {
    if (workingHours == null) {
      return [const Text('No working hours available.')];
    }

    return workingHours.entries.map((entry) {
      return Text('${entry.key}: ${entry.value}');
    }).toList();
  }

  List<DropdownMenuItem<String>> _buildAppointmentItems(
      List<dynamic>? appointments) {
    if (appointments == null) return [];

    return appointments.map((appointment) {
      final time = appointment['time'];
      return DropdownMenuItem<String>(
        value: time,
        child: Text(time ?? 'No Time Available'),
      );
    }).toList();
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: Material(
            type: MaterialType.transparency,
            child: Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Success',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text('Ticket purchased for $selectedTime.'),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: Material(
            type: MaterialType.transparency,
            child: Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Error',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                      'Please select an appointment time before buying a ticket.'),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
