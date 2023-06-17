import 'dart:typed_data';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:ironos_companion/data/iron_settings.dart';
import 'package:ironos_companion/data/iron_uuids.dart';

import 'iron.dart';

class IronSettingsState {
  IronSettings? settings;
  bool isRetrieveing;

  IronSettingsState({
    this.settings,
    this.isRetrieveing = false,
  });

  IronSettingsState copyWith({
    IronSettings? settings,
    bool? isRetrieveing,
  }) {
    return IronSettingsState(
      settings: settings ?? this.settings,
      isRetrieveing: isRetrieveing ?? this.isRetrieveing,
    );
  }

  // error state factory
  factory IronSettingsState.error() {
    return IronSettingsState(
      settings: null,
      isRetrieveing: false,
    );
  }

  @override
  String toString() =>
      'IronSettingsState(settings: $settings, isRetrieveing: $isRetrieveing)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is IronSettingsState &&
        other.settings == settings &&
        other.isRetrieveing == isRetrieveing;
  }

  @override
  int get hashCode => settings.hashCode ^ isRetrieveing.hashCode;
}

class IronSettingsProvider extends StateNotifier<IronSettingsState> {
  IronSettingsProvider(this.ref) : super(IronSettingsState()) {
    state = IronSettingsState(
      isRetrieveing: true,
    );
    getSettings();
  }

  Ref ref;

  Future<void> getSettings() async {
    final ironN = ref.read(ironProvider.notifier);
    final iron = ref.read(ironProvider);

    ironN.pauseTimer();

    if (!iron.isConnected) {
      throw Exception("Iron is not connected");
    }

    while (ironN.services == null) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    try {
      state = state.copyWith(
        isRetrieveing: true,
      );

      // Get the services
      final settingsService = ironN.services!.firstWhere(
          (element) => element.uuid.toString() == IronServices.settings);

      // Get Power Settings
      PowerSettings powerSettings = await _getPowerSettings(settingsService);

      // Get Sleep Settings
      SolderingSettings solderingSettings =
          await _getSolderingSettings(settingsService);

      // Get UI Settings
      UISettings uiSettings = await _getUISettings(settingsService);

      // Get advanced settings
      AdvancedSettings? advancedSettings =
          await _getAdvancedSettings(settingsService);

      // Get Sleep Settings
      SleepSettings? sleepSettings = await _getSleepSettings(settingsService);

      state = state.copyWith(
        settings: IronSettings(
          powerSettings: powerSettings,
          solderingSettings: solderingSettings,
          uiSettings: uiSettings,
          advancedSettings: advancedSettings,
          sleepSettings: sleepSettings,
        ),
        isRetrieveing: false,
      );
    } catch (e) {
      state = IronSettingsState.error();
    }

    ironN.resumeTimer();
    state = state.copyWith(
      isRetrieveing: false,
    );
  }

  Future<PowerSettings> _getPowerSettings(BluetoothService service) async {
    // Get the characteristics
    final sourceChar = service.characteristics.firstWhere((element) =>
        element.uuid.toString() == IronCharacteristicUUIDSs.dCInCutoff);

    // It is a byte array, so we need to convert it to an int
    final rawCutoff = await sourceChar.read();
    final intCutoff = rawCutoff[0];

    final cutoff = PowerSource.values[intCutoff];

    final minVolChar = service.characteristics.firstWhere((element) =>
        element.uuid.toString() == IronCharacteristicUUIDSs.minVolCell);

    final rawMinVol = await minVolChar.read();
    final minVolCell = rawMinVol[0];

    final qCMaxVoltageChar = service.characteristics.firstWhere((element) =>
        element.uuid.toString() == IronCharacteristicUUIDSs.qCMaxVoltage);

    final rawQCMaxVoltage = await qCMaxVoltageChar.read();
    final qCMaxVoltage = rawQCMaxVoltage[0];

    final pdTimeoutChar = service.characteristics.firstWhere((element) =>
        element.uuid.toString() == IronCharacteristicUUIDSs.pdNegTimeout);

    final rawPDTimeout = await pdTimeoutChar.read();
    final pdTimeout = rawPDTimeout[0];

    final powerSettings = PowerSettings(
      dCInCutoff: cutoff,
      minVolCell: minVolCell / 10,
      qCMaxVoltage: qCMaxVoltage / 10,
      pdTimeout: Duration(milliseconds: pdTimeout * 100),
    );

    return powerSettings;
  }

