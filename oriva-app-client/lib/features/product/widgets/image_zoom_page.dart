import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ImageZoomPage extends StatefulWidget {
  const ImageZoomPage({
    super.key,
    required this.imageUrls,
    required this.initialIndex,
    this.heroTagPrefix,
  });

  final List<String> imageUrls;
  final int initialIndex;
  final String? heroTagPrefix;

  @override
  State<ImageZoomPage> createState() => _ImageZoomPageState();
}

class _ImageZoomPageState extends State<ImageZoomPage> {
  late final PageController _controller =
      PageController(initialPage: widget.initialIndex);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: widget.imageUrls.length,
            itemBuilder: (_, i) {
              final url = widget.imageUrls[i];
              final image = CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.contain,
              );
              return InteractiveViewer(
                minScale: 1.0,
                maxScale: 4.0,
                child: Center(
                  child: widget.heroTagPrefix != null &&
                          i == widget.initialIndex
                      ? Hero(
                          tag: '${widget.heroTagPrefix}-$i',
                          child: image,
                        )
                      : image,
                ),
              );
            },
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 28),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}
