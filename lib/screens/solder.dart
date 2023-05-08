import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ironos_companion/screens/devices.dart';
import 'package:ironos_companion/widgets/thermostat.dart';

import '../providers/iron.dart';

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
    return Scaffold(
      appBar: const DeviceAppBar(),
      body: ironP.data == null
          ? SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  Text("Waiting for data..."),
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
                  Thermostat(
                    turnOn: (ironP.data?.estimatedWattage ?? 0) > 0,
                    modeIcon: Container(),
                    minValue: 0,
                    maxValue: ironP.data?.maxTemp ?? 200,
                    initialValue: ironP.data?.setpoint ?? 0,
                    radius: 200,
                    glowColor: Theme.of(context).colorScheme.secondary,
                    dividerColor: Theme.of(context).colorScheme.secondary,
                    tickColor: Theme.of(context).colorScheme.onSurface,
                    thumbColor: Theme.of(context).colorScheme.onSurface,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: Card(
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
                                  Icons.power_outlined,
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
                                  Icons.health_and_safety_rounded,
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
                  ),
                  // Expanded for charts
                  Expanded(
                    child: LineChart(
                      ironN.chartData,
                      swapAnimationDuration:
                          const Duration(milliseconds: 1000), // Optional
                      swapAnimationCurve: Curves.easeInOut, // Optional
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class DeviceAppBar extends StatefulHookConsumerWidget
    implements PreferredSizeWidget {
  const DeviceAppBar({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DeviceAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(60);
}

class _DeviceAppBarState extends ConsumerState<DeviceAppBar> {
  @override
  Widget build(BuildContext context) {
    final ironN = ref.watch(ironProvider.notifier);
    final ironP = ref.watch(ironProvider);
    return AppBar(
      title: DropdownButton<String>(
        value: ironP.name,
        items: [
          DropdownMenuItem(
            value: ironP.name,
            child: SizedBox(
              child: Chip(
                side: const BorderSide(
                  color: Colors.transparent,
                  width: 0,
                ),
                label: Text(ironP.name),
                avatar: ironP.isConnected
                    ? const Icon(
                        Icons.bluetooth_connected_rounded,
                        color: Colors.green,
                      )
                    : const Icon(
                        Icons.bluetooth_disabled_rounded,
                        color: Colors.red,
                      ),
              ),
            ),
          ),
          // Connect New Device
          const DropdownMenuItem(
            value: "add",
            child: SizedBox(
              child: Chip(
                side: BorderSide(
                  color: Colors.transparent,
                  width: 0,
                ),
                label: Text("Add Device"),
                avatar: Icon(
                  Icons.bluetooth_searching_rounded,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
        ],
        underline: Container(),
        borderRadius: BorderRadius.circular(10),
        icon: Container(),
        selectedItemBuilder: (context) {
          return [
            Chip(
              label: Row(
                children: [
                  Text(ironP.name),
                  const SizedBox(
                    width: 5,
                  ),
                  Icon(
                    Icons.arrow_drop_down_rounded,
                    color: Theme.of(context).iconTheme.color,
                  )
                ],
              ),
              avatar: ironP.isConnected
                  ? const Icon(
                      Icons.bluetooth_connected_rounded,
                      color: Colors.green,
                    )
                  : const Icon(
                      Icons.bluetooth_disabled_rounded,
                      color: Colors.red,
                    ),
              // Add drop down arrow
            ),
          ];
        },
        onChanged: (value) {
          if (value == "add") {
            ironN.resetNewDevice();
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const DeviceSelectionScreen(),
              ),
            );
          } else {
            if (ironP.isConnected) {
              ironN.disconnect();
            } else {
              ironN.attemptReconnect();
            }
          }
        },
      ),
    );
  }
}
