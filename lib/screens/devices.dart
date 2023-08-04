import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ironos_companion/providers/iron.dart';
import 'package:ironos_companion/widgets/device_list.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rive/rive.dart';

class DeviceSelectionScreen extends StatefulHookConsumerWidget {
  const DeviceSelectionScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DeviceSelectionScreenState();
}

class _DeviceSelectionScreenState extends ConsumerState<DeviceSelectionScreen> {
  PermissionStatus? bluetoothPerm;
  PermissionStatus? locationPerm;

  @override
  void initState() {
    super.initState();

    ref.read(ironProvider.notifier).getPerms();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: CustomScrollView(
      slivers: [
        SliverAppBar.large(
          title: const Text("Setup Companion"),
        ),
        SliverFillRemaining(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Text(
                  'Let\'s find your device, make sure it\'s turned on and bluetooth is enabled.',
                  textAlign: TextAlign.left,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                // Rive animation
                const SizedBox(
                  width: 300,
                  height: 300,
                  child: RiveAnimation.asset(
                    'assets/scanning.riv',
                    fit: BoxFit.contain,
                  ),
                ),
                const Expanded(child: DeviceList()),
              ],
            ),
          ),
        )
      ],
    ));
  }
}
