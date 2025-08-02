import 'package:flutter/material.dart';

void showConfirmationDialog(Function funcYes, String text, context) {
  Widget cancelButton = TextButton(
    child: const Text(
      "No",
      style: TextStyle(
        color: Colors.black,
      ),
    ),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );

  Widget continueButton = TextButton(
    child: const Text(
      "Yes",
      style: TextStyle(
        color: Colors.black,
      ),
    ),
    onPressed: () {
      funcYes();
      Navigator.of(context).pop();
    },
  );

  AlertDialog alert = AlertDialog(
    title: const Text("Confirmation"),
    content: Text(text),
    actions: [
      cancelButton,
      continueButton,
    ],
  );

  showDialog(
    context: context,
    builder: (context) {
      return alert;
    },
  );
}
