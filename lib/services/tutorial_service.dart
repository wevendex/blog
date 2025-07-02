import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class TutorialService {
  static final TutorialService _instance = TutorialService._internal();
  factory TutorialService() => _instance;
  TutorialService._internal();

  TutorialCoachMark? _tutorial;

  void showTutorial(BuildContext context, List<TargetFocus> targets) {
    if (_tutorial != null) return;
    _tutorial = TutorialCoachMark(
      context,
      targets: targets,
      colorShadow: Colors.black,
      textSkip: "跳过",
      onFinish: () => _tutorial = null,
      onSkip: () => _tutorial = null,
    )
      ..show();
  }
}