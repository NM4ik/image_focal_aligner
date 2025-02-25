# Image Focal Aligner

## Overview
**ImageFocalAligner** is a Flutter widget designed to align an image within a container while ensuring that a specified focal point remains centered. The widget preserves the aspect ratio of the image and dynamically adjusts its alignment to optimize visibility within the available space.

## Features
- Maintains the aspect ratio of the image while keeping the focal point visible.
- Dynamically shifts the image to ensure the focal region stays centered.
- Supports customizable image builders for seamless integration.
- Includes a debug mode for visualizing the focus region.

## Installation
Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
```

## Usage
Wrap your image with **ImageFocalAligner** and provide the necessary parameters:

```dart
ImageFocalAligner(
  rawPoint: 0.5, // Focal point as a normalized value (0 to 1)
  resourceSize: Size(800, 600), // Original image size
  imageBuilder: ({alignment, fit}) {
    return Image.network(
      'https://example.com/image.jpg',
      fit: fit,
      alignment: alignment ?? Alignment.center,
    );
  },
)
```

### Parameters
- **`rawPoint`** *(double?)* – A value between `0` and `1` indicating the horizontal position of the focal point.
- **`resourceSize`** *(Size?)* – The original size of the image.
- **`imageBuilder`** *(Widget Function({TransformAlignment? alignment, BoxFit? fit}))* – A builder function that returns the image widget with the appropriate alignment and fit settings.
- **`debug`** *(bool)* – Optional. If `true`, overlays visual guides for debugging alignment.

## Debug Mode
Enable `debug: true` to visualize the focus area and alignment points.

```dart
ImageFocalAligner(
  rawPoint: 0.5,
  resourceSize: Size(800, 600),
  imageBuilder: ({alignment, fit}) {
    return Image.asset('assets/sample.jpg', fit: fit, alignment: alignment ?? Alignment.center);
  },
  debug: true,
)
```

## Custom Alignment with TransformAlignment
The library includes a custom `TransformAlignment` class that extends `Alignment` to provide fine-grained control over image alignment and scaling.

## License
This project is licensed under the MIT License.
