import 'package:get/get.dart';
import 'package:study_app/controller/auth_controller.dart';
import 'package:study_app/controller/question_papers/data_uploader.dart';
import 'package:study_app/controller/theme_controller.dart';
import 'package:study_app/services/firebase_storage_service.dart';
import 'package:study_app/controller/question_papers/questions_controller.dart';
import 'package:study_app/controller/purchase_controller.dart'; // Import the PurchaseController

class InitialBindings implements Bindings {
  @override
  void dependencies() {
    Get.put(ThemeController());
    Get.put(AuthController(), permanent: true);
    Get.put(FirebaseStorageService());
    Get.put(DataUploader());
    Get.lazyPut(() => QuestionsController()); // Add QuestionsController initialization
    Get.put(PurchaseController(), permanent: true); // Add PurchaseController initialization
  }
}