  Future<SolderingSettings> _getSolderingSettings(
      BluetoothService service) async {
    final tempChar = service.characteristics.firstWhere((element) =>
        element.uuid.toString() == IronCharacteristicUUIDSs.setTemperature);

    final rawTemp = await tempChar.read();
    final temp = rawTemp[0] | (rawTemp[1] << 8);

    final boostChar = service.characteristics.firstWhere((element) =>
        element.uuid.toString() == IronCharacteristicUUIDSs.boostTemperature);

    final rawBoost = await boostChar.read();
    final boost = rawBoost[0] | (rawBoost[1] << 8);

    final startChar = service.characteristics.firstWhere((element) =>
        element.uuid.toString() == IronCharacteristicUUIDSs.autoStart);

    final rawStart = await startChar.read();
    final StartupBehavior start = StartupBehavior.values[rawStart[0]];

    final tempChangeShrtChar = service.characteristics.firstWhere((element) =>
        element.uuid.toString() ==
        IronCharacteristicUUIDSs.tempChangeShortStep);

    final rawTempChangeShrt = await tempChangeShrtChar.read();
    final tempChangeShrt = rawTempChangeShrt[0] | (rawTempChangeShrt[1] << 8);

    final tempChangeLngChar = service.characteristics.firstWhere((element) =>
        element.uuid.toString() == IronCharacteristicUUIDSs.tempChangeLongStep);

    final rawTempChangeLng = await tempChangeLngChar.read();
    final tempChangeLng = rawTempChangeLng[0] | (rawTempChangeLng[1] << 8);

    final lockChar = service.characteristics.firstWhere((element) =>
        element.uuid.toString() == IronCharacteristicUUIDSs.lockingMode);

    final rawLock = await lockChar.read();
    final LockingBehavior lock = LockingBehavior.values[rawLock[0]];

    final solderingSettings = SolderingSettings(
      solderingTemp: temp,
      boostTemp: boost,
      startUpBehavior: start,
      tempChangeShortPress: tempChangeShrt,
      tempChangeLongPress: tempChangeLng,
      allowLockingButtons: lock,
    );

    return solderingSettings;
  }

  Future<UISettings> _getUISettings(BluetoothService service) async {
    final unitChar = service.characteristics.firstWhere((element) =>
        element.uuid.toString() == IronCharacteristicUUIDSs.temperatureUnit);

    final rawUnit = await unitChar.read();
    final unit = TempUnit.values[rawUnit[0]];

    final orientationChar = service.characteristics.firstWhere((element) =>
        element.uuid.toString() == IronCharacteristicUUIDSs.displayRotation);

    final rawOrientation = await orientationChar.read();
    final orientation = DisplayOrientation.values[rawOrientation[0]];

    final cooldownChar = service.characteristics.firstWhere((element) =>
        element.uuid.toString() == IronCharacteristicUUIDSs.cooldownBlink);

    final rawCooldown = await cooldownChar.read();
    final bool cooldown = rawCooldown[0] == 1;

    final scrollSpeedChar = service.characteristics.firstWhere((element) =>
        element.uuid.toString() == IronCharacteristicUUIDSs.scrollingSpeed);

    final rawScrollSpeed = await scrollSpeedChar.read();
    final ScrollingSpeed scrollSpeed = ScrollingSpeed.values[rawScrollSpeed[0]];

    final swapKeysChar = service.characteristics.firstWhere((element) =>
        element.uuid.toString() ==
        IronCharacteristicUUIDSs.reverseButtonTempChange);

    final rawSwapKeys = await swapKeysChar.read();
    final bool swapKeys = rawSwapKeys[0] == 1;

    final animSpeedChar = service.characteristics.firstWhere((element) =>
        element.uuid.toString() == IronCharacteristicUUIDSs.animSpeed);

    final rawAnimSpeed = await animSpeedChar.read();
    final AnimationSpeed animSpeed = AnimationSpeed.values[rawAnimSpeed[0]];

    final brightnessChar = service.characteristics.firstWhere((element) =>
        element.uuid.toString() == IronCharacteristicUUIDSs.brightness);

    final rawBrightness = await brightnessChar.read();
    final brightness = rawBrightness[0];

    final invertChar = service.characteristics.firstWhere((element) =>
        element.uuid.toString() == IronCharacteristicUUIDSs.colourInversion);

    final rawInvert = await invertChar.read();
    final bool invert = rawInvert[0] == 1;

    final bootDurChar = service.characteristics.firstWhere((element) =>
        element.uuid.toString() == IronCharacteristicUUIDSs.logoTime);

    final rawBootDur = await bootDurChar.read();
    final Duration bootDur = Duration(seconds: rawBootDur[0]);

    final advIdleChar = service.characteristics.firstWhere((element) =>
        element.uuid.toString() == IronCharacteristicUUIDSs.advancedIdle);

    final rawAdvIdle = await advIdleChar.read();
    final bool advIdle = rawAdvIdle[0] == 1;

    final advSolderingChar = service.characteristics.firstWhere((element) =>
        element.uuid.toString() == IronCharacteristicUUIDSs.advancedSoldering);

    final rawAdvSoldering = await advSolderingChar.read();
    final bool advSoldering = rawAdvSoldering[0] == 1;

    final uiSettings = UISettings(
      tempUnit: unit,
      displayOrientation: orientation,
      cooldownFlashing: cooldown,
      scrollingSpeed: scrollSpeed,
      swapPlusMinusKeys: swapKeys,
      animationSpeed: animSpeed,
      screenBrightness: brightness,
      invertScreen: invert,
      bootLogoDuration: bootDur,
      detailedIdleScreen: advIdle,
      detailedSolderingScreen: advSoldering,
    );

    return uiSettings;
  }

