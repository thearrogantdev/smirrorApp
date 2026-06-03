import 'dart:typed_data';
import 'package:flat_buffers/flat_buffers.dart' as fb;
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:smirror_app/bloc/viewConfig/view_config_models.dart';
import 'package:smirror_wire/generated/widget_internals_widget_internals_generated.dart'
    as internals;
import 'package:smirror_app/items/types/busStop/bus_line_poco.dart';
import 'package:smirror_app/items/types/busStop/bus_rule_generator.dart';
import 'package:smirror_wire/constants/widget_ids.dart';
import 'package:smirror_app/items/widget_type_definition.dart';
import 'package:smirror_app/l10n/app_localizations.dart';

class BusStopWidgetType extends WidgetTypeDefinition {
  BusStopWidgetType()
    : super(
        typeId: WidgetIds.busStop,
        nameBuilder: (ctx) => AppLocalizations.of(ctx)!.widgetNameBusStop,
        defaultSize: const Size(200, 150),
      );

  @override
  List<ViewConfigProperty> createDefaultProperties() => [
    ViewConfigProperty(
      key: PropertyIdsBusStop.fontSize,
      type: ViewConfigPropertyType.int,
      intValue: 14,
    ),
    ViewConfigProperty(
      key: PropertyIdsBusStop.fontFamily,
      type: ViewConfigPropertyType.string,
      stringValue: 'Roboto',
    ),
    ViewConfigProperty(
      key: PropertyIdsBusStop.schedule,
      type: ViewConfigPropertyType.rawBytes,
      rawBytes: Uint8List(0),
    ),
  ];

  // --- PACKING / UNPACKING ---

  Uint8List _pack(List<BusLinePOCO> lines) {
    final b = fb.Builder(initialSize: 2048);

    // Helper to convert a List<TimeOfDay> into a Vector of Table Offsets
    int buildDepartureVector(List<TimeOfDay> times) {
      if (times.isEmpty) return 0;

      final List<int> offsets = [];
      for (final t in times) {
        // 1. Start the child table
        final db = internals.BusDepartureBuilder(b);
        db.begin();
        db.addHour(t.hour);
        db.addMinute(t.minute);
        // 2. Collect the offset
        offsets.add(db.finish());
      }
      // 3. Write the list of offsets (Just like the dashboard IDs)
      return b.writeList(offsets);
    }

    final List<int> lineOffsets = [];

    for (final line in lines) {
      // PRE-CALCULATE child offsets before calling lb.begin()
      // This prevents the "!_inVTable" assertion error.
      final numOff = b.writeString(line.number);
      final monOff = buildDepartureVector(line.monFri);
      final satOff = buildDepartureVector(line.sat);
      final sunOff = buildDepartureVector(line.sun);

      // Now build the BusLine table
      final lb = internals.BusLineBuilder(b);
      lb.begin();
      lb.addNumberOffset(numOff);
      if (monOff != 0) lb.addMonFriOffset(monOff);
      if (satOff != 0) lb.addSatOffset(satOff);
      if (sunOff != 0) lb.addSunOffset(sunOff);
      lineOffsets.add(lb.finish());
    }

    // Finalize the root
    final linesVectorOffset = b.writeList(lineOffsets);
    final sb = internals.BusScheduleBuilder(b);
    sb.begin();
    sb.addLinesOffset(linesVectorOffset);
    b.finish(sb.finish());

    return b.buffer;
  }

  List<BusLinePOCO> _unpack(Uint8List? bytes) {
    if (bytes == null || bytes.isEmpty) return [];
    try {
      final schedule = internals.BusSchedule(bytes);
      return List.generate(schedule.lines?.length ?? 0, (i) {
        final l = schedule.lines![i];

        List<TimeOfDay> getTimes(List<internals.BusDeparture>? fbList) {
          if (fbList == null) return [];
          // Now it's a standard List of Tables
          return List.generate(fbList.length, (di) {
            final d = fbList[di];
            return TimeOfDay(hour: d.hour, minute: d.minute);
          });
        }

        return BusLinePOCO(
          number: l.number ?? '?',
          monFri: getTimes(l.monFri),
          sat: getTimes(l.sat),
          sun: getTimes(l.sun),
        );
      });
    } catch (e) {
      return [];
    }
  }

