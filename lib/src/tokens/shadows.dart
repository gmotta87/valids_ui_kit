import 'package:flutter/widgets.dart';

/// Shadow (elevation) tokens from the ValiDS design system, matching the
/// Tailwind `shadow-*` utilities used by its components (dialogs, toasts).
class ValidsShadows {
  ValidsShadows._();

  /// `shadow-md` → 0 4px 6px -1px 10%, 0 2px 4px -2px 10%.
  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 4),
      blurRadius: 6,
      spreadRadius: -1,
    ),
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 2),
      blurRadius: 4,
      spreadRadius: -2,
    ),
  ];

  /// `shadow-lg` → 0 10px 15px -3px 10%, 0 4px 6px -4px 10%.
  static const List<BoxShadow> lg = [
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 10),
      blurRadius: 15,
      spreadRadius: -3,
    ),
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 4),
      blurRadius: 6,
      spreadRadius: -4,
    ),
  ];
}
