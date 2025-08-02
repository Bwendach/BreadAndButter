import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    List<String> imgList = [
      'https://preview.milingona.co/themes/bakery/shop/wp-content/uploads/2017/12/img-13.jpg',
      'https://www.shutterstock.com/image-photo/outside-view-bakery-glass-showcase-600nw-2207207873.jpg',
      'https://img.freepik.com/premium-photo/bakery-interior-with-clean-bright-aesthetic-photo_960396-976191.jpg',
      'https://plus.unsplash.com/premium_photo-1665669263531-cdcbe18e7fe4?fm=jpg&q=60&w=3000&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8YmFrZXJ5fGVufDB8fDB8fHww',
    ];

    return Center(
      child: CarouselSlider(
        items: imgList.map((e) {
          return Image.network(e, fit: BoxFit.cover);
        }).toList(),
        options: CarouselOptions(
          autoPlay: true,
          enlargeCenterPage: true,
          autoPlayInterval: const Duration(seconds: 2),
        ),
      ),
    );
  }
}
