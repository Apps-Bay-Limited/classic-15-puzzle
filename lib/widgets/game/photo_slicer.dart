import 'dart:math';
import 'dart:ui';

/// Computes the source rectangle for the tile whose solved position is
/// [targetPoint], cut out of a decoded photo of size [imageWidth] x
/// [imageHeight], for a board of [boardSize] x [boardSize] tiles.
///
/// Uses a centered square crop of the image, so tiles stay square
/// regardless of the original photo's aspect ratio. Pure geometry — no
/// image decoding happens here, so it doesn't need a decoded [Image] to be
/// tested.
Rect computePhotoTileSrcRect({
  required double imageWidth,
  required double imageHeight,
  required int boardSize,
  required Point<int> targetPoint,
}) {
  final side = min(imageWidth, imageHeight);
  final left = (imageWidth - side) / 2;
  final top = (imageHeight - side) / 2;
  final cell = side / boardSize;
  return Rect.fromLTWH(
    left + targetPoint.x * cell,
    top + targetPoint.y * cell,
    cell,
    cell,
  );
}
