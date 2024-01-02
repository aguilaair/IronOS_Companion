import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ironos_companion/widgets/settings/power.dart';
import 'package:ironos_companion/widgets/settings/sleep.dart';
import 'package:ironos_companion/widgets/settings/soldering.dart';
import 'package:ironos_companion/widgets/settings/ui.dart';

import '../providers/iron.dart';
import '../providers/iron_settings.dart';

class SettingsScreen extends StatefulHookConsumerWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  int tempValue = 0;
  int boostValue = 0;

  @override
  void initState() {
    tempValue = ref.read(ironProvider).data?.setpoint ?? -1;
    boostValue =
        ref.read(ironSettingsProvider).settings?.solderingSettings.boostTemp ??
            -1;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ironP = ref.watch(ironProvider);
    final ironS = ref.watch(ironSettingsProvider);
    final ironSN = ref.watch(ironSettingsProvider.notifier);

    if (tempValue == -1) {
      tempValue = ironP.data?.setpoint ?? -1;
    }
    if (boostValue == -1) {
      boostValue = ironS.settings?.solderingSettings.boostTemp ?? -1;
    }

    return Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            ironSN.saveToFlash();
          },
          icon: const Icon(Icons.save),
          label: const Text(
            "Save to Flash",
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
          ),
        ),
        body: CustomScrollView(
          slivers: [
            SliverAppBar.large(
              //title: const Text("Settings"),
              flexibleSpace: FlexibleSpaceBar(
                title: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      "Settings",
                    ),
                    Text(
                      "for ${ironP.name}",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                background: Align(
                  alignment: Alignment.bottomRight,
                  child: Icon(
                    Icons.bluetooth_connected,
                    size: 150,
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  ),
                ),
                collapseMode: CollapseMode.parallax,
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    ironP.isConnected == false
                        ? Column(
                            children: [
                              const Text("Not connected to an iron"),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text(
                                  "Go back",
                                  style: TextStyle(fontSize: 15),
                                ),
                              ),
                            ],
                          )
                        : ironS.settings == null
                            ? ironS.isRetrieveing
                                ? const Column(
                                    children: [
                                      CircularProgressIndicator(),
                                      SizedBox(height: 10),
                                      Text("Retrieving settings..."),
                                    ],
                                  )
                                : Column(
                                    children: [
                                      const Text("Failed to retrieve settings"),
                                      TextButton(
                                        onPressed: () {
                                          ironSN.getSettings();
                                        },
                                        child: const Text("Retry"),
                                      ),
                                    ],
                                  )
                            : const Column(
                                children: [
                                  SolderingSettingsTile(),
                                  SleepSettingsTile(),
                                  PowerSettingsTile(),
                                  UISettingsTile(),
                                  SizedBox(height: 50),
                                ],
                              )
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}
