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

  int brightnessValue = 0;
  int logoDurationValue = 0;

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
        const SizedBox(height: 10),
        ////////////////////////
        const Text("Cooldown Flashing"),
        SwitchListTile(
          title: const Text("Enable"),
          value: ironS.settings!.uiSettings.cooldownFlashing,
          onChanged: (value) {
            ironSN.setCooldownFlashing(value);
          },
        ),
        const SizedBox(height: 10),
        ////////////////////////
        const Text("Scrolling Speed"),
        ...ScrollingSpeed.values.map(
          (e) => RadioListTile<ScrollingSpeed>(
            title: Text(e.name[0].toUpperCase() + e.name.substring(1)),
            value: e,
            groupValue: ironS.settings!.uiSettings.scrollingSpeed,
            onChanged: (value) {
              ironSN.setScrollingSpeed(value!);
            },
          ),
        ),
        const SizedBox(height: 10),
        ////////////////////////
        const Text("Swap Buttons"),
        SwitchListTile(
          title: const Text("Enable"),
          value: ironS.settings!.uiSettings.swapPlusMinusKeys,
          onChanged: (value) {
            ironSN.setSwapButtons(value);
          },
        ),
        const SizedBox(height: 10),
        ////////////////////////
        const Text("Animation Speed"),
        ...AnimationSpeed.values.map(
          (e) => RadioListTile<AnimationSpeed>(
            title: Text(e.name[0].toUpperCase() + e.name.substring(1)),
            value: e,
            groupValue: ironS.settings!.uiSettings.animationSpeed,
            onChanged: (value) {
              ironSN.setAnimationSpeed(value!);
            },
          ),
        ),
        const SizedBox(height: 10),
        ////////////////////////
        const Text("Screen Brightness"),
        Slider(
          value: brightnessValue.toDouble(),
          min: 0,
          max: 101,
          label: ironS.settings!.uiSettings.screenBrightness.round().toString(),
          onChangeEnd: (value) {
            ironSN.setScreenBrightness(value.toInt());
          },
          onChanged: (value) {
            setState(() {
              brightnessValue = value.toInt();
            });
          },
        ),
        Center(
          child: Text(
            "${ironS.settings!.uiSettings.screenBrightness.round()}%",
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        const SizedBox(height: 10),
        ////////////////////////
        const Text("Invert Screen"),
        SwitchListTile(
          title: const Text("Enable"),
          value: ironS.settings!.uiSettings.invertScreen,
          onChanged: (value) {
            ironSN.setInvertScreen(value);
          },
        ),
        const SizedBox(height: 10),
        ////////////////////////
        const Text("Boot Logo Duration"),
        Slider(
          value: logoDurationValue.toDouble(),
          min: 0,
          max: 5,
          onChangeEnd: (value) {
            ironSN.setBootLogoDuration(value.toInt());
          },
          onChanged: (value) {
            setState(() {
              logoDurationValue = value.toInt();
            });
          },
        ),
        Center(
          child: Text(
            "${ironS.settings!.uiSettings.bootLogoDuration.inSeconds} seconds",
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        const SizedBox(height: 10),
        ////////////////////////
        const Text("Detailed Idle Screen"),
        SwitchListTile(
          title: const Text("Enable"),
          value: ironS.settings!.uiSettings.detailedIdleScreen,
          onChanged: (value) {
            ironSN.setDetailedIdleScreen(value);
          },
        ),
        const SizedBox(height: 10),
        ////////////////////////
        const Text("Detailed Solder Screen"),
        SwitchListTile(
          title: const Text("Enable"),
          value: ironS.settings!.uiSettings.detailedSolderingScreen,
          onChanged: (value) {
            ironSN.setDetailedSolderScreen(value);
          },
        ),
        const SizedBox(height: 10),
        ////////////////////////
      ],
    );
  }
}
