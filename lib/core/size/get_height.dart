import 'package:flutter/cupertino.dart';

double rh({required BuildContext context, required double px}) {
  final h = MediaQuery.of(context).size.height;
  return px * (h / 812);
}