import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:story_app/routes/route_delegate.dart';
import '../provider/add_story_provider.dart';

class LocationPickerScreen extends StatefulWidget {
  final LatLng? initialLocation;

  const LocationPickerScreen({Key? key, this.initialLocation})
    : super(key: key);

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  LatLng? _pickedLocation;

  @override
  void initState() {
    super.initState();
    _pickedLocation = widget.initialLocation;
  }

  void _onTap(LatLng position) {
    setState(() {
      _pickedLocation = position;
    });
  }

  void _onConfirm() {
    if (_pickedLocation != null) {
      context.read<AddStoryProvider>().setLocation(_pickedLocation!);
      context.read<RouteState>().goBack();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Pilih lokasi terlebih dahulu')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final initialCameraPosition = CameraPosition(
      target:
          _pickedLocation ?? LatLng(-6.200000, 106.816666), // Default Jakarta
      zoom: 14,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Pilih Lokasi'),
        actions: [IconButton(icon: Icon(Icons.check), onPressed: _onConfirm)],
      ),
      body: GoogleMap(
        initialCameraPosition: initialCameraPosition,
        onTap: _onTap,
        markers:
            _pickedLocation == null
                ? {}
                : {
                  Marker(
                    markerId: MarkerId('picked-location'),
                    position: _pickedLocation!,
                  ),
                },
      ),
    );
  }
}
