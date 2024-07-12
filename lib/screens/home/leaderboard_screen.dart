import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:study_app/configs/themes/custom_text_styles.dart';
import 'package:study_app/configs/themes/ui_parameter.dart';
import 'package:study_app/configs/themes/app_colors.dart';
import 'package:study_app/widgets/content_area.dart';
import 'package:study_app/widgets/common/background_decoration.dart';
import 'package:study_app/controller/question_papers/questions_controller.dart'; // Import the file where calculateTotalScore is defined

class LeaderboardPage extends StatelessWidget {
  static const String routeName = "/leaderboardpage";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Leaderboard',
          style: TextStyle(
              fontSize: 20,
              color: onSurfaceTextColor,
              fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: BackgroundDecoration(
        child: ContentArea(
          child: FutureBuilder(
            future: FirebaseFirestore.instance.collection('leaderboard').get(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                print("Error fetching data: ${snapshot.error}");
                return Center(child: Text("Error loading data."));
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                print("No data available in snapshot.");
                return Center(child: Text("No leaderboard entries."));
              }

              final leaderboardEntries = snapshot.data!.docs;
              print("Leaderboard entries found: ${leaderboardEntries.length}");

              return FutureBuilder(
                future: Future.wait(leaderboardEntries.map((entry) async {
                  await QuestionsController.calculateTotalScore(entry.id);
                  return entry;
                })),
                builder: (context,
                    AsyncSnapshot<List<QueryDocumentSnapshot>> newSnapshot) {
                  if (newSnapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (newSnapshot.hasError) {
                    print(
                        "Error calculating total scores: ${newSnapshot.error}");
                    return Center(child: Text("Error loading leaderboard."));
                  }

                  final sortedEntries = newSnapshot.data!
                    ..sort((a, b) {
                      int scoreA =
                          (a.data() as Map<String, dynamic>?)?['total_score'] ??
                              0;
                      int scoreB =
                          (b.data() as Map<String, dynamic>?)?['total_score'] ??
                              0;
                      return scoreB.compareTo(scoreA);
                    });

                  return ListView.builder(
                    itemCount: sortedEntries.length,
                    itemBuilder: (context, index) {
                      final entry = sortedEntries[index];
                      final entryData = entry.data() as Map<String, dynamic>?;

                      return Card(
                        margin: const EdgeInsets.all(10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ExpansionTile(
                          title: Text(
                            entryData?['name'] ?? 'No Name',
                            style: detailText.copyWith(
                              color: Get.isDarkMode
                                  ? Colors.white
                                  : Theme.of(context).primaryColor,
                            ),
                          ),
                          subtitle: Text(
                            'Total Score: ${entryData?['total_score'] ?? 0}',
                            style: detailText.copyWith(color: Colors.black),
                          ),
                          children: [
                            StreamBuilder(
                              stream: entry.reference
                                  .collection('questions')
                                  .snapshots(),
                              builder: (context,
                                  AsyncSnapshot<QuerySnapshot> testSnapshot) {
                                if (testSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                      child: CircularProgressIndicator());
                                }

                                if (testSnapshot.hasError) {
                                  print(
                                      "Error fetching test data: ${testSnapshot.error}");
                                  return Center(
                                      child: Text("Error loading test data."));
                                }

                                if (!testSnapshot.hasData ||
                                    testSnapshot.data!.docs.isEmpty) {
                                  print("No data available in test snapshot.");
                                  return Center(
                                      child: Text("No test data available."));
                                }

                                final tests = testSnapshot.data!.docs;
                                print("Test data found: ${tests.length}");

                                return Column(
                                  children: tests.map((test) {
                                    final testData =
                                        test.data() as Map<String, dynamic>?;
                                    return ListTile(
                                      title: Text(
                                        'Question ID: ${testData?['question id'] ?? 'Unknown'}',
                                        style: detailText.copyWith(
                                          color: Get.isDarkMode
                                              ? Colors.white
                                              : Theme.of(context).primaryColor,
                                        ),
                                      ),
                                      subtitle: Text(
                                        'Score: ${testData?['final_score'] ?? 0} Time: ${testData?['remaining_time'] ?? 0} secs | Accuracy: ${testData?['accuracy'] ?? 0.0}',
                                        style: detailText.copyWith(
                                            color: Colors.black),
                                      ),
                                    );
                                  }).toList(),
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
