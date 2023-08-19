import 'dart:convert';

class IronSettings {
  PowerSettings powerSettings;
  SolderingSettings solderingSettings;
  UISettings uiSettings;
  AdvancedSettings advancedSettings;
  UnusedSettings? unusedSettings;
  SleepSettings sleepSettings;

  IronSettings({
    required this.powerSettings,
    required this.solderingSettings,
    required this.uiSettings,
    required this.advancedSettings,
    this.unusedSettings,
    required this.sleepSettings,
  });

  IronSettings copyWith({
    PowerSettings? powerSettings,
    SolderingSettings? solderingSettings,
    UISettings? uiSettings,
    AdvancedSettings? advancedSettings,
    UnusedSettings? unusedSettings,
    SleepSettings? sleepSettings,
  }) {
    return IronSettings(
      powerSettings: powerSettings ?? this.powerSettings,
      solderingSettings: solderingSettings ?? this.solderingSettings,
      uiSettings: uiSettings ?? this.uiSettings,
      advancedSettings: advancedSettings ?? this.advancedSettings,
      unusedSettings: unusedSettings ?? this.unusedSettings,
      sleepSettings: sleepSettings ?? this.sleepSettings,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'powerSettings': powerSettings.toMap(),
      'solderingSettings': solderingSettings.toMap(),
      'uiSettings': uiSettings.toMap(),
      'advancedSettings': advancedSettings.toMap(),
      'unusedSettings': unusedSettings?.toMap(),
      'sleepSettings': sleepSettings.toMap(),
    };
  }

  factory IronSettings.fromMap(Map<String, dynamic> map) {
    return IronSettings(
      powerSettings: PowerSettings.fromMap(map['powerSettings']),
      solderingSettings: SolderingSettings.fromMap(map['solderingSettings']),
      uiSettings: UISettings.fromMap(map['uiSettings']),
      advancedSettings: AdvancedSettings.fromMap(map['advancedSettings']),
      unusedSettings: map['unusedSettings'] != null
          ? UnusedSettings.fromMap(map['unusedSettings'])
          : null,
      sleepSettings: SleepSettings.fromMap(map['sleepSettings']),
    );
  }

  String toJson() => json.encode(toMap());

  factory IronSettings.fromJson(String source) =>
      IronSettings.fromMap(json.decode(source));

  @override
  String toString() {
    return 'IronSettings(powerSettings: $powerSettings, solderingSettings: $solderingSettings, uiSettings: $uiSettings, advancedSettings: $advancedSettings, unusedSettings: $unusedSettings, sleepSettings: $sleepSettings)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is IronSettings &&
        other.powerSettings == powerSettings &&
        other.solderingSettings == solderingSettings &&
        other.uiSettings == uiSettings &&
        other.advancedSettings == advancedSettings &&
        other.unusedSettings == unusedSettings &&
        other.sleepSettings == sleepSettings;
  }

  @override
  int get hashCode {
    return powerSettings.hashCode ^
        solderingSettings.hashCode ^
        uiSettings.hashCode ^
        advancedSettings.hashCode ^
        unusedSettings.hashCode ^
        sleepSettings.hashCode;
  }
}

class PowerSettings {
  PowerSource dCInCutoff;
  double minVolCell;
  double qCMaxVoltage;
  Duration pdTimeout;

  PowerSettings({
    required this.dCInCutoff,
    required this.minVolCell,
    required this.qCMaxVoltage,
    required this.pdTimeout,
  });

  PowerSettings copyWith({
    PowerSource? dCInCutoff,
    double? minVolCell,
    double? qCMaxVoltage,
    Duration? pdTimeout,
  }) {
    return PowerSettings(
      dCInCutoff: dCInCutoff ?? this.dCInCutoff,
      minVolCell: minVolCell ?? this.minVolCell,
      qCMaxVoltage: qCMaxVoltage ?? this.qCMaxVoltage,
      pdTimeout: pdTimeout ?? this.pdTimeout,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dCInCutoff': dCInCutoff.index,
      'minVolCell': minVolCell,
      'qCMaxVoltage': qCMaxVoltage,
      'pdTimeout': pdTimeout.inSeconds,
    };
  }

