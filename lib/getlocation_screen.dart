import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class GetlocationScreen extends StatefulWidget {
  const GetlocationScreen({super.key});

  @override
  State<GetlocationScreen> createState() => _GetlocationScreenState();
}

class _GetlocationScreenState extends State<GetlocationScreen> {
  String? latitude;
  String? longitude;
  String? address;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getLocation();
  }

  Future<void> getLocation() async {
    setState(() {
      isLoading = true;
    });
    try {
      // Check permission for location
      LocationPermission permission = await Geolocator.checkPermission();
      // if denied, request permission
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            isLoading = false;
            address = 'Permission denied';
          });
          return;
        }
      }
      // if denied forever, open settings
      if (permission == LocationPermission.deniedForever) {
        setState(() {
          isLoading = false;
          address = 'Permission denied forever, please enable from settings';
        });
      }

      // Get current latitude and longitude
      Position position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
          )
      );

      // Get address from latitude and longitude
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark placemark = placemarks[0];
      setState(() {
        isLoading = false;
        latitude = position.latitude.toString();
        longitude = position.longitude.toString();
        address = "${placemark.name}, ${placemark.locality}, ${placemark.administrativeArea}, ${placemark.country}";
      });

    } catch (e) {
      setState(() {
        isLoading = false;
        address = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Geolocator and Geocode'),
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Coordinates:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    'Latitude: $latitude, Longitude: $longitude',
                  ),
                  const SizedBox(height: 20),
                  const Text('Address:', style: TextStyle(fontWeight: FontWeight.bold)),  
                  Text(address ?? 'No data'),
                ],
              ),
      ),
    );
  }
}