import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../config/typography.dart';
import '../../../.const.dart';
import '../../../utils/distance_calculator.dart';
import '../../../utils/location_handler.dart';

class MapWidget extends StatefulWidget {
  final List<LatLng>? waypoints;
  final List<List<double>>? geometry;
  final LatLng? startCoords;
  final LatLng? endCoords;
  final bool isCreatingRoute;

  const MapWidget({
    Key? key,
    this.waypoints,
    this.geometry,
    this.startCoords,
    this.endCoords,
    this.isCreatingRoute = false,
  }) : super(key: key);

  @override
  _MapWidgetState createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  final MapController mapController = MapController();
  final mapUrlTemplate =
      "https://api.mapbox.com/styles/v1/mapbox/navigation-day-v1/tiles/{z}/{x}/{y}?access_token=$MAPBOX_API_KEY";
  Position? _currentPosition;
  bool _permissionGranted = false;
  LatLng? _centerCoords;
  double _initialZoom = 13.0;


  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
    _centerMapToCoords(widget.startCoords, widget.endCoords);
  }


  @override
  void didUpdateWidget(MapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _centerMapToCoords(widget.startCoords, widget.endCoords);
  }

  Future<bool> _checkLocationPermission() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool permissionGranted = prefs.getBool('location_permission') ?? false;
    if (!permissionGranted) {
      permissionGranted = await requestLocationPermission();
      prefs.setBool('location_permission', permissionGranted);
    }
    setState(() {
      _permissionGranted = permissionGranted;
    });
    if (permissionGranted) {
      _getCurrentLocation();
    }
    return permissionGranted;
  }

  Future<void> _getCurrentLocation() async {
    try {
      var currentPosition = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = currentPosition;
      });
    } catch (e) {
      setState(() {
        _permissionGranted = false;
      });
    }
  }

  void _centerMapToCoords(LatLng? startCoords, LatLng? endCoords) {
    if (startCoords == null && endCoords == null) {
      return;
    }

    if (startCoords != null && endCoords != null) {
      double distance = calculateDistance(startCoords, endCoords);
      _initialZoom = _calculateZoomLevel(distance);

      _centerCoords = LatLng(
        (startCoords.latitude + endCoords.latitude) / 2,
        (startCoords.longitude + endCoords.longitude) / 2,
      );
    } else {
      _centerCoords = startCoords ?? endCoords!;
    }

    if (_centerCoords != null) {
      setState(() {});
    }
  }

  void _centerMap() {
    if (_currentPosition != null) {
      mapController.move(
        LatLng(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        ),
        15.0,
      );
    }
  }

  double _calculateZoomLevel(double distance) {
    if (distance < 100) {
      return 18.0;
    } else if (distance < 200) {
      return 17.0;
    } else if (distance < 500) {
      return 16.0;
    } else if (distance < 1000) {
      return 15.0;
    } else if (distance < 2000) {
      return 14.0;
    } else if (distance < 5000) {
      return 13.0;
    } else if (distance < 10000) {
      return 12.0;
    } else if (distance < 20000) {
      return 11.0;
    } else {
      return 10.0;
    }
  }

  Future<MapController> _loadMapData() async {
    final Completer<MapController> completer = Completer<MapController>();

    Future<void> loadMapDataInIsolate(MapController mapController) async {
      await Future.delayed(Duration(seconds: 2)); // Simulate loading delay
      completer.complete(mapController);
    }

    return mapController;
  }

  @override
  Widget build(BuildContext context) {
    print(widget.waypoints != null);
    return FutureBuilder<MapController>(
      future: _loadMapData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading map data: ${snapshot.error}',
              textAlign: TextAlign.center,
              style: AppTypography(context: context).bodyText,
            ),
          );
        } else {
          MapController mapController = snapshot.data!;
          return _permissionGranted
              ? Stack(
                  children: [
                    FlutterMap(
                      mapController: mapController,
                      options: MapOptions(
                        keepAlive: true,
                        initialCenter: _centerCoords ??
                            LatLng(_currentPosition?.latitude ?? 0,
                                _currentPosition?.longitude ?? 0),
                        initialZoom: _initialZoom,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: mapUrlTemplate,
                          additionalOptions: const {
                            'accessToken': MAPBOX_API_KEY,
                            'id': 'mapbox.mapbox-streets-v12'
                          },
                          tileProvider: CancellableNetworkTileProvider(),
                        ),
                        if (widget.geometry != null &&
                            widget.geometry!.isNotEmpty)
                          PolylineLayer(
                            polylines: [
                              Polyline(
                                points: widget.geometry!
                                    .map((list) => LatLng(list[0], list[1]))
                                    .toList(),
                                color: Colors.blue,
                                strokeWidth: 4,
                              ),
                            ],
                          ),

                        // Current Location layer

                        StreamBuilder<Position>(
                          stream: Geolocator.getPositionStream(),
                          builder: (context, positionSnapshot) {
                            if (!positionSnapshot.hasData) {
                              return const SizedBox.shrink();
                            }
                            final position = positionSnapshot.data!;
                            return CircleLayer(
                              circles: [
                                CircleMarker(
                                  point: LatLng(
                                    position.latitude,
                                    position.longitude,
                                  ),
                                  radius: 12,
                                  color: Colors.blue.withOpacity(0.2),
                                  borderStrokeWidth: 2,
                                  borderColor: Colors.blue.withOpacity(0.4),
                                ),
                                CircleMarker(
                                  point: LatLng(
                                    position.latitude,
                                    position.longitude,
                                  ),
                                  radius: 8,
                                  color: Colors.blue.withOpacity(0.8),
                                  borderStrokeWidth: 2,
                                  borderColor: Colors.blue,
                                ),
                              ],
                            );
                          },
                        ),
                        MarkerLayer(
                          markers: [
                            if (widget.startCoords != null)
                              Marker(
                                width: 40.0,
                                height: 40.0,
                                point: widget.startCoords!,
                                child: const Icon(
                                  Icons.location_pin,
                                  color: Colors.blue,
                                  size: 40.0,
                                ),
                              ),
                            if (widget.endCoords != null)
                              Marker(
                                width: 40.0,
                                height: 40.0,
                                point: widget.endCoords!,
                                child: const Icon(
                                  Icons.location_pin,
                                  color: Colors.red,
                                  size: 40.0,
                                ),
                              ),
                            if (widget.waypoints != null)
                              ...widget.waypoints!.asMap().entries.map((entry) {
                                final int index = entry.key;
                                final LatLng waypoint = entry.value;

                                return Marker(
                                  width: 40.0,
                                  height: 40.0,
                                  point: waypoint,
                                  child: Icon(
                                    Icons.location_pin,
                                    color: index == 0
                                        ? Colors.yellow
                                        : Colors.green,
                                    size: 40.0,
                                  ),
                                );
                              }),
                          ],
                        ),
                      ],
                    ),
                    widget.isCreatingRoute
                        ? Positioned(
                            bottom: 64,
                            right: 16,
                            child: Material(
                              elevation: 8,
                              borderRadius: BorderRadius.circular(90),
                              child: IconButton(
                                onPressed: _centerMap,
                                style: IconButton.styleFrom(
                                  padding: const EdgeInsets.all(16),
                                ),
                                icon: const Icon(
                                  Icons.my_location,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          )
                        : Positioned(
                            top: 8,
                            right: 16,
                            child: Material(
                              elevation: 8,
                              borderRadius: BorderRadius.circular(90),
                              child: IconButton(
                                onPressed: _centerMap,
                                style: IconButton.styleFrom(
                                  padding: const EdgeInsets.all(16),
                                ),
                                icon: const Icon(
                                  Icons.my_location,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ),
                  ],
                )
              : Center(
                  child: Text(
                    'Location access is required for this app to function properly. Please grant the location permission.',
                    textAlign: TextAlign.center,
                    style: AppTypography(context: context).bodyText,
                  ),
                );
        }
      },
    );
  }
}
