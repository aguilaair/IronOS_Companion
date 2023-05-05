import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class DeviceList extends StatefulHookConsumerWidget {
  const DeviceList({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DeviceListState();
}

class _DeviceListState extends ConsumerState<DeviceList> {
  FlutterBluePlus flutterBlue = FlutterBluePlus.instance;

  @override
  void initState() {
    super.initState();
    flutterBlue.startScan(timeout: const Duration(seconds: 3), withServices: [
      Guid("9eae1000-9d0d-48c5-aa55-33e27f9bc533"),
      Guid("f6d80000-5a10-4eba-aa55-33e27f9bc533")
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ScanResult>>(
        stream: flutterBlue.scanResults,
        builder: (context, snapshot) {
          final numDev = snapshot.data?.length ?? 0;
          if (numDev == 0) {
            return const Center(
              child: Text("No devices found"),
            );
          } else if (numDev == 1) {
            return const Text("Found IronOS device!");
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
                      onTap: () {
                        flutterBlue.stopScan();
                        Navigator.of(context)
                            .pushNamed("/device", arguments: device);
                      },
                    );
                  },
                ),
              ],
            );
          }
        });
  }
}
