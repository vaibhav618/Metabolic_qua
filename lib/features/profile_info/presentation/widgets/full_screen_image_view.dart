import 'dart:io';
import 'package:flutter/material.dart';

class FullScreenImageView extends StatefulWidget {
  /// Pass a file path (String) via GoRouter `extra`
  final String? imagePath;

  const FullScreenImageView({super.key, required this.imagePath});

  @override
  State<FullScreenImageView> createState() => _FullScreenImageViewState();
}

class _FullScreenImageViewState extends State<FullScreenImageView>
    with SingleTickerProviderStateMixin {
  double _verticalOffset = 0.0;
  double _opacity = 1.0;
  bool _isDragging = false;

  late final TransformationController _transformationController;
  late final AnimationController _animationController;
  Animation<Matrix4>? _animationReset;
  bool _zoomed = false;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..addListener(() {
      _transformationController.value = _animationReset!.value;
    });
  }

  void _handleDoubleTap() {
    final Matrix4 end = _zoomed
        ? Matrix4.identity()
        : (Matrix4.identity()..scale(1.2)); // zoom in a bit

    _animationReset = Matrix4Tween(
      begin: _transformationController.value,
      end: end,
    ).animate(CurveTween(curve: Curves.easeInOut).animate(_animationController));

    _animationController.forward(from: 0);
    _zoomed = !_zoomed;
  }

  @override
  void dispose() {
    _animationController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final path = widget.imagePath;
    final hasImage = path != null && path.isNotEmpty && File(path).existsSync();

    return Scaffold(
      backgroundColor: Colors.transparent, // Important (overlay feel)
      body: GestureDetector(
        onVerticalDragStart: (_) => setState(() => _isDragging = true),
        onVerticalDragUpdate: (details) {
          setState(() {
            _verticalOffset += details.delta.dy;
            _opacity = (1 - (_verticalOffset.abs() / 300)).clamp(0.0, 1.0);
          });
        },
        onVerticalDragEnd: (_) {
          if (_verticalOffset.abs() > 120) {
            Navigator.of(context).pop();
          } else {
            setState(() {
              _verticalOffset = 0;
              _opacity = 1.0;
              _isDragging = false;
            });
          }
        },
        onDoubleTap: _handleDoubleTap,
        child: Stack(
          children: [
            // Dimmed backdrop that fades with drag
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: _opacity,
              child: Container(
                color: Colors.black.withAlpha((_opacity * 255).toInt()),
              ),
            ),

            // Image area (moves with drag)
            AnimatedPositioned(
              duration: _isDragging
                  ? Duration.zero
                  : const Duration(milliseconds: 200),
              top: _verticalOffset,
              left: 0,
              right: 0,
              bottom: -_verticalOffset,
              child: Hero(
                tag: 'croppedImage', // keep same tag if you use Hero on the caller
                child: hasImage
                    ? InteractiveViewer(
                  panEnabled: true,
                  scaleEnabled: true,
                  minScale: 1,
                  maxScale: 5,
                  transformationController: _transformationController,
                  child: Image.file(
                    File(path),
                    fit: BoxFit.contain,
                  ),
                )
                    : const _ImageErrorView(),
              ),
            ),

            // Close button
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageErrorView extends StatelessWidget {
  const _ImageErrorView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Image not available',
        style: TextStyle(color: Colors.white70, fontSize: 16),
      ),
    );
  }
}
