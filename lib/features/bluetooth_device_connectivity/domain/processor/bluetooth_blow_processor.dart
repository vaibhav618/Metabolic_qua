import 'package:flutter/foundation.dart';

class BluetoothBlowProcessor {
  double? blowBaseValue;
  double? blowThresholdValue;
  double? blowP;
  bool isBaseValueCaptured = false;
  bool isBlowThresholdSet = false;
  bool firstDataValueCaptured = false;
  bool perfectBlowValueCaptured = false;
  bool isBlown = false;
  bool isBlownInFresher = false;
  bool isBlowStartTimeCaptured = false;
  bool isAbort = false;
  bool diffTStampFlag = false;
  bool moveToResults = false;
  bool improperBlow = false;

  double? firstDataValue;
  double? thresholdPercentage;

  int? blowStartTime;
  int? blowEndTime;

  List<double> blowValuesList = [];
  List<double> baseBlowValueList = [];

  bool debugEnabled = true;
  int blowValueCounter = 0;

  void _debugImproper(String reason, {double? blowValue}) {
    if (!debugEnabled) return;
    debugPrint(
        '[BluetoothBlowProcessor] improperBlow=true | $reason | '
            'base=$blowBaseValue | blow=${blowValue ?? "NA"} | '
            'threshold%=$thresholdPercentage | blowP=$blowP | '
            'isBlown=$isBlown | perfect=$perfectBlowValueCaptured | '
            'startCaptured=$isBlowStartTimeCaptured | '
            'start=$blowStartTime | end=$blowEndTime | '
            'durationAfterThreshold=${(blowEndTime != null && blowStartTime != null) ? (blowEndTime! - blowStartTime!) : 0}ms'
    );
  }

  void reset() {
    blowBaseValue = null;
    blowThresholdValue = null;
    blowP = null;
    isBaseValueCaptured = false;
    isBlowThresholdSet = false;
    firstDataValueCaptured = false;
    perfectBlowValueCaptured = false;
    isBlown = false;
    isBlownInFresher = false;
    isBlowStartTimeCaptured = false;
    isAbort = false;
    diffTStampFlag = false;
    moveToResults = false;
    improperBlow = false;
    firstDataValue = null;
    thresholdPercentage = null;
    blowStartTime = null;
    blowEndTime = null;
    blowValuesList = [];
    baseBlowValueList = [];
    blowValueCounter = 0;
  }

  void processBlowData(
      String data,
      double? Function(double) thresholdPercentageCalc,
      double Function(double, double) blowPercentageCalc,
      ) {
    final baseValueRegex = RegExp(r'/([0-9.]+)/');
    final blowValueRegex = RegExp(r'\{([0-9.]+)\}');

    final baseValueMatch = baseValueRegex.firstMatch(data);
    final blowValueMatch = blowValueRegex.firstMatch(data);

    if (baseValueMatch != null && !isBaseValueCaptured) {
      blowBaseValue = double.parse(baseValueMatch.group(1)!);
      baseBlowValueList.add(blowBaseValue!);
      blowThresholdValue = blowBaseValue! + 20;
      isBaseValueCaptured = true;

      if (!isBlowThresholdSet) {
        thresholdPercentage = thresholdPercentageCalc(blowBaseValue!);
        isBlowThresholdSet = true;
      }
    } else if (blowValueMatch != null && isBaseValueCaptured) {
      double blowValue = double.parse(blowValueMatch.group(1)!);

      blowValueCounter++;
      if(blowValueCounter < 10){
        return;
      }


      if (!firstDataValueCaptured) {
        firstDataValue = blowValue;
        firstDataValueCaptured = true;
      }

      // if (blowValue < firstDataValue!) {
      //   blowValue = firstDataValue!;
      // }

      blowP = blowPercentageCalc(blowBaseValue!, blowValue);

      if (blowP! > 10) isBlown = true;

      if (blowP! >= thresholdPercentage!) {
        perfectBlowValueCaptured = true;

        if (!isBlowStartTimeCaptured) {
          blowStartTime = DateTime.now().millisecondsSinceEpoch;
          isBlowStartTimeCaptured = true;
          blowValuesList.clear();
        }

        blowValuesList.add(blowValue);
      }



      if (perfectBlowValueCaptured && isBlown && blowP! <= thresholdPercentage!) {
        blowEndTime = DateTime.now().millisecondsSinceEpoch;

        final durationAfterThreshold = blowEndTime! - (blowStartTime ?? 0);

        if (durationAfterThreshold <= 1500) {
          improperBlow = true;
          _debugImproper(
            'Dropped below threshold too quickly (<1500ms)',
            blowValue: blowValue,
          );
        } else {
          moveToResults = true;
        }

        isAbort = true;
      }
    }
  }

  bool get isBlowComplete => moveToResults;
  bool get isImproperBlow => improperBlow;

  int get blowDuration {
    if (!isBlowStartTimeCaptured) return 0;
    return DateTime.now().millisecondsSinceEpoch - (blowStartTime ?? 0);
  }
}
