import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/home/add_location.dart';
import 'package:flutter_application_1/pages/home/edit_location.dart';
import 'package:flutter_application_1/pages/home/login_page.dart';
import 'package:flutter_application_1/pages/home/main_page.dart';
import 'package:flutter_application_1/pages/home/manage_page.dart';
import 'package:flutter_application_1/pages/home/recommend_page.dart';
import 'package:flutter_application_1/pages/location/popular_location_detail.dart';
import 'package:flutter_application_1/pages/location/recommend_detail.dart';
import 'package:flutter_application_1/pages/search/search_page.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart'; // Import Firebase App Check
import 'package:firebase_storage/firebase_storage.dart'; // Import Firebase Storage

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // เริ่มต้น Firebase
  await Firebase.initializeApp();

  // เปิดใช้งาน Firebase App Check
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,  // ใช้ Debug provider สำหรับ Android
    appleProvider: AppleProvider.debug,      // สำหรับ iOS (ถ้าจำเป็น)
  );

  // เริ่มต้นแอป
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MainPage(),
    );
  }
}