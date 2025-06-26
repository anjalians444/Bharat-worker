import 'package:bharat_worker/widgets/common_button.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../constants/my_colors.dart';
import '../constants/assets_paths.dart';
import '../provider/language_provider.dart';

class JobNavigationView extends StatelessWidget {
  final String address;
  final String time;
  final String userName;
  final String userAddress;
  final String userAvatarUrl;
  final VoidCallback onCall;
  final VoidCallback onMessage;

  const JobNavigationView({
    Key? key,
    required this.address,
    required this.time,
    required this.userName,
    required this.userAddress,
    required this.userAvatarUrl,
    required this.onCall,
    required this.onMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Google Map
          Positioned.fill(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(30.6942, 76.8606), // Example: Panchkula
                zoom: 15,
              ),
              polylines: {
                Polyline(
                  polylineId: PolylineId('route'),
                  color: MyColors.appTheme,
                  width: 5,
                  points: [
                    LatLng(30.6942, 76.8606),
                    LatLng(30.6955, 76.8620),
                  ],
                ),
              },
              markers: {
                Marker(
                  markerId: MarkerId('start'),
                  position: LatLng(30.6942, 76.8606),
                ),
                Marker(
                  markerId: MarkerId('end'),
                  position: LatLng(30.6955, 76.8620),
                ),
              },
              myLocationEnabled: true,
              zoomControlsEnabled: false,
            ),
          ),


          // Address and time card
          Positioned(
            top: 130,
            left: 16,
            right: 16,
            child: Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Icon(Icons.location_on, color: MyColors.appTheme),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        address,
                        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(time, style: TextStyle(color: Colors.grey, fontSize: 14)),
                  ],
                ),
              ),
            ),
          ),
          // Zoom controls
          Positioned(
            right: 16,
            bottom: 200,
            child: Column(
              children: [
                FloatingActionButton(
                  mini: true,
                  heroTag: 'zoom_in',
                  backgroundColor: Colors.white,
                  onPressed: () {},
                  child: Icon(Icons.add, color: Colors.black),
                ),
                SizedBox(height: 8),
                FloatingActionButton(
                  mini: true,
                  heroTag: 'zoom_out',
                  backgroundColor: Colors.white,
                  onPressed: () {},
                  child: Icon(Icons.remove, color: Colors.black),
                ),
              ],
            ),
          ),
          // User info and actions
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.07),
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundImage: NetworkImage(userAvatarUrl),
                      ),
                      SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(userName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            SizedBox(height: 4),
                            Text(userAddress, style: TextStyle(color: Colors.grey, fontSize: 14)),
                          ],
                        ),
                      ),

                    ],
                  ),

                  _buildButtonBottomBar(languageProvider)
                ],
              ),
            ),
          ),

          Positioned(
            top: 60,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: MyColors.borderColor),
                        borderRadius: BorderRadius.circular(12)
                    ),
                    padding: EdgeInsets.all(10),
                    child: const Icon(Icons.arrow_back,size: 24,)),

                Text( languageProvider.translate('navigation_map_title')),

                Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: MyColors.borderColor),
                        borderRadius: BorderRadius.circular(12)
                    ),
                    padding: EdgeInsets.all(10),
                    child: const Icon(Icons.more_vert_sharp,size: 24,)),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildButtonBottomBar(LanguageProvider languageProvider) {
    return Wrap(
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: Offset(0, -3),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                  child: CommonButton(
                    text: languageProvider.translate('call'),
                    onTap: () {
                    },
                    margin: EdgeInsets.zero,
                  )),
              SizedBox(width: 10),
              Expanded(
                  child:  CommonButton(
                    text: languageProvider.translate('message'),
                    onTap: () {},
                    backgroundColor: Colors.white,
                    textColor: MyColors.darkText,
                    borderColor: MyColors.borderColor,
                    margin: EdgeInsets.zero,
                  )
              ),
            ],
          ),
        ),
      ],
    );
  }

} 