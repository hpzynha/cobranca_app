import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AnimatedLogoRow extends StatefulWidget {
  const AnimatedLogoRow({super.key});

  @override
  State<AnimatedLogoRow> createState() => _AnimatedLogoRowState();
}

class _AnimatedLogoRowState extends State<AnimatedLogoRow> {
  double _scale = 0.8;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        _scale = 1.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.8, end: _scale),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutBack,
          builder: (context, value, child) {
            return Transform.scale(scale: value, child: child);
          },
          child: SvgPicture.asset('assets/images/logoC.svg', height: 40),
        ),
        const SizedBox(width: 12),
        const Text(
          'CobrançaAPP',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
