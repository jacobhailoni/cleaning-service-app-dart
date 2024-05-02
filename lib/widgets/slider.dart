import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

final List<String> imageList = ['assets/1.png', 'assets/2.png', 'assets/3.png'];

final List<Widget> imageSliders = imageList
    .map(
      (item) => Container(
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(10.0)),
          child: Stack(
            children: <Widget>[
              Image.asset(item, fit: BoxFit.cover, width: 1000.0),
              // Positioned(
              //   bottom: 0.0,
              //   left: 0.0,
              //   right: 0.0,
              //   child: Container(
              //     decoration: const BoxDecoration(
              //       gradient: LinearGradient(
              //         colors: [
              //           Color.fromARGB(200, 0, 0, 0),
              //           Color.fromARGB(0, 0, 0, 0)
              //         ],
              //         begin: Alignment.bottomCenter,
              //         end: Alignment.topCenter,
              //       ),
              //     ),
              //     padding: const EdgeInsets.symmetric(
              //         vertical: 10.0, horizontal: 20.0),
              //     child: Text(
              //       'No. ${imageList.indexOf(item)} image',
              //       style: const TextStyle(
              //         color: Colors.white,
              //         fontSize: 20.0,
              //         fontWeight: FontWeight.bold,
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    )
    .toList();

class ImageSlider extends StatelessWidget {
  ImageSlider({super.key});
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        autoPlay: true,
        aspectRatio: 12 / 7,
        enlargeCenterPage: true,
      ),
      items: imageSliders,
    );
  }
}
