import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class BannerPic extends StatelessWidget {
  const BannerPic({
    Key? key,
    required this.size, required this.imgList,
  }) : super(key: key);

  final Size size;
  final List<String> imgList;

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(left: 20, right: 20),
        height: size.height,
        child: CarouselSlider(
          options: CarouselOptions(
              height: size.height,
              viewportFraction: 1.0,
              enlargeCenterPage: false,
              autoPlay: true),
          items: imgList
              .map((item) => Container(
                    child: Center(
                        child: Image.asset(
                      item,
                      fit: BoxFit.fitHeight,
                      height: size.height*0.9,
                    )),
                  ))
              .toList(),
        ));
  }
}
