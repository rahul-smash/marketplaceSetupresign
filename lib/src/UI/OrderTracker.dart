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
  double Runlattitude;
  double Runlongitude;
  double Uslattitude;
  double Uslongitude;
  static final LatLng _center = LatLng(45.521563, -122.677433);
  final Set<Marker> _markers = {};
  LatLng _currentMapPosition = _center;
  BitmapDescriptor customMarker1;
  BitmapDescriptor customMarker2;
  String bullet = "\u2022 ";

  getCustomMarker() async{
    customMarker1 = await BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(12, 12)), 'images/runner-location.png');
    customMarker2 = await BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(12, 12)), 'images/user-location.png');
  }
  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;
  }

  @override
  void initState() {
    super.initState();
    getCustomMarker();
    _getRunlatlng(widget.orderHistoryData);
    _getUslatlng(widget.orderHistoryData);
        // _markers.add(Marker(
        //   markerId: MarkerId(_currentMapPosition.toString()),
        //   position: _currentMapPosition,
        //   icon: customMarker2,
        // ));
    }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(Runlattitude, Runlongitude),
                      zoom: 14.0,
                    ),
                  //mapType: MapType.normal,
                  markers:  _markers,
                ),
              ),

              Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(width: 10.0, color: Colors.grey[300]),
                    ),
                    color: Colors.white,
                  ),
                  height: 100,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                              margin: EdgeInsets.only(left: 40, top: 5),
                              height: 30,
                              width: 200,
                              child: Text('${_getBottomTrack()}')
                          ),
                        ],
                      ),
                      Row(
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
                          Container(
                            margin: EdgeInsets.only(right: 20.0),
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                //color: Color(0xff75990B),
                                borderRadius: BorderRadius.circular(20)),
                            child: GestureDetector(
                              onTap: () {
                                print('Map');

                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (BuildContext context) => super.widget));
                              },
                              child: Image(image: AssetImage("images/refresh.png"), height: 23, width: 23,)
                              ),

                            ),
                        ],
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

  _getBottomTrack() {
    // Delivered == 5, On Way to destination == 7
    print('${widget.orderHistoryData.status}');
    switch(widget.orderHistoryData.status)
    {
      case '6':
        return bullet + ' Order Cancelled';
        break;
      case '7':
        return bullet+' On the way to destination';
        break;
      case '8':
        return bullet+' On the way to take your order';
        break;
      default:
        return '';
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
      return '';
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
      return 'Runner Yet to be selected';
    }
  }

  _getRunlatlng(OrderData orderHistoryData) {
    if (orderHistoryData.runnerDetail != null &&
        orderHistoryData.runnerDetail.isNotEmpty
    ) {
      String runlat = '${orderHistoryData.runnerDetail.first.lat}';
      String runlng = '${orderHistoryData.runnerDetail.first.lng}';
      setState(() {
        Runlattitude = double.parse('$runlat');
        Runlongitude= double.parse('$runlng');
          _markers.add(Marker(
            markerId: MarkerId('1'),
            position: LatLng(Runlattitude, Runlongitude),
            icon: customMarker1,
          ));
      });
      print('${Runlattitude}');
      print('${Runlongitude}');
      return LatLng(Runlattitude, Runlongitude);
    } else {
      return '';
    }
  }
  _getUslatlng(OrderData orderHistoryData) {
    if (orderHistoryData.deliveryAddress != null &&
        orderHistoryData.deliveryAddress.isNotEmpty) {
      String uslat = '${orderHistoryData.deliveryAddress.first.lat}';
      String uslng = '${orderHistoryData.deliveryAddress.first.lng}';
      setState(() {
        Uslattitude = double.parse('$uslat');
        Uslongitude= double.parse('$uslng');
        _markers.add(Marker(
          markerId: MarkerId('2'),
          position: LatLng(Uslattitude, Uslongitude),
          icon: customMarker2,
        ));
      });
      print('${Uslattitude}');
      print('${Uslongitude}');
      return LatLng(Uslattitude, Uslongitude);
    } else {
      return '';
    }
  }
}
