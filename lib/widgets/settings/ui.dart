import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ironos_companion/data/iron_settings.dart';

import '../../providers/iron_settings.dart';

class UISettingsTile extends StatefulHookConsumerWidget {
  const UISettingsTile({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _UISettingsTileState();
}

class _UISettingsTileState extends ConsumerState<UISettingsTile> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ironS = ref.watch(ironSettingsProvider);
    final ironSN = ref.watch(ironSettingsProvider.notifier);

    return ExpansionTile(
      title: const Text("User Interface"),
      subtitle: const Text("On-device settings for the user interface"),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      childrenPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 10,
      ),
      children: [
        const Text("Temperature Unit"),
        RadioListTile<TempUnit>(
          title: const Text("Celsius"),
          value: TempUnit.celsius,
          groupValue: ironS.settings!.uiSettings.tempUnit,
          onChanged: (value) {
            ironSN.setTempUnit(value!);
          },
        ),
        RadioListTile<TempUnit>(
          title: const Text("Fahrenheit"),
          value: TempUnit.fahrenheit,
          groupValue: ironS.settings!.uiSettings.tempUnit,
          onChanged: (value) {
            ironSN.setTempUnit(value!);
          },
        ),
        const SizedBox(height: 10),
        ////////////////////////
        const Text("Display Orientation"),
        RadioListTile<DisplayOrientation>(
          title: const Text("Automatic"),
          value: DisplayOrientation.auto,
          groupValue: ironS.settings!.uiSettings.displayOrientation,
          onChanged: (value) {
            ironSN.setDisplayOrientation(value!);
          },
        ),
        RadioListTile<DisplayOrientation>(
          title: const Text("Left-Handed"),
          value: DisplayOrientation.left,
          groupValue: ironS.settings!.uiSettings.displayOrientation,
          onChanged: (value) {
            ironSN.setDisplayOrientation(value!);
          },
        ),
        RadioListTile<DisplayOrientation>(
          title: const Text("Right-Handed"),
          value: DisplayOrientation.right,
          groupValue: ironS.settings!.uiSettings.displayOrientation,
          onChanged: (value) {
            ironSN.setDisplayOrientation(value!);
          },
        ),
      ],
    );
  }
}
