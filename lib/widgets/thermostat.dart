import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ironos_companion/data/iron_states.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

import '../providers/iron.dart';

class Thermostat extends StatefulHookConsumerWidget {
  const Thermostat({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ThermostatState();
}

class _ThermostatState extends ConsumerState<Thermostat> {
  bool isOn = false;

  @override
  Widget build(BuildContext context) {
    final ironN = ref.watch(ironProvider.notifier);
    final ironP = ref.watch(ironProvider);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SleekCircularSlider(
        key: const Key("thermostat"),
        appearance: CircularSliderAppearance(
          customColors: CustomSliderColors(
            trackColor: Colors.grey[300],
            progressBarColors: getGradientFromMode(
                ironP.data?.currentMode ?? OperatingMode.idle),
            shadowColor: Colors.grey[300],
            shadowMaxOpacity: 0.1,
            shadowStep: 10,
            dotColor: Colors.grey[300]?.withOpacity(0.3),
            hideShadow: false,
          ),
          infoProperties: InfoProperties(
            mainLabelStyle: const TextStyle(fontSize: 40),
            topLabelText: 'Current',
            topLabelStyle: const TextStyle(fontSize: 20),
            bottomLabelText: 'Setpoint',
            bottomLabelStyle: const TextStyle(fontSize: 20),
            modifier: (double value) {
              return '${value.toInt()}°C';
            },
          ),
          startAngle: 130,
          angleRange: 280,
          size: 300,
          animationEnabled: false,
        ),
        max: max(ironP.data?.maxTemp.toDouble() ?? 400,
            ironP.data?.setpoint.toDouble() ?? 0),
        min: 0,
        initialValue: ironP.data?.setpoint.toDouble() ?? 0,
        onChangeEnd: (value) {
          HapticFeedback.heavyImpact();
          ironN.setData(ironP.data!.copyWith(setpoint: value.toInt()));
        },
        onChangeStart: (value) {
          HapticFeedback.lightImpact();
        },
        innerWidget: (percentage) {
          return Padding(
            padding: const EdgeInsets.all(35),
            child: SleekCircularSlider(
              appearance: CircularSliderAppearance(
                customColors: CustomSliderColors(
                  trackColor: Colors.transparent,
                  progressBarColors: [
                    Colors.red,
                    Colors.orange,
                    Colors.yellow,
                  ],
                  shadowColor: Colors.transparent,
                  shadowMaxOpacity: 0,
                  shadowStep: 10,
                  dotColor: Colors.transparent,
                  hideShadow: false,
                ),
                customWidths: CustomSliderWidths(
                  progressBarWidth: 15,
                  trackWidth: 0,
                  handlerSize: 0,
                  shadowWidth: 0,
                ),
                startAngle: 130,
                angleRange: 280,
                size: 300,
                animationEnabled: true,
              ),
              max: ironP.data?.maxTemp.toDouble() ?? 400,
              min: 0,
              initialValue: ironP.data?.currentTemp.toDouble() ?? 0,
              innerWidget: (_) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Temperature
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedScale(
                            scale: !(OperatingMode.idle ==
                                    (ironP.data?.currentMode ??
                                        OperatingMode.idle))
                                ? 1
                                : 0.8,
                            curve: Curves.easeInOut,
                            duration: const Duration(milliseconds: 200),
                            child: Text(
                              '${ironP.data?.currentTemp.toInt()}',
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: (OperatingMode.idle ==
                                        (ironP.data?.currentMode ??
                                            OperatingMode.idle))
                                    ? Theme.of(context)
                                        .textTheme
                                        .displaySmall!
                                        .color
                                    : Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                          const Text(
                            '/',
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            percentage.toInt().toString(),
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            '°C',
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      // Heat button
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Decrease temperature
                            TextButton(
                              style: ElevatedButton.styleFrom(
                                shape: const CircleBorder(),
                                padding: const EdgeInsets.all(15),
                              ),
                              onPressed: () {
                                int newTemp = ironP.data!.setpoint - 2;
                                if (newTemp <= 0) {
                                  newTemp = 0;
                                }
                                ironN.setData(
                                    ironP.data!.copyWith(setpoint: newTemp));
                                HapticFeedback.mediumImpact();
                              },
                              onLongPress: () {
                                int newTemp = ironP.data!.setpoint - 10;
                                if (newTemp <= 0) {
                                  newTemp = 0;
                                }
                                ironN.setData(
                                    ironP.data!.copyWith(setpoint: newTemp));
                                HapticFeedback.heavyImpact();
                              },
                              child: Icon(
                                Icons.remove,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            Column(
                              children: [
                                Text(
                                  'Current Status:',
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                const Padding(padding: EdgeInsets.all(5)),
                                CircleAvatar(
                                  backgroundColor: getColorFromMode(
                                      ironP.data?.currentMode ??
                                          OperatingMode.idle),
                                  radius: 30,
                                  child: Icon(
                                    getIconFromMode(ironP.data?.currentMode ??
                                        OperatingMode.idle),
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                            // Increase temperature
                            TextButton(
                              style: ElevatedButton.styleFrom(
                                shape: const CircleBorder(),
                                padding: const EdgeInsets.all(15),
                              ),
                              onPressed: () {
                                int newTemp = ironP.data!.setpoint + 2;
                                if (newTemp >= ironP.data!.maxTemp) {
                                  newTemp = ironP.data!.maxTemp;
                                }
                                ironN.setData(
                                    ironP.data!.copyWith(setpoint: newTemp));
                                HapticFeedback.mediumImpact();
                              },
                              onLongPress: () {
                                int newTemp = ironP.data!.setpoint + 10;
                                if (newTemp >= ironP.data!.maxTemp) {
                                  newTemp = ironP.data!.maxTemp;
                                }
                                ironN.setData(
                                    ironP.data!.copyWith(setpoint: newTemp));
                                HapticFeedback.heavyImpact();
                              },
                              child: Icon(
                                Icons.add,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Color getColorFromMode(OperatingMode mode) {
    switch (mode) {
      case OperatingMode.idle:
        return Colors.grey.withOpacity(0.5);
      case OperatingMode.soldering:
        return Colors.orange.withOpacity(0.5);
      case OperatingMode.boost:
        return Colors.red.withOpacity(0.5);
      case OperatingMode.settings:
        return Colors.blue.withOpacity(0.5);
      case OperatingMode.debug:
        return Colors.green.withOpacity(0.5);
      case OperatingMode.sleeping:
        return Colors.purple.withOpacity(0.5);
      default:
        return Colors.grey;
    }
  }

  List<Color> getGradientFromMode(OperatingMode mode) {
    switch (mode) {
      case OperatingMode.idle:
        return [
          Colors.grey,
          Colors.blueGrey,
        ];

      case OperatingMode.soldering:
        return [
          Colors.red,
          Colors.orange,
        ];
      case OperatingMode.boost:
        return [
          Colors.red,
          Colors.redAccent,
        ];
      case OperatingMode.settings:
        return [
          Colors.grey,
          Colors.blueGrey,
        ];
      case OperatingMode.debug:
        return [
          Colors.grey,
          Colors.blueGrey,
        ];
      case OperatingMode.sleeping:
        return [
          Colors.purple,
          Colors.blue,
        ];
      default:
        return [
          Colors.grey,
          Colors.blueGrey,
        ];
    }
  }

  IconData getIconFromMode(OperatingMode mode) {
    switch (mode) {
      case OperatingMode.idle:
        return Icons.power_settings_new_outlined;
      case OperatingMode.soldering:
        return Icons.whatshot_rounded;
      case OperatingMode.boost:
        return Icons.bolt_rounded;
      case OperatingMode.settings:
        return Icons.settings_rounded;
      case OperatingMode.debug:
        return Icons.bug_report_rounded;
      case OperatingMode.sleeping:
        return Icons.bedtime_rounded;
      default:
        return Icons.power_settings_new_outlined;
    }
  }
}
