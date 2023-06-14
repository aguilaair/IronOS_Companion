import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
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
    isOn = ironP.data?.currentMode != 0;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SleekCircularSlider(
        key: const Key("thermostat"),
        appearance: CircularSliderAppearance(
          customColors: CustomSliderColors(
            trackColor: Colors.grey[300],
            progressBarColors: !isOn
                ? [
                    Colors.grey,
                    Colors.blueGrey,
                  ]
                : [
                    Colors.red,
                    Colors.orange,
                  ],
            shadowColor: Colors.grey[300],
            shadowMaxOpacity: 0.1,
            shadowStep: 10,
            dotColor: Colors.grey[300]?.withOpacity(0.3),
            hideShadow: false,
          ),
          infoProperties: InfoProperties(
            mainLabelStyle: const TextStyle(fontSize: 40),
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
                      Text(
                        '${percentage.toInt()}°C',
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
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
                            // Power button
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: const CircleBorder(),
                                padding: const EdgeInsets.all(15),
                                backgroundColor: !isOn
                                    ? null
                                    : Colors.blueGrey.withOpacity(0.6),
                              ),
                              onPressed: () {
                                ironN.setData(ironP.data!
                                    .copyWith(currentMode: isOn ? 0 : 1));
                                HapticFeedback.lightImpact();
                              },
                              child: !isOn
                                  ? const Icon(
                                      Icons.whatshot,
                                    )
                                  : const Icon(
                                      Icons.ac_unit,
                                      color: Colors.white,
                                    ),
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
}
