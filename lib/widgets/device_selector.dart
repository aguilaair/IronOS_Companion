import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../providers/iron.dart';
import '../screens/devices.dart';

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
