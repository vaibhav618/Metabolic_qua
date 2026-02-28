import 'package:flutter/material.dart';

import '../../settings-manager/app_settings.dart';
import '../data/repository/test_log_manager.dart';
import '../presentation/widgets/bottom-sheets/test_reminder_sheet.dart';

void checkTestLog({required BuildContext context, required String profileId}) async {
  final now = DateTime.now();
  if (now.isBefore(AppSettings().testReminderEndTime)) {
    final dateYmd = "${now.year.toString().padLeft(4, '0')}-"
        "${now.month.toString().padLeft(2, '0')}-"
        "${now.day.toString().padLeft(2, '0')}";

    final status = await TestLogService().getTestLogStatus(
      clientId: profileId,
      dateYmd: dateYmd,
      dietPlanId: "RespyrD01",
    );
    if (!status.hasLog && context.mounted) {
      showTestReminder(context: context);
    }
  }
}

void showTestReminder({required BuildContext context}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true, // lets the sheet grow as needed (with scroll)
    builder: (_) => const TestReminderSheet(),
  );
}