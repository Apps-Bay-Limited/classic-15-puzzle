import 'dart:math';

import 'package:classic_15_puzzle/widgets/game/photo_slicer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('computePhotoTileSrcRect', () {
    test('centers a square crop inside a wider-than-tall image', () {
      final rect = computePhotoTileSrcRect(
        imageWidth: 400,
        imageHeight: 200,
        boardSize: 4,
        targetPoint: const Point(0, 0),
      );

      // Square side is min(400, 200) = 200, centered horizontally.
      expect(rect.left, 100);
      expect(rect.top, 0);
      expect(rect.width, 50);
      expect(rect.height, 50);
    });

    test('centers a square crop inside a taller-than-wide image', () {
      final rect = computePhotoTileSrcRect(
        imageWidth: 300,
        imageHeight: 600,
        boardSize: 3,
        targetPoint: const Point(0, 0),
      );

      // Square side is min(300, 600) = 300, centered vertically.
      expect(rect.left, 0);
      expect(rect.top, 150);
      expect(rect.width, 100);
      expect(rect.height, 100);
    });

    test('offsets each tile by its target point within the square crop', () {
      const boardSize = 4;
      for (var y = 0; y < boardSize; y++) {
        for (var x = 0; x < boardSize; x++) {
          final rect = computePhotoTileSrcRect(
            imageWidth: 800,
            imageHeight: 800,
            boardSize: boardSize,
            targetPoint: Point(x, y),
          );
          expect(rect.left, x * 200);
          expect(rect.top, y * 200);
          expect(rect.width, 200);
          expect(rect.height, 200);
        }
      }
    });

    test('tiles exactly tile the full square crop with no gaps/overlap', () {
      const boardSize = 5;
      const imageSize = 500.0;
      for (var y = 0; y < boardSize; y++) {
        for (var x = 0; x < boardSize; x++) {
          final rect = computePhotoTileSrcRect(
            imageWidth: imageSize,
            imageHeight: imageSize,
            boardSize: boardSize,
            targetPoint: Point(x, y),
          );
          expect(rect.right, lessThanOrEqualTo(imageSize));
          expect(rect.bottom, lessThanOrEqualTo(imageSize));
        }
      }
    });
  });
}
