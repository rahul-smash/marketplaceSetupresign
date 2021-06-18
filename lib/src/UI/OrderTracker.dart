import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:restroapp/src/models/GetOrderHistory.dart';

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
  final Set<Polyline> polyLine = {};
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
    polyLine.add(Polyline(
      polylineId: PolylineId(_lastMapPosition.toString()),
      visible: true,
      points: routeCoordinates,
      color: Colors.blue,
      startCap: Cap.roundCap,
      endCap: Cap.buttCap,
    ));
    return Scaffold(
      body: Column(
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
          Expanded(
            child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(30.341288, 76.419609),
                  zoom: 14.0,
                ),
              mapType: MapType.normal,
              polylines: polyLine,
              markers: _markers,
            ),
          ),
          //Expanded(child: Text(_liveTrackerMap(widget.orderHistoryData))),
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





}
