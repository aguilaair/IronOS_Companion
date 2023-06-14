import 'dart:convert';

import 'package:ironos_companion/data/iron_states.dart';

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
  final OperatingMode currentMode;
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
    this.currentMode = OperatingMode.idle,
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
    OperatingMode? currentMode,
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
