import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

void main() {
  runApp(const MapsTrackerApp());
}

class MapsTrackerApp extends StatelessWidget {
  const MapsTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Maps Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const TrackerMapView(),
    );
  }
}

class TrackerMapView extends StatefulWidget {
  const TrackerMapView({super.key});

  @override
  State<TrackerMapView> createState() => _TrackerMapViewState();
}

class _TrackerMapViewState extends State<TrackerMapView> {
  final MapController _mapController = MapController();
  LatLng _userPosition = const LatLng(55.7558, 37.6173);
  bool _isLocationReady = false;

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  void _loadLocation() {
    setState(() {
      _userPosition = const LatLng(55.7558, 37.6173);
      _isLocationReady = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _userPosition,
          initialZoom: 13.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.maps_tracker',
          ),
          if (_isLocationReady)
            MarkerLayer(
              markers: [
                Marker(
                  point: _userPosition,
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
    );
  }
}
