import 'package:ironos_companion/data/iron_data.dart';

IronData extractData(List<int> chars) {
  final temp = chars[0] + (chars[1] << 8) + (chars[2] << 16) + (chars[3] << 24);

  final setpoint =
      chars[4] + (chars[5] << 8) + (chars[6] << 16) + (chars[7] << 24);

  final inputVolts =
      (chars[8] + (chars[9] << 8) + (chars[10] << 16) + (chars[11] << 24)) / 10;

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

  return ironData;
}
