import 'package:flutter/material.dart';
import '../tokens/colors.dart';

class ValidsSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool isDisabled;

  const ValidsSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: value,
      onChanged: isDisabled ? null : onChanged,
      activeColor: ValidsColors.white,
      activeTrackColor: ValidsColors.primary,
      inactiveThumbColor: ValidsColors.white,
      inactiveTrackColor: ValidsColors.grey400,
      trackOutlineColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return ValidsColors.primary;
        }
        return ValidsColors.grey400;
      }),
    );
  }
}
