import 'dart:math' as math;
import 'package:flutter/material.dart';

/// {@template image_cropper}
/// A widget that aligns an image within a given container,
/// ensuring the focus point stays centered while maintaining the aspect ratio.
/// {@endtemplate}
class ImageFocalAligner extends StatelessWidget {
  /// {@macro image_cropper}
  const ImageFocalAligner({
    required this.rawPoint,
    required this.imageBuilder,
    required this.resourceSize,
    this.debug = false,
    super.key, // ignore: unused_element
  });

  final Widget Function({TransformAlignment? alignment, BoxFit? fit})
      imageBuilder;
  final double? rawPoint;
  final Size? resourceSize;
  final bool debug;

  @override
  Widget build(BuildContext context) {
    final double? rawPoint = this.rawPoint;
    final Size? resourceSize = this.resourceSize;
    if (rawPoint == null || resourceSize == null) {
      return imageBuilder();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // The image's original aspect ratio (4:3).
        const double resourceAspectRatio = 4 / 3;
        final double resourceHeight = resourceSize.height;
        final double resourceWidth = resourceSize.width;

        // Clamping the raw point between 0 and 1 to ensure it's within bounds.
        // This is the percentage offset from the left edge of the image.
        final double rawPointSafe = rawPoint.clamp(0, 1);

        final double maxWidth = constraints.maxWidth;
        final double maxHeight = constraints.maxHeight;

        // The displayed image width is determined based on the height
        // and the aspect ratio.
        final double imageWidth = maxHeight * (1 / resourceAspectRatio);

        // The position of the focal point within the image.
        final double rawPointIndent = imageWidth * rawPointSafe;

        // The width of the focus rectangle (16:9 aspect ratio).
        final double focusRectangleWidth = maxHeight * 9 / 16;

        // The center point of the focus rectangle.
        final double focusRectangleCenterPoint = focusRectangleWidth / 2;

        // The distance from the left of the image to the left of the focus rectangle.
        final double focusRectangleLeftIndent =
            rawPointIndent - focusRectangleCenterPoint;

        // The distance from the right of the focus rectangle to the right edge of the container.
        final double focusRectangleRightIndent =
            maxWidth - (focusRectangleLeftIndent + focusRectangleWidth);

        double shift = 0;

        /// If the focus rectangle starts before the left edge of the image,
        /// there's no need for a shift since the image is already aligned to the left.
        if (focusRectangleLeftIndent < 0) {
          shift = 0;
        }

        /// If the focus rectangle extends past the right side of the screen,
        /// shift the image to keep the focal point visible.
        if (focusRectangleLeftIndent > 0 &&
            focusRectangleLeftIndent > focusRectangleRightIndent) {
          // Remaining width of the image beyond the visible area.
          final double imageWidthRemains = imageWidth - maxWidth;

          // Attempt to center the focus rectangle by shifting it.
          final double centeredRectangleShift = math.min(
            (focusRectangleLeftIndent - focusRectangleRightIndent) / 2,
            focusRectangleLeftIndent,
          );

          // Ensure the shift does not exceed the remaining width of the image.
          final double safeRectangleShift = math.min(
            imageWidthRemains,
            centeredRectangleShift,
          );

          shift = math.max(safeRectangleShift, 0);
        }

        /// If the focus rectangle is wider than the available width,
        /// center it within the container.
        if (focusRectangleWidth > maxWidth) {
          shift += (focusRectangleWidth - maxWidth) / 2;
        }

        // Calculate the scaling factors for BoxFit.cover.
        final double scaleX = maxWidth / resourceWidth;
        final double scaleY = maxHeight / resourceHeight;

        // Create a custom alignment based on calculated shift and scale.
        final TransformAlignment alignment = TransformAlignment(
          -1, // Aligns the image to the left.
          0, // Keeps vertical alignment centered.
          shift: -shift,
          scaleX: scaleX,
          scaleY: scaleY,
        );

        return Stack(
          fit: StackFit.expand,
          alignment: Alignment.center,
          children: [
            imageBuilder(alignment: alignment, fit: BoxFit.cover),

            // Draws the focus rectangle and points for debugging.
            if (debug) ...[
              Positioned(
                left: focusRectangleLeftIndent - shift,
                child: SizedBox(
                  height: constraints.maxHeight,
                  width: focusRectangleWidth,
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.blue,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Marks the raw point position.
              Positioned(
                left: rawPointIndent - 5 - shift,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red,
                  ),
                ),
              ),
              // Marks the focus rectangle's left edge.
              Positioned(
                left: focusRectangleLeftIndent - 5 - shift,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.purple,
                  ),
                ),
              )
            ]
          ],
        );
      },
    );
  }
}

/// A custom alignment class that extends [Alignment] and overrides the [inscribe] method,
/// which is used to determine the position of a image in [paintImage] method within a given rectangle.
///
/// [TransformAlignment] allows for flexible positioning of widgets
/// by incorporating scaling factors along the X and Y axes, as well
/// as an additional shift parameter for fine-tuned control.
///
/// The [inscribe] method calculates the destination rectangle for
/// the aligned object, taking into account the scaling and shifting
/// parameters.
class TransformAlignment extends Alignment {
  const TransformAlignment(
    super.x,
    super.y, {
    required this.shift,
    required this.scaleY,
    required this.scaleX,
  });

  /// The shift amount applied to the alignment.
  final double shift;

  /// The horizontal scaling factor.
  final double scaleX;

  /// The vertical scaling factor.
  final double scaleY;

  @override
  Rect inscribe(Size size, Rect rect) {
    final double scale = math.max(scaleX, scaleY);
    final double shiftInIntrinsic = shift / scale;

    final double halfWidthDelta = (rect.width - size.width) / 2.0;
    final double halfHeightDelta = (rect.height - size.height) / 2.0;

    final Rect destinationRect = Rect.fromLTWH(
      rect.left + halfWidthDelta + x * halfWidthDelta - shiftInIntrinsic,
      rect.top + halfHeightDelta + y * halfHeightDelta,
      size.width,
      size.height,
    );

    return destinationRect;
  }

  @override
  int get hashCode => Object.hashAll([
        super.hashCode,
        scaleX.hashCode,
        scaleY.hashCode,
        shift.hashCode,
      ]);

  @override
  bool operator ==(Object other) {
    return other is TransformAlignment &&
        other.x == x &&
        other.y == y &&
        other.scaleX == scaleX &&
        other.scaleY == scaleY &&
        shift == other.shift;
  }
}
