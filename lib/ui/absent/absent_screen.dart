import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:students_attendance_with_mlkit/ui/components/custom_snackbar.dart';
import 'package:students_attendance_with_mlkit/ui/home_screen.dart';

class AbsentScreen extends StatefulWidget {
  const AbsentScreen({super.key});

  @override
  State<AbsentScreen> createState() => _AbsentScreenState();
}

class _AbsentScreenState extends State<AbsentScreen> {
  String? strAlamat, strDate, strTime, strDateTime;
  double dlat = 0.0, dlong = 0.0;

  final controllerName = TextEditingController();
  final controllerFrom = TextEditingController();
  final controllerTo = TextEditingController();

  String dropValueCategory = 'Please Select';
  List<String> categoryList = [
    'Please Select',
    'Other',
    'Permission',
    'Sick',
  ];

  final CollectionReference dataCollection = FirebaseFirestore.instance.collection('attendance');

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
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white,),
        ),
        title: Text(
          'Permission Request Menu',
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
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                child: Row(
                  children: [
                    SizedBox(width: 12),
                    Icon(
                      Icons.maps_home_work_outlined,
                      color: Colors.white,
                    ),
                    Text(
                      'Please fill the form below',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                child: TextField(
                  textInputAction: TextInputAction.next,
                  controller: controllerName,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    labelText: 'Your name',
                    hintText: 'Enter your name here...',
                    hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                    labelStyle: TextStyle(
                      fontSize: 14,
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.blueAccent)
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.blueAccent)
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.blueAccent,
                      style: BorderStyle.solid,
                      width: 1
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButton(
                    dropdownColor: Colors.white,
                    value: dropValueCategory,
                    onChanged: (value) {
                      setState(() {
                        dropValueCategory = value!;
                      });
                    },
                    items: categoryList.map((value) {
                      return DropdownMenuItem(
                        value: value.toString(),
                        child: Text(value.toString(), style: TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 14,
                          fontWeight: FontWeight.bold
                        )),
                      );
                    }).toList(), 
                    icon: Icon(Icons.arrow_drop_down),
                    iconSize: 24,
                    elevation: 16,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                    ),
                    underline: Container(
                      height: 2,
                      color: Colors.transparent,
                    ),
                    isExpanded: true,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            'From : ',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              readOnly: true,
                              onTap: () async {
                                DateTime? pickedDate = await showDatePicker(
                                    context: context,
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2029),
                                    initialDate: DateTime.now(),
                                    builder: (BuildContext context, Widget? child) {
                                      return Theme(
                                        data: Theme.of(context).copyWith(
                                          colorScheme: ColorScheme.light(
                                            onPrimary: Colors.white,
                                            onSurface: Colors.blueAccent,
                                            primary: Colors.blueAccent,
                                          ),
                                          datePickerTheme: DatePickerThemeData(
                                            headerBackgroundColor:
                                                Colors.blueAccent,
                                            backgroundColor: Colors.white,
                                            headerForegroundColor: Colors.white,
                                            surfaceTintColor: Colors.white,
                                          ),
                                        ),
                                        child: child!,
                                      );
                                    });
                                if (pickedDate != null) {
                                  controllerFrom.text = DateFormat('dd/MM/yy')
                                      .format(pickedDate);
                                }
                              },
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                              controller: controllerFrom,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(8),
                                hintText: 'Starting from',
                                hintStyle: TextStyle(
                                  fontSize: 16,
                                  color: Colors.blueAccent,
                                )
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 14,
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            'Until : ',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              readOnly: true,
                              onTap: () async {
                                DateTime? pickedDate = await showDatePicker(
                                    context: context,
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2029),
                                    initialDate: DateTime.now(),
                                    builder: (BuildContext context, Widget? child) {
                                      return Theme(
                                        data: Theme.of(context).copyWith(
                                          colorScheme: ColorScheme.light(
                                            onPrimary: Colors.white,
                                            onSurface: Colors.blueAccent,
                                            primary: Colors.blueAccent,
                                          ),
                                          datePickerTheme: DatePickerThemeData(
                                            headerBackgroundColor:
                                                Colors.blueAccent,
                                            backgroundColor: Colors.white,
                                            headerForegroundColor: Colors.white,
                                            surfaceTintColor: Colors.white,
                                          ),
                                        ),
                                        child: child!,
                                      );
                                    });
                                if (pickedDate != null) {
                                  controllerTo.text = DateFormat('dd/MM/yy')
                                      .format(pickedDate);
                                }
                              },
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                              controller: controllerTo,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(8),
                                hintText: 'Until',
                                hintStyle: TextStyle(
                                  fontSize: 16,
                                  color: Colors.blueAccent,
                                )
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
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
                          if (controllerName.text.isEmpty || controllerFrom.text.isEmpty || controllerTo.text.isEmpty || dropValueCategory == 'Please Select') {
                            customSnackbar(context, Icons.info_outline, 'Please fill all the form');
                          } else {
                            submitAbsen('-', controllerName.text, dropValueCategory, controllerFrom.text, controllerTo.text);
                          }
                        },
                        child: Center(
                          child: Text(
                            "Make a Request",
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
  showLoaderDialog(BuildContext context) {
      AlertDialog alert = AlertDialog(
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
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
  
  void submitAbsen(String? strAlamat, String name, String strStatus, String from, String until) async {
    showLoaderDialog(context);

    dataCollection.add({
      'address': strAlamat,
      'name': name,
      'status': strStatus,
      'dateTime': '$from-$until',
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