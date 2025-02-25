import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:students_attendance_with_mlkit/firebase_options.dart';
import 'package:students_attendance_with_mlkit/ui/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        cardTheme: const CardTheme(surfaceTintColor: Colors.white),
        dialogTheme: const DialogTheme(
          surfaceTintColor: Colors.white,
          backgroundColor: Colors.white
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}


/*======= Abandoned ========*/

// class MyHome extends StatelessWidget {
//   const MyHome({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Students Attendance'),
//       ),
//       body: Center(
//         child: Column(
//           children: [
//             Lottie.asset('assets/raw/office.json'),
//             const SizedBox(height: 20),
//             FilledButton(
//                 onPressed: () {
//                   Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => const GetlocationScreen()));
//                 },
//                 child: const Text('Get Location'))
//           ],
//         ),
//       ),
//     );
//   }
// }
