// Internal smoke-test widget — NOT connected to app routing or navigation.
//
// Purpose: verify the Google Maps SDK renders map tiles after API key setup.
// Usage:   push this widget manually from a debug build; remove or leave as
//          a dev tool — it is never reachable by end users.
//
// This widget intentionally has no markers, no location access, no discovery
// behavior, and no connection to Firestore or any user data.

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapSmokeTest extends StatelessWidget {
  const GoogleMapSmokeTest({super.key});

  // Neutral camera — mid-Atlantic, zoom 1. No real user location used.
  static const CameraPosition _initialCamera = CameraPosition(
    target: LatLng(0, 0),
    zoom: 1,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map SDK Smoke Test'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: const GoogleMap(
        initialCameraPosition: _initialCamera,
        myLocationEnabled: false,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
      ),
    );
  }
}
