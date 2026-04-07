import 'package:flutter/foundation.dart';

/// [Switch.adaptive] uses [CupertinoSwitch] on iOS and Material switches on Android.
/// Profile rows use [Transform.scale] + fixed heights: Android tolerates small
/// sizes; iOS often clips or hides Cupertino switches unless scaled up slightly.
/// On Android these helpers return [materialDesignScale] / [materialDesignHeight] unchanged.
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
