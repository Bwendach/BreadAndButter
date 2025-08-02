import 'package:flutter/material.dart';

void navigate(BuildContext context, Widget page, bool back) {
  MaterialPageRoute materialPageRoute = MaterialPageRoute(
    builder: (context) {
      return page;
    },
  );

  back == true
      ? Navigator.push(context, materialPageRoute)
      : Navigator.pushAndRemoveUntil(
          context, materialPageRoute, (route) => false);
}
