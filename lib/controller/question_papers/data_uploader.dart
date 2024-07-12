import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:study_app/models/question_paper_model.dart';
import 'package:study_app/firebase_ref/loading_status.dart';
import 'package:study_app/firebase_ref/references.dart';

class DataUploader extends GetxController {
  final loadingStatus = LoadingStatus.loading.obs;

  @override
  void onReady() {
    uploadData();
    super.onReady();
  }

  Future<void> uploadData() async {
    loadingStatus.value = LoadingStatus.loading;
    final fireStore = FirebaseFirestore.instance;

    try {
      final manifestContent = await DefaultAssetBundle.of(Get.context!)
          .loadString("AssetManifest.json");
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);

      final papersInAssets = manifestMap.keys
          .where((path) =>
              path.startsWith("assets/DB/papers") && path.contains(".json"))
          .toList();

      if (papersInAssets.isEmpty) {
        print('No question paper JSON files found in assets/DB/papers');
        loadingStatus.value = LoadingStatus.error;
        return;
      }

      List<QuestionsPaperModel> questionPapers = [];
      for (var paper in papersInAssets) {
        String stringPaperContent = await rootBundle.loadString(paper);
        print('Loaded content from: $paper');
        questionPapers
            .add(QuestionsPaperModel.fromJson(json.decode(stringPaperContent)));
      }

      var batch = fireStore.batch();

      for (var paper in questionPapers) {
        batch.set(questionPaperRF.doc(paper.id), {
          'id': paper.id,
          'title': paper.title,
          'image_url': paper.imageUrl,
          'description': paper.description,
          'time_seconds': paper.timeSeconds,
          'difficulty': paper.difficulty,
          'questions_count':
              paper.questions == null ? 0 : paper.questions!.length,
        });

        for (var question in paper.questions!) {
          var questionPath =
              questionRF(paperId: paper.id, questionId: question.id);
          batch.set(questionPath, {
            "question": question.question,
            "correct_answer": question.correctAnswer
          });

          for (var answer in question.answers) {
            batch.set(
                questionPath.collection("answers").doc(answer.identifier), {
              "identifier": answer.identifier,
              "answer": answer.answer,
            });
          }
        }
      }

      await batch.commit();
      print('Question papers uploaded successfully.');
      loadingStatus.value = LoadingStatus.completed;
    } catch (e) {
      print('Error uploading data: $e');
      loadingStatus.value = LoadingStatus.error;
    }
  }
}
