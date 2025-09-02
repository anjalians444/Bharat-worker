import 'dart:convert';
import 'package:bharat_worker/constants/font_style.dart';
import 'package:bharat_worker/constants/my_colors.dart';
import 'package:bharat_worker/constants/sized_box.dart';
import 'package:bharat_worker/helper/common.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

const kGoogleApiKey = "AIzaSyA9CuQUrT9RikUFLRH65ojtX2UdshPs1sQ";

class PlacePickerScreen extends StatefulWidget {
  final String? initialAddress;
  final double? initialLat;
  final double? initialLng;

  const PlacePickerScreen({
    Key? key,
    this.initialAddress,
    this.initialLat,
    this.initialLng,
  }) : super(key: key);

  @override
  State<PlacePickerScreen> createState() => _PlacePickerScreenState();
}

class _PlacePickerScreenState extends State<PlacePickerScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  GoogleMapController? _mapController;
  LatLng? _currentLatLng;
  String _currentAddress = '';
  Marker? _marker;
  bool _loading = true;
  List<dynamic> _suggestions = [];
  bool _isProgrammaticChange = false;
  bool isList = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchTextChanged);

    /* if (widget.initialLat != null && widget.initialLng != null && (widget.initialAddress != null && widget.initialAddress!.isNotEmpty)) {
      // Set initial location and address
      _currentLatLng = LatLng(widget.initialLat!, widget.initialLng!);
      _searchController.text = widget.initialAddress!;
      _updateLocation(_currentLatLng!, updateText: false);
      _loading = false;
    } else {
    */
    _getCurrentLocation();
    // }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchTextChanged);
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _onSearchTextChanged() {
    if (_isProgrammaticChange) {
      _isProgrammaticChange = false;
      return;
    }
    // Only show suggestions if the text field is focused
    if (!_searchFocus.hasFocus) {
      return;
    }
    if (_searchController.text.isEmpty) {
      setState(() {
        _currentAddress = "";
        _marker = null;
        _suggestions = [];
      });
    } else {
      _getPlaceSuggestions(_searchController.text);
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
      }
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      await _updateLocation(
        LatLng(position.latitude, position.longitude),
        updateText: true,
      );
    } catch (e) {
      // Fallback to a default location (India center) if location cannot be fetched
      await _updateLocation(
        const LatLng(20.5937, 78.9629),
        updateText: true,
      );
    }
    setState(() {
      _loading = false;
    });
  }

  Future<void> _updateLocation(LatLng latLng, {bool updateText = false}) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(latLng.latitude, latLng.longitude);
    Placemark place = placemarks.isNotEmpty ? placemarks[0] : Placemark();
    List<String?> parts = [
      place.name,
      place.street,
      place.locality,
      place.administrativeArea,
      place.country,
      place.postalCode
    ].where((e) => (e ?? '').isNotEmpty).toList();

    // Remove consecutive duplicates
    List<String?> filtered = [];
    for (var part in parts) {
      if (filtered.isEmpty || filtered.last != part) {
        filtered.add(part);
      }
    }
    String address = filtered.join(", ");

    setState(() {
      _currentLatLng = latLng;
      _currentAddress = address;
      _marker = Marker(
        markerId: const MarkerId('selected_location'),
        position: latLng,
      );
      if (updateText) {
        _isProgrammaticChange = true;
        _searchController.text = address;
      }
    });
    if (_mapController != null) {
      _mapController!.animateCamera(CameraUpdate.newLatLng(latLng));
    }
  }

  Future<void> _getPlaceSuggestions(String input) async {
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$kGoogleApiKey&components=country:in');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List predictions = data['predictions'];
      setState(() {
        _suggestions = predictions;
      });
    }
  }

  Future<void> _onSuggestionTap(String placeId, String description) async {
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$kGoogleApiKey');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final location = data['result']['geometry']['location'];
      setState(() {
        _searchController.text = description;
      });
      await _updateLocation(LatLng(location['lat'], location['lng']),
          updateText: false);
      setState(() => _suggestions = []);
      FocusScope.of(context).unfocus();
    }
  }

  void _returnSelected() async {
    if (_currentLatLng == null) return;
    List<Placemark> placemarks = await placemarkFromCoordinates(
        _currentLatLng!.latitude, _currentLatLng!.longitude);
    Placemark place = placemarks.isNotEmpty ? placemarks[0] : Placemark();
    Navigator.pop(context, {
      'address': _searchController.text,
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
      backgroundColor: Colors.white,
      appBar: commonAppBar(() {
        Navigator.pop(context);
        // _returnSelected();
      }, "Search Address", actions: [
        InkWell(
          onTap: _returnSelected,
          child: Container(
            decoration: BoxDecoration(
              color: MyColors.appTheme,
              border: Border.all(color: MyColors.borderColor),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.all(8),
            child: Icon(Icons.check, size: 24, color: Colors.white),
          ),
        )
      ]),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _currentLatLng ?? const LatLng(20.5937, 78.9629),
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
                  child: Column(
                    children: [
                      Material(
                        elevation: 6,
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        child: TextField(
                          controller: _searchController,
                          maxLines: null,
                          minLines: 1,
                          keyboardType: TextInputType.multiline,
                          focusNode: _searchFocus,
                          onTap: () {
                            setState(() {
                              isList = true;
                            });
                          },
                          style: mediumTextStyle(
                              fontSize: 14.0, color: MyColors.darkText),
                          decoration: InputDecoration(
                            hintText: "Search place",
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: Icon(Icons.clear),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() => _suggestions = []);
                                    },
                                  )
                                : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                          ),
                        ),
                      ),
                      if (_suggestions.isNotEmpty && isList)
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 6,
                                color: Colors.black.withOpacity(0.1),
                              ),
                            ],
                          ),
                          child: SingleChildScrollView(
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: _suggestions.length,
                              physics: NeverScrollableScrollPhysics(),

                              itemBuilder: (context, index) {
                                final suggestion = _suggestions[index];
                                return ListTile(
                                  leading: Icon(Icons.location_on),
                                  title: Text(suggestion['description']),
                                  onTap: () async {
                                    _isProgrammaticChange = true;
                                    isList = false;
                                    await _onSuggestionTap(suggestion['place_id'],
                                        suggestion['description']);
                                    FocusScope.of(context)
                                        .unfocus(); // Remove focus so suggestions don't reopen
                                  },
                                );
                              },
                            ),
                          ),
                        ),

                    ],
                  ),
                ),
                if (_currentAddress.isNotEmpty && !isList)
                  Positioned(
                    bottom: 30,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () async {
                            setState(() {
                              _loading = true;
                            });
                            await _getCurrentLocation();
                          },
                          // backgroundColor: MyColors.appTheme,
                          child: Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: MyColors.appTheme,
                                  borderRadius: BorderRadius.circular(10)),
                              child: const Icon(Icons.my_location,
                                  color: Colors.white)),
                          // tooltip: 'Set to current location',
                        ),
                        hsized10,
                        InkWell(
                          onTap: () {
                            print("_currentAddress..${_currentAddress}");
                          },
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
                  ),
              ],
            ),
      /* floatingActionButton: _loading ? null : FloatingActionButton(
        onPressed: () async {
          setState(() { _loading = true; });
          await _getCurrentLocation();
        },
        backgroundColor: MyColors.appTheme,
        child: const Icon(Icons.my_location, color: Colors.white),
        tooltip: 'Set to current location',
      ),*/
    );
  }
}

/*
import 'package:bharat_worker/constants/my_colors.dart';
import 'package:bharat_worker/helper/common.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
    _searchController.addListener(_onSearchTextChanged);
    _getCurrentLocation();
  }
  @override
  void dispose() {
    _searchController.removeListener(_onSearchTextChanged);
    _searchController.dispose();
    super.dispose();
  }
  void _onSearchTextChanged() {
    // If the user deletes all text manually or via keyboard
    if (_searchController.text.isEmpty) {
      setState(() {
        _currentAddress = "";
        _marker = null;
      });
    }
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
      backgroundColor: Colors.white,
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
                      color: Colors.white,
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
                        clearData: (v){

                        },
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
*/
