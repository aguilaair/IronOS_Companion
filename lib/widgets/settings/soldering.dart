import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../data/iron_settings.dart';
import '../../providers/iron.dart';
import '../../providers/iron_settings.dart';

class SolderingSettingsTile extends StatefulHookConsumerWidget {
  const SolderingSettingsTile({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SolderingSettingsTileState();
}

class _SolderingSettingsTileState extends ConsumerState<SolderingSettingsTile> {
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
    final tempSHortController = useTextEditingController(
      text: ironS.settings?.solderingSettings.tempChangeShortPress.toString(),
    );
    final tempLongController = useTextEditingController(
      text: ironS.settings?.solderingSettings.tempChangeLongPress.toString(),
    );
    return ExpansionTile(
      title: const Text("Soldering Settings"),
      subtitle: const Text("Temperature, Start Up Behavior, etc..."),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      childrenPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 10,
      ),
      children: [
        const Text("Soldering Temperature"),
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
        const SizedBox(height: 10),
        ////////////////////////////
        const Text("Boost Temperature"),
        Slider(
          value: boostValue.toDouble(),
          thumbColor: Theme.of(context).colorScheme.error,
          activeColor: Theme.of(context).colorScheme.error,
          onChangeEnd: (value) {
            ironSN.setBoost(value.toInt());
          },
          onChanged: (value) {
            setState(() {
              boostValue = value.toInt();
            });
          },
          min: 10,
          max: ironP.data!.maxTemp.toDouble(),
        ),
        Center(
          child: Text(
            "$boostValue °C",
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        const SizedBox(height: 10),
        ////////////////////////////
        const Text("Start Up Behavior"),
        const SizedBox(height: 10),
        ...StartupBehavior.values.map(
          (e) => RadioListTile(
            title: Text(startupBehaviorMap[e]!),
            value: e,
            groupValue: ironS.settings!.solderingSettings.startUpBehavior,
            onChanged: (value) {
              ironSN.setStartupBehavior(value!);
            },
          ),
        ),
        const SizedBox(height: 10),
        ////////////////////////////
        Row(
          children: [
            const Expanded(
              child: Text("Temp Change Short"),
            ),
            SizedBox(
              width: 100,
              child: TextField(
                keyboardType: TextInputType.number,
                controller: tempSHortController,
                onChanged: (value) {
                  if (value.isEmpty) {
                    return;
                  }
                  ironSN.setTempChangeShort(int.parse(value));
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text("°C"),
          ],
        ),
        const SizedBox(height: 10),
        ////////////////////////////
        Row(
          children: [
            const Expanded(
              child: Text("Temp Change Long"),
            ),
            SizedBox(
              width: 100,
              child: TextField(
                keyboardType: TextInputType.number,
                controller: tempLongController,
                onChanged: (value) {
                  if (value.isEmpty) {
                    return;
                  }
                  ironSN.setTempChangeShort(int.parse(value));
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text("°C"),
          ],
        ),
        const SizedBox(height: 10),
        ////////////////////////////
        const Text("Allow Locking Buttons"),
        const SizedBox(height: 10),
        ...LockingBehavior.values.map(
          (e) => RadioListTile(
            title: Text(allowLockingButtonsMap[e]!),
            value: e,
            groupValue: ironS.settings!.solderingSettings.allowLockingButtons,
            onChanged: (value) {
              ironSN.setLockButtons(value!);
            },
          ),
        ),
      ],
    );
  }
}

Map<StartupBehavior, String> startupBehaviorMap = {
  StartupBehavior.heatToSetpoint: "Heat to Setpoint",
  StartupBehavior.off: "Off",
  StartupBehavior.standbyUntilMoved: "Standby Until Moved",
  StartupBehavior.standbyWithoutHeating: "Standby without Heating",
};

Map<LockingBehavior, String> allowLockingButtonsMap = {
  LockingBehavior.off: "Off",
  LockingBehavior.boostOnly: "Boost Only",
  LockingBehavior.full: "Full",
};
