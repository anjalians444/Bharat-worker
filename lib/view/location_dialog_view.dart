import 'package:bharat_worker/constants/sized_box.dart';
import 'package:bharat_worker/provider/profile_provider.dart';
import 'package:bharat_worker/widgets/place_picker_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'dart:async';
import '../constants/my_colors.dart';
import '../constants/font_style.dart';
import '../constants/assets_paths.dart';

class LocationDialogView extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String address;
  final String customerName;
  final String customerPhone;

  const LocationDialogView({
    Key? key,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.customerName,
    this.customerPhone = '',
  }) : super(key: key);

  @override
  State<LocationDialogView> createState() => _LocationDialogViewState();
}

class _LocationDialogViewState extends State<LocationDialogView> {
  GoogleMapController? mapController;
  String travelTime = 'Calculating...';

  @override
  void initState() {
    super.initState();
    _calculateTravelTime();
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
                 //   margin: EdgeInsets.symmetric(horizontal: 18.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: MyColors.borderColor),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [

              FutureBuilder<Set<Marker>>(
                future: _getAllMarkers(widget.latitude, widget.longitude, widget.address),
                builder: (context, snapshot) {
                  return GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(widget.latitude, widget.longitude),
                      zoom: 12,
                    ),
                    markers: snapshot.data ?? {},
                    polylines: _getRoutePolylines(widget.latitude, widget.longitude),
                    zoomControlsEnabled: false,
                    mapToolbarEnabled: false,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    compassEnabled: false,
                    mapType: MapType.normal,
                    onMapCreated: (GoogleMapController controller) {
                      mapController = controller;
                    },
                  );
                },
              ),
              // Zoom controls at bottom right


              Wrap(
                children: [
                  // Header with back button and title
                  Container(
                    margin: EdgeInsets.only(top:60.0, left:16,right:16),
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8),
                      border: Border(bottom: BorderSide(color: MyColors.borderColor, width: 1)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: MyColors.borderColor),
                                borderRadius: BorderRadius.circular(12)
                            ),
                            padding: EdgeInsets.all(8),
                            child: const Icon(Icons.arrow_back, size: 24,),
                          ),
                        ),

                        Text('Map', style: boldTextStyle(fontSize: 18.0, color: MyColors.blackColor)),

                        InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: MyColors.borderColor),
                                borderRadius: BorderRadius.circular(12)
                            ),
                            padding: EdgeInsets.all(8),
                            child: SvgPicture.asset(MyAssetsPaths.searchIcon)
                          ),
                        ),
                      
                      ],
                    ),
                  ),

                  // Address bar
                  InkWell(
                    onTap: () =>
                        //_openInMaps(widget.longitude,widget.longitude),

                        _launchMap(),
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 18.0, vertical: 12),
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: MyColors.borderColor),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SvgPicture.asset(MyAssetsPaths.location),
                         // Icon(Icons.location_on, size: 20, color: MyColors.appTheme),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              widget.address,
                              style: regularTextStyle(fontSize: 12.0, color: MyColors.blackColor),
                            //  maxLines: 1,
                             // overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 10,),
                          Text(travelTime, style: regularTextStyle(fontSize: 12.0, color: MyColors.color838383)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

          /*    Positioned(
                right: 0,
                bottom: 10,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      IconButton(
                        icon: Icon(Icons.add, size: 20),
                        onPressed: () {
                          mapController?.animateCamera(
                            CameraUpdate.zoomIn(),
                          );
                        },
                        padding: EdgeInsets.all(8),
                      ),
                      Divider(height: 1, color: MyColors.borderColor),
                      IconButton(
                        icon: Icon(Icons.remove, size: 20),
                        onPressed: () {
                          mapController?.animateCamera(
                            CameraUpdate.zoomOut(),
                          );
                        },
                        padding: EdgeInsets.all(8),
                      ),
                    ],
                  ),
                ),
              ),*/

              // Bottom location card

            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton:  Wrap(
        children: [

          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              width: 50,
              margin: EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  IconButton(
                    icon: Icon(Icons.add, size: 20),
                    onPressed: () {
                      mapController?.animateCamera(
                        CameraUpdate.zoomIn(),
                      );
                    },
                    padding: EdgeInsets.all(8),
                  ),
                  Divider(height: 1, color: MyColors.borderColor),
                  IconButton(
                    icon: Icon(Icons.remove, size: 20),
                    onPressed: () {
                      mapController?.animateCamera(
                        CameraUpdate.zoomOut(),
                      );
                    },
                    padding: EdgeInsets.all(8),
                  ),
                ],
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.all(10.0),
             padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Profile and name row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile picture
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: MyColors.appTheme.withOpacity(0.1),
                      child: Icon(Icons.person, color: MyColors.appTheme, size: 24),
                    ),
                    SizedBox(width: 12),
                    // Name and address
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.customerName,
                            style: boldTextStyle(fontSize: 16.0, color: MyColors.blackColor),
                          ),
                          SizedBox(height: 4),
                          Text(
                            widget.address,
                            style: regularTextStyle(fontSize: 12.0, color: MyColors.color838383),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                // Action buttons in row
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MyColors.appTheme,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: EdgeInsets.symmetric(vertical: 8),
                        ),
                        onPressed: () {
                          _makePhoneCall();
                        },
                        child: Text('Call', style: boldTextStyle(fontSize: 14.0, color: Colors.white)),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          side: BorderSide(color: MyColors.appTheme),
                          padding: EdgeInsets.symmetric(vertical:8),
                        ),
                        onPressed: () {
                          // Handle message action
                        },
                        child: Text('Message', style: boldTextStyle(fontSize: 14.0, color: MyColors.appTheme)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<BitmapDescriptor> _getCustomMarkerIcon(String image) async {
    return BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(48, 48)),
      image,
    );
  }

  void _openInMaps(double latitude, double longitude) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    final uri = Uri.parse(url);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open maps')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening maps: ${e.toString()}')),
      );
    }
  }

  Future<Set<Marker>> _getAllMarkers(double destinationLat, double destinationLng, String address) async {
    Set<Marker> markers = {};
    
    // Get current location (you can replace with actual current location)
    double currentLat = 30.7333; // Example: Chandigarh coordinates
    double currentLng = 76.7794;
    
    // Current location marker with custom icon (bullseye style)
    markers.add(
      Marker(
        markerId: MarkerId('current_location'),
        position: LatLng(currentLat, currentLng),
        infoWindow: InfoWindow(title: 'Current Location', snippet: 'Your location'),
        icon: await _getCustomMarkerIcon(MyAssetsPaths.currentLocation),
        flat: true,
        anchor: Offset(0.5, 0.5),
      ),
    );
    
    // Destination marker (custom red marker)
    markers.add(
      Marker(
        markerId: MarkerId('destination'),
        position: LatLng(destinationLat, destinationLng),
        infoWindow: InfoWindow(title: 'Destination', snippet: address),
        icon: await _getCustomMarkerIcon(MyAssetsPaths.locationMarker),
      ),
    );
    
    return markers;
  }

  Set<Polyline> _getRoutePolylines(double destinationLat, double destinationLng) {
    Set<Polyline> polylines = {};
    
    // Get current location (you can replace with actual current location)
    double currentLat = 30.7333; // Example: Chandigarh coordinates
    double currentLng = 76.7794;
    
    polylines.add(
      Polyline(
        polylineId: PolylineId('route'),
        color: MyColors.appTheme,
        width: 4,
        points: [
          LatLng(currentLat, currentLng),
          LatLng(destinationLat, destinationLng),
        ],
      ),
    );
    
    return polylines;
  }

  Future<void> _calculateTravelTime() async {
    try {
      // Get current location (you can replace with actual current location)
      double currentLat = 30.7333; // Example: Chandigarh coordinates
      double currentLng = 76.7794;
      
      // Validate coordinates
      if (widget.latitude == 0.0 && widget.longitude == 0.0) {
        setState(() {
          travelTime = 'Invalid location';
        });
        return;
      }
      
      print('Current location: $currentLat, $currentLng'); // Debug print
      print('Destination: ${widget.latitude}, ${widget.longitude}'); // Debug print
      
      // First try to get real travel time from Google Directions API
      await _getRealTravelTime(currentLat, currentLng);
      
      // If API fails, calculate approximate time based on distance
      if (travelTime == 'Calculating...' || travelTime == 'Error calculating') {
        _calculateApproximateTime(currentLat, currentLng);
      }
    } catch (e) {
      print('Error in _calculateTravelTime: $e'); // Debug print
      // Fallback to approximate calculation
      double currentLat = 30.7333;
      double currentLng = 76.7794;
      _calculateApproximateTime(currentLat, currentLng);
    }
  }

  Future<void> _getRealTravelTime(double currentLat, double currentLng) async {
    try {
      // Google Directions API URL
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json?'
        'origin=$currentLat,$currentLng'
        '&destination=${widget.latitude},${widget.longitude}'
        '&mode=driving'
        '&key=${kGoogleApiKey}'
      );
      
      print('API URL: $url'); // Debug print
      
      // Make HTTP request with timeout
      final response = await http.get(url).timeout(
        Duration(seconds: 10),
        onTimeout: () {
          print('API request timed out'); // Debug print
          throw TimeoutException('Request timed out');
        },
      );
      
      print('Response status: ${response.statusCode}'); // Debug print
      print('Response body: ${response.body}'); // Debug print
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        print('API Response: $data'); // Debug print
        
        if (data['status'] == 'OK' && data['routes'] != null && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final leg = route['legs'][0];
          final duration = leg['duration']['text'];
          
          setState(() {
            travelTime = duration;
          });
          print('Travel time calculated: $duration'); // Debug print
        } else {
          print('API Status: ${data['status']}'); // Debug print
          print('Routes: ${data['routes']}'); // Debug print
          
          // Try fallback calculation immediately
          _calculateApproximateTime(currentLat, currentLng);
        }
      } else {
        print('HTTP Error: ${response.statusCode}'); // Debug print
        setState(() {
          travelTime = 'Unable to calculate';
        });
      }
    } catch (e) {
      print('Exception in _getRealTravelTime: $e'); // Debug print
      setState(() {
        travelTime = 'Error calculating';
      });
    }
  }

  void _calculateApproximateTime(double currentLat, double currentLng) {
    try {
      // Calculate distance using Haversine formula
      double distance = _calculateDistance(
        currentLat, currentLng,
        widget.latitude, widget.longitude,
      );
      
      print('Distance calculated: ${distance.toStringAsFixed(2)} km'); // Debug print
      
      // Estimate travel time based on distance
      // Assuming average speed of 25 km/h in city (more realistic)
      double timeInHours = distance / 25.0; // 25 km/h average speed
      int timeInMinutes = (timeInHours * 60).round();
      
      // Ensure minimum time of 1 minute
      timeInMinutes = timeInMinutes < 1 ? 1 : timeInMinutes;
      
      String timeText;
      if (timeInMinutes < 60) {
        timeText = '~${timeInMinutes} min';
      } else {
        int hours = timeInMinutes ~/ 60;
        int minutes = timeInMinutes % 60;
        if (minutes == 0) {
          timeText = '~${hours}h';
        } else {
          timeText = '~${hours}h ${minutes}min';
        }
      }
      
      print('Approximate time calculated: $timeText'); // Debug print
      
      setState(() {
        travelTime = timeText;
      });
    } catch (e) {
      print('Error in approximate calculation: $e'); // Debug print
      setState(() {
        travelTime = '~10 min'; // Default fallback
      });
    }
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    
    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);
    
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) * cos(_degreesToRadians(lat2)) *
        sin(dLon / 2) * sin(dLon / 2);
    
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = earthRadius * c;
    
    return distance;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  void _makePhoneCall() async {
    if (widget.customerPhone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Phone number not available')),
      );
      return;
    }

    final phoneNumber = widget.customerPhone.startsWith('+')
        ? widget.customerPhone
        : '+91${widget.customerPhone}'; // Default to India +91 if no country code

    final uri = Uri.parse('tel:$phoneNumber');

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not make phone call')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error making phone call: ${e.toString()}')),
      );
    }
  }

  void _launchMap() async {
    try {
      // Create URL for Google Maps with the destination coordinates
      final url = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=${widget.latitude},${widget.longitude}'
      );

      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        // Fallback to Apple Maps on iOS or other map apps
        final fallbackUrl = Uri.parse(
          'https://maps.apple.com/?daddr=${widget.latitude},${widget.longitude}'
        );
        
        if (await canLaunchUrl(fallbackUrl)) {
          await launchUrl(fallbackUrl, mode: LaunchMode.externalApplication);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not launch map application')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error launching map: ${e.toString()}')),
      );
    }
  }
} 