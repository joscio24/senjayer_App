import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:senjayer/app/routes/app_routes.dart';
import 'app/routes/app_pages.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      locale: Locale('fr', 'FR'),
      debugShowCheckedModeBanner: false,
      title: "Senjayer Priv8",
      initialRoute: AppRoutes.SPLASH,
      getPages: AppPages.pages,
    );
  }
}
