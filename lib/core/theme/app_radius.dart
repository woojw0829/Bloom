import 'package:flutter/material.dart';

abstract final class AppRadius {
  static const double input = 12;
  static const double card = 16;
  static const double modal = 24;
  static const double pill = 999;
  static const double profileCard = 32;
  static const double button = 16;
  static const double messagebubble = 20;
  static const double avatar = 999;
  static const double badge = 999;
  static const double chip = 999;
  static const double mapMarker = 999;

  static const BorderRadius inputBorder = BorderRadius.all(Radius.circular(input));
  static const BorderRadius cardBorder = BorderRadius.all(Radius.circular(card));
  static const BorderRadius modalBorder = BorderRadius.vertical(top: Radius.circular(modal));
  static const BorderRadius pillBorder = BorderRadius.all(Radius.circular(pill));
  static const BorderRadius profileCardBorder = BorderRadius.all(Radius.circular(profileCard));
  static const BorderRadius buttonBorder = BorderRadius.all(Radius.circular(button));
}
