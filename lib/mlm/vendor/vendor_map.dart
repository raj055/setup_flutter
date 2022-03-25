import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:unicons/unicons.dart';

import '../../../../services/api.dart';
import '../../../../services/size_config.dart';
import '../../../../widget/network_image.dart';
import '../../../../widget/theme.dart';

class NearMeStore extends StatefulWidget {
  const NearMeStore({Key? key}) : super(key: key);

  @override
  _NearMeStoreState createState() => _NearMeStoreState();
}

class _NearMeStoreState extends State<NearMeStore> {
  Iterable markers = [];
  Map? currentlySelectedPin;

  late BitmapDescriptor sourceIcon;
  late BitmapDescriptor customIcon1;

  void setSourceAndDestinationIcons() async {
    sourceIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(devicePixelRatio: 2.5),
      'assets/images/destination_map_marker.png',
    );
  }

  void setCustomIcons() async {
    customIcon1 = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(devicePixelRatio: 2.5),
      'assets/images/location.png',
    );
  }

  setUpMarkers(mapData) {
    Iterable _markers = Iterable.generate(mapData.length + 1, (index) {
      if (index == mapData.length) {
        return Marker(
          markerId: MarkerId('0'),
          onTap: () {
            _futureBuild(mainMarker);
          },
          icon: customIcon1,
          position: mainMarker,
          zIndex: 999,
        );
      }

      return Marker(
        markerId: MarkerId(mapData[index]['vendorId'].toString()),
        icon: sourceIcon,
        position: LatLng(
          double.parse(mapData[index]['latitude'].toString()).toDouble(),
          double.parse(mapData[index]['longitude'].toString()).toDouble(),
        ),
        infoWindow: InfoWindow(title: mapData[index]["shopName"]),
        onTap: () {
          _showModal(mapData, index);
        },
      );
    });

    setState(() {
      markers = _markers;
    });
  }

  List mapData = [];

  Future _futureBuild(currentLocation) {
    return Api.http.post('member/vendor-list', data: {
      "latitude": currentLocation.latitude,
      "longitude": currentLocation.longitude,
    }).then(
      (res) {
        setState(() {
          mapData = res.data!['list'];
        });
        setUpMarkers(mapData);
        return res.data;
      },
    );
  }

  LatLng initPosition = LatLng(0, 0); //initial Position cannot assign null values
  LatLng currentLatLng = LatLng(0.0, 0.0); //initial currentPosition values cannot assign null values
  LatLng mainMarker = LatLng(0.0, 0.0);
  LocationPermission permission = LocationPermission.denied; //initial permission status
  Completer<GoogleMapController> _controller = Completer();

  @override
  void initState() {
    super.initState();
    checkPermission();
    setSourceAndDestinationIcons();
    setCustomIcons();
  }

  //checkPermission before initialize the map
  void checkPermission() async {
    permission = await Geolocator.checkPermission();
    getCurrentLocation();
  }

  // get current location
  void getCurrentLocation() async {
    await Geolocator.getCurrentPosition().then((currLocation) {
      setState(() {
        currentLatLng = LatLng(currLocation.latitude, currLocation.longitude);
        mainMarker = LatLng(currentLatLng.latitude + 0.001, currentLatLng.longitude);
      });
      _futureBuild(currentLatLng);
    });
  }

  //Check permission status and currentPosition before render the map
  bool checkReady(LatLng? x, LocationPermission? y) {
    if (x == initPosition || y == LocationPermission.denied || y == LocationPermission.deniedForever) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vendor in Map'),
      ),
      body: checkReady(currentLatLng, permission)
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: false,
                  markers: Set.from(markers),
                  onCameraMove: (CameraPosition position) {
                    setState(() {
                      mainMarker = position.target;
                    });
                  },
                  mapType: MapType.normal,
                  initialCameraPosition: CameraPosition(target: currentLatLng, zoom: 15),
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                    if (mapData.length > 0) {
                      setUpMarkers(mapData);
                    }
                  },
                ),
              ],
            ),
    );
  }

  void _showModal(mapData, index) {
    Future<void> future = showModalBottomSheet<void>(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            margin: const EdgeInsets.all(20),
            height: h(25),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  blurRadius: 20,
                  offset: Offset.zero,
                  color: Colors.grey.withOpacity(0.5),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  right: 1.0,
                  top: 1.0,
                  child: IconButton(
                    icon: Icon(UniconsLine.multiply),
                    onPressed: () {
                      Get.back();
                    },
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: 70,
                      height: 70,
                      margin: const EdgeInsets.only(left: 10),
                      child: ClipOval(
                        child: PNetworkImage(
                          mapData[index]['profileImage'],
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(left: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            text(
                              mapData[index]['shopName'],
                            ),
                            text(
                              mapData[index]['category'],
                              fontSize: 12.0,
                              textColor: Colors.grey,
                            ),
                            Row(
                              children: [
                                SmoothStarRating(
                                  allowHalfRating: false,
                                  starCount: 5,
                                  rating: double.parse(mapData[index]['averageRating'].toString()),
                                  size: 30.0,
                                  color: Colors.green,
                                  borderColor: Colors.green,
                                  spacing: 0.0,
                                ),
                                SizedBox(width: 10.0),
                                text(
                                  mapData[index]['ratingCount'].toString(),
                                  fontSize: 12.0,
                                  textColor: Colors.grey,
                                ),
                              ],
                            ),
                            text(
                              "Mobile : ${mapData[index]['phone']}",
                              fontSize: 12.0,
                            ),
                            text(
                              "Address : ${mapData[index]['address']}",
                              fontSize: 12.0,
                              isLongText: true,
                            ),
                            text(
                              "${mapData[index]['city']['name']}",
                              fontSize: 12.0,
                            ),
                            text(
                              "${mapData[index]['state']['name']} - ${mapData[index]['pincode']}",
                              fontSize: 12.0,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
