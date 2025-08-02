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
              title: const Text('Edit Menu Item'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Menu Name'),
                    ),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                    ),
                    TextField(
                      controller: priceController,
                      decoration: const InputDecoration(labelText: 'Price'),
                    ),
                    const SizedBox(height: 16),
                    selectedImage != null
                        ? Image.file(selectedImage!, height: 100)
                        : Image.network(
                            '$URLPATH/assets/${menu.menuImageUrl}',
                            height: 100,
                          ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _pickImage,
                      child: const Text('Change Image'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: _updateItem,
                  child: const Text('Save'),
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

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          child: const Text(
            "Our Menu",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<MenuModel>>(
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
                  final imageUrl =
                      '$URLPATH/assets/${currentMenu.menuImageUrl}';

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
                      elevation: 3,
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
                            padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  currentMenu.menuName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '\$${currentMenu.menuPrice.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                if (isAdmin) ...[
                                  const SizedBox(height: 1),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Colors.blue,
                                        ),
                                        iconSize: 18,
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        onPressed: () =>
                                            _handleEdit(currentMenu),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        iconSize: 18,
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        onPressed: () =>
                                            _handleDelete(currentMenu.menuId),
                                      ),
                                    ],
                                  ),
                                ],
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
          ),
        ),
      ],
    );
  }
}
