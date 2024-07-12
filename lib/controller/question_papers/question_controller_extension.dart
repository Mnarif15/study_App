import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:study_app/controller/auth_controller.dart';
import 'package:study_app/controller/question_papers/questions_controller.dart';
import 'package:study_app/firebase_ref/references.dart';

extension QuestionControllerExtension on QuestionsController {
  
  String get correctAnswerdQuestions {
    return '$correctQuestionCount out of ${allQuestions.length} are correct';
  }

  String get points {
    var points = (correctQuestionCount / allQuestions.length) *
        100 *
        (questionsPaperModel.timeSeconds - remainSeconds) /
        questionsPaperModel.timeSeconds *
        100;
    return points.toStringAsFixed(2);
  }

  Future<void> saveTestResult() async {
    var batch = fireStore.batch();
    User? _user = Get.find<AuthController>().getUser();
    if (_user == null) return;
    batch.set(
        userRF
            .doc(_user.email)
            .collection('myrecent_tests')
            .doc(questionsPaperModel.id),
        {
          "points": points,
          "correct_answer": '$correctQuestionCount/${allQuestions.length}',
          "question_id": questionsPaperModel.id,
          'time': questionsPaperModel.timeSeconds - remainSeconds
        });
    batch.commit();
    navigateToHome();

    
  }
}
