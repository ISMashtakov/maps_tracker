import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/adventure.dart';

const String _defaultStageName = 'Этап';
const String _hideButtonText = 'Скрыть';
const String _showButtonText = 'Показать';

class TrackerMapView extends StatefulWidget {
  final Adventure? adventure;

  const TrackerMapView({super.key, this.adventure});

  @override
  State<TrackerMapView> createState() => _TrackerMapViewState();
}

class _TrackerMapViewState extends State<TrackerMapView> {
  final MapController _mapController = MapController();
  LatLng? _userPosition;
  StreamSubscription<Position>? _positionStream;
  bool _isTaskVisible = true;

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

      if (widget.adventure != null && widget.adventure!.stages.isNotEmpty) {
        final firstStage = widget.adventure!.stages.first;
        final targetPosition = LatLng(firstStage.targetLat, firstStage.targetLng);
        _mapController.move(targetPosition, 15.0);
      } else {
        _mapController.move(_userPosition!, 15.0);
      }

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

  void _toggleTaskVisibility() {
    setState(() {
      _isTaskVisible = !_isTaskVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentStage = widget.adventure?.stages.isNotEmpty == true
        ? widget.adventure!.stages.first
        : null;

    final stageName = currentStage?.name ?? _defaultStageName;
    final taskMessage = currentStage?.type == 'text' ? currentStage?.params.message : null;

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
              if (currentStage != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(currentStage.targetLat, currentStage.targetLng),
                      child: const Icon(
                        Icons.flag,
                        color: Colors.blue,
                        size: 40.0,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4.0,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    stageName,
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (taskMessage != null) ...[
                    const SizedBox(height: 8.0),
                    AnimatedCrossFade(
                      firstChild: const SizedBox.shrink(),
                      secondChild: Text(
                        taskMessage,
                        style: const TextStyle(fontSize: 14.0),
                      ),
                      crossFadeState: _isTaskVisible
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 300),
                    ),
                    const SizedBox(height: 8.0),
                    TextButton(
                      onPressed: _toggleTaskVisibility,
                      child: Text(_isTaskVisible ? _hideButtonText : _showButtonText),
                    ),
                  ],
                ],
              ),
            ),
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