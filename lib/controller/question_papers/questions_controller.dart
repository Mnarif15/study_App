import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:study_app/controller/auth_controller.dart';
import 'package:study_app/controller/question_papers/question_paper_controller.dart';
import 'package:study_app/firebase_ref/loading_status.dart';
import 'package:study_app/firebase_ref/references.dart';
import 'package:study_app/models/question_paper_model.dart';
import 'package:study_app/screens/home/home_screen.dart';
import 'package:study_app/screens/question/result_screen.dart';

class QuestionsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final loadingStatus = LoadingStatus.loading.obs;
  late QuestionsPaperModel questionsPaperModel;
  final allQuestions = <Questions>[];
  final questionIndex = 0.obs;

  bool get isFirstQuestion => questionIndex.value > 0;
  bool get isLastQuestion => questionIndex.value >= allQuestions.length - 1;

  Rxn<Questions> currentQuestion = Rxn<Questions>();

  Timer? _timer;
  int remainSeconds = 1;
  final time = '00.00'.obs;
  double age = 0;

  int get correctQuestionCount => allQuestions
      .where((element) => element.selectedAnswer == element.correctAnswer)
      .toList()
      .length;

  //accuracy calculation based on the right answer
  double get accuracy {
    if (allQuestions.isEmpty) return 0.0;
    return correctQuestionCount / allQuestions.length;
  }

  @override
  void onInit() {
    super.onInit();
    final _questionPaper = Get.arguments;
    if (_questionPaper != null && _questionPaper is QuestionsPaperModel) {
      questionsPaperModel = _questionPaper;
      print("Received question paper ID: ${_questionPaper.id}");
      print("...onReady...");
      loadData(_questionPaper);
    } else {
      // Handle the case where _questionPaper is null or not of expected type
      print("Invalid or null question paper data");
      loadingStatus.value = LoadingStatus.error;
    }
  }

  Future<void> loadData(QuestionsPaperModel questionPaper) async {
  questionsPaperModel = questionPaper;
  loadingStatus.value = LoadingStatus.loading;
  try {
    print("Loading questions for paper ID: ${questionPaper.id}");
    final questionPaperDoc = questionPaperRF.doc(questionPaper.id);
    final questionPaperSnapshot = await questionPaperDoc.get();
    if (!questionPaperSnapshot.exists) {
      print("Question paper document does not exist: ${questionPaper.id}");
      loadingStatus.value = LoadingStatus.error;
      return;
    }
    final QuerySnapshot<Map<String, dynamic>> questionQuery =
        await questionPaperDoc
            .collection("question") // Ensure this matches the Firestore collection name
            .get();
    final questions = questionQuery.docs
        .map((snapshot) => Questions.fromSnapshot(snapshot))
        .toList();
    print("Loaded ${questions.length} questions");

    questionPaper.questions = questions;
    for (Questions _question in questionPaper.questions!) {
      print("Loading answers for question ID: ${_question.id}");
      final QuerySnapshot<Map<String, dynamic>> answerQuery =
          await questionPaperDoc
              .collection("question")
              .doc(_question.id)
              .collection("answers")
              .get();
      final answers = answerQuery.docs
          .map((answer) => Answers.fromSnapshot(answer))
          .toList();
      _question.answers = answers;
      print("Loaded ${answers.length} answers for question ID: ${_question.id}");
    }
  } catch (e) {
    if (kDebugMode) {
      print("Error loading questions: ${e.toString()}");
    }
    loadingStatus.value = LoadingStatus.error;
  }
  if (questionPaper.questions != null &&
      questionPaper.questions!.isNotEmpty) {
    allQuestions.assignAll(questionPaper.questions!);
    currentQuestion.value = questionPaper.questions![0];
    _startTimer(questionPaper.timeSeconds);
    print("...startTimer...");
    if (kDebugMode) {
      print("First question: ${questionPaper.questions![0].question}");
    }
    loadingStatus.value = LoadingStatus.completed;
    print("Loading status: $loadingStatus");
  } else {
    loadingStatus.value = LoadingStatus.error;
  }
}


  void selectedAnswer(String? answer) {
    currentQuestion.value!.selectedAnswer = answer;
    update(['answers_list']);
  }

  String get completedTest {
    final answered = allQuestions
        .where((element) => element.selectedAnswer != null)
        .toList()
        .length;
    return '$answered out of ${allQuestions.length} answered';
  }

  void jumpToQuestion(int index, {bool isGoBack = true}) {
    questionIndex.value = index;
    currentQuestion.value = allQuestions[index];
    if (isGoBack) {
      Get.back();
    }
  }

  void nextQuestion() {
    if (questionIndex.value >= allQuestions.length - 1) return;
    questionIndex.value++;
    currentQuestion.value = allQuestions[questionIndex.value];
  }

  void prevQuestion() {
    if (questionIndex.value <= 0) return;
    questionIndex.value--;
    currentQuestion.value = allQuestions[questionIndex.value];
  }

  void _startTimer(int seconds) {
    const duration = Duration(seconds: 1);
    remainSeconds = seconds;
    _timer = Timer.periodic(duration, (Timer timer) {
      if (remainSeconds == 0) {
        timer.cancel();
      } else {
        int minutes = remainSeconds ~/ 60;
        int seconds = remainSeconds % 60;
        time.value = minutes.toString().padLeft(2, "0") +
            ":" +
            seconds.toString().padLeft(2, "0");
        remainSeconds--;
      }
    });
  }

  RxInt finalScore = 0.obs;

  int calculateFinalScore(Map<String, dynamic> data) {
    // Define adjusted weights for each criterion
  
    const double weightDifficulty = 0.2;
    const double weightAccuracy = 0.5;
    const double weightAttempts = 0.1;
    const double weightRemainingTime = 0.2;

    // Retrieve the values from the data
   
    double difficulty = data['difficulty'];
    double accuracy = data['accuracy'];
    int attempts = data['attempts'];
    int remainingTime = data['remaining_time'];

    // Normalize the values
    double normDifficulty = difficulty / 3.0; // Max level of difficulty is 3
    double normAccuracy = accuracy; // Accuracy is already a percentage
    double normAttempts = 1.0 / (attempts + 1); // Inverse of attempts
    double normRemainingTime = remainingTime / 900.0; //max time is 900 seconds

    // Calculate the weighted sum
    double finalScore =
        (weightDifficulty * normDifficulty) +
        (weightAccuracy * normAccuracy) +
        (weightAttempts * normAttempts) +
        (weightRemainingTime * normRemainingTime);

    // Multiply by 100 to scale up the score and round it
    return (finalScore * 100).round();
  }

  Future<void> complete() async {
    _timer?.cancel();

    // Get the user ID
    User? _user = Get.find<AuthController>().getUser();
    if (_user == null) return;

    // Update number of attempts for the question paper
    await updateQuestionAttempt(
        questionsPaperModel.id, _user.uid, questionsPaperModel.id);

    // Calculate and upload the final score
    finalScore.value = await leaderboardUpload();

    Get.offAndToNamed(ResultScreen.routeName);
  }

  Future<int> leaderboardUpload() async {
    var batch = _firestore.batch();
    User? _user = Get.find<AuthController>().getUser();
    if (_user == null) return 0;

    // Fetch user data to get the name
    DocumentSnapshot userSnapshot = await userRF.doc(_user.email).get();
    var userName = userSnapshot['name'];
    var age = userSnapshot['age'];
    int? ageInt = (age is String) ? int.tryParse(age) : age;

    //fetch question paper difficulty from the stored question paper database
    DocumentSnapshot questionPaperSnapshot = await _firestore
        .collection('questionPapers')
        .doc(questionsPaperModel.id)
        .get();
    var difficulty = questionPaperSnapshot['difficulty'];

    DocumentReference questionDoc = leaderboardRF
        .doc(_user.email)
        .collection('questions')
        .doc(questionsPaperModel.id);

    DocumentSnapshot questionSnapshot = await questionDoc.get();
    Map<String, dynamic>? data =
        questionSnapshot.data() as Map<String, dynamic>?;
    int attempts =
        (data != null && data.containsKey('attempts')) ? data['attempts'] : 0;

    int remainingTime = remainSeconds;

    // Prepare data for WSM calculation
    Map<String, dynamic> wsmData = {
      
      'difficulty': difficulty,
      'accuracy': accuracy,
      'attempts': attempts,
      'remaining_time': remainingTime
    };

    // Calculate final score using WSM algorithm
    int finalScore = calculateFinalScore(wsmData);

    // Use the retrieved and incremented attempts value in the batch.set operation
    batch.set(
      leaderboardRF
          .doc(_user.email)
          .collection('questions')
          .doc(questionsPaperModel.id),
      {
        "question id": questionsPaperModel.id,
        "age": ageInt,
        "difficulty": difficulty,
        "accuracy": accuracy,
        "attempts": attempts,
        "remaining_time": remainingTime,
        "final_score": finalScore, // Include final score
      },
      SetOptions(merge: true),
    );

    // Also add/update the name at the user document level
    batch.set(
      leaderboardRF.doc(_user.email),
      {
        "name": userName,
      },
      SetOptions(merge: true),
    );

    await batch.commit();
    print(
        'Leaderboard data uploaded for question paper ID: ${questionsPaperModel.id}, accuracy: $accuracy, attempts: $attempts, remaining_time: $remainingTime, final_score: $finalScore');
    return finalScore;
  }

  void tryAgain() {
    Get.find<QuestionPaperController>()
        .navigateToQuestions(paper: questionsPaperModel, tryAgain: true);
  }

  void navigateToHome() {
    _timer?.cancel();
    Get.offNamedUntil(HomeScreen.routeName, (route) => false);
  }

  int calculateRemainingTime(int totalTime, int timeUsed) {
    return totalTime - timeUsed;
  }

  void updateAccuracy(double accuracy) {
    accuracy = (correctQuestionCount / allQuestions.length);
  }

  Future<void> updateQuestionAttempt(
      String questionId, String userId, String questionPaperId) async {
    User? _user = Get.find<AuthController>().getUser();
    if (_user == null) return;

    DocumentReference questionDoc =
        leaderboardRF.doc(_user.email).collection('questions').doc(questionId);

    DocumentSnapshot questionSnapshot = await questionDoc.get();
    Map<String, dynamic>? data =
        questionSnapshot.data() as Map<String, dynamic>?;
    int numOfAttempt = (data != null && data.containsKey('attempts'))
        ? data['attempts'] + 1
        : 1;

    await questionDoc.set({'attempts': numOfAttempt}, SetOptions(merge: true));
    print(
        "Updated number of attempts for question ID: $questionId to $numOfAttempt");
  }

  static Future<void> calculateTotalScore(String userEmail) async {
  int totalScore = 0;
  QuerySnapshot questionsSnapshot = await leaderboardRF
      .doc(userEmail)
      .collection('questions')
      .get();

  for (var doc in questionsSnapshot.docs) {
    if (doc.exists) {
      Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
      if (data != null && data['final_score'] != null) {
        totalScore += (data['final_score'] as num).toInt();
      }
    }
  }

  await leaderboardRF.doc(userEmail).set(
    {
      "total_score": totalScore,
    },
    SetOptions(merge: true),
  );
}

}
