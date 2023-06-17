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
  double cutoffVolValue = -1;
  double qcMaxVolValue = -1;
  Duration pdNegotiationValue = const Duration(seconds: -1);

  @override
  void initState() {
    cutoffVolValue =
        ref.read(ironSettingsProvider).settings?.powerSettings.minVolCell ?? -1;
    qcMaxVolValue =
        ref.read(ironSettingsProvider).settings?.powerSettings.qCMaxVoltage ??
            -1;
    pdNegotiationValue =
        ref.read(ironSettingsProvider).settings?.powerSettings.pdTimeout ??
            const Duration(seconds: -1);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ironS = ref.watch(ironSettingsProvider);
    final ironSN = ref.watch(ironSettingsProvider.notifier);

    if (cutoffVolValue == -1) {
      cutoffVolValue = ironS.settings?.powerSettings.minVolCell ?? -1;
    }
    if (qcMaxVolValue == -1) {
      qcMaxVolValue = ironS.settings?.powerSettings.qCMaxVoltage ?? -1;
    }
    if (pdNegotiationValue == const Duration(seconds: -1)) {
      pdNegotiationValue = ironS.settings?.powerSettings.pdTimeout ??
          const Duration(seconds: -1);
    }

    return ExpansionTile(
      title: const Text("Power settings"),
      subtitle: const Text("Power Source, Voltages and PD settings."),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      childrenPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 10,
      ),
      children: [
        const Text(
          "Power Source",
        ),
        const SizedBox(height: 10),
        ...PowerSource.values.map(
          (e) => RadioListTile<PowerSource>(
            title: Text(powerSourceMap[e]!),
            value: e,
            groupValue:
                ironS.settings?.powerSettings.dCInCutoff ?? PowerSource.dc,
            onChanged: (v) => ironSN.setPowerSource(v!),
          ),
        ),
        //////////////////////
        if (ironS.settings?.powerSettings.dCInCutoff != PowerSource.dc)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Text("Minimum Cell Voltage"),
              // Slider
              Slider(
                value: cutoffVolValue,
                onChangeEnd: (value) {
                  ironSN.setCutoffVol(value);
                },
                onChanged: (value) {
                  setState(() {
                    cutoffVolValue = value;
                  });
                },
                min: 2.4,
                max: 3.8,
              ),
              Center(
                child: Text(
                  "${cutoffVolValue.toStringAsFixed(2)} v",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const Text("Quick Charge Max Voltage"),
            // Slider
            Slider(
              value: qcMaxVolValue,
              onChangeEnd: (value) {
                ironSN.setQcMaxVoltage(value);
              },
              onChanged: (value) {
                setState(() {
                  qcMaxVolValue = value;
                });
              },
              min: 9,
              max: 22,
              divisions: 13,
            ),
            Center(
              child: Text(
                "${qcMaxVolValue.toStringAsFixed(2)} v",
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            const SizedBox(height: 10),
            //////////////////////
            const Text("PD Timeout"),
            // Slider
            Slider(
              value: pdNegotiationValue.inMilliseconds.toDouble(),
              onChangeEnd: (value) {
                ironSN.setPdTimeout(Duration(milliseconds: value.toInt()));
              },
              onChanged: (value) {
                setState(() {
                  pdNegotiationValue = Duration(milliseconds: value.toInt());
                });
              },
              min: 0,
              max: 5000,
              divisions: 50,
            ),
            Center(
              child: Text(
                pdNegotiationValue == Duration.zero
                    ? "Off"
                    : "${pdNegotiationValue.inMilliseconds} ms",
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

Map<PowerSource, String> powerSourceMap = {
  PowerSource.dc: "DC",
  PowerSource.threeCell: "3 Cell",
  PowerSource.fourCell: "4 Cell",
  PowerSource.fiveCell: "5 Cell",
  PowerSource.sixCell: "6 Cell",
};