  // --- UI LOGIC ---

  @override
  Future<List<ViewConfigProperty>?> promptForProperties(
    BuildContext context, {
    List<ViewConfigProperty>? initial,
    VoidCallback? onDelete,
  }) async {
    final loc = AppLocalizations.of(context)!;
    final formKey = GlobalKey<FormBuilderState>();

    // 1. Extract existing values from ObjectBox properties
    final propMap = {for (var p in initial ?? []) p.key: p};

    final int initialSize =
        propMap[PropertyIdsBusStop.fontSize]?.intValue ?? 14;
    final String initialFont =
        propMap[PropertyIdsBusStop.fontFamily]?.stringValue ?? 'Roboto';
    final List<BusLinePOCO> initialLines = _unpack(
      propMap[PropertyIdsBusStop.schedule]?.rawBytes,
    );

    return showDialog<List<ViewConfigProperty>>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.haConfigureBusStop),
        content: SizedBox(
          width: 450,
          child: FormBuilder(
            key: formKey,
            initialValue: {
              'font': initialFont,
              'size': initialSize.toString(),
              'lines': initialLines,
            },
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Styling Row (Size & Font)
                  Row(
                    children: [
                      Expanded(
                        child: FormBuilderTextField(
                          name: 'size',
                          decoration: InputDecoration(labelText: loc.fontSize),
                          keyboardType: TextInputType.number,
                          validator: FormBuilderValidators.integer(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FormBuilderDropdown<String>(
                          name: 'font',
                          decoration: InputDecoration(
                            labelText: loc.fontFamily,
                          ),
                          items: ['Roboto', 'Orbitron', 'Montserrat', 'Lato']
                              .map(
                                (f) =>
                                    DropdownMenuItem(value: f, child: Text(f)),
                              )
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),

                  // Custom Field for Bus Lines
                  FormBuilderField<List<BusLinePOCO>>(
                    name: 'lines',
                    builder: (field) {
                      final lines = field.value ?? [];
                      return Column(
                        children: [
                          ReorderableListView(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            buildDefaultDragHandles: false,
                            onReorder: (oldIdx, newIdx) {
                              if (newIdx > oldIdx) newIdx -= 1;
                              final newList = List<BusLinePOCO>.from(lines);
                              final item = newList.removeAt(oldIdx);
                              newList.insert(newIdx, item);
                              field.didChange(newList);
                            },
                            children: [
                              for (int i = 0; i < lines.length; i++)
                                ReorderableDragStartListener(
                                  key: ValueKey(lines[i].hashCode + i),
                                  index: i,
                                  child: Card(
                                    child: ListTile(
                                      leading: const Icon(Icons.drag_handle),
                                      title: Text(
                                        "${loc.haBusLine} ${lines[i].number}",
                                      ),
                                      subtitle: Text(
                                        "M-F: ${lines[i].monFri.length} | Sat: ${lines[i].sat.length} | Sun: ${lines[i].sun.length}",
                                        style: const TextStyle(fontSize: 11),
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit_note),
                                            onPressed: () => _editLine(
                                              ctx,
                                              lines[i],
                                              (updated) {
                                                final newList =
                                                    List<BusLinePOCO>.from(
                                                      lines,
                                                    );
                                                newList[i] = updated;
                                                field.didChange(newList);
                                              },
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete_sweep,
                                              color: Colors.red,
                                            ),
                                            onPressed: () {
                                              field.didChange(
                                                List<BusLinePOCO>.from(lines)
                                                  ..removeAt(i),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: () => field.didChange(
                              List<BusLinePOCO>.from(lines)..add(
                                BusLinePOCO(
                                  number: '100',
                                  monFri: [],
                                  sat: [],
                                  sun: [],
                                ),
                              ),
                            ),
                            icon: const Icon(Icons.add_road),
                            label: Text(loc.haAddBusLine),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          if (onDelete != null)
            TextButton(
              onPressed: onDelete,
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text(loc.delete),
            ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(loc.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.saveAndValidate() ?? false) {
                final vals = formKey.currentState!.value;

                // Pack all configuration back into ObjectBox properties
                Navigator.pop(ctx, [
                  ViewConfigProperty(
                    key: PropertyIdsBusStop.fontSize,
                    type: ViewConfigPropertyType.int,
                    intValue: int.tryParse(vals['size'].toString()) ?? 14,
                  ),
                  ViewConfigProperty(
                    key: PropertyIdsBusStop.fontFamily,
                    type: ViewConfigPropertyType.string,
                    stringValue: vals['font'],
                  ),
                  ViewConfigProperty(
                    key: PropertyIdsBusStop.schedule,
                    type: ViewConfigPropertyType.rawBytes,
                    rawBytes: _pack(
                      vals['lines'],
                    ), // Pack the complex nested schedule
                  ),
                ]);
              }
            },
            child: Text(loc.save),
          ),
        ],
      ),
    );
  }

  void _editLine(
    BuildContext context,
    BusLinePOCO line,
    Function(BusLinePOCO) onSave,
  ) async {
    List<TimeOfDay> tMonFri = List.from(line.monFri);
    List<TimeOfDay> tSat = List.from(line.sat);
    List<TimeOfDay> tSun = List.from(line.sun);
    String num = line.number;

    final loc = AppLocalizations.of(context)!;

    await showDialog(
      context: context,
      builder: (ctx) => DefaultTabController(
        length: 3,
        child: AlertDialog(
          title: Text(loc.haBusEditLine(num)),
          content: SizedBox(
            width: 400,
            height: 500,
            child: Column(
              children: [
                TextField(
                  onChanged: (v) => num = v,
                  decoration: InputDecoration(
                    labelText: loc.haBusLineNumberLabel,
                  ),
                ),
                const TabBar(
                  labelColor: Colors.blue,
                  tabs: [
                    Tab(text: "Mon-Fri"),
                    Tab(text: "Sat"),
                    Tab(text: "Sun"),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildTimeList(
                        ctx,
                        tMonFri,
                        (newList) => tMonFri = newList,
                      ),
                      _buildTimeList(ctx, tSat, (newList) => tSat = newList),
                      _buildTimeList(ctx, tSun, (newList) => tSun = newList),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(loc.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                onSave(
                  BusLinePOCO(
                    number: num,
                    monFri: tMonFri,
                    sat: tSat,
                    sun: tSun,
                  ),
                );
                Navigator.pop(ctx);
              },
              child: Text(loc.save),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeList(
    BuildContext context,
    List<TimeOfDay> times,
    Function(List<TimeOfDay>) onChanged,
  ) {
    final loc = AppLocalizations.of(context)!;
    return StatefulBuilder(
      builder: (ctx, setS) {
        return Column(
          children: [
            Row(
              children: [
                TextButton(
                  onPressed: () async {
                    await showDialog(
                      context: context,
                      builder: (c) => BusRuleGeneratorDialog(
                        onGenerated: (generated) {
                          setS(() {
                            //Add all new times
                            times.addAll(generated);
                            //Remove duplicates
                            final unique = <int>{};
                            times.retainWhere(
                              (t) => unique.add(t.hour * 60 + t.minute),
                            );
                            // Sort correctly
                            times.sort(
                              (a, b) => (a.hour * 60 + a.minute).compareTo(
                                b.hour * 60 + b.minute,
                              ),
                            );
                          });
                          onChanged(times); // Notify the main form
                        },
                      ),
                    );
                  },
                  child: Text(loc.haBusAutoGenerate),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () async {
                    final t = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (t != null) {
                      setS(() {
                        times.add(t);
                        final unique = <int>{};
                        times.retainWhere(
                          (x) => unique.add(x.hour * 60 + x.minute),
                        );
                        times.sort(
                          (a, b) => (a.hour * 60 + a.minute).compareTo(
                            b.hour * 60 + b.minute,
                          ),
                        );
                      });
                      onChanged(times);
                    }
                  },
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: times.length,
                itemBuilder: (c, i) => ListTile(
                  title: Text(times[i].format(context)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      setS(() => times.removeAt(i));
                      onChanged(times);
                    },
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget buildChild(ViewConfigItem item) => const Center(
    child: Icon(Icons.directions_bus, color: Colors.white54, size: 40),
  );
}
