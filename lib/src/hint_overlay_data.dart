import 'package:flutter/widgets.dart';

class HintOverlayData({
  /// Screen location of target
  required final Rect rect,
  required final String hint,
  required final FocusNode target,
});

HintOverlayData? findMatchingOverlay(
  List<HintOverlayData> overlays,
  String typedText,
) {
  try {
    return overlays.firstWhere((o) => o.hint == typedText);
  } on StateError {
    return null;
  }
}