  factory PowerSettings.fromMap(Map<String, dynamic> map) {
    return PowerSettings(
      dCInCutoff: PowerSource.values[map['dCInCutoff']],
      minVolCell: map['minVolCell']?.toDouble() ?? 0.0,
      qCMaxVoltage: map['qCMaxVoltage']?.toDouble() ?? 0.0,
      pdTimeout: Duration(seconds: map['pdTimeout']),
    );
  }

  String toJson() => json.encode(toMap());

  factory PowerSettings.fromJson(String source) =>
      PowerSettings.fromMap(json.decode(source));

  @override
  String toString() {
    return 'PowerSettings(dCInCutoff: $dCInCutoff, minVolCell: $minVolCell, qCMaxVoltage: $qCMaxVoltage, pdTimeout: $pdTimeout)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PowerSettings &&
        other.dCInCutoff == dCInCutoff &&
        other.minVolCell == minVolCell &&
        other.qCMaxVoltage == qCMaxVoltage &&
        other.pdTimeout == pdTimeout;
  }

  @override
  int get hashCode {
    return dCInCutoff.hashCode ^
        minVolCell.hashCode ^
        qCMaxVoltage.hashCode ^
        pdTimeout.hashCode;
  }
}

enum PowerSource {
  dc,
  threeCell,
  fourCell,
  fiveCell,
  sixCell,
}

class SleepMode {
  int motionSensitivity;
  int sleepTemp;
  Duration sleepTimeout;
  Duration shutdownTimeout;

  SleepMode({
    required this.motionSensitivity,
    required this.sleepTemp,
    required this.sleepTimeout,
    required this.shutdownTimeout,
  });

  SleepMode copyWith({
    int? motionSensitivity,
    int? sleepTemp,
    Duration? sleepTimeout,
    Duration? shutdownTimeout,
  }) {
    return SleepMode(
      motionSensitivity: motionSensitivity ?? this.motionSensitivity,
      sleepTemp: sleepTemp ?? this.sleepTemp,
      sleepTimeout: sleepTimeout ?? this.sleepTimeout,
      shutdownTimeout: shutdownTimeout ?? this.shutdownTimeout,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'motionSensitivity': motionSensitivity,
      'sleepTemp': sleepTemp,
      'sleepTimeout': sleepTimeout.inSeconds,
      'shutdownTimeout': shutdownTimeout.inSeconds,
    };
  }

  factory SleepMode.fromMap(Map<String, dynamic> map) {
    return SleepMode(
      motionSensitivity: map['motionSensitivity']?.toInt() ?? 0,
      sleepTemp: map['sleepTemp']?.toInt() ?? 0,
      sleepTimeout: Duration(seconds: map['sleepTimeout']),
      shutdownTimeout: Duration(seconds: map['shutdownTimeout']),
    );
  }

  String toJson() => json.encode(toMap());

  factory SleepMode.fromJson(String source) =>
      SleepMode.fromMap(json.decode(source));

  @override
  String toString() {
    return 'SleepMode(motionSensitivity: $motionSensitivity, sleepTemp: $sleepTemp, sleepTimeout: $sleepTimeout, shutdownTimeout: $shutdownTimeout)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SleepMode &&
        other.motionSensitivity == motionSensitivity &&
        other.sleepTemp == sleepTemp &&
        other.sleepTimeout == sleepTimeout &&
        other.shutdownTimeout == shutdownTimeout;
  }

  @override
  int get hashCode {
    return motionSensitivity.hashCode ^
        sleepTemp.hashCode ^
        sleepTimeout.hashCode ^
        shutdownTimeout.hashCode;
  }
}

class SolderingSettings {
  int solderingTemp;
  int boostTemp;
  StartupBehavior startUpBehavior;
  int tempChangeShortPress, tempChangeLongPress;
  LockingBehavior allowLockingButtons;

  SolderingSettings({
    required this.solderingTemp,
    required this.boostTemp,
    required this.startUpBehavior,
    required this.tempChangeLongPress,
    required this.tempChangeShortPress,
    required this.allowLockingButtons,
  });

