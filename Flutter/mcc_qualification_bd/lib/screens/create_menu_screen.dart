import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:bread_and_butter/apis/api.dart';
import 'package:bread_and_butter/utils/snack_bar.dart';

class CreateMenuScreen extends StatefulWidget {
  const CreateMenuScreen({super.key});

  @override
  State<CreateMenuScreen> createState() => _CreateMenuScreenState();
}

class _CreateMenuScreenState extends State<CreateMenuScreen> {
  final _menuNameController = TextEditingController();
  final _menuDescriptionController = TextEditingController();
  final _menuPriceController = TextEditingController();
  File? _selectedImage;
  bool _isLoading = false;

  final _picker = ImagePicker();

  @override
  void dispose() {
    _menuNameController.dispose();
    _menuDescriptionController.dispose();
    _menuPriceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitMenu() async {
    if (_menuNameController.text.isEmpty ||
        _menuDescriptionController.text.isEmpty ||
        _menuPriceController.text.isEmpty ||
        _selectedImage == null) {
      showSnackBar(context, 'Please fill in all fields and select an image.');
      return;
    }

    final price = double.tryParse(_menuPriceController.text);
    if (price == null) {
      showSnackBar(context, 'Please enter a valid price.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await createMenuItem(
        menuName: _menuNameController.text,
        menuDescription: _menuDescriptionController.text,
        menuPrice: price,
        menuImage: _selectedImage!,
      );

      showSnackBar(context, 'Menu item created successfully!');

      _menuNameController.clear();
      _menuDescriptionController.clear();
      _menuPriceController.clear();
      setState(() {
        _selectedImage = null;
      });
    } catch (e) {
      showSnackBar(context, 'Failed to create menu item: $e');
    } finally {
      setState(() {
        _isLoading = false; 
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Create a New Menu Item',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8C5E58),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Menu Name Field
            TextField(
              controller: _menuNameController,
              decoration: InputDecoration(
                labelText: 'Menu Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
            const SizedBox(height: 16),

            // Menu Description Field
            TextField(
              controller: _menuDescriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Menu Price Field
            TextField(
              controller: _menuPriceController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'Price',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
            const SizedBox(height: 24),

            // Image Preview and Pick Button
            Center(
              child: _selectedImage == null
                  ? const Text('No image selected.')
                  : Image.file(_selectedImage!, height: 150, fit: BoxFit.cover),
            ),
            const SizedBox(height: 16),

            // Pick Image Button
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: const Text('Pick Image'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB47B84),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            ElevatedButton(
              onPressed: _isLoading ? null : _submitMenu,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8C5E58),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Create Menu Item',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
