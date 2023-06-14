enum OperatingMode {
  idle,
  soldering,
  boost,
  sleeping,
  settings,
  debug,
}

// Map 0 to 5 to OperatingMode enum values
OperatingMode operatingModeFromInt(int value) {
  switch (value) {
    case 0:
      return OperatingMode.idle;
    case 1:
      return OperatingMode.soldering;
    case 2:
      return OperatingMode.boost;
    case 3:
      return OperatingMode.sleeping;
    case 4:
      return OperatingMode.settings;
    case 5:
      return OperatingMode.debug;
    default:
      return OperatingMode.idle;
  }
}
