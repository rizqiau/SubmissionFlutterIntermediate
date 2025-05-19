import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:story_app/routes/route_delegate.dart';
import '../provider/story_provider.dart';
import '../db/auth_repository.dart';

class AddStoryScreen extends StatefulWidget {
  @override
  State<AddStoryScreen> createState() => _AddStoryScreenState();
}

class _AddStoryScreenState extends State<AddStoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descController = TextEditingController();
  File? _imageFile;
  bool _isSubmitting = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _imageFile == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lengkapi form dan pilih gambar')));
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final token = await context.read<AuthRepository>().getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Token tidak ditemukan, silakan login ulang')),
      );
      setState(() {
        _isSubmitting = false;
      });
      return;
    }

    final storyProvider = context.read<StoryProvider>();
    final success = await storyProvider.addStory(
      token: token,
      description: _descController.text,
      photo: _imageFile!,
    );

    setState(() {
      _isSubmitting = false;
    });

    if (success) {
      final token = await context.read<AuthRepository>().getToken();
      if (token != null) {
        await context.read<StoryProvider>().loadStories(token);
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Cerita berhasil ditambahkan')));
      context.read<RouteState>().goToHome();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            storyProvider.errorMessage ?? 'Gagal menambahkan cerita',
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tambah Cerita')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _imageFile == null
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
                      _imageFile!,
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
              const SizedBox(height: 20),
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
