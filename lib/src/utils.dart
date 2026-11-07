
import 'dart:math';

/// Generate a list of hints of length [n] using alphabet defined by [characters].
///
/// The hints aim to be as short as possible while not having any duplicate activation
/// when typing them from beginning to end.
List<String> generateHintList(int n, String characters) {
    final base = characters.length;
    if (base == 0) {
      throw ArgumentError('characters cannot be an empty string');
    }

    // base width of hints
    final width = n <= base ? 1 : (log(n - 1) / log(base)).floor() + 1;
    // n hints to be generated with `width - 1` length.
    final nShort = width == 1 ? 0 : (pow(base, width).toInt() - n) ~/ (base - 1);

    return List<String>.generate(n, (i) {
      final length = i < nShort ? width - 1 : width;
      final value = i < nShort ? i : nShort * base + i - nShort;
      return List<String>.generate(length, (j) =>
        characters[(value ~/ pow(base, length - j - 1).toInt()) % base],
      ).join();
    });
  }

  /// Get number of chars from beginning of [hint] that are equal to [typedText].
  int getNMatchedChars(String hint, String typedText) {
    var i = 0;
    for (; i < hint.length; i += 1) {
      if (i >= typedText.length || hint[i] != typedText[i]) {
        break;
      }
    }
    return i;
  }