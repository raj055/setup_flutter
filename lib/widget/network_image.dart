import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class PNetworkImage extends StatelessWidget {
  final String? image;
  final BoxFit? fit, errorFit;
  final double? width, height, errorWidth, errorHeight;

  const PNetworkImage(
    this.image, {
    Key? key,
    this.fit,
    this.height,
    this.width,
    this.errorWidth,
    this.errorHeight,
    this.errorFit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: image!,
      placeholder: (context, url) => Center(child: CircularProgressIndicator()),
      errorWidget: (context, url, error) => Image.asset(
        'assets/images/placeholder.png',
        fit: errorFit ?? BoxFit.cover,
        width: errorWidth ?? 100,
        height: errorHeight ?? 100,
      ),
      fit: fit,
      width: width ?? 100,
      height: height ?? 100,
    );
  }
}
