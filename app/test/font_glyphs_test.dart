import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';

import 'package:app/core/theme/app_theme.dart';

bool hasGlyph(ByteData data, int codePoint) {
  int u16(int offset) => data.getUint16(offset, Endian.big);
  int u32(int offset) => data.getUint32(offset, Endian.big);

  final numTables = u16(4);
  var cmapOffset = -1;
  var cmapLength = 0;
  for (var index = 0; index < numTables; index++) {
    final recordOffset = 12 + index * 16;
    if (data.getUint32(recordOffset, Endian.big) == 0x636D6170) {
      cmapOffset = u32(recordOffset + 8);
      cmapLength = u32(recordOffset + 12);
      break;
    }
  }
  if (cmapOffset < 0 || cmapOffset + cmapLength > data.lengthInBytes) {
    return false;
  }

  final encodingCount = u16(cmapOffset + 2);
  for (var index = 0; index < encodingCount; index++) {
    final recordOffset = cmapOffset + 4 + index * 8;
    final platform = u16(recordOffset);
    final encoding = u16(recordOffset + 2);
    if (platform != 0 && platform != 3) continue;
    if (platform == 3 && encoding != 1 && encoding != 10) continue;

    final subtableOffset = cmapOffset + u32(recordOffset + 4);
    final format = u16(subtableOffset);
    if (format == 4 && codePoint <= 0xFFFF) {
      final segmentCount = u16(subtableOffset + 6) ~/ 2;
      final endCodesOffset = subtableOffset + 14;
      final startCodesOffset = endCodesOffset + segmentCount * 2 + 2;
      for (var segment = 0; segment < segmentCount; segment++) {
        final end = u16(endCodesOffset + segment * 2);
        final start = u16(startCodesOffset + segment * 2);
        if (start <= codePoint && codePoint <= end) return true;
      }
    } else if (format == 12) {
      final groupCount = u32(subtableOffset + 12);
      for (var group = 0; group < groupCount; group++) {
        final groupOffset = subtableOffset + 16 + group * 12;
        final start = u32(groupOffset);
        final end = u32(groupOffset + 4);
        if (start <= codePoint && codePoint <= end) return true;
      }
    }
  }
  return false;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('money styles use the bundled glyph fallback', () async {
    final font = await rootBundle.load('assets/fonts/NotoSans-Regular.ttf');

    expect(hasGlyph(font, 0x20B8), isTrue);
    expect(hasGlyph(font, 0x2212), isTrue);
    expect(AppTheme.moneyFallback, contains('Noto Sans'));
  });
}
