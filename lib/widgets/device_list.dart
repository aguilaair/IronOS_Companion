import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ironos_companion/providers/iron.dart';
import 'package:ironos_companion/screens/solder.dart';

class DeviceList extends StatefulHookConsumerWidget {
  const DeviceList({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DeviceListState();
}

class _DeviceListState extends ConsumerState<DeviceList> {
  FlutterBluePlus flutterBlue = FlutterBluePlus.instance;

  Future<dynamic>? scanFuture;

  @override
  Widget build(BuildContext context) {
    final ironP = ref.watch(ironProvider.notifier);
    ironP.startScan();
    return StreamBuilder<List<ScanResult>>(
        stream: ironP.scanResults,
        builder: (context, snapshot) {
          final numDev = snapshot.data?.length ?? 0;
          if (numDev == 0) {
            return Column(
              children: const [
                Text("No devices found"),
              ],
            );
          } else if (numDev == 1) {
            return Column(
              children: [
                const Text("Found IronOS device!"),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: ListTile(
                      title: Text(snapshot.data![0].device.name),
                      subtitle: Text(snapshot.data![0].device.id.toString()),
                    ),
                  ),
                ),
                // Connect Button
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton(
                      onPressed: () async {
                        await ref
                            .read(ironProvider.notifier)
                            .connect(snapshot.data![0].device);
                        if (mounted) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => const SolderPage(),
                            ),
                          );
                        }
                      },
                      child: const Text("Connect To Device"),
                    ),
                  ],
                ),
              ],
            );
          } else {
            return Column(
              children: [
                Text("Found $numDev IronOS devices!"),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: numDev,
                  itemBuilder: (context, index) {
                    final device = snapshot.data![index].device;
                    return ListTile(
                      title: Text(device.name),
                      subtitle: Text(device.id.toString()),
                      trailing: IconButton(
                        icon: const Icon(Icons.bluetooth_connected),
                        onPressed: () async {
                          await ref
                              .read(ironProvider.notifier)
                              .connect(snapshot.data![0].device);
                          if (mounted) {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => const SolderPage(),
                              ),
                            );
                          }
                        },
                      ),
                    );
                  },
                ),
                // Connect Button
              ],
            );
          }
        });
  }
}
