import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ImageViewPage extends StatelessWidget {
  final String imageUrl;

  const ImageViewPage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Container(height: MediaQuery.of(context).size.height * 1,
        child: Hero(
          tag: imageUrl,
          child: InteractiveViewer(
            child: Image.network(
              imageUrl,
            ),
          ),
        ),
      ),

    );
  }
}
