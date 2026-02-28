

import 'package:respyr_dietitian/features/practice_test/practice_test_home/domain/enums/practice_test.dart';

extension PracticeTestExtension on PracticeTestSteps {
  String get title {
    switch (this) {
      case PracticeTestSteps.connect:
        return "Connect to your Respyr device";
      case PracticeTestSteps.inhaleTest:
        return "Inhale Test";
      case PracticeTestSteps.exhaleTest:
        return "Exhale Test";
      case PracticeTestSteps.fullTest:
        return "Full Test";
    }
  }

  String get subtitle {
    switch (this) {
      case PracticeTestSteps.connect:
        return "";
      case PracticeTestSteps.inhaleTest:
        return "Inhale successfully through your Respyr device";
      case PracticeTestSteps.exhaleTest:
        return "Exhale successfully through your Respyr device";
      case PracticeTestSteps.fullTest:
        return "Inhale, hold and exhale successfully through your Respyr device";
    }
  }
}
