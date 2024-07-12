import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:study_app/configs/themes/app_icons.dart';
import 'package:study_app/configs/themes/custom_text_styles.dart';
import 'package:study_app/configs/themes/ui_parameter.dart';
import 'package:study_app/controller/auth_controller.dart';
import 'package:study_app/controller/question_papers/question_paper_controller.dart';
import 'package:study_app/controller/question_papers/questions_controller.dart';
import 'package:study_app/controller/purchase_controller.dart'; // Import the PurchaseController
import 'package:study_app/models/question_paper_model.dart';
import 'package:study_app/screens/home/leaderboard_screen.dart';
import 'package:study_app/screens/purchase_screen.dart';
import 'package:study_app/widgets/app_icon_text.dart';
import 'package:study_app/widgets/dialogs/dialogue_widget.dart'; // Import the Dialogs

class QuestionCard extends StatefulWidget {
  final QuestionsPaperModel model;

  const QuestionCard({Key? key, required this.model}) : super(key: key);

  @override
  _QuestionCardState createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard> {
  final PurchaseController purchaseController = Get.find<PurchaseController>();

  void _handleTap(BuildContext context) async {
    if (widget.model.difficulty > 1 &&
        !purchaseController.isPurchased(widget.model.id)) {
      String? result =
          await Get.to(() => PurchaseScreen(questionId: widget.model.id));

      if (result == widget.model.id) {
        purchaseController.addPurchasedItem(widget.model.id);
        setState(() {});
        Get.back(); // Navigate back to the home screen
      }
    } else {
      _navigateToQuestions();
    }
  }

  void _navigateToQuestions() {
    Get.find<QuestionPaperController>()
        .navigateToQuestions(paper: widget.model, tryAgain: false);
  }

  @override
  Widget build(BuildContext context) {
    const double _padding = 10.0;
    bool isLocked = widget.model.difficulty > 1 &&
        !purchaseController.isPurchased(widget.model.id);

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
              borderRadius: UIParameters.cardBorderRadius,
              color: Theme.of(context).cardColor),
          child: InkWell(
            onTap: () => _handleTap(context),
            child: Padding(
              padding: const EdgeInsets.all(_padding),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: ColoredBox(
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.1),
                          child: SizedBox(
                            height: Get.width * 0.15,
                            width: Get.width * 0.15,
                            child: CachedNetworkImage(
                              imageUrl: widget.model.imageUrl!,
                              placeholder: (context, url) => Container(
                                alignment: Alignment.center,
                                child: const CircularProgressIndicator(),
                              ),
                              errorWidget: (context, url, error) => Image.asset(
                                  "assets/images/app_splash_logo.png"),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 12,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.model.title,
                              style: cartTitles(context),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 10, bottom: 15),
                              child: Text(widget.model.description),
                            ),
                            Row(
                              children: [
                                AppIconText(
                                    icon: Icon(
                                      Icons.help_outline_sharp,
                                      color: Get.isDarkMode
                                          ? Colors.white
                                          : Theme.of(context).primaryColor,
                                    ),
                                    text: Text(
                                      '${widget.model.questionCount} Questions',
                                      style: detailText.copyWith(
                                        color: Get.isDarkMode
                                            ? Colors.white
                                            : Theme.of(context).primaryColor,
                                      ),
                                    )),
                                const SizedBox(
                                  width: 15,
                                ),
                                AppIconText(
                                    icon: Icon(
                                      Icons.timer,
                                      color: Get.isDarkMode
                                          ? Colors.white
                                          : Theme.of(context).primaryColor,
                                    ),
                                    text: Text(
                                      widget.model.timeInMinits(),
                                      style: detailText.copyWith(
                                        color: Get.isDarkMode
                                            ? Colors.white
                                            : Theme.of(context).primaryColor,
                                      ),
                                    ))
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                  Positioned(
                    bottom: -_padding,
                    right: -_padding,
                    child: GestureDetector(
                      onTap: () async {
                        await uploadTotalScoreAndNavigate();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 20),
                        child: Icon(AppIcons.throphyOutline),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(cardBoardRadius),
                              bottomRight: Radius.circular(cardBoardRadius),
                            ),
                            color: Theme.of(context).primaryColor),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        if (isLocked)
          Positioned.fill(
            child: GestureDetector(
              onTap: () => _handleTap(context),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.lock,
                        color: Colors.white,
                        size: 50,
                      ),
                      Text(
                        'Purchase Required',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> uploadTotalScoreAndNavigate() async {
    User? _user = Get.find<AuthController>().getUser();
    if (_user != null) {
      await QuestionsController.calculateTotalScore(_user.email!);
    }
    Get.to(() => LeaderboardPage());
  }
}