  Future<AdvancedSettings> _getAdvancedSettings(
      BluetoothService service) async {
    final powerLimitChar = service.characteristics.firstWhere((element) =>
        element.uuid.toString() == IronCharacteristicUUIDSs.powerLimit);

    final rawPowerLimit = await powerLimitChar.read();
    final powerLimit = rawPowerLimit[0] | (rawPowerLimit[1] << 8);

    final calibrateCJCChar = service.characteristics.firstWhere((element) =>
        element.uuid.toString() == IronCharacteristicUUIDSs.calibrateCJC);

    final rawCalibrateCJC = await calibrateCJCChar.read();
    final bool alibrateCJC = rawCalibrateCJC[0] == 1;

    final powerPulseChar = service.characteristics.firstWhere((element) =>
        element.uuid.toString() == IronCharacteristicUUIDSs.powerPulsePower);

    final rawPowerPulse = await powerPulseChar.read();
    final powerPulse = (rawPowerPulse[0] | (rawPowerPulse[1] << 8)) / 10;

    final powerPulseDurChar = service.characteristics.firstWhere((element) =>
        element.uuid.toString() == IronCharacteristicUUIDSs.powerPulseDuration);

    final rawPowerPulseDur = await powerPulseDurChar.read();
    final Duration powerPulseDur =
        Duration(seconds: rawPowerPulseDur[0] | (rawPowerPulseDur[1] << 8));

    final powePulseDelayChar = service.characteristics.firstWhere((element) =>
        element.uuid.toString() == IronCharacteristicUUIDSs.powerPulseWait);

    final rawPowerPulseDelay = await powePulseDelayChar.read();
    final Duration powerPulseDelay =
        Duration(seconds: rawPowerPulseDelay[0] | (rawPowerPulseDelay[1] << 8));

    final advancedSetings = AdvancedSettings(
      powerLimit: powerLimit,
      calibrateCJCNextBoot: alibrateCJC,
      powerPulse: powerPulse,
      powerPulseDuration: powerPulseDur,
      powerPulseDelay: powerPulseDelay,
    );

    return advancedSetings;
  }

  Future<SleepSettings> _getSleepSettings(BluetoothService service) async {
    final sleepTempChar = service.characteristics.firstWhere((element) =>
        element.uuid.toString() == IronCharacteristicUUIDSs.sleepTemperature);

    final rawSleepTemp = await sleepTempChar.read();
    final sleepTemp = rawSleepTemp[0] | (rawSleepTemp[1] << 8);

    final sleepDelayChar = service.characteristics.firstWhere((element) =>
        element.uuid.toString() == IronCharacteristicUUIDSs.sleepTimeout);

    final rawSleepDelay = await sleepDelayChar.read();
    final int sleepDelay = rawSleepDelay[0] | (rawSleepDelay[1] << 8);

    final shutdownChar = service.characteristics.firstWhere((element) =>
        element.uuid.toString() == IronCharacteristicUUIDSs.shutdownTimeout);

    final rawShutdown = await shutdownChar.read();
    final Duration shutdown =
        Duration(minutes: rawShutdown[0] | (rawShutdown[1] << 8));

    final motionSensChar = service.characteristics.firstWhere((element) =>
        element.uuid.toString() == IronCharacteristicUUIDSs.motionSensitivity);

    final rawMotionSens = await motionSensChar.read();
    final motionSens = rawMotionSens[0];

    final sleepSettings = SleepSettings(
      sleepTemp: sleepTemp,
      sleepTimeout: sleepDelay,
      shutdownTimeout: shutdown,
      motionSenitivity: motionSens,
    );

    return sleepSettings;
  }

