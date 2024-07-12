import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:study_app/bindings/initial_bindings.dart';
import 'package:study_app/controller/theme_controller.dart';
import 'package:study_app/firebase_options.dart';
import 'package:study_app/routes/app_routes.dart';
import 'configs/themes/app_dark_theme.dart';
import 'configs/themes/app_light_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  InitialBindings().dependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.put(ThemeController());

    return Obx(
      () => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        theme: LightTheme().buildLightTheme(),
        darkTheme: DarkTheme().buildDarkTheme(),
        themeMode: themeController.isDarkMode.value ? ThemeMode.dark : ThemeMode.light,
        getPages: Approutes.routes(),
      ),
    );
  }
}
