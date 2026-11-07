import 'package:flutter/widgets.dart';

/// A FocusNode that remembers whether the field has lost focus once, so
/// validation messages appear only after the user leaves the field.
class TouchedFocusNode extends FocusNode {
  TouchedFocusNode({required VoidCallback onTouched}) {
    addListener(() {
      if (!hasFocus && !wasTouched) {
        wasTouched = true;
        onTouched();
      }
    });
  }

  bool wasTouched = false;
}
