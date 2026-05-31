import 'package:flutter/material.dart';
import 'package:smirror_app/objectbox/home_dashboard.dart';
import 'package:smirror_app/screens/home_assistant/picker_helpers.dart';

class DashboardWidget extends StatelessWidget {
  final DashboardItem item;
  final String liveValue;

  const DashboardWidget({
    super.key,
    required this.item,
    required this.liveValue,
  });

  /// Logic to parse the Home Assistant state string into a comparable double
  double _getNumericValue() {
    // If it's a boolean type, map specific strings to 1.0 or 0.0
    if (item.type == DashboardItemType.boolean) {
      final s = liveValue.toLowerCase();
      return (s == 'on' ||
              s == 'true' ||
              s == 'home' ||
              s == 'open' ||
              s == 'locked')
          ? 1.0
          : 0.0;
    }
    // If it's numeric, parse directly
    return double.tryParse(liveValue) ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final double numericValue = _getNumericValue();

    // Set default style
    int activeIcon = item.standardIconCodePoint;
    int activeColor = item.standardColorValue;

    if (item.thresholds.isNotEmpty) {
      // Sort thresholds descending so we find the "highest" met threshold first
      final sortedThresholds = item.thresholds.toList()
        ..sort((a, b) => b.triggerValue.compareTo(a.triggerValue));

      for (final threshold in sortedThresholds) {
        if (numericValue >= threshold.triggerValue) {
          activeIcon = threshold.iconCodePoint;
          activeColor = threshold.colorValue;
          break; // Stop at the highest matching threshold
        }
      }
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (activeIcon != 0)
          Icon(
            getIconFromCodePoint(activeIcon),
            color: Color(activeColor),
            size: 32,
          )
        else
          Icon(
            Icons.block,
            color: Color(activeColor).withValues(alpha: 0.5),
            size: 32,
          ),
        const SizedBox(height: 4),
        Text(
          item.displayName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        Text(
          liveValue + (item.unitOverride ?? ''),
          style: TextStyle(
            color: Color(activeColor).withValues(alpha: 0.7),
            fontSize: 9,
          ),
        ),
      ],
    );
  }
}
