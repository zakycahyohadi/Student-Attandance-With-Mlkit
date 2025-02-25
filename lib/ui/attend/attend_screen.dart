import 'dart:io';

import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:students_attendance_with_mlkit/ui/attend/camera_screen.dart';
import 'package:students_attendance_with_mlkit/ui/components/custom_snackbar.dart';
import 'package:students_attendance_with_mlkit/ui/home_screen.dart';

class AttendScreen extends StatefulWidget {
  const AttendScreen({
    super.key,
    this.image
  });

  final XFile ? image;


  @override
  State < AttendScreen > createState() => _AttendScreenState(image);
}

class _AttendScreenState extends State < AttendScreen > {
  _AttendScreenState(this.image);
  XFile ? image;
  String ? strAlamat,
  strDate,
  strTime,
  strDateTime,
  strStatus = "Attend";
  bool isLoading = false;
  double dlat = 0.0,
  dlong = 0.0;
  int dateHours = 0,
  dateMinutes = 0;
  final controllerName = TextEditingController();
  final CollectionReference dataCollection = FirebaseFirestore.instance.collection('attendance');

  @override
  void initState() {
    handleLocationPermission();
    setDateTime();
    setStatusAbsent();

    if (image != null) {
      isLoading = true;
      getGeoLocationPosition();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blueAccent,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white, ),
        ),
        title: Text(
          'Attendance Menu',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Card(
          color: Colors.white,
          margin: const EdgeInsets.fromLTRB(10, 10, 10, 30),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)
            ),
            elevation: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10)
                    ),
                    color: Colors.blueAccent,
                  ),
                  child: Row(
                    children: [
                      SizedBox(width: 12),
                      Icon(Icons.face_retouching_natural, color: Colors.white),
                      SizedBox(width: 12),
                      Text(
                        'Please Take a Selfie!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white
                        ),
                      )
                    ],
                  ),
                ),
                const Padding(
                    padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
                    child: Text(
                      'Capture a Picture!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CameraScreen()
                      ),
                    ),
                    child: Container(
                      margin: EdgeInsets.fromLTRB(10, 0, 10, 20),
                      width: size.width,
                      height: 150,
                      child: DottedBorder(
                        radius: Radius.circular(10),
                        borderType: BorderType.RRect,
                        color: Colors.blueAccent,
                        strokeWidth: 1,
                        dashPattern: [5, 5],
                        child: SizedBox.expand(
                          child: FittedBox(
                            child: image != null ?
                            Image.file(File(image!.path), fit: BoxFit.cover) :
                            const Icon(Icons.camera_enhance_outlined, color: Colors.blueAccent)
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: TextField(
                      textInputAction: TextInputAction.done,
                      controller: controllerName,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        labelText: 'Your name',
                        hintText: 'Enter your name here...',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: Colors.grey
                        ),
                        labelStyle: TextStyle(
                          fontSize: 14,
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.blueAccent,
                          )
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.blueAccent,
                          )
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      "Your Location",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent
                      ),
                    )
                  ),
                  isLoading ?
                  Center(child: CircularProgressIndicator(color: Colors.blueAccent, )) :
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: SizedBox(
                      height: 5 * 24.0,
                      child: TextField(
                        enabled: false,
                        maxLines: 5,
                        decoration: InputDecoration(
                          alignLabelWithHint: true,
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.blueAccent,
                            )
                          ),
                          hintText: strAlamat != null ?
                          strAlamat :
                          'Your location...',
                          hintStyle: TextStyle(
                            fontSize: 14,
                            color: Colors.grey
                          ),
                          fillColor: Colors.transparent,
                          filled: true,
                        ),
                      ),
                    )
                  ),
                  Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.all(30),
                    child: Material(
                      elevation: 3,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: size.width,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white,
                        ),
                        child: Material(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.blueAccent,
                          child: InkWell(
                            splashColor: Colors.blue,
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              if (image == null || controllerName.text.isEmpty) {
                                customSnackbar(context, Icons.info_outline, "Please complete the form");
                              } else {
                                submitAbsen(strAlamat, controllerName.text.toString(), strStatus);
                              }
                            },
                            child: Center(
                              child: Text(
                                "Report Now",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
              ],
            ),
        ),
      ),
    );
  }

  // Handle Location Permission
  Future < bool > handleLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      customSnackbar(context, Icons.location_off,
        'Location services is disabled, please enable it');
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        customSnackbar(context, Icons.location_off, 'Permission denied');
        return false;
      }
    }

    if (permission == LocationPermission.denied) {
      customSnackbar(context, Icons.location_off,
        "Location Permission denied forever, we can't request permission");
      return false;
    }
    return true;
  }

  // Set Date Time
  void setDateTime() async {
    var dateNow = DateTime.now();
    var dateFormat = DateFormat('dd MMMM yyyy');
    var dateTime = DateFormat('HH:mm:ss');
    var dateHour = DateFormat('HH');
    var dateMinute = DateFormat('mm');

    setState(() {
      strDate = dateFormat.format(dateNow);
      strTime = dateTime.format(dateNow);
      strDateTime = "$strDate | $strTime";

      dateHours = int.parse(dateHour.format(dateNow));
      dateMinutes = int.parse(dateMinute.format(dateNow));
    });
  }

  // Check Absent Status
  void setStatusAbsent() {
    if (dateHours < 8 || (dateHours == 8 && dateMinutes <= 30)) {
      strStatus = "Attend";
    } else if ((dateHours > 8 && dateHours < 18) || (dateHours == 8 && dateMinutes >= 31)) {
      strStatus = "Late";
    } else {
      strStatus = "Absent";
    }
  }

  // Get Location
  Future < void > getGeoLocationPosition() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    setState(() {
      // dlat = position.latitude;
      // dlong = position.longitude;
      isLoading = false;
      getAddressFromLongLat(position);
    });
  }

  void getAddressFromLongLat(Position position) async {
    List < Placemark > placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

    Placemark place = placemarks[0];
    setState(() {
      dlat = position.latitude;
      dlong = position.longitude;

      strAlamat = "${place.street}, ${place.subLocality}, ${place.postalCode}, ${place.country}";
    });
  }

  showLoaderDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation < Color > (Colors.blueAccent),
          ),
          SizedBox(width: 10),
          Text('Checking data...')
        ],
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void submitAbsen(String ? strAlamat, String name, String ? strStatus) async {
    showLoaderDialog(context);

    dataCollection.add({
      'address': strAlamat,
      'name': name,
      'status': strStatus,
      'dateTime': strDateTime,
    }).then((result) {
      setState(() {
        Navigator.pop(context);
        try {
          customSnackbar(context, Icons.check_circle_outline, 'Yeay! attendance report succeeded!');
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
        } catch (e) {
          customSnackbar(context, Icons.error_outline, "Error: $e");
        }
      });
    }).catchError((error) {
      customSnackbar(context, Icons.error_outline, "Error: $error");
      Navigator.pop(context);
    });
  }
}