import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:study_app/configs/themes/app_colors.dart';
import 'package:study_app/configs/themes/ui_parameter.dart';
import 'package:study_app/widgets/questions/answer_card.dart';

class QuestionNumberCard extends StatelessWidget {
  const QuestionNumberCard({
    super.key,
    required this.index,
    required this.onTap,
    required this.status,
  });

  final int index;
  final AnswerStatus? status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    Color _backgroundColor;
    IconData _iconData;
    Color _iconColor;

    switch (status) {
      case AnswerStatus.correct:
        _backgroundColor = correctAnswerColor;
        _iconData = Icons.check_circle;
        _iconColor = Colors.white;
        break;
      case AnswerStatus.wrong:
        _backgroundColor = wrongAnswerColor;
        _iconData = Icons.cancel;
        _iconColor = Colors.white;
        break;
      case AnswerStatus.answered:
        _backgroundColor = Colors.blueAccent.withOpacity(0.1);
        _iconData = Icons.check_circle;
        _iconColor = Colors.blueAccent;
        break;
      case AnswerStatus.notanswered:
        _backgroundColor = Get.isDarkMode
            ? Colors.red.withOpacity(0.5)
            : Theme.of(context).primaryColor.withOpacity(0.1);
        _iconData = Icons.help;
        _iconColor = Colors.grey;
        break;
      default:
        _backgroundColor = Theme.of(context).primaryColor.withOpacity(0.1);
        _iconData = Icons.help_outline;
        _iconColor = Colors.grey;
    }

    return InkWell(
      borderRadius: UIParameters.cardBorderRadius,
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: _backgroundColor,
          borderRadius: UIParameters.cardBorderRadius,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _iconData,
                color: _iconColor,
                size: 17, // Keep the size of the icon to 20
              ),
              const SizedBox(height: 5),
              Text(
                '$index',
                style: TextStyle(
                  color: status == AnswerStatus.notanswered
                      ? Theme.of(context).primaryColor
                      : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