  SolderingSettings copyWith({
    int? solderingTemp,
    int? boostTemp,
    StartupBehavior? startUpBehavior,
    int? tempChangeShortPress,
    int? tempChangeLongPress,
    LockingBehavior? allowLockingButtons,
  }) {
    return SolderingSettings(
      solderingTemp: solderingTemp ?? this.solderingTemp,
      boostTemp: boostTemp ?? this.boostTemp,
      startUpBehavior: startUpBehavior ?? this.startUpBehavior,
      tempChangeLongPress: tempChangeLongPress ?? this.tempChangeLongPress,
      tempChangeShortPress: tempChangeShortPress ?? this.tempChangeShortPress,
      allowLockingButtons: allowLockingButtons ?? this.allowLockingButtons,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'solderingTemp': solderingTemp,
      'boostTemp': boostTemp,
      'startUpBehavior': startUpBehavior.index,
      'tempChangeLongPress': tempChangeLongPress,
      'tempChangeShortPress': tempChangeShortPress,
      'allowLockingButtons': allowLockingButtons.index,
    };
  }

  factory SolderingSettings.fromMap(Map<String, dynamic> map) {
    return SolderingSettings(
      solderingTemp: map['solderingTemp']?.toInt() ?? 0,
      boostTemp: map['boostTemp']?.toInt() ?? 0,
      startUpBehavior: StartupBehavior.values[map['startUpBehavior']],
      tempChangeLongPress: map['tempChangeLongPress']?.toInt() ?? 0,
      tempChangeShortPress: map['tempChangeShortPress']?.toInt() ?? 0,
      allowLockingButtons: LockingBehavior.values[map['allowLockingButtons']],
    );
  }

  String toJson() => json.encode(toMap());

  factory SolderingSettings.fromJson(String source) =>
      SolderingSettings.fromMap(json.decode(source));

  @override
  String toString() {
    return 'SolderingSettings(solderingTemp: $solderingTemp, boostTemp: $boostTemp, startUpBehavior: $startUpBehavior, tempChangeLongPress: $tempChangeLongPress, tempChangeShortPess: $tempChangeShortPress allowLockingButtons: $allowLockingButtons)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SolderingSettings &&
        other.solderingTemp == solderingTemp &&
        other.boostTemp == boostTemp &&
        other.startUpBehavior == startUpBehavior &&
        other.tempChangeLongPress == tempChangeLongPress &&
        other.tempChangeShortPress == tempChangeShortPress &&
        other.allowLockingButtons == allowLockingButtons;
  }

  @override
  int get hashCode {
    return solderingTemp.hashCode ^
        boostTemp.hashCode ^
        startUpBehavior.hashCode ^
        tempChangeLongPress.hashCode ^
        tempChangeShortPress.hashCode ^
        allowLockingButtons.hashCode;
  }
}

enum StartupBehavior {
  off,
  heatToSetpoint,
  standbyUntilMoved,
  standbyWithoutHeating,
}

enum LockingBehavior {
  off,
  boostOnly,
  full,
}

class UISettings {
  TempUnit tempUnit;
  DisplayOrientation displayOrientation;
  bool cooldownFlashing;
  ScrollingSpeed scrollingSpeed;
  bool swapPlusMinusKeys;
  AnimationSpeed animationSpeed;
  int screenBrightness;
  bool invertScreen;
  Duration bootLogoDuration;
  bool detailedIdleScreen;
  bool detailedSolderingScreen;

  UISettings({
    required this.tempUnit,
    required this.displayOrientation,
    required this.cooldownFlashing,
    required this.scrollingSpeed,
    required this.swapPlusMinusKeys,
    required this.animationSpeed,
    required this.screenBrightness,
    required this.invertScreen,
    required this.bootLogoDuration,
    required this.detailedIdleScreen,
    required this.detailedSolderingScreen,
  });

