import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class IconPickerRow extends StatelessWidget {
  final int selectedIcon;
  final int? selectedColor;
  final Function(int) onSelected;
  static final List<IconData> commonIcons = [
    Icons.lightbulb,
    Icons.thermostat,
    Icons.power,
    Icons.sensors,
    Icons.meeting_room,
    Icons.window,
    Icons.water_drop,
    Icons.bolt,
    Icons.battery_full,
    Icons.garage,
    Icons.lock,
  ];

  static final List<IconData> allIcons = [
    // General
    Icons.lightbulb,
    Icons.outlet,
    Icons.bolt,
    Icons.power,
    Icons.settings,
    Icons.info,
    Icons.help,
    Icons.question_mark,
    Icons.star,
    Icons.favorite,
    // Sensors
    Icons.sensors,
    Icons.thermostat,
    Icons.water_drop,
    Icons.wind_power,
    Icons.wb_sunny,
    Icons.wb_cloudy,
    Icons.grain,
    Icons.ac_unit,
    Icons.air,
    Icons.co2,
    // Home/Rooms
    Icons.home,
    Icons.meeting_room,
    Icons.bed,
    Icons.kitchen,
    Icons.bathtub,
    Icons.garage,
    Icons.window,
    Icons.chair,
    Icons.balcony,
    // Security
    Icons.lock,
    Icons.lock_open,
    Icons.security,
    Icons.shield,
    Icons.videocam,
    Icons.visibility,
    Icons.doorbell,
    // Entertainment
    Icons.tv,
    Icons.speaker,
    Icons.music_note,
    Icons.movie,
    Icons.videogame_asset,
    Icons.cast,
    // Vehicles
    Icons.car_repair,
    Icons.electric_car,
    Icons.directions_car,
    Icons.directions_bike,
    // Others
    Icons.pets,
    Icons.grass,
    Icons.local_florist,
    Icons.nightlight,
    Icons.timer,
    Icons.alarm,
  ];

  const IconPickerRow({
    super.key,
    required this.selectedIcon,
    this.selectedColor,
    required this.onSelected,
  });

  void _showAllIcons(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Pick an Icon"),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 10,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: allIcons.length,
            itemBuilder: (context, index) {
              final icon = allIcons[index];
              return IconButton(
                padding: EdgeInsets.zero,
                icon: Icon(
                  icon,
                  size: 20,
                  color: selectedIcon == icon.codePoint
                      ? (selectedColor != null ? Color(selectedColor!) : Theme.of(context).colorScheme.primary)
                      : null,
                ),
                onPressed: () {
                  onSelected(icon.codePoint);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isSelectedInCommon = commonIcons.any((icon) => icon.codePoint == selectedIcon);
    final theme = Theme.of(context);
    
    return Wrap(
      spacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        IconButton(
          icon: Icon(
            Icons.block,
            color: selectedIcon == 0 ? theme.colorScheme.primary : Colors.grey,
          ),
          onPressed: () => onSelected(0),
          tooltip: "No Icon",
        ),
        ...commonIcons.map(
          (icon) => IconButton(
            icon: Icon(
              icon,
              color: selectedIcon == icon.codePoint
                  ? (selectedColor != null ? Color(selectedColor!) : theme.colorScheme.primary)
                  : Colors.grey,
            ),
            onPressed: () => onSelected(icon.codePoint),
          ),
        ),
        if (!isSelectedInCommon && selectedIcon != 0)
          IconButton(
            icon: Icon(
              getIconFromCodePoint(selectedIcon),
              color: selectedColor != null ? Color(selectedColor!) : theme.colorScheme.primary,
            ),
            onPressed: () => onSelected(selectedIcon),
          ),
        IconButton(
          icon: const Icon(Icons.more_horiz),
          onPressed: () => _showAllIcons(context),
          tooltip: "More Icons",
        ),
      ],
    );
  }
}

class ColorPickerRow extends StatelessWidget {
  final int selectedColor;
  final Function(int) onSelected;
  static const List<Color> colors = [
    Colors.white,
    Colors.yellow,
    Colors.orange,
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.purple,
    Colors.grey,
  ];

  const ColorPickerRow({
    super.key,
    required this.selectedColor,
    required this.onSelected,
  });

  void _showFullPicker(BuildContext context) {
    Color pickerColor = Color(selectedColor);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Pick a Color"),
        content: SingleChildScrollView(
          child: HueRingPicker(
            pickerColor: pickerColor,
            onColorChanged: (color) {
              pickerColor = color;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              onSelected(pickerColor.toARGB32());
              Navigator.pop(context);
            },
            child: const Text("Select"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isSelectedInCommon = colors.any((color) => color.toARGB32() == selectedColor);

    return Wrap(
      spacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ...colors.map(
          (color) => GestureDetector(
            onTap: () => onSelected(color.toARGB32()),
            child: CircleAvatar(
              backgroundColor: color,
              radius: 15,
              child: selectedColor == color.toARGB32()
                  ? Icon(
                      Icons.check,
                      size: 16,
                      color:
                          ThemeData.estimateBrightnessForColor(color) ==
                                  Brightness.light
                              ? Colors.black
                              : Colors.white,
                    )
                  : null,
            ),
          ),
        ),
        if (!isSelectedInCommon)
          GestureDetector(
            onTap: () => onSelected(selectedColor),
            child: CircleAvatar(
              backgroundColor: Color(selectedColor),
              radius: 15,
              child: Icon(
                Icons.check,
                size: 16,
                color: ThemeData.estimateBrightnessForColor(Color(selectedColor)) == Brightness.light
                    ? Colors.black
                    : Colors.white,
              ),
            ),
          ),
        IconButton(
          icon: const Icon(Icons.colorize),
          onPressed: () => _showFullPicker(context),
          tooltip: "Custom Color",
        ),
      ],
    );
  }
}

final Map<int, IconData> _iconMap = {
  for (final icon in IconPickerRow.allIcons) icon.codePoint: icon,
  for (final icon in IconPickerRow.commonIcons) icon.codePoint: icon,
};

IconData getIconFromCodePoint(int codePoint) {
  return _iconMap[codePoint] ?? Icons.help_outline;
}
