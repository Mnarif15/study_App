import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:study_app/configs/themes/custom_text_styles.dart';
import 'package:study_app/configs/themes/ui_parameter.dart';
import 'package:study_app/controller/question_papers/question_controller_extension.dart';
import 'package:study_app/controller/question_papers/questions_controller.dart';
import 'package:study_app/screens/question/answer_check_screen.dart';
import 'package:study_app/widgets/common/background_decoration.dart';
import 'package:study_app/widgets/common/custom_app_bar.dart';
import 'package:study_app/widgets/common/main_button.dart';
import 'package:study_app/widgets/content_area.dart';
import 'package:study_app/widgets/questions/answer_card.dart';
import 'package:study_app/widgets/questions/question_number_card.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});
  static const String routeName = "/resultscreen";

  @override
  Widget build(BuildContext context) {
    final QuestionsController _controller = Get.find<QuestionsController>();
    Color _textColor =
        Get.isDarkMode ? Colors.white : Theme.of(context).primaryColor;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(
        leading: const SizedBox(
          height: 80,
        ),
        title: _controller.correctAnswerdQuestions,
      ),
      body: BackgroundDecoration(
          child: Column(
        children: [
          Expanded(
              child: ContentArea(
                  child: Column(
            children: [
              SvgPicture.asset('assets/images/bulb.svg'),
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 5),
                child: Text('You have answered all questions',
                    style: headerText.copyWith(color: _textColor)),
              ),
              Obx(() => Text(
                'Your Final Score: ${_controller.finalScore.value}',
                style: TextStyle(color: _textColor, fontSize: 24),
              )),
              const SizedBox(
                height: 25,
              ),
              const Text(
                'Tap below question numbers to view correct answers',
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 25,
              ),
              Expanded(
                  child: GridView.builder(
                      itemCount: _controller.allQuestions.length,
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: Get.width ~/ 75,
                          childAspectRatio: 1,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8),
                      itemBuilder: (_, index) {
                        final _question = _controller.allQuestions[index];
                        AnswerStatus _status = AnswerStatus.notanswered;
                        final _selectedAnswer = _question.selectedAnswer;
                        final _correctAnswer = _question.correctAnswer;
                        if (_selectedAnswer == _correctAnswer) {
                          _status = AnswerStatus.correct;
                        } else if (_question.selectedAnswer == null) {
                          _status = AnswerStatus.notanswered;
                        } else {
                          _status = AnswerStatus.wrong;
                        }
                        return QuestionNumberCard(
                            index: index + 1,
                            status: _status,
                            onTap: () {
                              _controller.jumpToQuestion(index, isGoBack: false);
                              Get.toNamed(AnswerCheckScreen.routeName);
                            });
                      }))
            ],
          ))),
          ColoredBox(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Padding(
              padding: UIParameters.mobileScreenPadding,
              child: Row(
                children: [
                  Expanded(
                      child: MainButton(
                    onTap: () {
                      _controller.tryAgain();
                    },
                    color: Colors.blueGrey,
                    title: 'Try Again',
                  )),
                  const SizedBox(width: 5),
                  Expanded(
                      child: MainButton(
                    onTap: () {
                      _controller.navigateToHome();
                    },
                    title: 'Go Home',
                  ))
                ],
              ),
            ),
          )
        ],
      )),
    );
  }
}