  UISettings copyWith({
    TempUnit? tempUnit,
    DisplayOrientation? displayOrientation,
    bool? cooldownFlashing,
    ScrollingSpeed? scrollingSpeed,
    bool? swapPlusMinusKeys,
    AnimationSpeed? animationSpeed,
    int? screenBrightness,
    bool? invertScreen,
    Duration? bootLogoDuration,
    bool? detailedIdleScreen,
    bool? detailedSolderingScreen,
  }) {
    return UISettings(
      tempUnit: tempUnit ?? this.tempUnit,
      displayOrientation: displayOrientation ?? this.displayOrientation,
      cooldownFlashing: cooldownFlashing ?? this.cooldownFlashing,
      scrollingSpeed: scrollingSpeed ?? this.scrollingSpeed,
      swapPlusMinusKeys: swapPlusMinusKeys ?? this.swapPlusMinusKeys,
      animationSpeed: animationSpeed ?? this.animationSpeed,
      screenBrightness: screenBrightness ?? this.screenBrightness,
      invertScreen: invertScreen ?? this.invertScreen,
      bootLogoDuration: bootLogoDuration ?? this.bootLogoDuration,
      detailedIdleScreen: detailedIdleScreen ?? this.detailedIdleScreen,
      detailedSolderingScreen:
          detailedSolderingScreen ?? this.detailedSolderingScreen,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tempUnit': tempUnit.index,
      'displayOrientation': displayOrientation.index,
      'cooldownFlashing': cooldownFlashing,
      'scrollingSpeed': scrollingSpeed.index,
      'swapPlusMinusKeys': swapPlusMinusKeys,
      'animationSpeed': animationSpeed.index,
      'screenBrightness': screenBrightness,
      'invertScreen': invertScreen,
      'bootLogoDuration': bootLogoDuration.inSeconds,
      'detailedIdleScreen': detailedIdleScreen,
      'detailedSolderingScreen': detailedSolderingScreen,
    };
  }

