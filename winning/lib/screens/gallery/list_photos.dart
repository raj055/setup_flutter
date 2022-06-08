import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart' hide Response;
import 'package:optimized_cached_image/widgets.dart';

import '../../services/translator.dart';

class GalleryMorePhotos extends StatefulWidget {
  @override
  _GalleryMorePhotosState createState() => _GalleryMorePhotosState();
}

class _GalleryMorePhotosState extends State<GalleryMorePhotos> {
  List<StaggeredTile> _staggeredTiles = [];
  List? imgUrls = [];
  int? id;

  @override
  void initState() {
    super.initState();
    imgUrls = Get.arguments;
    print('IMAGE URL $imgUrls');
    // id = Get.arguments;
    galleryList();
  }

  Future galleryList() async {
    for (int i = 0; i <= imgUrls!.length; i++) {
      if (i % 8 == 0) {
        _staggeredTiles.add(StaggeredTile.count(2, 2));
      } else {
        _staggeredTiles.add(StaggeredTile.count(1, 1));
      }
    }
    return _staggeredTiles;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text(Translator.get('Gallery Photos')!)),
      body: StaggeredGridView.countBuilder(
        padding: const EdgeInsets.all(8.0),
        crossAxisCount: 3,
        itemCount: imgUrls!.length,
        itemBuilder: (BuildContext context, index) => GestureDetector(
          onTap: () {
            Get.toNamed(
              'photo-zoom',
              arguments: {
                'url': imgUrls![index],
              },
            );
          },
          child: Platform.isAndroid
              ? OptimizedCacheImage(
                  imageUrl: imgUrls![index],
                  imageBuilder: (context, imageProvider) => Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  placeholder: (context, url) => Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => Image.asset(
                    'assets/images/placeholder.png',
                  ),
                )
              : CachedNetworkImage(
                  imageUrl: imgUrls![index],
                  imageBuilder: (context, imageProvider) => Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  placeholder: (context, url) => Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => Image.asset(
                    'assets/images/placeholder.png',
                  ),
                ),
        ),
        staggeredTileBuilder: (index) => _staggeredTiles[index],
        mainAxisSpacing: 8.0,
        crossAxisSpacing: 8.0,
      ),
    );
  }
}
