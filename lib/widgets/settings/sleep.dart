import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../providers/iron.dart';
import '../../providers/iron_settings.dart';

class SleepSettingsTile extends StatefulHookConsumerWidget {
  const SleepSettingsTile({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SleepSettingsTileState();
}

class _SleepSettingsTileState extends ConsumerState<SleepSettingsTile> {
  int sensitivityValue = -1;
  int sleepTempValue = -1;
  int sleepTimeValue = -1;
  Duration shutdownTimeValue = const Duration(seconds: -1);

  @override
  void initState() {
    sensitivityValue = ref
            .read(ironSettingsProvider)
            .settings
            ?.sleepSettings
            .motionSenitivity ??
        -1;
    sleepTempValue =
        ref.read(ironSettingsProvider).settings?.sleepSettings.sleepTemp ?? -1;
    sleepTimeValue =
        ref.read(ironSettingsProvider).settings?.sleepSettings.sleepTimeout ??
            -1;
    shutdownTimeValue = ref
            .read(ironSettingsProvider)
            .settings
            ?.sleepSettings
            .shutdownTimeout ??
        const Duration(seconds: -1);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ironP = ref.watch(ironProvider);
    final ironS = ref.watch(ironSettingsProvider);
    final ironSN = ref.watch(ironSettingsProvider.notifier);

    if (sensitivityValue == -1) {
      sensitivityValue = ironS.settings?.sleepSettings.motionSenitivity ?? -1;
    }
    if (sleepTempValue == -1) {
      sleepTempValue = ironS.settings?.sleepSettings.sleepTemp ?? -1;
    }
    if (sleepTimeValue == -1) {
      sleepTimeValue = ironS.settings?.sleepSettings.sleepTimeout ?? -1;
    }
    if (shutdownTimeValue.inSeconds == -1) {
      shutdownTimeValue = ironS.settings?.sleepSettings.shutdownTimeout ??
          const Duration(seconds: -1);
    }

    return ExpansionTile(
      title: const Text("Sleep Settings"),
      subtitle:
          const Text("Sleep mode settings like sensitivity, timeout, etc..."),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      childrenPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 10,
      ),
      children: [
        const Text("Motion Sensitivity"),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Off", style: Theme.of(context).textTheme.bodySmall),
            Text(
              "Medium",
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              "High",
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        Slider(
          value: sensitivityValue.toDouble(),
          onChangeEnd: (value) {
            ironSN.setMotionSensitivity(value.toInt());
          },
          onChanged: (value) {
            setState(() {
              sensitivityValue = value.toInt();
            });
          },
          min: 0,
          max: 9,
          divisions: 9,
        ),
        Center(
          child: Text(
            "$sensitivityValue",
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        const SizedBox(height: 10),
        ////////////////////////////
        const Text("Sleep Temperature"),
        Slider(
          value: sleepTempValue.toDouble(),
          thumbColor: Colors.purple,
          activeColor: Colors.purple,
          onChangeEnd: (value) {
            ironSN.setBoost(value.toInt());
          },
          onChanged: (value) {
            setState(() {
              sleepTempValue = value.toInt();
            });
          },
          min: 10,
          max: ironP.data!.maxTemp.toDouble(),
        ),
        Center(
          child: Text(
            "$sleepTempValue °C",
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        const SizedBox(height: 10),
        ////////////////////////////
        const Text("Sleep Timeout"),
        Slider(
          value: sleepTimeValue.toDouble(),
          onChangeEnd: (value) {
            ironSN.setSleepTimeout(value.toInt());
          },
          onChanged: (value) {
            setState(() {
              sleepTimeValue = value.toInt();
            });
          },
          min: 0,
          max: 15,
          divisions: 15,
        ),
        Center(
          child: Text(
            sleepTimeoutMap[sleepTimeValue] ?? "Off",
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        const SizedBox(height: 10),
        ////////////////////////////
        const Text("Shutdown Timeout"),
        Slider(
          value: shutdownTimeValue.inMinutes.toDouble(),
          onChangeEnd: (value) {
            ironSN.setShutdownTimeout(Duration(minutes: value.toInt()));
          },
          onChanged: (value) {
            setState(() {
              shutdownTimeValue = Duration(minutes: value.toInt());
            });
          },
          min: 0,
          max: 60,
          divisions: 60,
        ),
        Center(
          child: Text(
            shutdownTimeValue == Duration.zero
                ? "Off"
                : "${shutdownTimeValue.inMinutes} minutes",
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}

Map<int, String> sleepTimeoutMap = {
  0: "Off",
  1: "10 seconds",
  2: "20 seconds",
  3: "30 seconds",
  4: "40 seconds",
  5: "50 seconds",
  6: "1 minute",
  7: "2 minutes",
  8: "3 minutes",
  9: "4 minutes",
  10: "5 minutes",
  11: "6 minutes",
  12: "7 minutes",
  13: "8 minutes",
  14: "9 minutes",
  15: "10 minutes",
};
