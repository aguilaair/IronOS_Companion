import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ironos_companion/providers/iron_settings.dart';
import '../widgets/thermostat.dart';

import '../providers/iron.dart';
import '../widgets/device_selector.dart';

class SolderPage extends StatefulHookConsumerWidget {
  const SolderPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SolderPageState();
}

class _SolderPageState extends ConsumerState<SolderPage> {
  @override
  Widget build(BuildContext context) {
    final ironN = ref.watch(ironProvider.notifier);
    final ironP = ref.watch(ironProvider);

    if (ironP.isConnected) {
      Future.delayed(const Duration(milliseconds: 5000), () {
        ref.watch(ironSettingsProvider);
      });
    }
    return Scaffold(
      appBar: const DeviceAppBar(),
      body: !ironP.isConnected
          ? const SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Connecting to device..."),
                  SizedBox(
                    height: 10,
                  ),
                  CircularProgressIndicator(),
                ],
              ),
            )
          : SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  const Thermostat(),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Icon(
                                Icons.thermostat_outlined,
                                size: 30,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                "${ironP.data?.currentTemp ?? 0}°C",
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Icon(
                                Icons.bolt_outlined,
                                size: 30,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                "${ironP.data?.inputVoltage ?? 0}V",
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Icon(
                                Icons.power_rounded,
                                size: 30,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                "${ironP.data?.estimatedWattage ?? 0}W",
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Icon(
                                Icons.front_hand_rounded,
                                size: 30,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                "${ironP.data?.handleTemp ?? 0}ºC",
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Expanded for charts
                  Expanded(
                    child: LineChart(
                      ironN.chartData,
                      duration: const Duration(milliseconds: 1000),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
