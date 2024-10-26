import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/color_constants.dart';
import '../../core/constants/message_constants.dart';

enum SpeechSpeed {
  tooFast,
  good,
  normal,
}

class SpeechAnalysisModel {
  final int textLengthDifference;
  final SpeechSpeed speed;
  final Color borderColor;
  final String comment;

  SpeechAnalysisModel({
    required this.textLengthDifference,
    required this.speed,
    required this.borderColor,
    required this.comment,
  });

  factory SpeechAnalysisModel.analyze(int lengthDifference) {
    if (lengthDifference > AppConstants.fastSpeechThreshold) {
      return SpeechAnalysisModel(
        textLengthDifference: lengthDifference,
        speed: SpeechSpeed.tooFast,
        borderColor: ColorConstants.statusFast,
        comment: MessageConstants.speedFastMessage,
      );
    } else if (lengthDifference > AppConstants.normalSpeechThreshold) {
      return SpeechAnalysisModel(
        textLengthDifference: lengthDifference,
        speed: SpeechSpeed.good,
        borderColor: ColorConstants.statusGood,
        comment: MessageConstants.speedGoodMessage,
      );
    } else {
      return SpeechAnalysisModel(
        textLengthDifference: lengthDifference,
        speed: SpeechSpeed.normal,
        borderColor: ColorConstants.statusNormal,
        comment: MessageConstants.speedEmptyMessage,
      );
    }
  }
}
