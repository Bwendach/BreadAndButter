import 'package:bread_and_butter/utils/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:bread_and_butter/apis/api.dart';

class CreateMenuScreen extends StatefulWidget {
  const CreateMenuScreen({super.key});

  @override
  State<CreateMenuScreen> createState() => _CreateMenuScreenState();
}

class _CreateMenuScreenState extends State<CreateMenuScreen> {
  final _formKey = GlobalKey<FormState>();
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
    if (!_formKey.currentState!.validate() || _selectedImage == null) {
      showSnackBar(context, 'Please fill in all fields and select an image.');
      return;
    }

    final price = double.tryParse(_menuPriceController.text);
    if (price == null || price <= 0) {
      showSnackBar(context, 'Please enter a valid price.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await createMenuItem(
        menuName: _menuNameController.text.trim(),
        menuDescription: _menuDescriptionController.text.trim(),
        menuPrice: price,
        menuImage: _selectedImage!,
      );

      showSnackBar(context, 'Menu item created successfully!');

      _formKey.currentState!.reset();
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
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Add New Menu Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _menuNameController,
                decoration: InputDecoration(
                  labelText: 'Menu Name',
                  hintText: 'e.g., Chocolate Croissant',
                  prefixIcon: Icon(
                    Icons.restaurant,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Menu name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _menuDescriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  hintText: 'Describe your delicious creation...',
                  prefixIcon: Icon(
                    Icons.description,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Description is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _menuPriceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: 'Price',
                  hintText: '0.00',
                  prefixIcon: Icon(
                    Icons.attach_money,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  prefixText: '\$',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Price is required';
                  }
                  final price = double.tryParse(value);
                  if (price == null || price <= 0) {
                    return 'Please enter a valid price';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Image Preview and Pick Button
              _selectedImage == null
                  ? Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate,
                            size: 48,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.5),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No image selected',
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                          Text(
                            'Tap the button below to add an image',
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(
                        _selectedImage!,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
              const SizedBox(height: 16),

              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: Icon(
                  _selectedImage == null ? Icons.image : Icons.edit,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                label: Text(
                  _selectedImage == null ? 'Select Image' : 'Change Image',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _isLoading ? null : _submitMenu,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor: Theme.of(context).colorScheme.onSecondary,
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
      ),
    );
  }
}
