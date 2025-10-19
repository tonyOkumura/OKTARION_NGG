import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';

import 'animated_background/particles_widget.dart';

enum ColorTweenBg {
  color1,
  color2,
}

class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({super.key});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground> {
  MovieTween? _tween;

  MovieTween _buildTween(ColorScheme cs) {
    return MovieTween()
      ..tween(
        ColorTweenBg.color1,
        ColorTween(begin: cs.primaryContainer, end: cs.secondaryContainer),
        duration: const Duration(seconds: 30),
        curve: Curves.easeIn,
      )
      ..tween(
        ColorTweenBg.color2,
        ColorTween(begin: cs.secondaryContainer, end: cs.tertiaryContainer),
        duration: const Duration(seconds: 30),
      );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final cs = Theme.of(context).colorScheme;
    setState(() {
      _tween = _buildTween(cs);
    });
  }

  @override
  Widget build(BuildContext context) {
    final tween = _tween ?? _buildTween(Theme.of(context).colorScheme);
    return MirrorAnimationBuilder<Movie>(
      tween: tween,
      duration: tween.duration,
      builder: (context, value, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                value.get<Color>(ColorTweenBg.color1),
                value.get<Color>(ColorTweenBg.color2),
              ],
            ),
          ),
          child: const ParticlesWidget(50), // 50 частиц для фона
        );
      },
    );
  }
}