  factory UISettings.fromMap(Map<String, dynamic> map) {
    return UISettings(
      tempUnit: TempUnit.values[map['tempUnit']],
      displayOrientation: DisplayOrientation.values[map['displayOrientation']],
      cooldownFlashing: map['cooldownFlashing'] ?? false,
      scrollingSpeed: ScrollingSpeed.values[map['scrollingSpeed']],
      swapPlusMinusKeys: map['swapPlusMinusKeys'] ?? false,
      animationSpeed: AnimationSpeed.values[map['animationSpeed']],
      screenBrightness: map['screenBrightness']?.toInt() ?? 0,
      invertScreen: map['invertScreen'] ?? false,
      bootLogoDuration: Duration(seconds: map['bootLogoDuration']),
      detailedIdleScreen: map['detailedIdleScreen'] ?? false,
      detailedSolderingScreen: map['detailedSolderingScreen'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory UISettings.fromJson(String source) =>
      UISettings.fromMap(json.decode(source));

  @override
  String toString() {
    return 'UISettings(tempUnit: $tempUnit, displayOrientation: $displayOrientation, cooldownFlashing: $cooldownFlashing, scrollingSpeed: $scrollingSpeed, swapPlusMinusKeys: $swapPlusMinusKeys, animationSpeed: $animationSpeed, screenBrightness: $screenBrightness, invertScreen: $invertScreen, bootLogoDuration: $bootLogoDuration, detailedIdleScreen: $detailedIdleScreen, detailedSolderingScreen: $detailedSolderingScreen)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UISettings &&
        other.tempUnit == tempUnit &&
        other.displayOrientation == displayOrientation &&
        other.cooldownFlashing == cooldownFlashing &&
        other.scrollingSpeed == scrollingSpeed &&
        other.swapPlusMinusKeys == swapPlusMinusKeys &&
        other.animationSpeed == animationSpeed &&
        other.screenBrightness == screenBrightness &&
        other.invertScreen == invertScreen &&
        other.bootLogoDuration == bootLogoDuration &&
        other.detailedIdleScreen == detailedIdleScreen &&
        other.detailedSolderingScreen == detailedSolderingScreen;
  }

  @override
  int get hashCode {
    return tempUnit.hashCode ^
        displayOrientation.hashCode ^
        cooldownFlashing.hashCode ^
        scrollingSpeed.hashCode ^
        swapPlusMinusKeys.hashCode ^
        animationSpeed.hashCode ^
        screenBrightness.hashCode ^
        invertScreen.hashCode ^
        bootLogoDuration.hashCode ^
        detailedIdleScreen.hashCode ^
        detailedSolderingScreen.hashCode;
  }
}

enum TempUnit {
  celsius,
  fahrenheit,
}

enum DisplayOrientation {
  right,
  left,
  auto,
}

enum ScrollingSpeed {
  slow,
  fast,
}

enum AnimationSpeed {
  off,
  slow,
  medium,
  fast,
}

class AdvancedSettings {
  int powerLimit;
  bool calibrateCJCNextBoot;
  double powerPulse;
  Duration powerPulseDelay, powerPulseDuration;

  AdvancedSettings({
    required this.powerLimit,
    required this.calibrateCJCNextBoot,
    required this.powerPulse,
    required this.powerPulseDuration,
    required this.powerPulseDelay,
  });

  AdvancedSettings copyWith({
    int? powerLimit,
    bool? calibrateCJCNextBoot,
    double? powerPulse,
    Duration? powerPulseDelay,
    Duration? powerPulseDuration,
  }) {
    return AdvancedSettings(
      powerLimit: powerLimit ?? this.powerLimit,
      calibrateCJCNextBoot: calibrateCJCNextBoot ?? this.calibrateCJCNextBoot,
      powerPulse: powerPulse ?? this.powerPulse,
      powerPulseDuration: powerPulseDuration ?? this.powerPulseDuration,
      powerPulseDelay: powerPulseDelay ?? this.powerPulseDelay,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'powerLimit': powerLimit,
      'calibrateCJCNextBoot': calibrateCJCNextBoot,
      'powerPulse': powerPulse,
      'powerPulseDuration': powerPulseDuration.inSeconds,
      'powerPulseDelay': powerPulseDelay.inSeconds,
    };
  }

  factory AdvancedSettings.fromMap(Map<String, dynamic> map) {
    return AdvancedSettings(
      powerLimit: map['powerLimit']?.toInt() ?? 0,
      calibrateCJCNextBoot: map['calibrateCJCNextBoot'] ?? false,
      powerPulse: map['powerPulse']?.toInt() ?? 0,
      powerPulseDuration: Duration(seconds: map['powerPulseDuration']),
      powerPulseDelay: Duration(seconds: map['powerPulseDelay']),
    );
  }

  String toJson() => json.encode(toMap());

  factory AdvancedSettings.fromJson(String source) =>
      AdvancedSettings.fromMap(json.decode(source));

  @override
  String toString() {
    return 'AdvancedSettings(powerLimit: $powerLimit, calibrateCJCNextBoot: $calibrateCJCNextBoot, powerPulse: $powerPulse, powerPulseDuration: $powerPulseDuration, powerPulseDelay: $powerPulseDelay)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AdvancedSettings &&
        other.powerLimit == powerLimit &&
        other.calibrateCJCNextBoot == calibrateCJCNextBoot &&
        other.powerPulse == powerPulse &&
        other.powerPulseDuration == powerPulseDuration &&
        other.powerPulseDelay == powerPulseDelay;
  }

  @override
  int get hashCode {
    return powerLimit.hashCode ^
        calibrateCJCNextBoot.hashCode ^
        powerPulse.hashCode ^
        powerPulseDuration.hashCode ^
        powerPulseDelay.hashCode;
  }
}

class UnusedSettings {
  int accelMissingWarningCount;
  int animLoop;
  int calibrationOffset;
  int hallEffectSensitivity;
  int pDMissingWarningCount;
  int uiLanguage;

  UnusedSettings({
    required this.accelMissingWarningCount,
    required this.animLoop,
    required this.calibrationOffset,
    required this.hallEffectSensitivity,
    required this.pDMissingWarningCount,
    required this.uiLanguage,
  });

  UnusedSettings copyWith({
    int? accelMissingWarningCount,
    int? animLoop,
    int? calibrationOffset,
    int? hallEffectSensitivity,
    int? pDMissingWarningCount,
    int? uiLanguage,
  }) {
    return UnusedSettings(
      accelMissingWarningCount:
          accelMissingWarningCount ?? this.accelMissingWarningCount,
      animLoop: animLoop ?? this.animLoop,
      calibrationOffset: calibrationOffset ?? this.calibrationOffset,
      hallEffectSensitivity:
          hallEffectSensitivity ?? this.hallEffectSensitivity,
      pDMissingWarningCount:
          pDMissingWarningCount ?? this.pDMissingWarningCount,
      uiLanguage: uiLanguage ?? this.uiLanguage,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'accelMissingWarningCount': accelMissingWarningCount,
      'animLoop': animLoop,
      'calibrationOffset': calibrationOffset,
      'hallEffectSensitivity': hallEffectSensitivity,
      'pDMissingWarningCount': pDMissingWarningCount,
      'uiLanguage': uiLanguage,
    };
  }

  factory UnusedSettings.fromMap(Map<String, dynamic> map) {
    return UnusedSettings(
      accelMissingWarningCount: map['accelMissingWarningCount']?.toInt() ?? 0,
      animLoop: map['animLoop']?.toInt() ?? 0,
      calibrationOffset: map['calibrationOffset']?.toInt() ?? 0,
      hallEffectSensitivity: map['hallEffectSensitivity']?.toInt() ?? 0,
      pDMissingWarningCount: map['pDMissingWarningCount']?.toInt() ?? 0,
      uiLanguage: map['uiLanguage']?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory UnusedSettings.fromJson(String source) =>
      UnusedSettings.fromMap(json.decode(source));

  @override
  String toString() {
    return 'UnusedSettings(accelMissingWarningCount: $accelMissingWarningCount, animLoop: $animLoop, calibrationOffset: $calibrationOffset, hallEffectSensitivity: $hallEffectSensitivity, pDMissingWarningCount: $pDMissingWarningCount, uiLanguage: $uiLanguage)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UnusedSettings &&
        other.accelMissingWarningCount == accelMissingWarningCount &&
        other.animLoop == animLoop &&
        other.calibrationOffset == calibrationOffset &&
        other.hallEffectSensitivity == hallEffectSensitivity &&
        other.pDMissingWarningCount == pDMissingWarningCount &&
        other.uiLanguage == uiLanguage;
  }

  @override
  int get hashCode {
    return accelMissingWarningCount.hashCode ^
        animLoop.hashCode ^
        calibrationOffset.hashCode ^
        hallEffectSensitivity.hashCode ^
        pDMissingWarningCount.hashCode ^
        uiLanguage.hashCode;
  }
}

class SleepSettings {
  int motionSenitivity;
  int sleepTemp;
  int sleepTimeout;
  Duration shutdownTimeout;

  SleepSettings({
    required this.motionSenitivity,
    required this.sleepTemp,
    required this.sleepTimeout,
    required this.shutdownTimeout,
  });

  SleepSettings copyWith({
    int? motionSenitivity,
    int? sleepTemp,
    int? sleepTimeout,
    Duration? shutdownTimeout,
  }) {
    return SleepSettings(
      motionSenitivity: motionSenitivity ?? this.motionSenitivity,
      sleepTemp: sleepTemp ?? this.sleepTemp,
      sleepTimeout: sleepTimeout ?? this.sleepTimeout,
      shutdownTimeout: shutdownTimeout ?? this.shutdownTimeout,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'motionSenitivity': motionSenitivity,
      'sleepTemp': sleepTemp,
      'sleepTimeout': sleepTimeout,
      'shutdownTimeout': shutdownTimeout.inSeconds,
    };
  }

  factory SleepSettings.fromMap(Map<String, dynamic> map) {
    return SleepSettings(
      motionSenitivity: map['motionSenitivity']?.toInt() ?? 0,
      sleepTemp: map['sleepTemp']?.toInt() ?? 0,
      sleepTimeout: map['sleepTimeout'],
      shutdownTimeout: Duration(seconds: map['shutdownTimeout']),
    );
  }

  String toJson() => json.encode(toMap());

  factory SleepSettings.fromJson(String source) =>
      SleepSettings.fromMap(json.decode(source));

  @override
  String toString() {
    return 'SleepSettings(motionSenitivity: $motionSenitivity, sleepTemp: $sleepTemp, sleepTimeout: $sleepTimeout, shutdownTimeout: $shutdownTimeout)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SleepSettings &&
        other.motionSenitivity == motionSenitivity &&
        other.sleepTemp == sleepTemp &&
        other.sleepTimeout == sleepTimeout &&
        other.shutdownTimeout == shutdownTimeout;
  }

  @override
  int get hashCode {
    return motionSenitivity.hashCode ^
        sleepTemp.hashCode ^
        sleepTimeout.hashCode ^
        shutdownTimeout.hashCode;
  }
}
