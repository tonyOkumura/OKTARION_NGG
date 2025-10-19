import 'dart:math';

import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:supercharged/supercharged.dart';

import 'particle_model.dart';
import 'particle_painter.dart';

class ParticlesWidget extends StatefulWidget {
  final int numberOfParticles;

  const ParticlesWidget(this.numberOfParticles, {super.key});

  @override
  State<ParticlesWidget> createState() => _ParticlesWidgetState();
}

class _ParticlesWidgetState extends State<ParticlesWidget>
    with WidgetsBindingObserver {
  final Random random = Random();

  final List<ParticleModel> particles = [];

  @override
  void initState() {
    super.initState();
    widget.numberOfParticles.times(() => particles.add(ParticleModel(random)));
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      for (var particle in particles) {
        particle.restart();
        particle.shuffle();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoopAnimationBuilder(
      tween: ConstantTween(1),
      duration: const Duration(seconds: 1),
      builder: (context, dynamic _, child) {
        _simulateParticles();
        return CustomPaint(painter: ParticlePainter(particles));
      },
    );
  }

  _simulateParticles() {
    for (var particle in particles) {
      particle.checkIfParticleNeedsToBeRestarted();
    }
  }
}
