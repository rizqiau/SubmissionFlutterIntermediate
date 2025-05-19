import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AddStoryProvider extends ChangeNotifier {
  File? imageFile;
  String description = '';
  double? lat;
  double? lon;

  void setImage(File file) {
    imageFile = file;
    notifyListeners();
  }

  void setDescription(String desc) {
    description = desc;
    notifyListeners();
  }

  void setLocation(LatLng location) {
    lat = location.latitude;
    lon = location.longitude;
    notifyListeners();
  }

  void reset() {
    imageFile = null;
    description = '';
    lat = null;
    lon = null;
    notifyListeners();
  }
}
