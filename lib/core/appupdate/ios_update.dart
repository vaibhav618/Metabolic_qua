import 'package:flutter/cupertino.dart';
import 'package:new_version_plus/new_version_plus.dart';

Future<void> checkIosUpdate(BuildContext context) async {
  final newVersion = NewVersionPlus(
    iOSId: '6758504953', // preferred: App Store ID
  );

  final status = await newVersion.getVersionStatus();
  if (status == null) return;

  if (status.canUpdate) {
    newVersion.showUpdateDialog(
      context: context,
      versionStatus: status,
      dialogTitle: "Update available",
      dialogText: "A new version (${status.storeVersion}) is available.",
      updateButtonText: "Update",
      dismissButtonText: "Later",
      allowDismissal: true,
    );
  }
}
