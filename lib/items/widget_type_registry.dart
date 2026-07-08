import 'package:flutter/material.dart';
import 'package:smirror_app/items/types/entertainment/cataas_gif.dart';
import 'package:smirror_app/items/types/entertainment/cataas_image.dart';
import 'package:smirror_app/items/types/entertainment/pokemon_of_the_day.dart';
import 'package:smirror_app/items/types/entertainment/random_compliment.dart';
import 'package:smirror_app/items/types/entertainment/random_dog.dart';
import 'package:smirror_app/items/types/entertainment/random_insult.dart';
import 'package:smirror_app/items/types/entertainment/random_pokemon.dart';
import 'package:smirror_app/items/types/entertainment/random_useless_fact.dart';
import 'package:smirror_app/items/types/busStop/bus_stop.dart';
import 'package:smirror_app/items/types/google/google_calendar_two_days.dart';
import 'package:smirror_app/items/types/google/google_calendar_upcoming.dart';
import 'package:smirror_app/items/types/google/google_tasks.dart';
import 'package:smirror_app/items/types/general/image.dart';
import 'package:smirror_app/items/types/homeassistant/multi_dashboard.dart';
import 'package:smirror_app/items/types/homeassistant/single_dashboard.dart';
import 'package:smirror_app/items/types/openweather/current_weather.dart';
import 'package:smirror_app/items/types/general/text_label.dart';
import 'package:smirror_app/items/types/general/system_usage.dart';
import 'package:smirror_app/items/widget_type_definition.dart';
import 'types/openweather/forecast_weather.dart';
import 'types/openweather/rain_radar.dart';
import 'types/general/digital_clock.dart';

class WidgetTypeRegistry {
  static final List<WidgetTypeDefinition> _registeredTypes = [
    TextLabelWidgetType(),
    ImageWidgetType(),
    OpenWeatherCurrent(),
    OpenWeatherForecast(),
    GoogleCalendarUpcoming(),
    HASingleDashboard(),
    CataasImageWidgetType(),
    CataasGifWidgetType(),
    RandomDogWidgetType(),
    RandomPokemonWidgetType(),
    PokemonOfTheDayWidgetType(),
    RandomComplimentWidgetType(),
    RandomInsultWidgetType(),
    RandomUselessFactWidgetType(),
    HAMultiDashboard(),
    BusStopWidgetType(),
    GoogleCalendarNextTwoDays(),
    SystemUsageWidgetType(),
    RainRadarWidgetType(),
    DigitalClockWidgetType(),
    GoogleTasksWidget(),
  ];

  static final Map<int, WidgetTypeDefinition> _types = {
    for (final t in _registeredTypes) t.typeId: t,
  };

  static WidgetTypeDefinition? get(int typeId) => _types[typeId];

  static Map<int, String> getAvailableTypes(BuildContext context) =>
      _types.map((key, value) => MapEntry(key, value.nameOf(context)));
}
