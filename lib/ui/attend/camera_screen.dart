import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:lottie/lottie.dart';
import 'package:students_attendance_with_mlkit/ui/attend/attend_screen.dart';
import 'package:students_attendance_with_mlkit/ui/components/custom_snackbar.dart';
import 'package:students_attendance_with_mlkit/utils/google_ml_kit.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  FaceDetector faceDetector = GoogleMlKit.vision.faceDetector(FaceDetectorOptions(
    enableContours: true,
    enableClassification: true,
    enableLandmarks: true,
    enableTracking: true
  ));

  List<CameraDescription>? cameras;
  CameraController? controller;
  XFile? image;
  bool isBusy = false;

  @override
  void initState() {
    super.initState();
    loadCamera();
  }

  Future<void> loadCamera() async {
    try {
      cameras = await availableCameras();
      if (cameras != null && cameras!.isNotEmpty) {
        int cameraIndex = cameras!.length > 1 ? 1 : 0;
        controller = CameraController(cameras![cameraIndex], ResolutionPreset.max);
        await controller!.initialize();
        if (mounted) setState(() {});
      } else {
        if (mounted) customSnackbar(context, Icons.camera_enhance_outlined, 'No camera found');
      }
    } catch (e) {
      if (mounted) customSnackbar(context, Icons.error_outline, "Failed to initialize camera: $e");
    }
  }

  @override
  void dispose() {
    faceDetector.close();
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    void showLoaderDialog(BuildContext context) {
      AlertDialog alert = AlertDialog(
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent)),
            SizedBox(width: 10),
            Text('Checking data...')
          ],
        ),
      );
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => alert,
      );
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blueAccent,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        ),
        title: Text(
          'Take a selfie', 
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          SizedBox(
            height: size.height,
            width: size.width,
            child: controller == null
                ? const Center(child: Text('Oops, camera error!',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))
                : !controller!.value.isInitialized
                ? const Center(child: CircularProgressIndicator())
                : CameraPreview(controller!),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 40),
            child: Lottie.asset('assets/raw/face_id_ring.json', fit: BoxFit.cover),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: size.width,
              height: 200,
              padding: const EdgeInsets.symmetric(horizontal: 30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    "Make sure you're in a well-lit area and your face is clearly visible",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: ClipOval(
                      child: Material(
                        color: Colors.blueAccent,
                        child: InkWell(
                          splashColor: Colors.blue,
                          child: SizedBox(
                            width: 56,
                            height: 56,
                            child: Icon(Icons.camera_enhance_outlined, color: Colors.white),
                          ),
                          onTap: () async {
                            final hasPermissions = await handleLocationPermission();
                            try {
                              if (controller != null && controller!.value.isInitialized) {
                                controller!.setFlashMode(FlashMode.off);
                                image = await controller!.takePicture();
                                if (image != null && mounted) {
                                  setState(() {
                                    if (hasPermissions) {
                                      showLoaderDialog(context);
                                      final inputImage = InputImage.fromFilePath(image!.path);
                                      Platform.isAndroid
                                          ? processImage(inputImage)
                                          : Navigator.push(context, MaterialPageRoute(builder: (context) => AttendScreen(image: image)));
                                    } else {
                                      customSnackbar(context, Icons.location_on_outlined, 'Please enable location permission');
                                    }
                                  });
                                } else {
                                  customSnackbar(context, Icons.camera_alt, 'Failed to capture image');
                                }
                              }
                            } catch (e) {
                              customSnackbar(context, Icons.error_outline, "Error: $e");
                            }
                          },
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<bool> handleLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) customSnackbar(context, Icons.location_off, 'Location services are disabled, please enable them');
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) customSnackbar(context, Icons.location_off, 'Permission denied');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) customSnackbar(context, Icons.location_off, "Location Permission denied forever, we can't request permission");
      return false;
    }
    return true;
  }

  Future<void> processImage(InputImage inputImage) async {
    if (isBusy) return;
    isBusy = true;
    final faces = await faceDetector.processImage(inputImage);
    isBusy = false;

    if (mounted) {
      setState(() {
        Navigator.of(context).pop(true);
        if (faces.isNotEmpty) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AttendScreen(image: image)));
        } else {
          customSnackbar(context, Icons.face_retouching_natural_outlined, 'Oops, make sure your face is clearly visible');
        }
      });
    }
  }
}
