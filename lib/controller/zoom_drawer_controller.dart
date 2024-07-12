import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:get/get.dart';
import 'package:study_app/controller/auth_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class MyZoomDrawerController extends GetxController {
  final zoomDrawerController = ZoomDrawerController();
  Rxn<User?> user = Rxn();

  @override
  void onReady() {
    user.value = Get.find<AuthController>().getUser();
    super.onReady();
  }

  void toogleDrawer() {
    zoomDrawerController.toggle?.call();
    update();
  }

  void signOut() {
    Get.find<AuthController>().signOut();
  }

  void signIn(String age) {
    Get.find<AuthController>().signInWithGoogle(age);
  }

  void promptSignIn() {
    Get.defaultDialog(
      title: "Enter Age",
      content: Column(
        children: [
          TextField(
            decoration: InputDecoration(hintText: "Age"),
            keyboardType: TextInputType.number,
            onSubmitted: (age) {
              if (age.isNotEmpty) {
                signIn(age);
                Get.back();
              }
            },
          ),
        ],
      ),
    );
  }

  void website() {}

  void facebook() {
    _launch("https://www.facebook.com");
  }

  void email() {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'info@bestech.com',
    );
    _launch(emailLaunchUri.toString());
  }

  Future<void> _launch(String url) async {
    if (!await launch(url)) {
      throw 'Could not launch $url';
    }
  }
}
