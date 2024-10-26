import 'dart:io';

import 'package:flutter/material.dart';
import 'package:let_us_chat/widgets/app_bar_with_title_arrow.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class CustomPhotoGallery extends StatefulWidget {
  final List<String> imagePathList;
  final int initialIndex; //起始页面
  const CustomPhotoGallery(
      {super.key, required this.imagePathList, required this.initialIndex});

  @override
  State<CustomPhotoGallery> createState() => _CustomPhotoGalleryState();
}

class _CustomPhotoGalleryState extends State<CustomPhotoGallery> {
  late final List<String> _imagePathList;
  late int _initialIndex;
  late int _currentIndex;
  late int _imageCount;
  late PageController _pageController;
  @override
  void initState() {
    super.initState();
    _imagePathList = widget.imagePathList;
    _initialIndex = widget.initialIndex;
    _currentIndex = _initialIndex;
    _imageCount = _imagePathList.length;
    _pageController = PageController(initialPage: _initialIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWithTitleAndArrow(
        title: "${_currentIndex + 1}/$_imageCount",
        centerTitle: true,
      ),
      body: Stack(children: [
        PhotoViewGallery.builder(
          scrollPhysics: const BouncingScrollPhysics(),
          onPageChanged: (int index) {
            setState(() {
              _currentIndex = index;
            });
          },
          pageController: _pageController,
          itemCount: _imagePathList.length,
          builder: (BuildContext context, int index) {
            File file = File(_imagePathList[index]);
            return PhotoViewGalleryPageOptions(
                imageProvider: FileImage(file),
                initialScale: PhotoViewComputedScale.contained,
                minScale: PhotoViewComputedScale.contained);
          },
        ),
        Positioned(
            bottom: 20,
            left: 10,
            right: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  iconSize: 50,
                  onPressed: () {
                    print("点击了上一张图片");
                    if (_currentIndex > 0) {
                      _pageController.previousPage(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeIn);
                    }
                  },
                  icon: const Icon(Icons.arrow_circle_left_outlined),
                ),
                IconButton(
                  iconSize: 50,
                  onPressed: () {
                    print("点击了下一张图片");
                    if (_currentIndex + 1 < _imageCount) {
                      _pageController.nextPage(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeIn);
                    }
                  },
                  icon: const Icon(Icons.arrow_circle_right_outlined),
                )
              ],
            ))
      ]),
    );
  }
}
