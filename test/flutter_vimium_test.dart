import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_vimium/src/utils.dart';

void main() {
  test('generateHintList - more hints than characters', () {
    final hints = generateHintList(5, 'abc');
    expect(hints, hasLength(5));
    expect(hints, equals(['a', 'b', 'ca', 'cb', 'cc']));
  });
  test('generateHintList - less hints than characters', () {
    final hints = generateHintList(2, 'abc');
    expect(hints, hasLength(2));
    expect(hints, equals(['a', 'b']));
  });
  test('getNMatchedChars', () {
    expect(getNMatchedChars('', ''), equals(0));
    expect(getNMatchedChars('a', 'b'), equals(0));
    expect(getNMatchedChars('a', 'a'), equals(1));
    expect(getNMatchedChars('a', 'ab'), equals(1));
    expect(getNMatchedChars('ab', 'a'), equals(1));
    expect(getNMatchedChars('a_', 'ab'), equals(1));
    expect(getNMatchedChars('ab', 'a_'), equals(1));
    expect(getNMatchedChars('abc', 'abc'), equals(3));
    expect(getNMatchedChars('abc_', 'abcd'), equals(3));
    expect(getNMatchedChars('abcd', 'abc_'), equals(3));
  });
}
