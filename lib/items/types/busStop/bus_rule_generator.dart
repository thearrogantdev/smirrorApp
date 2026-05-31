import 'package:flutter/material.dart';
import 'package:smirror_app/items/types/busStop/bus_line_poco.dart';
import 'package:smirror_app/l10n/app_localizations.dart';

class BusRuleGeneratorDialog extends StatefulWidget {
  final Function(List<TimeOfDay>) onGenerated;
  const BusRuleGeneratorDialog({super.key, required this.onGenerated});

  @override
  State<BusRuleGeneratorDialog> createState() => _BusRuleGeneratorDialogState();
}

class _BusRuleGeneratorDialogState extends State<BusRuleGeneratorDialog> {
  final List<FrequencyRule> _rules = [];

  // Logic to pick parameters for a new rule
  Future<void> _showAddRuleWizard() async {
    final start = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 6, minute: 0),
      helpText: "Select Start Time",
    );
    if (start == null || !mounted) return;

    final end = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 20, minute: 0),
      helpText: "Select End Time",
    );
    if (end == null || !mounted) return;

    int freq = 20;
    final loc = AppLocalizations.of(context)!;
    final result = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.haBusFrequency),
        content: TextField(
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(suffixText: "min"),
          onChanged: (v) => freq = int.tryParse(v) ?? 20,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(loc.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, freq),
            child: Text(loc.haBusAdd),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() {
        _rules.add(FrequencyRule(start: start, end: end, frequency: result));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(loc.haBusGenerateSchedule),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_rules.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  loc.haBusNoRanges,
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _rules.length,
                itemBuilder: (context, i) {
                  final r = _rules[i];
                  return ListTile(
                    dense: true,
                    title: Text(
                      loc.haBusTimeRangeTitle(
                        r.start.format(context),
                        r.end.format(context),
                      ),
                    ),
                    subtitle: Text(
                      loc.haBusTimeRangeSubtitle(r.frequency.toString()),
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.remove_circle_outline,
                        color: Colors.red,
                      ),
                      onPressed: () => setState(() => _rules.removeAt(i)),
                    ),
                  );
                },
              ),
            ),
            const Divider(),
            TextButton.icon(
              onPressed: _showAddRuleWizard,
              icon: const Icon(Icons.add_alarm),
              label: Text(loc.haBusAddTimeRange),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(loc.cancel),
        ),
        ElevatedButton(
          onPressed: _rules.isEmpty
              ? null
              : () {
                  final List<TimeOfDay> allTimes = [];
                  for (var r in _rules) {
                    allTimes.addAll(r.calculateTimes());
                  }
                  widget.onGenerated(allTimes);
                  Navigator.pop(context);
                },
          child: Text(loc.haBusGenerate),
        ),
      ],
    );
  }
}
