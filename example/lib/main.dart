import 'package:flutter/material.dart';
import 'package:image_focal_aligner/image_focal_aligner.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Builder(
                  builder: (context) {
                    final imageData = imageCollection[_index];
                    return ImageFocalAligner(
                      rawPoint: imageData.rawPointToPercent,
                      resourceSize: imageData.resolutionToSize,
                      debug: true,
                      imageBuilder: ({alignment, fit}) {
                        return Image.network(
                          imageData.source,
                          alignment: alignment ?? Alignment.centerRight,
                          fit: fit ?? BoxFit.cover,
                        );
                      },
                    );
                  },
                ),
              ),
              Container(
                color: Colors.black,
                height: 200,
                width: double.infinity,
                child: Center(
                  child: Wrap(
                    children: [
                      for (int i = 0; i < imageCollection.length; i++)
                        ElevatedButton(
                          onPressed: () {
                            setState(() => _index = i);
                          },
                          child: Text(i.toString()),
                        ),
                    ],
                  ),
                ),
              )
            ],
          ),
          // BoxResizer(),
          const Align(
            alignment: Alignment.bottomRight,
            child: _SizeMonitor(),
          ),
        ],
      ),
    );
  }
}

const List<ImageData> imageCollection = [
  ImageData(
    rawPoint: 583,
    source:
        'https://static.lichi.com/product/49000/0d793262d76e8f6ffdfd2e6657692dc6.jpg?v=0_49000.0',
    imageResolution: '1536_2048',
  ),
  ImageData(
    rawPoint: 631,
    source:
        'https://static.lichi.com/product/49000/986083efb94ca49a1d3e244ed1fb049b.jpg?v=3_49000.3',
    imageResolution: '1536_2048',
  ),
  ImageData(
    rawPoint: 714,
    source:
        'https://static.lichi.com/product/49000/3aef9f75e4d10a21041d20285879f161.jpg?v=8_49000.8',
    imageResolution: '1536_2048',
  ),
];

class ImageData {
  final String source;
  final double? rawPoint;
  final String? imageResolution;

  const ImageData({
    required this.source,
    required this.rawPoint,
    required this.imageResolution,
  });

  Size? get resolutionToSize => switch (imageResolution) {
        '1536_2048' => const Size(1536, 2048),
        '768_1024' => const Size(768, 1024),
        '384_512' => const Size(384, 512),
        _ => null,
      };

  /// Mock data
  double? get rawPointToPercent =>
      rawPoint != null ? (rawPoint! / 1536 * 1.113) : null;
}

class _SizeMonitor extends StatefulWidget {
  const _SizeMonitor({
    super.key, // ignore: unused_element
  });

  @override
  State<_SizeMonitor> createState() => _SizeMonitorState();
}

class _SizeMonitorState extends State<_SizeMonitor> {
  double opacity = 1;

  String getAspectRatio(int width, int height) {
    int gcd(int a, int b) => b == 0 ? a : gcd(b, a % b);

    int divisor = gcd(width, height);
    int aspectWidth = width ~/ divisor;
    int aspectHeight = height ~/ divisor;

    return "$aspectWidth:$aspectHeight";
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onDoubleTap: () {
        setState(() {
          opacity = opacity == 0 ? 1 : 0;
        });
      },
      child: Opacity(
        opacity: opacity,
        child: Material(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Size: ${size}'),
              Text(
                'AspectRatio: ${getAspectRatio(
                  size.width.toInt(),
                  size.height.toInt(),
                )}',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
