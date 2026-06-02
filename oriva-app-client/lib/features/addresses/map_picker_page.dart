import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class MapPickerPage extends StatefulWidget {
  const MapPickerPage({super.key, this.initialLat, this.initialLng});

  final double? initialLat;
  final double? initialLng;

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  static const LatLng _ouaga = LatLng(12.3714, -1.5197);

  final MapController _mapController = MapController();
  late LatLng _center;
  bool _locating = false;

  @override
  void initState() {
    super.initState();
    _center = (widget.initialLat != null && widget.initialLng != null)
        ? LatLng(widget.initialLat!, widget.initialLng!)
        : _ouaga;
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _confirm() {
    Navigator.of(context).pop(_center);
  }

  Future<void> _useMyLocation() async {
    setState(() => _locating = true);
    try {
      final serviceOn = await Geolocator.isLocationServiceEnabled();
      if (!serviceOn) {
        _showMsg('Activez la localisation de votre téléphone.');
        return;
      }
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        _showMsg('Permission de localisation refusée.');
        return;
      }
      final pos = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      final here = LatLng(pos.latitude, pos.longitude);
      setState(() => _center = here);
      _mapController.move(here, 16);
    } catch (_) {
      _showMsg('Impossible d\'obtenir la position.');
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  void _showMsg(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080808),
      appBar: AppBar(
        backgroundColor: const Color(0xFF080808),
        foregroundColor: const Color(0xFFF5F0E8),
        title: const Text('Choisir la position'),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _center,
              initialZoom: 15,
              onPositionChanged: (camera, hasGesture) {
                _center = camera.center;
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.oriva.app',
              ),
            ],
          ),
          const Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 36),
              child: Icon(Icons.location_pin,
                  size: 48, color: Color(0xFFC9A96E)),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            top: 12,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF222222)),
              ),
              child: const Text(
                'Déplacez la carte pour placer le point sur votre adresse',
                style: TextStyle(color: Color(0xFFF5F0E8), fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Positioned(
            right: 16,
            top: 70,
            child: FloatingActionButton.small(
              backgroundColor: const Color(0xFFC9A96E),
              foregroundColor: const Color(0xFF080808),
              onPressed: _locating ? null : _useMyLocation,
              child: _locating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF080808),
                      ),
                    )
                  : const Icon(Icons.my_location),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 28,
            child: SizedBox(
              height: 52,
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC9A96E),
                  foregroundColor: const Color(0xFF080808),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _confirm,
                child: const Text(
                  'Confirmer cette position',
                  style:
                      TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
