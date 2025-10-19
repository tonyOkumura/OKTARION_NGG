import 'dart:math';
import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:supercharged/supercharged.dart';

enum ParticleOffsetProps {
  x,
  y,
}

const _minParticleLifetimeMs = 3000;
const _maxParticleLifetimeMs = 60000;
const _particleAnimationDuration = Duration(seconds: 2);
const _particleXStartOffset = -0.2;
const _particleXRange = 1.4;
const _particleYStart = 1.2;
const _particleYEnd = -0.2;
const _minParticleSize = 0.2;
const _particleSizeRange = 0.4;

class ParticleModel {
  late MovieTween tween;
  late double size;
  late Duration duration;
  late Duration startTime;
  final Random random;

  ParticleModel(this.random) {
    restart();
    shuffle();
  }

  void restart() {
    final startPosition = Offset(
      _particleXStartOffset + _particleXRange * random.nextDouble(),
      _particleYStart,
    );
    final endPosition = Offset(
      _particleXStartOffset + _particleXRange * random.nextDouble(),
      _particleYEnd,
    );

    tween = MovieTween()
      ..tween(
        ParticleOffsetProps.x,
        Tween(begin: startPosition.dx, end: endPosition.dx),
        duration: _particleAnimationDuration,
      )
      ..tween(
        ParticleOffsetProps.y,
        Tween(begin: startPosition.dy, end: endPosition.dy),
        duration: _particleAnimationDuration,
      );

    duration =
        (_minParticleLifetimeMs +
                random.nextInt(_maxParticleLifetimeMs - _minParticleLifetimeMs))
            .milliseconds;
    startTime = DateTime.now().difference(
      DateTime.fromMillisecondsSinceEpoch(0),
    );
    size = _minParticleSize + random.nextDouble() * _particleSizeRange;
  }

  void shuffle() {
    startTime -= (random.nextDouble() * duration.inMilliseconds)
        .round()
        .milliseconds;
  }

  void checkIfParticleNeedsToBeRestarted() {
    if (progress() >= 1.0) {
      restart();
    }
  }

  double progress() {
    final elapsed =
        DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(0)) -
        startTime;
    return (elapsed.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);
  }
}
