import 'package:flutter/material.dart';

import '../../../../core/format/formatters.dart';

class DaySwitcher extends StatelessWidget {
  const DaySwitcher({
    required this.date,
    required this.onPrevious,
    required this.onNext,
    required this.onSelect,
    super.key,
  });

  final DateTime date;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      IconButton(
        tooltip: 'Предыдущий день',
        onPressed: onPrevious,
        icon: const Icon(Icons.chevron_left),
      ),
      Semantics(
        button: true,
        label: 'Выбранная дата ${formatDate(date)}',
        child: TextButton(
          onPressed: () async {
            final selected = await showDatePicker(
              context: context,
              firstDate: DateTime(2020),
              lastDate: DateTime(2100),
              initialDate: date,
            );
            if (selected != null) onSelect(selected);
          },
          child: Text(
            formatDate(date),
            style: const TextStyle(
              color: Color(0xFF1E293B),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
      IconButton(
        tooltip: 'Следующий день',
        onPressed: onNext,
        icon: const Icon(Icons.chevron_right),
      ),
    ],
  );
}
