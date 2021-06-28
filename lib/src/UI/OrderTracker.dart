import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:restroapp/src/models/GetOrderHistory.dart';
import 'package:geolocator/geolocator.dart';
import 'package:restroapp/src/utils/AppConstants.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderTrackerLive extends StatefulWidget {
  OrderData orderHistoryData;

  OrderTrackerLive(this.orderHistoryData);

  @override
  _OrderTrackerLiveState createState() {
    return _OrderTrackerLiveState();
  }
}

class _OrderTrackerLiveState extends State<OrderTrackerLive> {
  GoogleMapController _controller;
  static const LatLng _center = const LatLng(30.341288, 76.419609);
  final Set<Marker> _markers = {};
  LatLng _lastMapPosition = _center;
  //final Set<Polyline> polyLine = {};
  List <LatLng> routeCoordinates = List();
  LatLng _new = LatLng(30.341288, 76.419609);
  LatLng _news = LatLng(31.6231717, 74.8689733);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _markers.add(Marker(
      markerId: MarkerId(_lastMapPosition.toString()),
      position: _lastMapPosition,
      infoWindow: InfoWindow(
        title: 'Really cool place',
        snippet: '5 Star Rating',
      ),
      icon: BitmapDescriptor.defaultMarker,

    ));
    routeCoordinates.add(_new);
    routeCoordinates.add(_news);
    // polyLine.add(Polyline(
    //   polylineId: PolylineId(_lastMapPosition.toString()),
    //   visible: true,
    //   points: routeCoordinates,
    //   color: Colors.blue,
    //   startCap: Cap.roundCap,
    //   endCap: Cap.buttCap,
    // ));
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              // Align(
              //   alignment: Alignment.topRight,
              //   child: IconButton(
              //     icon: Icon(Icons.clear),
              //     onPressed: () {
              //       Navigator.pop(context);
              //     },
              //   ),
              // ),
              Expanded(
                child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(30.341288, 76.419609),
                      zoom: 14.0,
                    ),
                  mapType: MapType.normal,
                 // polylines: polyLine,37.4219983, -122.084
                  markers: _markers,
                ),
              ),
              //Expanded(child: Text(_liveTrackerMap(widget.orderHistoryData))),
              Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(width: 10.0, color: Colors.grey[300]),
                    ),
                    color: Colors.white,
                  ),
                  height: 100,
                  child: Row(
                    children: [
                      Container(
                        height: 30,
                        width: 30,
                        margin: EdgeInsets.only(left: 30, right: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: _getImage(widget.orderHistoryData),
                      ),
                      Expanded(
                        // margin: EdgeInsets.only(top: 5),
                        child: RichText(
                          text: TextSpan(
                              text: 'Delivery Boy',
                              style:
                              TextStyle(color: Colors.black, fontSize: 16),
                              children: [
                                TextSpan(
                                    text:
                                    '\n${_getRunnerName(widget.orderHistoryData)}',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold))
                                //TextSpan(text: '\n${widget.runnerDetail.fullName}',style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold))
                              ]),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(right: 20.0),
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: Color(0xff75990B),
                            borderRadius: BorderRadius.circular(20)),
                        child: GestureDetector(
                          onTap: () {
                            print('Calling');
                            _launchCaller(widget.orderHistoryData);
                            //_launchCaller(widget.runnerDetail.phone);
                          },
                          child: Icon(
                            Icons.call_outlined,
                            size: 25.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ))
            ],
          ),
          Positioned(
            top: 1,
            // left: MediaQuery.of(context).size.width/2,
            child: Container(
                height: 80,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.4),
                ),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    Text('Map View', textAlign: TextAlign.center,style: TextStyle(fontSize: 18)),
                  ],
                )
            ),
          ),
        ],
      ),
    );
  }
  
  

  void onMapCreated(GoogleMapController controller){
    setState(() {
      _controller = controller;
    });
  }

  _liveTrackerMap(OrderData orderHistoryData) {

      if (orderHistoryData.runnerDetail != null &&
          orderHistoryData.runnerDetail.isNotEmpty &&
          orderHistoryData.deliveryAddress != null &&
          orderHistoryData.deliveryAddress.isNotEmpty) {

        String runnerLat = '${orderHistoryData.runnerDetail.first.lat}';
        String runerLng = '${orderHistoryData.runnerDetail.first.lng}';
        String deliveryLat = '${orderHistoryData.deliveryAddress.first.lat}';
        String deliveryLng = '${orderHistoryData.deliveryAddress.first.lng}';
        return '$runerLng$runnerLat$deliveryLng$deliveryLat';
      } else {
        return '\nRajesh Kumar' ;
      }
  }
  _getImage(OrderData orderHistoryData) {
    //Image(image: AssetImage('images/whatsapp.png' ),

    if (orderHistoryData.runnerDetail != null &&
        orderHistoryData.runnerDetail.isNotEmpty) {
      AppConstant.placeholderUrl =
      '${orderHistoryData.runnerDetail.first.profileImage}';
      return CachedNetworkImage(imageUrl: "${orderHistoryData.runnerDetail.first.profileImage}");
    } else {
      return Image(image: AssetImage('images/whatsapp.png'));
    }
  }

  void _launchCaller(OrderData orderHistoryData) async {
    if (orderHistoryData.runnerDetail != null &&
        orderHistoryData.runnerDetail.isNotEmpty) {
      String contact = '${orderHistoryData.runnerDetail.first.phone}';
      String url = "tel:${contact}";
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    }
  }

  String _getRunnerName(OrderData orderHistoryData) {
    if (orderHistoryData.runnerDetail != null &&
        orderHistoryData.runnerDetail.isNotEmpty) {
      String name = '${orderHistoryData.runnerDetail.first.fullName}';

      return '$name';
    } else {
      return 'Rajesh Kumar';
    }
  }

}