  // Set data - write to f6d7ffff-5a10-4eba-aa55-33e27f9bc533 value 1 to save settings
  Future<void> setTemp(int temp) async {
    state = state.copyWith(
      settings: state.settings?.copyWith(
          solderingSettings:
              state.settings?.solderingSettings.copyWith(solderingTemp: temp)),
    );

    ref.read(ironProvider.notifier).setTemp(temp);

    // Get service
    final service = ref.read(ironProvider.notifier).services!.firstWhere(
        (element) => element.uuid.toString() == IronServices.settings);

    // Get characteristic
    final tempCharacteristic = service.characteristics.firstWhere((element) =>
        element.uuid.toString() == IronCharacteristicUUIDSs.setTemperature);

    // Write data
    ByteData view = ByteData(2);
    view.setUint16(0, temp, Endian.little);

    await sendBlePacket(tempCharacteristic, view.buffer.asUint8List(), 0, 3);
  }

  Future<void> setBoost(int temp) async {
    state = state.copyWith(
      settings: state.settings?.copyWith(
          solderingSettings:
              state.settings?.solderingSettings.copyWith(boostTemp: temp)),
    );

    // Get service
    final service = ref.read(ironProvider.notifier).services!.firstWhere(
        (element) => element.uuid.toString() == IronServices.settings);

    // Get characteristic
    final tempCharacteristic = service.characteristics.firstWhere((element) =>
        element.uuid.toString() == IronCharacteristicUUIDSs.boostTemperature);

    // Write data
    ByteData view = ByteData(2);
    view.setUint16(0, temp, Endian.little);

    await sendBlePacket(tempCharacteristic, view.buffer.asUint8List(), 0, 3);
  }

  Future<void> setStartupBehavior(StartupBehavior behavior) async {
    state = state.copyWith(
      settings: state.settings?.copyWith(
          solderingSettings: state.settings?.solderingSettings
              .copyWith(startUpBehavior: behavior)),
    );

    // Get service
    final service = ref.read(ironProvider.notifier).services!.firstWhere(
        (element) => element.uuid.toString() == IronServices.settings);

    // Get characteristic
    final tempCharacteristic = service.characteristics.firstWhere((element) =>
        element.uuid.toString() == IronCharacteristicUUIDSs.autoStart);

    // Write data
    ByteData view = ByteData(2);
    view.setUint16(0, behavior.index, Endian.little);

    await sendBlePacket(tempCharacteristic, view.buffer.asUint8List(), 0, 3);
  }

  Future<void> setTempChangeShort(int value) {
    state = state.copyWith(
      settings: state.settings?.copyWith(
          solderingSettings: state.settings?.solderingSettings
              .copyWith(tempChangeShortPress: value)),
    );

    // Get service
    final service = ref.read(ironProvider.notifier).services!.firstWhere(
        (element) => element.uuid.toString() == IronServices.settings);

    // Get characteristic
    final tempCharacteristic = service.characteristics.firstWhere((element) =>
        element.uuid.toString() ==
        IronCharacteristicUUIDSs.tempChangeShortStep);

    // Write data
    ByteData view = ByteData(2);
    view.setUint16(0, value, Endian.little);

    return sendBlePacket(tempCharacteristic, view.buffer.asUint8List(), 0, 3);
  }

  Future<void> setLockButtons(LockingBehavior behavior) async {
    state = state.copyWith(
      settings: state.settings?.copyWith(
          solderingSettings: state.settings?.solderingSettings
              .copyWith(allowLockingButtons: behavior)),
    );

    // Get service
    final service = ref.read(ironProvider.notifier).services!.firstWhere(
        (element) => element.uuid.toString() == IronServices.settings);

    // Get characteristic
    final tempCharacteristic = service.characteristics.firstWhere((element) =>
        element.uuid.toString() == IronCharacteristicUUIDSs.lockingMode);

    // Write data
    ByteData view = ByteData(2);
    view.setUint16(0, behavior.index, Endian.little);

    await sendBlePacket(tempCharacteristic, view.buffer.asUint8List(), 0, 3);
  }

