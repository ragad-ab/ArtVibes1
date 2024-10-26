library art_vibes_default; // Change this to something else

import 'package:firebase_data_connect/firebase_data_connect.dart';
// ignore: unused_import
import 'dart:convert';

class DefaultConnector {
  // Configuration for Firebase Data Connect
  static ConnectorConfig connectorConfig = ConnectorConfig(
    'us-central1', // Firebase region
    'default', // Dataset name
    'art_vibes1', // Project ID
  );

  // Define the Firebase Data Connect instance
  FirebaseDataConnect dataConnect;

  // Constructor with required FirebaseDataConnect instance
  DefaultConnector({required this.dataConnect});

  // Singleton pattern to return an instance of DefaultConnector
  static DefaultConnector get instance {
    return DefaultConnector(
      dataConnect: FirebaseDataConnect.instanceFor(
        connectorConfig: connectorConfig,
        sdkType: CallerSDKType.generated, // Caller SDK Type
      ),
    );
  }
}
