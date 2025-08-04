import 'dart:convert';
import 'dart:io';
import 'package:mime/mime.dart';

import 'package:bread_and_butter/models/menu_model.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final String URLPATH = dotenv.env['URLPATH'] ?? 'http://10.0.2.2:3000';

// user apis (login, get user detail, get username)
Future<(bool, String, {String? userId})> login(
  String usernameOrEmail,
  String password,
) async {
  String url = "$URLPATH/api/users/login";

  var response = await post(
    Uri.parse(url),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"login": usernameOrEmail, "password": password}),
  );

  var data = json.decode(response.body);

  if (response.statusCode == 200) {
    String token = data['token'];
    String userId = data['userId'].toString();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", token);
    await prefs.setString("userId", userId);

    return (true, "Login successful!", userId: userId);
  } else {
    return (false, (data['error'] ?? "Login failed").toString(), userId: null);
  }
}

Future<String> getUsername(String userId) async {
  String url = "$URLPATH/api/users/username/$userId";

  var response = await get(Uri.parse(url));

  if (response.statusCode == 200) {
    var data = json.decode(response.body);
    return data['username'];
  } else {
    throw Exception("Failed to fetch username");
  }
}

Future<Map<String, dynamic>> getUser(String userId) async {
  String url = "$URLPATH/api/users/$userId";

  var response = await get(Uri.parse(url));

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception("Failed to fetch user details");
  }
}

// menu apis (get menu list, create, update, delete)
Future<List<MenuModel>> getMenuList() async {
  String url = "$URLPATH/api/menu";

  var response = await get(Uri.parse(url));

  if (response.statusCode == 200) {
    List<dynamic> data = json.decode(response.body);
    return data.map((item) => MenuModel.fromJson(item)).toList();
  } else {
    throw Exception("Failed to fetch menu list");
  }
}

// Function to create a new menu item
Future<void> createMenuItem({
  required String menuName,
  required String menuDescription,
  required double menuPrice,
  required File menuImage,
}) async {
  String url = "$URLPATH/api/menu/create";
  var request = http.MultipartRequest('POST', Uri.parse(url));

  request.fields['menuName'] = menuName;
  request.fields['menuDescription'] = menuDescription;
  request.fields['menuPrice'] = menuPrice.toString();

  String? mimeType = lookupMimeType(menuImage.path, headerBytes: [0xFF, 0xD8]);
  String filename = menuImage.path.split('/').last;

  if (mimeType != null) {
    request.files.add(
      http.MultipartFile(
        'menuImage',
        menuImage.readAsBytes().asStream(),
        menuImage.lengthSync(),
        filename: filename,
        contentType: MediaType.parse(mimeType),
      ),
    );
  } else {
    throw Exception('Could not determine image MIME type.');
  }

  var response = await request.send();

  if (response.statusCode != 200) {
    final responseBody = await response.stream.bytesToString();
    print('Error creating menu item: $responseBody');
    throw Exception(
      "Failed to create menu item. Status: ${response.statusCode}",
    );
  }
}

// Function to update an existing menu item
Future<void> updateMenuItem({
  required int menuId,
  required String menuName,
  required String menuDescription,
  required double menuPrice,
  File? menuImage,
}) async {
  String url = "$URLPATH/api/menu/update/$menuId";
  var request = http.MultipartRequest('PUT', Uri.parse(url));

  request.fields['menuName'] = menuName;
  request.fields['menuDescription'] = menuDescription;
  request.fields['menuPrice'] = menuPrice.toString();

  request.fields['shouldUpdateImage'] = (menuImage != null).toString();

  if (menuImage != null) {
    String? mimeType = lookupMimeType(
      menuImage.path,
      headerBytes: [0xFF, 0xD8],
    );
    String filename = menuImage.path.split('/').last;

    if (mimeType != null) {
      request.files.add(
        http.MultipartFile(
          'menuImage',
          menuImage.readAsBytes().asStream(),
          menuImage.lengthSync(),
          filename: filename,
          contentType: MediaType.parse(mimeType),
        ),
      );
    } else {
      throw Exception('Could not determine image MIME type.');
    }
  }

  var response = await request.send();

  if (response.statusCode != 200) {
    final responseBody = await response.stream.bytesToString();
    print('Error updating menu item: $responseBody');
    throw Exception(
      "Failed to update menu item. Status: ${response.statusCode}",
    );
  }
}

// Function to delete a menu item
Future<void> deleteMenuItem(int menuId) async {
  String url = "$URLPATH/api/menu/delete/$menuId";

  var response = await delete(Uri.parse(url));

  if (response.statusCode != 200) {
    throw Exception(
      "Failed to delete menu item. Status: ${response.statusCode}",
    );
  }
}

// Review apis (get reviews, create, update, delete)
Future<List<Map<String, dynamic>>> getReviews(int menuId) async {
  String url = "$URLPATH/api/reviews/menu/$menuId";

  var response = await get(Uri.parse(url));

  if (response.statusCode == 200) {
    return List<Map<String, dynamic>>.from(json.decode(response.body));
  } else {
    throw Exception("Failed to fetch reviews");
  }
}

// get user review for menu
Future<List<Map<String, dynamic>>> getUserReviewForMenu(
  int menuId,
  String userId,
) async {
  String url = "$URLPATH/api/reviews/menu/$menuId/user/$userId";

  var response = await get(Uri.parse(url));

  if (response.statusCode == 200) {
    return List<Map<String, dynamic>>.from(json.decode(response.body));
  } else {
    throw Exception("Failed to fetch user review for menu");
  }
}

Future<void> createReview({
  required int menuId,
  required String userId,
  required String reviewText,
  required double rating,
}) async {
  String url = "$URLPATH/api/reviews/create";

  var response = await post(
    Uri.parse(url),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "menuId": menuId,
      "userId": int.parse(userId),
      "reviewContent": reviewText,
      "reviewRating": rating.toInt(),
    }),
  );

  if (response.statusCode != 200) {
    final responseBody = response.body;
    print('Error creating review: $responseBody');
    throw Exception("Failed to create review: $responseBody");
  }
}

Future<void> updateReview({
  required int reviewId,
  required String reviewText,
  required double rating,
}) async {
  String url = "$URLPATH/api/reviews/update/$reviewId";

  var response = await put(
    Uri.parse(url),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "reviewContent": reviewText,
      "reviewRating": rating.toInt(),
    }),
  );

  if (response.statusCode != 200) {
    final responseBody = response.body;
    print('Error updating review: $responseBody');
    throw Exception("Failed to update review: $responseBody");
  }
}

Future<void> deleteReview(int reviewId) async {
  String url = "$URLPATH/api/reviews/delete/$reviewId";

  var response = await delete(Uri.parse(url));

  if (response.statusCode != 200) {
    final responseBody = response.body;
    print('Error deleting review: $responseBody');
    throw Exception("Failed to delete review: $responseBody");
  }
}
