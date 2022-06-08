import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class PNetworkImage extends StatelessWidget {
  final String? image;
  final BoxFit? fit;
  final double? width, height, errorWidth, errorHeight;

  const PNetworkImage(
    this.image, {
    Key? key,
    this.fit,
    this.height,
    this.width,
    this.errorWidth,
    this.errorHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: image!,
      placeholder: (context, url) => Center(child: CircularProgressIndicator()),
      errorWidget: (context, url, error) => Image.asset(
        'assets/images/placeholder.png',
        fit: BoxFit.cover,
        width: errorWidth,
        height: errorHeight,
      ),
      fit: fit,
      width: width,
      height: height,
    );
  }
}
