import 'package:flutter/material.dart';

PreferredSizeWidget ExhaleScreenAppBar({required BuildContext context , required VoidCallback cancelTestClicked}) {
  return AppBar(
    backgroundColor: Colors.white,
    surfaceTintColor: Colors.white,
    automaticallyImplyLeading: false,
    actions: [
      IconButton(
        icon: const Icon(Icons.close),
        onPressed: () {
          cancelTestClicked();
        },
      ),
    ],
  );
}