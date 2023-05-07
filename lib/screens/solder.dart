import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ironos_companion/screens/devices.dart';

import '../providers/iron.dart';

class SolderPage extends StatefulHookConsumerWidget {
  const SolderPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SolderPageState();
}

class _SolderPageState extends ConsumerState<SolderPage> {
  @override
  Widget build(BuildContext context) {
    final ironN = ref.watch(ironProvider.notifier);
    final ironP = ref.watch(ironProvider);
    return Scaffold(
      appBar: AppBar(
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
      ),
      body: const Center(
        child: Text("Solder Page"),
      ),
    );
  }
}
