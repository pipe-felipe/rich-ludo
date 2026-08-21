import 'package:flutter/material.dart';

/// Month header with previous/next arrows and a tap target that jumps back
/// to the calendar's current month. Shared by [MainTopBar] and [ChartScreen].
class MonthSelector extends StatelessWidget {
  final String currentMonthYear;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final VoidCallback onCurrentMonthClick;

  const MonthSelector({
    super.key,
    required this.currentMonthYear,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onCurrentMonthClick,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: onPreviousMonth,
          icon: Icon(
            Icons.keyboard_arrow_left,
            color: Theme.of(context).colorScheme.tertiary,
          ),
        ),
        TextButton(
          onPressed: onCurrentMonthClick,
          child: Text(
            currentMonthYear,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        IconButton(
          onPressed: onNextMonth,
          icon: Icon(
            Icons.keyboard_arrow_right,
            color: Theme.of(context).colorScheme.tertiary,
          ),
        ),
      ],
    );
  }
}
