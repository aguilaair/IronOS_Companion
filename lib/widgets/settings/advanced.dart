import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../data/iron_settings.dart';
import '../../providers/iron_settings.dart';

class PowerSettingsTile extends StatefulHookConsumerWidget {
  const PowerSettingsTile({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PowerSettingsTileState();
}

class _PowerSettingsTileState extends ConsumerState<PowerSettingsTile> {
  double powerLimit = -1;
  double powerPulse = -1;
  Duration powerPulseDelay = Duration.zero;
  Duration powerPulseDuration = Duration.zero;

  @override
  void initState() {
    powerLimit = ref
            .read(ironSettingsProvider)
            .settings
            ?.advancedSettings
            .powerLimit
            .toDouble() ??
        -1;
    powerPulse = ref
            .read(ironSettingsProvider)
            .settings
            ?.advancedSettings
            .powerPulse
            .toDouble() ??
        -1;
    powerPulseDelay = ref
            .read(ironSettingsProvider)
            .settings
            ?.advancedSettings
            .powerPulseDelay ??
        Duration.zero;

    powerPulseDuration = ref
            .read(ironSettingsProvider)
            .settings
            ?.advancedSettings
            .powerPulseDuration ??
        Duration.zero;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ironS = ref.watch(ironSettingsProvider);
    final ironSN = ref.watch(ironSettingsProvider.notifier);

    if (powerLimit == -1) {
      powerLimit = ironS.settings?.advancedSettings.powerLimit.toDouble() ?? -1;
    }
    if (powerPulse == -1) {
      powerPulse = ironS.settings?.advancedSettings.powerPulse.toDouble() ?? -1;
    }
    if (powerPulseDelay == Duration.zero) {
      powerPulseDelay =
          ironS.settings?.advancedSettings.powerPulseDelay ?? Duration.zero;
    }
    if (powerPulseDuration == Duration.zero) {
      powerPulseDuration =
          ironS.settings?.advancedSettings.powerPulseDuration ?? Duration.zero;
    }

    return ExpansionTile(
      title: const Text("Advanced settings"),
      subtitle: const Text("Tweak power and other settings."),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      childrenPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 10,
      ),
      children: [
        const Text(
          "Power Limit",
        ),
        const SizedBox(height: 10),
        // Slider
        Slider(
          value: powerLimit,
          onChangeEnd: (value) {
            ironSN.setPowerLimit(value.toInt());
          },
          onChanged: (value) {
            setState(() {
              powerLimit = value;
            });
          },
          min: 0,
          max: 220,
          // Increment of 10s
          divisions: 22,
        ),
        Center(
          child: Text(
            "${powerLimit.toInt()} %",
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        const SizedBox(height: 10),
        //////////////////////
        const Text("Power Pulse"),
        const SizedBox(height: 10),
        // Slider
        Slider(
          value: powerPulse,
          onChangeEnd: (value) {
            ironSN.setPowerPulse(value);
          },
          onChanged: (value) {
            setState(() {
              powerPulse = value;
            });
          },
          min: 0,
          max: 99,
          divisions: 99,
        ),
        Center(
          child: Text(
            "${powerPulse.toInt()} W",
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        const SizedBox(height: 10),
        //////////////////////
        const Text("Power Pulse Delay"),
        const SizedBox(height: 10),
        // Slider
        Slider(
          value: powerPulseDelay.inMilliseconds.toDouble(),
          onChangeEnd: (value) {
            ironSN.setPowerPulseDelay(Duration(milliseconds: value.toInt()));
          },
          onChanged: (value) {
            setState(() {
              powerPulseDelay = Duration(milliseconds: value.toInt());
            });
          },
          min: 0,
          max: 9,
          divisions: 9,
        ),
        Center(
          child: Text(
            "${powerPulseDelay.inMilliseconds} ms",
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        const SizedBox(height: 10),
        //////////////////////
        const Text("Restore Defaults"),
        const SizedBox(height: 10),
        // Button
        ElevatedButton(
          onPressed: () {
            // Confirm Dialog
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text("Restore Defaults"),
                  content: const Text(
                      "Are you sure you want to restore the default settings?"),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () {
                        ironSN.resetAdvancedSettings();
                        Navigator.of(context).pop();
                      },
                      child: const Text("Reset"),
                    ),
                  ],
                );
              },
            );
          },
          child: const Text("Reset"),
        ),
      ],
    );
  }
}
