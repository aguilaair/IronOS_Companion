import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../providers/iron.dart';
import '../providers/iron_settings.dart';

class SettingsScreen extends StatefulHookConsumerWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  int tempValue = 0;

  @override
  void initState() {
    tempValue = ref.read(ironProvider).data!.setpoint;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ironP = ref.watch(ironProvider);
    final ironS = ref.watch(ironSettingsProvider);
    final ironSN = ref.watch(ironSettingsProvider.notifier);

    return Scaffold(
        body: CustomScrollView(
      slivers: [
        SliverAppBar.large(
          title: const Text("Settings"),
          flexibleSpace: FlexibleSpaceBar(
            title: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Settings",
                ),
                const SizedBox(height: 5),
                Text(
                  "for ${ironP.name}",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            background: Align(
              alignment: Alignment.bottomLeft,
              child: Icon(
                Icons.bluetooth_connected,
                size: 150,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              ),
            ),
            collapseMode: CollapseMode.parallax,
          ),
        ),
        SliverFillRemaining(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(children: [
              const SizedBox(height: 20),
              ironS.settings == null
                  ? ironS.isRetrieveing
                      ? Column(
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: 10),
                            Text("Retrieving settings..."),
                          ],
                        )
                      : Column(
                          children: [
                            Text("Failed to retrieve settings"),
                            TextButton(
                              onPressed: () {
                                ironSN.getSettings();
                              },
                              child: Text("Retry"),
                            ),
                          ],
                        )
                  : Column(
                      children: [
                        ExpansionTile(
                          title: Text("Soldering Settings"),
                          subtitle:
                              Text("Temperature, Start Up Behavior, etc..."),
                          expandedCrossAxisAlignment: CrossAxisAlignment.start,
                          childrenPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          children: [
                            Text("Soldering Temperature"),
                            Slider(
                              value: tempValue.toDouble(),
                              onChangeEnd: (value) {
                                ironSN.setTemp(value.toInt());
                              },
                              onChanged: (value) {
                                setState(() {
                                  tempValue = value.toInt();
                                });
                              },
                              min: 10,
                              max: ironP.data!.maxTemp.toDouble(),
                            ),
                            Center(
                              child: Text(
                                "$tempValue °C",
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          ],
                        )
                      ],
                    )
            ]),
          ),
        ),
      ],
    ));
  }
}
