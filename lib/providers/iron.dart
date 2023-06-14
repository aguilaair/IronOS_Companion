import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ironos_companion/data/iron_states.dart';
import 'package:ironos_companion/data/iron_uuids.dart';
import 'package:ironos_companion/utils/iron_data_extract.dart';
import 'package:ironos_companion/utils/line_chart.dart';

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

    _blueInstance.connectedDevices.then((value) async {
      if (value.isNotEmpty) {
        for (final device in value) {
          if (device.id.id == state.id) {
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
      _blueInstance.scanResults.listen((event) {
        if (event.isNotEmpty &&
            !state.isConnected &&
            event.first.device.id.id == state.id) {
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
        if (await _blueInstance.isOn) {
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

  final _blueInstance = FlutterBluePlus.instance;

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

  Stream<List<ScanResult>> get scanResults => _blueInstance.scanResults;

  bool _isScanning = false;
  List<BluetoothService>? _services;

  void startScan() {
    // Check if scanning
    if (_isScanning) return;
    _blueInstance.startScan(withServices: [
      Guid(IronServices.bulk), // Bulk data
      Guid(IronServices.settings) // Settings
    ]);
    _isScanning = true;
  }

  void stopScan() {
    // Check if scanning
    if (!_isScanning) return;
    _blueInstance.stopScan();
    _isScanning = false;
  }

  Future<bool> connect(BluetoothDevice device, {bool connect = true}) async {
    if (connect) {
      await device.connect();
    }

    stopScan();

    state = state.copyWith(
      isConnected: true,
      name: device.name,
      id: device.id.id,
      device: device,
    );

    // Update state
    update(state);

    _timer?.cancel();
    // Discover services
    _services = await device.discoverServices();

    final stateService = _services!
        .firstWhere((element) => element.uuid.toString() == IronServices.bulk);

    // Setup timer for polling characteristics
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(milliseconds: 1000),
      (_) => poll(stateService),
    );

    // Listen for disconnect
    device.state.listen((event) {
      if (event == BluetoothDeviceState.disconnected) {
        state = state.copyWith(
          isConnected: false,
        );
        _timer?.cancel();
      }
    });

    return true;
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

  // Set data - write to f6d7ffff-5a10-4eba-aa55-33e27f9bc533 value 1 to save settings
  Future<void> setData(IronData data) async {
    state = state.copyWith(data: data);

    // Get service
    final service = _services!.firstWhere(
        (element) => element.uuid.toString() == IronServices.settings);

    // Get characteristic
    final tempCharacteristic = service.characteristics.firstWhere((element) =>
        element.uuid.toString() == IronCharacteristicUUIDSs.setTemperature);

    // Write data
    ByteData view = ByteData(2);
    view.setUint16(0, data.setpoint, Endian.little);

    await tempCharacteristic.write(view.buffer.asUint8List(),
        withoutResponse: true);
  }

  Future<void> saveToFlash() async {
    final service = _services!.firstWhere(
        (element) => element.uuid.toString() == IronServices.settings);

    // Get characteristic for save
    final saveCharacteristic = service.characteristics.firstWhere((element) =>
        element.uuid.toString() == IronCharacteristicUUIDSs.saveToFlash);

    // Set to 1 to save
    ByteData view = ByteData(1);
    view.setUint8(0, 1);

    await saveCharacteristic.write(view.buffer.asUint8List(),
        withoutResponse: true);
  }
}

final ironProvider =
    StateNotifierProvider<IronProvider, IronState>((ref) => IronProvider());
