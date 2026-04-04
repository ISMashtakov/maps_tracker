import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class TrackerMapView extends StatefulWidget {
  const TrackerMapView({super.key});

  @override
  State<TrackerMapView> createState() => _TrackerMapViewState();
}

class _TrackerMapViewState extends State<TrackerMapView> {
  final MapController _mapController = MapController();
  LatLng? _userPosition;
  StreamSubscription<Position>? _positionStream;

  @override
  void initState() {
    super.initState();
    _startLocationTracking();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  Future<void> _startLocationTracking() async {
    final permissionStatus = await Permission.location.request();

    if (permissionStatus == PermissionStatus.granted) {
      final position = await Geolocator.getCurrentPosition();

      setState(() {
        _userPosition = LatLng(position.latitude, position.longitude);
      });

      _mapController.move(_userPosition!, 15.0);

      _positionStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      ).listen((position) {
        setState(() {
          _userPosition = LatLng(position.latitude, position.longitude);
        });
      });
    }
  }

  void _centerOnUser() {
    if (_userPosition != null) {
      _mapController.move(_userPosition!, 15.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _userPosition ?? const LatLng(55.7558, 37.6173),
              initialZoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.maps_tracker',
              ),
              if (_userPosition != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _userPosition!,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40.0,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          Positioned(
            bottom: 24,
            right: 24,
            child: FloatingActionButton(
              onPressed: _centerOnUser,
              backgroundColor: Colors.white,
              child: const Icon(Icons.my_location, color: Colors.deepPurple),
            ),
          ),
        ],
      ),
    );
  }
}
