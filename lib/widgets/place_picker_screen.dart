import 'package:bharat_worker/constants/my_colors.dart';
import 'package:bharat_worker/helper/common.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/place_type.dart';
import 'package:google_places_flutter/model/prediction.dart';

const kGoogleApiKey = "AIzaSyDdic_2j3bnqNOh-azIzC6BhNQAUI5t8kI";

class PlacePickerScreen extends StatefulWidget {
  const PlacePickerScreen({Key? key}) : super(key: key);

  @override
  State<PlacePickerScreen> createState() => _PlacePickerScreenState();
}

class _PlacePickerScreenState extends State<PlacePickerScreen> {
  final TextEditingController _searchController = TextEditingController();
  GoogleMapController? _mapController;
  LatLng? _currentLatLng;
  String _currentAddress = '';
  Marker? _marker;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    _updateLocation(LatLng(position.latitude, position.longitude),
        updateText: true);
    setState(() {
      _loading = false;
    });
  }

  Future<void> _updateLocation(LatLng latLng, {bool updateText = false}) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(latLng.latitude, latLng.longitude);
    Placemark place = placemarks.isNotEmpty ? placemarks[0] : Placemark();
    String address = [
      if (place.name != null && place.name!.isNotEmpty) place.name,
      if (place.street != null && place.street!.isNotEmpty) place.street,
      if (place.locality != null && place.locality!.isNotEmpty) place.locality,
      if (place.administrativeArea != null &&
          place.administrativeArea!.isNotEmpty)
        place.administrativeArea,
      if (place.country != null && place.country!.isNotEmpty) place.country,
      if (place.postalCode != null && place.postalCode!.isNotEmpty)
        place.postalCode,
    ].where((e) => e != null && e.isNotEmpty).join(", ");
    setState(() {
      _currentLatLng = latLng;
      _currentAddress = address;
      _marker = Marker(
        markerId: const MarkerId('selected_location'),
        position: latLng,
      );
      if (updateText) {
        _searchController.text = address;
      }
    });
    if (_mapController != null) {
      _mapController!.animateCamera(CameraUpdate.newLatLng(latLng));
    }
  }

  void _onPlaceSelected(Prediction prediction) async {
    try {
      debugPrint("📍 Inside _onPlaceSelected");
      if (prediction.lat == null || prediction.lng == null) {
        debugPrint("❌ lat/lng is null");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location not found.')),
        );
        return;
      }

      final lat = double.tryParse(prediction.lat!);
      final lng = double.tryParse(prediction.lng!);

      if (lat != null && lng != null) {
        debugPrint("✅ Coordinates: $lat, $lng");
        await _updateLocation(LatLng(lat, lng), updateText: true);
      } else {
        debugPrint("❌ Invalid coordinates");
      }
    } catch (e, s) {
      debugPrint("❌ Exception: $e");
      debugPrint("$s");
    }
  }

  void _onPlaceSelected1(Prediction prediction) async {
    if (prediction.lat == null || prediction.lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Location not found for this place. Please try another.')),
      );
      return;
    }
    final lat = double.tryParse(prediction.lat!);
    final lng = double.tryParse(prediction.lng!);
    if (lat != null && lng != null) {
      await _updateLocation(LatLng(lat, lng), updateText: true);
      // Optionally pop here if you want to auto-select
      // _returnSelected();
    } else {
      setState(() {
        _searchController.text = prediction.description ?? "";
      });
    }
  }

  void _returnSelected() async {
    if (_currentLatLng == null) return;
    List<Placemark> placemarks = await placemarkFromCoordinates(
        _currentLatLng!.latitude, _currentLatLng!.longitude);
    Placemark place = placemarks.isNotEmpty ? placemarks[0] : Placemark();
    Navigator.pop(context, {
      'address': _currentAddress,
      'country': place.country ?? "",
      'state': place.administrativeArea ?? "",
      'city': place.locality ?? place.subAdministrativeArea ?? "",
      'pincode': place.postalCode ?? "",
      'latitude': _currentLatLng!.latitude,
      'longitude': _currentLatLng!.longitude,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: commonAppBar((){
        _returnSelected();
      }, "Search Address",
      actions: [
        InkWell(
          child: Container(
              decoration: BoxDecoration(
                  color: MyColors.appTheme,
                  border: Border.all(color: MyColors.borderColor),
                  borderRadius: BorderRadius.circular(12)
              ),
              padding: EdgeInsets.all(8),
              child:  Icon(Icons.check,size: 24,color:Colors.white ,)),
          onTap: () {
            _returnSelected();
          },
        )
      ],),

      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _currentLatLng ?? const LatLng(20.5937, 78.9629),
                    // India center fallback
                    zoom: 16,
                  ),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  markers: _marker != null ? {_marker!} : {},
                  onMapCreated: (controller) => _mapController = controller,
                  onTap: (latLng) => _updateLocation(latLng, updateText: true),
                ),
                Positioned(
                  top: 20,
                  left: 16,
                  right: 16,
                  child: Material(
                      elevation: 6,
                      borderRadius: BorderRadius.circular(16),
                      child: GooglePlaceAutoCompleteTextField(
                        textEditingController: _searchController,
                        googleAPIKey: kGoogleApiKey,
                        inputDecoration: InputDecoration(
                          hintText: "Search place",
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                        debounceTime: 800,
                        // default 600 ms,
                        countries: ["in", "fr"],
                        // optional by default null is set
                        isLatLngRequired: true,
                        // if you required coordinates from place detail
                        getPlaceDetailWithLatLng: (Prediction prediction) {
                          // this method will return latlng with place detail
                          print("placeDetails" + prediction.lng.toString());
                          FocusScope.of(context).unfocus();
                          _onPlaceSelected(prediction);
                        },
                        // this callback is called when isLatLngRequired is true
                        itemClick: (Prediction prediction) {
                          _searchController.text =
                              prediction.description.toString();
                          _searchController.selection =
                              TextSelection.fromPosition(TextPosition(
                                  offset: prediction.description!.length));
                        },
                        // if we want to make custom list item builder
                        itemBuilder: (context, index, Prediction prediction) {
                          return Container(
                            padding: EdgeInsets.all(10),
                            child: Row(
                              children: [
                                Icon(Icons.location_on),
                                SizedBox(
                                  width: 7,
                                ),
                                Expanded(
                                    child:
                                        Text("${prediction.description ?? ""}"))
                              ],
                            ),
                          );
                        },
                        // if you want to add seperator between list items
                        seperatedBuilder: Divider(),
                        // want to show close icon
                        isCrossBtnShown: true,
                        // optional container padding
                        containerHorizontalPadding: 10,
                        // place type
                        placeType: PlaceType.geocode,
                      )

                      /* GooglePlaceAutoCompleteTextField(
                      textEditingController: _searchController,
                      googleAPIKey: kGoogleApiKey,
                      inputDecoration: InputDecoration(
                        hintText: "Search place",
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      debounceTime: 400,
                      countries: ["in"],
                      isLatLngRequired: true,
                      getPlaceDetailWithLatLng: (Prediction prediction) async {
                        debugPrint("🔥 Callback Triggered");
                        if (prediction == null) {
                          debugPrint("❌ Prediction is null");
                          return;
                        }
                        debugPrint("✅ Prediction: ${prediction.description}");
                        FocusScope.of(context).unfocus();
                        _onPlaceSelected(prediction);
                      },

                    ),*/
                      ),
                ),
                if (_currentAddress.isNotEmpty)
                  Positioned(
                    bottom: 30,
                    left: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on,
                              color: Colors.redAccent),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _currentAddress,
                              style: const TextStyle(
                                  fontSize: 15, color: Colors.black87),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
