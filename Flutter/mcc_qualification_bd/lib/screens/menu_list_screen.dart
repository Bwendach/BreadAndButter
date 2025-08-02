import 'dart:io';

import 'package:bread_and_butter/apis/api.dart';
import 'package:bread_and_butter/screens/detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:bread_and_butter/models/menu_model.dart';
import 'package:bread_and_butter/utils/snack_bar.dart';
import 'package:image_picker/image_picker.dart';

class MenuListScreen extends StatefulWidget {
  final String userId;
  final String role;

  const MenuListScreen({super.key, required this.userId, required this.role});

  @override
  State<MenuListScreen> createState() => _MenuListScreenState();
}

class _MenuListScreenState extends State<MenuListScreen> {
  late Future<List<MenuModel>> menuList;

  @override
  void initState() {
    super.initState();
    menuList = getMenuList();
  }

  void _refreshMenuList() {
    setState(() {
      menuList = getMenuList();
    });
  }

  Future<void> _handleDelete(int menuId) async {
    try {
      await deleteMenuItem(menuId);
      _refreshMenuList();
      showSnackBar(context, 'Menu item deleted successfully!');
    } catch (e) {
      showSnackBar(context, 'Failed to delete menu item: $e');
    }
  }

  void _handleEdit(MenuModel menu) {
    final TextEditingController nameController = TextEditingController(
      text: menu.menuName,
    );
    final TextEditingController descriptionController = TextEditingController(
      text: menu.menuDescription,
    );
    final TextEditingController priceController = TextEditingController(
      text: menu.menuPrice.toString(),
    );
    File? selectedImage;
    final picker = ImagePicker();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateInDialog) {
            Future<void> _pickImage() async {
              final pickedFile = await picker.pickImage(
                source: ImageSource.gallery,
              );
              if (pickedFile != null) {
                setStateInDialog(() {
                  selectedImage = File(pickedFile.path);
                });
              }
            }

            Future<void> _updateItem() async {
              try {
                await updateMenuItem(
                  menuId: menu.menuId,
                  menuName: nameController.text,
                  menuDescription: descriptionController.text,
                  menuPrice: double.parse(priceController.text),
                  menuImage: selectedImage,
                );
                showSnackBar(context, 'Menu item updated successfully!');
                _refreshMenuList();
                Navigator.of(context).pop();
              } catch (e) {
                showSnackBar(context, 'Failed to update menu item: $e');
              }
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                'Edit Menu Item',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Menu Name',
                        prefixIcon: Icon(
                          Icons.restaurant,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        prefixIcon: Icon(
                          Icons.description,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: priceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Price',
                        prefixIcon: Icon(
                          Icons.attach_money,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        prefixText: '\$',
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                          width: 1,
                        ),
                      ),
                      child: selectedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.file(
                                selectedImage!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(
                                '$URLPATH/assets/${menu.menuImageUrl}',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Center(
                                      child: Icon(Icons.broken_image, size: 40),
                                    ),
                              ),
                            ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: Icon(
                        selectedImage == null ? Icons.edit : Icons.image,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                      label: Text(
                        'Change Image',
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
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: _updateItem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Save',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isAdmin = widget.role == 'admin';

    return FutureBuilder<List<MenuModel>>(
      future: menuList,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No menu items available'));
        }

        final data = snapshot.data!;

        return GridView.builder(
          padding: const EdgeInsets.all(16.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            childAspectRatio: 0.75,
          ),
          itemCount: data.length,
          itemBuilder: (context, index) {
            final currentMenu = data[index];
            final imageUrl = '$URLPATH/assets/${currentMenu.menuImageUrl}';

            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailScreen(menu: currentMenu),
                  ),
                );
              },
              child: Card(
                clipBehavior: Clip.antiAlias,
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16.0),
                        ),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Center(
                                child: Icon(Icons.broken_image, size: 40),
                              ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentMenu.menuName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '\$${currentMenu.menuPrice.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          if (isAdmin)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.edit,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                  iconSize: 20,
                                  onPressed: () => _handleEdit(currentMenu),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.delete,
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                  iconSize: 20,
                                  onPressed: () =>
                                      _handleDelete(currentMenu.menuId),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
