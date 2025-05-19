import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:story_app/provider/add_story_provider.dart';
import 'package:story_app/routes/route_delegate.dart';
import '../provider/story_provider.dart';
import '../db/auth_repository.dart';

class AddStoryScreen extends StatefulWidget {
  @override
  State<AddStoryScreen> createState() => _AddStoryScreenState();
}

class _AddStoryScreenState extends State<AddStoryScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descController;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final addStoryProvider = context.read<AddStoryProvider>();
    _descController = TextEditingController(text: addStoryProvider.description);
    _descController.addListener(() {
      addStoryProvider.setDescription(_descController.text);
    });
  }

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
    );
    if (pickedFile != null) {
      context.read<AddStoryProvider>().setImage(File(pickedFile.path));
    }
  }

  Future<void> _submit() async {
    final addStoryProvider = context.read<AddStoryProvider>();

    if (!_formKey.currentState!.validate() ||
        addStoryProvider.imageFile == null) {
      setState(() {
        _errorMessage = 'Lengkapi form dan pilih gambar';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final token = await context.read<AuthRepository>().getToken();
    if (token == null) {
      setState(() {
        _isSubmitting = false;
        _errorMessage = 'Token tidak ditemukan, silakan login ulang';
      });
      return;
    }

    final storyProvider = context.read<StoryProvider>();
    final success = await storyProvider.addStory(
      token: token,
      description: addStoryProvider.description,
      photo: addStoryProvider.imageFile!,
      lat: addStoryProvider.lat,
      lon: addStoryProvider.lon,
    );

    setState(() {
      _isSubmitting = false;
    });

    if (success) {
      if (token != null) {
        await storyProvider.refreshStories(token);
      }
      addStoryProvider.reset();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Cerita berhasil ditambahkan')));
      context.read<RouteState>().goToHome();
    } else {
      setState(() {
        _errorMessage =
            storyProvider.errorMessage ?? 'Gagal menambahkan cerita';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final addStoryProvider = context.watch<AddStoryProvider>();
    final routeState = context.read<RouteState>();

    return Scaffold(
      appBar: AppBar(title: Text('Tambah Cerita')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              addStoryProvider.imageFile == null
                  ? Container(
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        'Belum ada gambar dipilih',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  )
                  : ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      addStoryProvider.imageFile!,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
              const SizedBox(height: 12),
              TextButton.icon(
                icon: Icon(Icons.photo),
                label: Text('Pilih Gambar'),
                onPressed: _pickImage,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descController,
                decoration: InputDecoration(
                  labelText: 'Deskripsi singkat',
                  border: OutlineInputBorder(),
                ),
                validator:
                    (val) =>
                        val != null && val.isNotEmpty
                            ? null
                            : 'Deskripsi wajib diisi',
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              Text(
                addStoryProvider.lat != null && addStoryProvider.lon != null
                    ? 'Lokasi terpilih: (${addStoryProvider.lat}, ${addStoryProvider.lon})'
                    : 'Belum memilih lokasi',
                style: TextStyle(fontSize: 16),
              ),
              TextButton.icon(
                icon: Icon(Icons.location_on),
                label: Text('Pilih Lokasi'),
                onPressed: () {
                  routeState.goToLocationPicker(
                    initialLocation:
                        addStoryProvider.lat != null &&
                                addStoryProvider.lon != null
                            ? LatLng(
                              addStoryProvider.lat!,
                              addStoryProvider.lon!,
                            )
                            : null,
                  );
                },
              ),
              const SizedBox(height: 20),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              _isSubmitting
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                    onPressed: _submit,
                    child: Text('Tambah Cerita'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      textStyle: TextStyle(fontSize: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