  Future<void> setMotionSensitivity(int sensitivity) {
    state = state.copyWith(
      settings: state.settings?.copyWith(
          sleepSettings: state.settings?.sleepSettings
              .copyWith(motionSenitivity: sensitivity)),
    );

    // Get service
    final service = ref.read(ironProvider.notifier).services!.firstWhere(
        (element) => element.uuid.toString() == IronServices.settings);

    // Get characteristic
    final tempCharacteristic = service.characteristics.firstWhere((element) =>
        element.uuid.toString() == IronCharacteristicUUIDSs.motionSensitivity);

    // Write data
    ByteData view = ByteData(2);
    view.setUint16(0, sensitivity, Endian.little);

    return sendBlePacket(tempCharacteristic, view.buffer.asUint8List(), 0, 3);
  }

  Future<void> setSleepTemp(int value) {
    state = state.copyWith(
      settings: state.settings?.copyWith(
          sleepSettings:
              state.settings?.sleepSettings.copyWith(sleepTemp: value)),
    );

    // Get service
    final service = ref.read(ironProvider.notifier).services!.firstWhere(
        (element) => element.uuid.toString() == IronServices.settings);

    // Get characteristic
    final tempCharacteristic = service.characteristics.firstWhere((element) =>
        element.uuid.toString() == IronCharacteristicUUIDSs.sleepTemperature);

    // Write data
    ByteData view = ByteData(2);
    view.setUint16(0, value, Endian.little);

    return sendBlePacket(tempCharacteristic, view.buffer.asUint8List(), 0, 3);
  }

  Future<void> setSleepTimeout(int timout) {
    state = state.copyWith(
      settings: state.settings?.copyWith(
          sleepSettings:
              state.settings?.sleepSettings.copyWith(sleepTimeout: timout)),
    );

    // Get service
    final service = ref.read(ironProvider.notifier).services!.firstWhere(
        (element) => element.uuid.toString() == IronServices.settings);

    // Get characteristic
    final tempCharacteristic = service.characteristics.firstWhere((element) =>
        element.uuid.toString() == IronCharacteristicUUIDSs.sleepTimeout);

    // Write data
    ByteData view = ByteData(2);
    view.setUint16(0, timout, Endian.little);

    return sendBlePacket(tempCharacteristic, view.buffer.asUint8List(), 0, 3);
  }

  Future<void> setShutdownTimeout(Duration timeout) {
    state = state.copyWith(
      settings: state.settings?.copyWith(
          sleepSettings:
              state.settings?.sleepSettings.copyWith(shutdownTimeout: timeout)),
    );

    // Get service
    final service = ref.read(ironProvider.notifier).services!.firstWhere(
        (element) => element.uuid.toString() == IronServices.settings);

    // Get characteristic
    final tempCharacteristic = service.characteristics.firstWhere((element) =>
        element.uuid.toString() == IronCharacteristicUUIDSs.shutdownTimeout);

    // Write data
    ByteData view = ByteData(2);
    view.setUint16(0, timeout.inMinutes, Endian.little);

    return sendBlePacket(tempCharacteristic, view.buffer.asUint8List(), 0, 3);
  }

  Future<void> setPowerSource(PowerSource source) {
    state = state.copyWith(
      settings: state.settings?.copyWith(
          powerSettings:
              state.settings?.powerSettings.copyWith(dCInCutoff: source)),
    );

    // Get service
    final service = ref.read(ironProvider.notifier).services!.firstWhere(
        (element) => element.uuid.toString() == IronServices.settings);

    // Get characteristic
    final tempCharacteristic = service.characteristics.firstWhere((element) =>
        element.uuid.toString() == IronCharacteristicUUIDSs.dCInCutoff);

    // Write data
    ByteData view = ByteData(2);
    view.setUint16(0, source.index, Endian.little);

    return sendBlePacket(tempCharacteristic, view.buffer.asUint8List(), 0, 3);
  }

  Future<void> setCutoffVol(double val) {
    state = state.copyWith(
      settings: state.settings?.copyWith(
          powerSettings:
              state.settings?.powerSettings.copyWith(minVolCell: val)),
    );

    // Get service
    final service = ref.read(ironProvider.notifier).services!.firstWhere(
        (element) => element.uuid.toString() == IronServices.settings);

    // Get characteristic
    final tempCharacteristic = service.characteristics.firstWhere((element) =>
        element.uuid.toString() == IronCharacteristicUUIDSs.minVolCell);

    // Write data
    ByteData view = ByteData(2);
    view.setUint16(0, (val * 10).toInt(), Endian.little);

    return sendBlePacket(tempCharacteristic, view.buffer.asUint8List(), 0, 3);
  }

