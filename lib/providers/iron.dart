import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ironos_companion/data/iron_states.dart';
import 'package:ironos_companion/data/iron_uuids.dart';
import 'package:ironos_companion/utils/iron_data_extract.dart';
import 'package:ironos_companion/utils/line_chart.dart';
import 'package:permission_handler/permission_handler.dart';

import '../data/iron_data.dart';

class IronState {
  bool isConnected;
  IronData? data;
  BluetoothDevice? device;
  String name;
  String id;

  IronState({
    this.isConnected = false,
    this.data,
    this.device,
    this.name = "",
    this.id = "",
  });

  // toMap and toJson but only static
  Map<String, dynamic> toMapStatic() {
    return {
      'name': name,
      'id': id,
    };
  }

  String toJsonStatic() => json.encode(toMapStatic());

  IronState copyWith({
    bool? isConnected,
    IronData? data,
    BluetoothDevice? device,
    String? name,
    String? id,
  }) {
    return IronState(
      isConnected: isConnected ?? this.isConnected,
      data: data ?? this.data,
      device: device ?? this.device,
      name: name ?? this.name,
      id: id ?? this.id,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isConnected': isConnected,
      'data': data?.toMap(),
      'name': name,
      'id': id,
    };
  }

  factory IronState.fromMap(Map<dynamic, dynamic> map) {
    return IronState(
      isConnected: map['isConnected'] ?? false,
      data: map['data'] != null ? IronData.fromMap(map['data']) : null,
      name: map['name'] ?? '',
      id: map['id'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory IronState.fromJson(String source) =>
      IronState.fromMap(json.decode(source));

  @override
  String toString() {
    return 'IronState(isConnected: $isConnected, data: $data, device: $device, name: $name, id: $id)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is IronState &&
        other.isConnected == isConnected &&
        other.data == data &&
        other.device == device &&
        other.name == name &&
        other.id == id;
  }

  @override
  int get hashCode {
    return isConnected.hashCode ^
        data.hashCode ^
        device.hashCode ^
        name.hashCode ^
        id.hashCode;
  }
}

// Riverpod Provider

class IronProvider extends StateNotifier<IronState> {
  IronProvider() : super(IronState()) {
    // Load from Hive
    final box = Hive.box(boxName);
    if (box.isNotEmpty) {
      state = IronState.fromMap(box.toMap());
    }

    FlutterBluePlus.connectedSystemDevices.then((value) async {
      if (value.isNotEmpty) {
        for (final device in value) {
          if (device.remoteId.str == state.id) {
            // Connect
            connect(device, connect: false);
            break;
          }
        }
      }
    });
    // Attempt to connect to iron
    if (state.isConnected) {
      connect(state.device!);
    } else if (state.id.isNotEmpty) {
      // Listen for iron
      FlutterBluePlus.scanResults.listen((event) {
        if (event.isNotEmpty &&
            !state.isConnected &&
            event.first.device.remoteId.str == state.id) {
          connect(event.first.device);
        }
      });
    }

    int count = 0;
    // Await Bluetooth ready
    Timer.periodic(
      const Duration(milliseconds: 50),
      (timer) async {
        count++;
        if (count > 10) {
          timer.cancel();
        }
        if (await FlutterBluePlus.adapterState.first ==
            BluetoothAdapterState.on) {
          timer.cancel();
          startScan();
        }
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    state.device?.disconnect();
    super.dispose();
  }

  void pauseTimer() {
    _timer?.cancel();
  }

  void resumeTimer() {
    _timer?.cancel();
    final stateService = services!
        .firstWhere((element) => element.uuid.toString() == IronServices.bulk);
    _timer = Timer.periodic(
      const Duration(milliseconds: 1000),
      (_) => poll(stateService),
    );
  }

  Future<void> resetNewDevice() async {
    await disconnect();

    state = IronState(
      isConnected: false,
      data: null,
      device: null,
      name: "",
      id: "",
    );

    update(state);

    startScan();
  }

  static const boxName = "iron";

  final List<IronData> _history = [];

  LineChartData get chartData {
    final List<FlSpot> spots = [];
    final List<FlSpot> powerSpots = [];
    final List<FlSpot> setpointSpots = [];
    int currTMax = state.data?.setpoint ?? 0;
    for (int i = 0; i < _history.length; i++) {
      spots.add(FlSpot(i.toDouble(), _history[i].currentTemp.toDouble()));
      powerSpots
          .add(FlSpot(i.toDouble(), _history[i].estimatedWattage.toDouble()));
      // Only add setpoint if the power is on
      if (_history[i].currentMode == OperatingMode.soldering) {
        setpointSpots
            .add(FlSpot(i.toDouble(), _history[i].setpoint.toDouble()));
      }

      // Update the max value
      if (_history[i].currentTemp > currTMax) {
        currTMax = _history[i].currentTemp;
      }
    }
    return genLineChartData(
      spots,
      powerSpots,
      setpointSpots,
      state.data,
      currTMax,
    );
  }

  Timer? _timer;

  void update(IronState newState) {
    state = newState;
    // Save to Hive
    final box = Hive.box(boxName);
    box.putAll(state.toMapStatic());
  }

  void attemptReconnect() {
    if (state.isConnected) return;
    if (state.id.isEmpty) return;

    connect(state.device!);
  }

  Stream<List<ScanResult>> get scanResults => FlutterBluePlus.scanResults;

  bool _isScanning = false;
  List<BluetoothService>? services;

  Future<void> startScan() async {
    await getPerms();

    // Check if scanning
    if (_isScanning) return;
    _isScanning = true;

    try {
      await FlutterBluePlus.startScan(withServices: [
        Guid(IronServices.bulk), // Bulk data
        Guid(IronServices.settings) // Settings
      ]);
    } // Catch FlutterBluePlusError
    on FlutterBluePlusException catch (error, _) {
      if (error.errorCode == 1) {
        // Scan already in progress error, should stop and restart scan
        await FlutterBluePlus.stopScan();
        startScan();
      } else {
        rethrow;
      }
    }
  }

  Future<void> stopScan() async {
    // Check if scanning
    if (!_isScanning) return;
    await FlutterBluePlus.stopScan();
    _isScanning = false;
  }

  Future<bool> connect(BluetoothDevice device, {bool connect = true}) async {
    if (connect) {
      await device.connect();
    }

    stopScan();

    state = state.copyWith(
      isConnected: true,
      name: device.localName,
      id: device.remoteId.str,
      device: device,
    );

    // Update state
    update(state);

    _timer?.cancel();
    // Discover services
    services = await device.discoverServices();

    final stateService = services!
        .firstWhere((element) => element.uuid.toString() == IronServices.bulk);

    // Setup timer for polling characteristics
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(milliseconds: 1000),
      (_) => poll(stateService),
    );

    // Listen for disconnect
    _disconnectListener = device.connectionState.listen(disconnectListener);

    return true;
  }

  StreamSubscription<BluetoothConnectionState>? _disconnectListener;

  void disconnectListener(BluetoothConnectionState event) {
    if (event == BluetoothConnectionState.disconnected) {
      print("Disconnected");
      state = state.copyWith(
        isConnected: false,
      );
      _timer?.cancel();

      // Attempt to reconnect
      attemptReconnect();

      // Ensure we don't have a listener
      _disconnectListener?.cancel();
      _disconnectListener = null;
    }
  }

  Future<void> disconnect() async {
    _timer?.cancel();
    await state.device!.disconnect();
    state = state.copyWith(
      isConnected: false,
    );
  }

  Future<void> poll(BluetoothService stateService) async {
    // Poll characteristics
    final characteristics = stateService.characteristics.sublist(0, 1);

    final List<int> chars = [];

    try {
      for (final characteristic in characteristics) {
        final value = await characteristic.read();
        chars.addAll(value);
      }
    } catch (e) {
      // Connection lost, disconnect
      disconnect();
      return;
    }

    final IronData ironData = extractData(chars);

    // Update state
    state = state.copyWith(
      data: ironData,
    );

    // Add to history, ensure we don't have more than 60 entries
    _history.add(ironData);
    if (_history.length > 60) {
      _history.removeAt(0);
    }
  }

  void setTemp(int temp) {
    state = state.copyWith(
      data: state.data?.copyWith(
        setpoint: temp,
      ),
    );
  }

  Future<void> getPerms() async {
    var shouldRestart = false;
    PermissionStatus bluetoothPerm, locationPerm;

    if (Platform.isAndroid) {
      // Check if bluetooth is On
      await FlutterBluePlus.turnOn();
      await FlutterBluePlus.adapterState
          .where((s) => s == BluetoothAdapterState.on)
          .first;

      // Get Android version

      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      final version = androidInfo.version.sdkInt;
      if (version <= 28) {
        // Android 9 or lower
        locationPerm = await Permission.location.status;
        if (locationPerm != PermissionStatus.granted) {
          shouldRestart = true;
          locationPerm = await Permission.location.request();

          while (locationPerm != PermissionStatus.granted) {
            locationPerm = await Permission.location.request();
          }
        }
      } else if (version <= 30) {
        // Android 10 or 11
        bluetoothPerm = await Permission.bluetooth.status;
        locationPerm = await Permission.location.status;

        if (bluetoothPerm != PermissionStatus.granted) {
          shouldRestart = true;
          bluetoothPerm = await Permission.bluetooth.request();

          while (bluetoothPerm != PermissionStatus.granted) {
            bluetoothPerm = await Permission.bluetooth.request();
          }
        }

        if (locationPerm != PermissionStatus.granted) {
          shouldRestart = true;
          locationPerm = await Permission.location.request();

          while (locationPerm != PermissionStatus.granted) {
            locationPerm = await Permission.location.request();
          }
        }
      } else {
        // Android 12 or higher
        bluetoothPerm = await Permission.bluetoothScan.status;
        locationPerm = await Permission.bluetoothConnect.status;

        if (bluetoothPerm != PermissionStatus.granted) {
          shouldRestart = true;
          bluetoothPerm = await Permission.bluetoothScan.request();

          while (bluetoothPerm != PermissionStatus.granted) {
            bluetoothPerm = await Permission.bluetoothScan.request();
          }
        }

        if (locationPerm != PermissionStatus.granted) {
          shouldRestart = true;
          locationPerm = await Permission.bluetoothConnect.request();

          while (locationPerm != PermissionStatus.granted) {
            locationPerm = await Permission.bluetoothConnect.request();
          }
        }
      }
    } else {
      // iOS

      // Get ios version
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      final version = int.parse(iosInfo.systemVersion.split(".").first);

      // Ios 13 and above
      if (version >= 13) {
        bluetoothPerm = await Permission.bluetooth.status;
        locationPerm = await Permission.location.status;

        if (bluetoothPerm != PermissionStatus.granted) {
          shouldRestart = true;
          bluetoothPerm = await Permission.bluetooth.request();

          while (bluetoothPerm != PermissionStatus.granted) {
            bluetoothPerm = await Permission.bluetooth.request();
          }
        }

        if (locationPerm != PermissionStatus.granted) {
          shouldRestart = true;
          locationPerm = await Permission.location.request();

          while (locationPerm != PermissionStatus.granted) {
            locationPerm = await Permission.location.request();
          }
        }
      } else {
        // Ios 12 and below
        locationPerm = await Permission.location.status;

        if (locationPerm != PermissionStatus.granted) {
          shouldRestart = true;
          locationPerm = await Permission.location.request();

          while (locationPerm != PermissionStatus.granted) {
            locationPerm = await Permission.location.request();
          }
        }
      }
    }

    if (shouldRestart && _isScanning) {
      // Restart scan
      await stopScan();
      await startScan();
    }
  }
}

final ironProvider =
    StateNotifierProvider<IronProvider, IronState>((ref) => IronProvider());
