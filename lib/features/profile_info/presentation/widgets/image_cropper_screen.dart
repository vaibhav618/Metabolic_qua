import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_svg/svg.dart';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:go_router/go_router.dart';

class ImageCropperScreen extends StatefulWidget {
  final Uint8List imageData;

  const ImageCropperScreen({super.key, required this.imageData});

  @override
  State<ImageCropperScreen> createState() => _ImageCropperScreenState();
}

class _ImageCropperScreenState extends State<ImageCropperScreen> {
  final CropController _controller = CropController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Crop(
                image: widget.imageData,
                controller: _controller,
                aspectRatio: 1,
                baseColor: Colors.black,
                maskColor: Colors.black.withAlpha(94),
                withCircleUi: false,
                radius: 10,
                interactive: true,
                progressIndicator: const Center(
                  child: CircularProgressIndicator(color: Colors.blue),
                ),

                onCropped: (result) {
                  _handleCropResult(result);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              child: IntrinsicHeight(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,

                  children: [
                    TextButton(
                      onPressed: () => context.pop(),
                      child: SvgPicture.asset(
                        "assets/images/common/closeicon.svg",
                        colorFilter: ColorFilter.mode(
                          Colors.black,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    VerticalDivider(color: Colors.black, thickness: 2),

                    TextButton(
                      onPressed: () => _controller.crop(),
                      child: SvgPicture.asset(
                        "assets/images/common/tick_icon.svg",
                        colorFilter: ColorFilter.mode(
                          Colors.black,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _handleCropResult(CropResult result) async {
    if (!mounted) return;

    switch (result) {
      case CropSuccess(:final croppedImage):
        try {
          const maxSizeInBytes = 2 * 1024 * 1024;
          int quality = 70;
          List<int>? compressedBytes;

          while (quality >= 10) {
            compressedBytes = await FlutterImageCompress.compressWithList(
              croppedImage,
              minWidth: 1080,
              minHeight: 1080,
              quality: quality,
            );

            if (compressedBytes.length <= maxSizeInBytes) break;
            quality -= 5;
          }

          if (!mounted) return;

          if (compressedBytes == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Error: Compression Failed!")),
            );
            return;
          }

          context.pop(Uint8List.fromList(compressedBytes));
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error compressing image: $e')),
          );
        }

      case CropFailure(:final cause):
        if (!mounted) return;
        showDialog(
          context: context,
          builder:
              (_) => AlertDialog(
                title: const Text('Crop Error'),
                content: Text(cause.toString()),
                actions: [
                  TextButton(
                    onPressed: () => context.pop(),
                    child: const Text('OK'),
                  ),
                ],
              ),
        );
    }
  }
}