  Future<void> setQcMaxVoltage(double val) {
    state = state.copyWith(
      settings: state.settings?.copyWith(
          powerSettings:
              state.settings?.powerSettings.copyWith(qCMaxVoltage: val)),
    );

    // Get service
    final service = ref.read(ironProvider.notifier).services!.firstWhere(
        (element) => element.uuid.toString() == IronServices.settings);

    // Get characteristic
    final tempCharacteristic = service.characteristics.firstWhere((element) =>
        element.uuid.toString() == IronCharacteristicUUIDSs.qCMaxVoltage);

    // Write data
    ByteData view = ByteData(2);
    view.setUint16(0, (val * 10).toInt(), Endian.little);

    return sendBlePacket(tempCharacteristic, view.buffer.asUint8List(), 0, 3);
  }

  Future<void> setPdTimeout(Duration timeout) {
    state = state.copyWith(
      settings: state.settings?.copyWith(
          powerSettings:
              state.settings?.powerSettings.copyWith(pdTimeout: timeout)),
    );

    // Get service
    final service = ref.read(ironProvider.notifier).services!.firstWhere(
        (element) => element.uuid.toString() == IronServices.settings);

    // Get characteristic
    final tempCharacteristic = service.characteristics.firstWhere((element) =>
        element.uuid.toString() == IronCharacteristicUUIDSs.pdNegTimeout);

    // Write data
    ByteData view = ByteData(2);
    view.setUint16(0, timeout.inMilliseconds ~/ 100, Endian.little);

    return sendBlePacket(tempCharacteristic, view.buffer.asUint8List(), 0, 3);
  }

  Future<void> setTempUnit(TempUnit unit) {
    state = state.copyWith(
      settings: state.settings?.copyWith(
          uiSettings: state.settings?.uiSettings.copyWith(tempUnit: unit)),
    );

    // Get service
    final service = ref.read(ironProvider.notifier).services!.firstWhere(
        (element) => element.uuid.toString() == IronServices.settings);

    // Get characteristic
    final tempCharacteristic = service.characteristics.firstWhere((element) =>
        element.uuid.toString() == IronCharacteristicUUIDSs.temperatureUnit);

    // Write data
    ByteData view = ByteData(2);
    view.setUint16(0, unit.index, Endian.little);

    return sendBlePacket(tempCharacteristic, view.buffer.asUint8List(), 0, 3);
  }

  Future<void> setDisplayOrientation(DisplayOrientation orientation) {
    state = state.copyWith(
      settings: state.settings?.copyWith(
          uiSettings: state.settings?.uiSettings
              .copyWith(displayOrientation: orientation)),
    );

    // Get service
    final service = ref.read(ironProvider.notifier).services!.firstWhere(
        (element) => element.uuid.toString() == IronServices.settings);

    // Get characteristic
    final tempCharacteristic = service.characteristics.firstWhere((element) =>
        element.uuid.toString() == IronCharacteristicUUIDSs.displayRotation);

    // Write data
    ByteData view = ByteData(2);
    view.setUint16(0, orientation.index, Endian.little);

    return sendBlePacket(tempCharacteristic, view.buffer.asUint8List(), 0, 3);
  }

  Future<void> sendBlePacket(BluetoothCharacteristic char, Uint8List data,
      int tries, int maxTries) async {
    try {
      await char.write(data, withoutResponse: true);
    } catch (e) {
      if (tries < maxTries) {
        await sendBlePacket(char, data, tries + 1, maxTries);
      } else {
        rethrow;
      }
    }
  }

  Future<void> saveToFlash() async {
    // Get service
    final service = ref.read(ironProvider.notifier).services!.firstWhere(
        (element) => element.uuid.toString() == IronServices.settings);

    // Get characteristic
    final tempCharacteristic = service.characteristics.firstWhere((element) =>
        element.uuid.toString() == IronCharacteristicUUIDSs.saveToFlash);

    // Write data
    ByteData view = ByteData(2);
    view.setUint16(0, 1, Endian.little);

    await sendBlePacket(tempCharacteristic, view.buffer.asUint8List(), 0, 3);
  }
}

final ironSettingsProvider =
    StateNotifierProvider<IronSettingsProvider, IronSettingsState>((ref) {
  return IronSettingsProvider(ref);
});
