import 'package:flutter/foundation.dart';

/// [Switch.adaptive] maps to [CupertinoSwitch] on iOS. Profile rows use
/// [Transform.scale] + fixed heights that work for Material switches on Android
/// but often clip or hide Cupertino switches on iOS.
double adaptiveProfileSwitchScale(double materialDesignScale) {
  if (defaultTargetPlatform == TargetPlatform.iOS) {
    return (materialDesignScale * 1.22).clamp(materialDesignScale, 0.92);
  }
  return materialDesignScale;
}

double adaptiveProfileSwitchHeight(double materialDesignHeight) {
  if (defaultTargetPlatform == TargetPlatform.iOS) {
    return materialDesignHeight + 8;
  }
  return materialDesignHeight;
}
