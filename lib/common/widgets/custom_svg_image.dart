import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomSvgImage extends StatelessWidget {
  final String assetPath;
  final double? width;
  final double? height;
  final double borderRadius;
  final Color? color;

  const CustomSvgImage({
    super.key,
    required this.assetPath,
    this.width,
    this.height,
    this.borderRadius = 0.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SvgPicture.asset(
        assetPath,
        color: color,
        width: width,
        height: height,
        fit: BoxFit.contain,
      ),
    );
  }
}
