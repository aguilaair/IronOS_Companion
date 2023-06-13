import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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
    for (int i = 0; i < _history.length; i++) {
      spots.add(FlSpot(i.toDouble(), _history[i].currentTemp.toDouble()));
      powerSpots
          .add(FlSpot(i.toDouble(), _history[i].estimatedWattage.toDouble()));
      // Only add setpoint if the power is on
      if (_history[i].currentMode != 0) {
        setpointSpots
            .add(FlSpot(i.toDouble(), _history[i].setpoint.toDouble()));
      }
    }
    return LineChartData(
      minY: 0,
      maxY: state.data?.setpoint.toDouble(),
      lineTouchData: LineTouchData(enabled: true),
      gridData: FlGridData(
        show: false,
      ),
      titlesData: FlTitlesData(
        show: false,
      ),
      borderData: FlBorderData(
        show: false,
      ),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          barWidth: 3,
          show: true,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                Colors.red.withOpacity(0.1),
                Colors.blue.withOpacity(0.1),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          gradient: const LinearGradient(
            colors: [
              Colors.red,
              Colors.blue,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        // Power
        LineChartBarData(
          spots: powerSpots,
          isCurved: true,
          barWidth: 3,
          show: true,
          dotData: FlDotData(show: false),
          gradient: const LinearGradient(
            colors: [
              Colors.green,
              Colors.greenAccent,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        // Setpoint
        LineChartBarData(
          spots: setpointSpots,
          isCurved: true,
          barWidth: 2,
          show: true,
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                Colors.orange.withOpacity(0.1),
                Colors.orangeAccent.withOpacity(0.1),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          dotData: FlDotData(show: false),
          gradient: const LinearGradient(
            colors: [
              Colors.orange,
              Colors.orangeAccent,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ],
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

  static const _tempSetUUID = "f6d70000-5a10-4eba-aa55-33e27f9bc533";
  static const _settingsServiceUUID = "f6d80000-5a10-4eba-aa55-33e27f9bc533";
  static const _saveSettingsUUID = "f6d7ffff-5a10-4eba-aa55-33e27f9bc533";
  static const _bulkDataUUID = "9eae1000-9d0d-48c5-aa55-33e27f9bc533";
  static const _bulkDataSecUUID = "9eae1001-9d0d-48c5-aa55-33e27f9bc533";

  void startScan() {
    // Check if scanning
    if (_isScanning) return;
    _blueInstance.startScan(withServices: [
      Guid(_bulkDataUUID), // Bulk data
      Guid(_settingsServiceUUID) // Settings
    ]);
    _blueInstance.scanResults.listen((event) {
      print("Found ${event.length} devices");
    });
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

    final stateService = _services!.firstWhere((element) =>
        element.uuid.toString() == _bulkDataUUID ||
        element.uuid.toString() == _bulkDataSecUUID);

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

    final temp =
        chars[0] + (chars[1] << 8) + (chars[2] << 16) + (chars[3] << 24);

    final setpoint =
        chars[4] + (chars[5] << 8) + (chars[6] << 16) + (chars[7] << 24);

    final inputVolts =
        (chars[8] + (chars[9] << 8) + (chars[10] << 16) + (chars[11] << 24)) /
            10;

    final handleTemp =
        (chars[12] + (chars[13] << 8) + (chars[14] << 16) + (chars[15] << 24)) /
            10;

    final pwsAsPwm =
        chars[16] + (chars[17] << 8) + (chars[18] << 16) + (chars[19] << 24);

    final powerSrc =
        chars[20] + (chars[21] << 8) + (chars[22] << 16) + (chars[23] << 24);

    final tipRes =
        chars[24] + (chars[25] << 8) + (chars[26] << 16) + (chars[27] << 24);

    final uptime =
        (chars[28] + (chars[29] << 8) + (chars[30] << 16) + (chars[31] << 24)) /
            10;

    final lastMovement =
        (chars[32] + (chars[33] << 8) + (chars[34] << 16) + (chars[35] << 24)) /
            10;

    final maxTemp =
        chars[36] + (chars[37] << 8) + (chars[38] << 16) + (chars[39] << 24);

    final rawTipMicroV =
        chars[40] + (chars[41] << 8) + (chars[42] << 16) + (chars[43] << 24);

    final hallSensor =
        chars[44] + (chars[45] << 8) + (chars[46] << 16) + (chars[47] << 24);

    final opMode =
        chars[48] + (chars[49] << 8) + (chars[50] << 16) + (chars[51] << 24);

    final watts =
        (chars[52] + (chars[53] << 8) + (chars[54] << 16) + (chars[55] << 24)) /
            10;

    final ironData = IronData(
      currentTemp: temp,
      setpoint: setpoint,
      inputVoltage: inputVolts,
      handleTemp: handleTemp,
      power: pwsAsPwm,
      powerSrc: powerSrc,
      tipResistance: tipRes,
      uptime: uptime,
      lastMovementTime: lastMovement,
      maxTemp: maxTemp,
      rawTip: rawTipMicroV,
      hallSensor: hallSensor,
      currentMode: opMode,
      estimatedWattage: watts,
    );

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
        (element) => element.uuid.toString() == _settingsServiceUUID);

    // Get characteristic
    final tempCharacteristic = service.characteristics
        .firstWhere((element) => element.uuid.toString() == _tempSetUUID);

    // Write data
    ByteData view = ByteData(2);
    view.setUint16(0, data.setpoint, Endian.little);

    await tempCharacteristic.write(view.buffer.asUint8List(),
        withoutResponse: true);
  }

  Future<void> saveToFlash() async {
    final service = _services!.firstWhere(
        (element) => element.uuid.toString() == _settingsServiceUUID);

    // Get characteristic for save
    final saveCharacteristic = service.characteristics
        .firstWhere((element) => element.uuid.toString() == _saveSettingsUUID);

    // Set to 1 to save
    ByteData view = ByteData(1);
    view.setUint8(0, 1);

    await saveCharacteristic.write(view.buffer.asUint8List(),
        withoutResponse: true);
  }
}

final ironProvider =
    StateNotifierProvider<IronProvider, IronState>((ref) => IronProvider());

/*
      uint32_t bulkData[] = {
          TipThermoModel::getTipInC(),                                         // 0  - Current temp
          getSettingValue(SettingsOptions::SolderingTemp),                     // 1  - Setpoint
          getInputVoltageX10(getSettingValue(SettingsOptions::VoltageDiv), 0), // 2  - Input voltage
          getHandleTemperature(0),                                             // 3  - Handle X10 Temp in C
          X10WattsToPWM(x10WattHistory.average()),                             // 4  - Power as PWM level
          getPowerSrc(),                                                       // 5  - power src
          getTipResistanceX10(),                                               // 6  - Tip resistance
          xTaskGetTickCount() / TICKS_100MS,                                   // 7  - uptime in deciseconds
          lastMovementTime / TICKS_100MS,                                      // 8  - last movement time (deciseconds)
          TipThermoModel::getTipMaxInC(),                                      // 9  - max temp
          TipThermoModel::convertTipRawADCTouV(getTipRawTemp(0), true),        // 10 - Raw tip in μV
          abs(getRawHallEffect()),                                             // 11 - hall sensor
          currentMode,                                                         // 12 - Operating mode
          x10WattHistory.average(),                                            // 13 - Estimated Wattage *10
      };


*/

class IronData {
  final int currentTemp;
  final int setpoint;
  final double inputVoltage;
  final double handleTemp;
  final int power;
  final int powerSrc;
  final int tipResistance;
  final double uptime;
  final double lastMovementTime;
  final int maxTemp;
  final int rawTip;
  final int hallSensor;
  final int currentMode;
  final double estimatedWattage;

  IronData({
    this.currentTemp = 0,
    this.setpoint = 0,
    this.inputVoltage = 0,
    this.handleTemp = 0,
    this.power = 0,
    this.powerSrc = 0,
    this.tipResistance = 0,
    this.uptime = 0,
    this.lastMovementTime = 0,
    this.maxTemp = 0,
    this.rawTip = 0,
    this.hallSensor = 0,
    this.currentMode = 0,
    this.estimatedWattage = 0,
  });

  IronData copyWith({
    int? currentTemp,
    int? setpoint,
    double? inputVoltage,
    double? handleTemp,
    int? power,
    int? powerSrc,
    int? tipResistance,
    double? uptime,
    double? lastMovementTime,
    int? maxTemp,
    int? rawTip,
    int? hallSensor,
    int? currentMode,
    double? estimatedWattage,
  }) {
    return IronData(
      currentTemp: currentTemp ?? this.currentTemp,
      setpoint: setpoint ?? this.setpoint,
      inputVoltage: inputVoltage ?? this.inputVoltage,
      handleTemp: handleTemp ?? this.handleTemp,
      power: power ?? this.power,
      powerSrc: powerSrc ?? this.powerSrc,
      tipResistance: tipResistance ?? this.tipResistance,
      uptime: uptime ?? this.uptime,
      lastMovementTime: lastMovementTime ?? this.lastMovementTime,
      maxTemp: maxTemp ?? this.maxTemp,
      rawTip: rawTip ?? this.rawTip,
      hallSensor: hallSensor ?? this.hallSensor,
      currentMode: currentMode ?? this.currentMode,
      estimatedWattage: estimatedWattage ?? this.estimatedWattage,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'currentTemp': currentTemp,
      'setpoint': setpoint,
      'inputVoltage': inputVoltage,
      'handleTemp': handleTemp,
      'power': power,
      'powerSrc': powerSrc,
      'tipResistance': tipResistance,
      'uptime': uptime,
      'lastMovementTime': lastMovementTime,
      'maxTemp': maxTemp,
      'rawTip': rawTip,
      'hallSensor': hallSensor,
      'currentMode': currentMode,
      'estimatedWattage': estimatedWattage,
    };
  }

  factory IronData.fromMap(Map<String, dynamic> map) {
    return IronData(
      currentTemp: map['currentTemp']?.toInt() ?? 0,
      setpoint: map['setpoint']?.toInt() ?? 0,
      inputVoltage: map['inputVoltage']?.toDouble() ?? 0.0,
      handleTemp: map['handleTemp']?.toDouble() ?? 0.0,
      power: map['power']?.toInt() ?? 0,
      powerSrc: map['powerSrc']?.toInt() ?? 0,
      tipResistance: map['tipResistance']?.toInt() ?? 0,
      uptime: map['uptime']?.toDouble() ?? 0.0,
      lastMovementTime: map['lastMovementTime']?.toDouble() ?? 0.0,
      maxTemp: map['maxTemp']?.toInt() ?? 0,
      rawTip: map['rawTip']?.toInt() ?? 0,
      hallSensor: map['hallSensor']?.toInt() ?? 0,
      currentMode: map['currentMode']?.toInt() ?? 0,
      estimatedWattage: map['estimatedWattage']?.toDouble() ?? 0.0,
    );
  }

  String toJson() => json.encode(toMap());

  factory IronData.fromJson(String source) =>
      IronData.fromMap(json.decode(source));

  @override
  String toString() {
    return 'IronData(currentTemp: $currentTemp, setpoint: $setpoint, inputVoltage: $inputVoltage, handleTemp: $handleTemp, power: $power, powerSrc: $powerSrc, tipResistance: $tipResistance, uptime: $uptime, lastMovementTime: $lastMovementTime, maxTemp: $maxTemp, rawTip: $rawTip, hallSensor: $hallSensor, currentMode: $currentMode, estimatedWattage: $estimatedWattage)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is IronData &&
        other.currentTemp == currentTemp &&
        other.setpoint == setpoint &&
        other.inputVoltage == inputVoltage &&
        other.handleTemp == handleTemp &&
        other.power == power &&
        other.powerSrc == powerSrc &&
        other.tipResistance == tipResistance &&
        other.uptime == uptime &&
        other.lastMovementTime == lastMovementTime &&
        other.maxTemp == maxTemp &&
        other.rawTip == rawTip &&
        other.hallSensor == hallSensor &&
        other.currentMode == currentMode &&
        other.estimatedWattage == estimatedWattage;
  }

  @override
  int get hashCode {
    return currentTemp.hashCode ^
        setpoint.hashCode ^
        inputVoltage.hashCode ^
        handleTemp.hashCode ^
        power.hashCode ^
        powerSrc.hashCode ^
        tipResistance.hashCode ^
        uptime.hashCode ^
        lastMovementTime.hashCode ^
        maxTemp.hashCode ^
        rawTip.hashCode ^
        hallSensor.hashCode ^
        currentMode.hashCode ^
        estimatedWattage.hashCode;
  }
}
