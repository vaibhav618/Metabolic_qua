import 'package:flutter/material.dart';

class ClientProfileAvatar extends StatelessWidget {
  final String profileImageUrl;
  final double height; // used as radius to keep your current sizing
  final String fallbackAsset;

  const ClientProfileAvatar({
    super.key,
    required this.profileImageUrl,
    this.height = 70,
    this.fallbackAsset = 'assets/images/icons/default2.png',
  });

  @override
  Widget build(BuildContext context) {
    final hasUrl = profileImageUrl.trim().isNotEmpty;

    return Hero(
      tag: "client-image",
      child: CircleAvatar(
        radius: height,
        backgroundColor: Colors.white,
        child: ClipOval(
          child: hasUrl
              ? Image.network(
            profileImageUrl,
            width: height * 2,
            height: height * 2,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stack) => Image.asset(
              fallbackAsset,
              width: height * 2,
              height: height * 2,
              fit: BoxFit.cover,
            ),
          )
              : Image.asset(
            fallbackAsset,
            width: height * 2,
            height: height * 2,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
