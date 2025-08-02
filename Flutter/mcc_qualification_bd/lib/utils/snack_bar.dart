import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, String content) {
  final SnackBar snackBar = SnackBar(
    content: Text(content),
    duration: const Duration(seconds: 3),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
