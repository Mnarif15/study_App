import 'package:flutter/material.dart';
import 'package:study_app/controller/question_papers/data_uploader.dart';
import 'package:get/get.dart';
import 'package:study_app/firebase_ref/loading_status.dart';

class DataUploaderScreen extends StatelessWidget {
  final DataUploader controller = Get.put(DataUploader());
  DataUploaderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Obx(() => Text(
          controller.loadingStatus.value == LoadingStatus.completed
              ? "Uploading Completed"
              : "Uploading...")),
    ));
  }
}
