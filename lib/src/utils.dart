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
  final width = n <= base ? 1 : _logBase(n - 1, base).floor() + 1;
  if (width == 1) {
    return List<String>.generate(n, (i) => characters[i]);
  }

  final nSlots = pow(base, width - 1).toInt();

  // Minimum number of prefixes needed.
  final minPrefixes = (n - nSlots + base - 2) ~/ (base - 1);

  // Prefer at least 4 different prefixes for longer hints.
  final nPrefixes = max(minPrefixes, min(4, nSlots));

  final nShort = nSlots - nPrefixes;
  final nLong = n - nShort;

  final result = <String>[];

  // Spread longer hints across different prefixes.
  for (var i = 0; i < nLong; i++) {
    final prefix = i % nPrefixes;
    final suffix = i ~/ nPrefixes;
    result.add(_encode(characters, prefix * base + suffix, width));
  }

  // Distribute shorter hints throughout the list.
  for (var i = 0; i < nShort; i++) {
    final index = (i + 1) * (result.length + 1) ~/ (nShort + 1);
    result.insert(index, _encode(characters, nPrefixes + i, width - 1));
  }

  return result;
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

/// Encode [value] using [characters] into a string of [length].
String _encode(String characters, int value, int length) {
  final base = characters.length;
  return List<String>.generate(
    length,
    (j) => characters[(value ~/ pow(base, length - j - 1).toInt()) % base],
  ).join();
}

double _logBase(int x, int base) {
  return log(x) / log(base);
}
