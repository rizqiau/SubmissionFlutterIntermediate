import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';

import '../provider/story_provider.dart';
import '../db/auth_repository.dart';

class StoryDetailScreen extends StatefulWidget {
  final String storyId;

  const StoryDetailScreen({Key? key, required this.storyId}) : super(key: key);

  @override
  State<StoryDetailScreen> createState() => _StoryDetailScreenState();
}

class _StoryDetailScreenState extends State<StoryDetailScreen> {
  late GoogleMapController mapController;
  String? _address;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    final token = await context.read<AuthRepository>().getToken();
    if (token != null) {
      await context.read<StoryProvider>().loadStoryDetail(
        token,
        widget.storyId,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final storyProvider = context.watch<StoryProvider>();
    final story = storyProvider.selectedStory;

    final LatLng? storyLocation =
        (story != null && story.lat != null && story.lon != null)
            ? LatLng(story.lat!, story.lon!)
            : null;

    if (storyProvider.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Cerita'), centerTitle: true),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (storyProvider.errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Cerita'), centerTitle: true),
        body: Center(child: Text(storyProvider.errorMessage!)),
      );
    }

    if (story == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Cerita'), centerTitle: true),
        body: const Center(child: Text('Cerita tidak ditemukan')),
      );
    }

    // Jika sudah pasti story tidak null, aman akses properti story
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Cerita'), centerTitle: true),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    story.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Image.network(
                    story.photoUrl,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(height: 16),
                  Text(story.description, style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
            if (storyLocation != null) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Lokasi Cerita',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: 200,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: storyLocation,
                    zoom: 14,
                  ),
                  markers: {
                    Marker(
                      markerId: const MarkerId('storyLocation'),
                      position: storyLocation,
                      infoWindow: InfoWindow(
                        title: 'Lokasi Cerita',
                        snippet: _address,
                      ),
                    ),
                  },
                  onMapCreated: (controller) async {
                    mapController = controller;
                    await _getAddress(storyLocation);
                  },
                ),
              ),
              if (_address != null)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Alamat: $_address',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _getAddress(LatLng position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      final place = placemarks.first;
      setState(() {
        _address = [
          place.street,
          place.subLocality,
          place.locality,
          place.postalCode,
        ].where((element) => element != null && element.isNotEmpty).join(', ');
      });
    } catch (e) {
      setState(() {
        _address = 'Tidak dapat menemukan alamat';
      });
    }
  }
}
