import 'package:flutter/material.dart';
import 'package:characters/characters.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import '../../core/core.dart';
import 'glass_loading.dart';

class GlassAvatar extends StatefulWidget {
  const GlassAvatar({
    super.key,
    required this.label,
    this.avatarUrl,
    this.radius = 16,
    this.backgroundColor,
    this.textColor,
    this.borderWidth = 0,
    this.borderColor,
  });

  final String label;
  final String? avatarUrl;
  final double radius;
  final Color? backgroundColor;
  final Color? textColor;
  final double borderWidth;
  final Color? borderColor;

  @override
  State<GlassAvatar> createState() => _GlassAvatarState();
}

class _GlassAvatarState extends State<GlassAvatar> {
  Timer? _timeoutTimer;
  bool _hasTimedOut = false;
  bool _imageLoaded = false;
  bool _imageError = false;

  static int _accentIndexForLabel(String label) {
    if (label.isEmpty) return 0;
    int hash = 0;
    for (final int codeUnit in label.codeUnits) {
      hash = (hash * 31 + codeUnit) & 0x7fffffff;
    }
    return hash % 5; // map to 5 accent slots
  }

  static String _computeInitials(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return '?';
    final parts = trimmed
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.length == 1) {
      final first = parts[0].characters.first;
      return first.toUpperCase();
    }
    final first = parts[0].characters.first;
    final second = parts[1].characters.first;
    return (first + second).toUpperCase();
  }

  /// Получить токен авторизации для запросов изображений
  Map<String, String>? _getAuthHeaders() {
    try {
      final session = Supabase.instance.client.auth.currentSession;
      if (session?.accessToken != null) {
        return {
          'Authorization': 'Bearer ${session!.accessToken}',
        };
      }
    } catch (e) {
      // Игнорируем ошибки получения токена
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    // Устанавливаем таймаут в 5 секунд только если есть URL
    if (widget.avatarUrl != null && widget.avatarUrl!.isNotEmpty) {
      _timeoutTimer = Timer(const Duration(seconds: 5), () {
        if (mounted && !_imageLoaded && !_imageError) {
          setState(() {
            _hasTimedOut = true;
          });
        }
      });
    }
  }

  /// Отменить таймаут при успешной загрузке изображения
  void _onImageLoaded() {
    _timeoutTimer?.cancel();
    if (mounted) {
      setState(() {
        _imageLoaded = true;
        _hasTimedOut = false;
      });
    }
  }

  /// Отменить таймаут при ошибке загрузки изображения
  void _onImageError() {
    _timeoutTimer?.cancel();
    if (mounted) {
      setState(() {
        _imageError = true;
        _hasTimedOut = false;
      });
    }
  }

  @override
  void didUpdateWidget(GlassAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Если URL изменился, сбрасываем состояние
    if (oldWidget.avatarUrl != widget.avatarUrl) {
      _timeoutTimer?.cancel();
      _hasTimedOut = false;
      _imageLoaded = false;
      _imageError = false;
      
      // Устанавливаем новый таймаут если есть URL
      if (widget.avatarUrl != null && widget.avatarUrl!.isNotEmpty) {
        _timeoutTimer = Timer(const Duration(seconds: 5), () {
          if (mounted && !_imageLoaded && !_imageError) {
            setState(() {
              _hasTimedOut = true;
            });
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String initials = _computeInitials(widget.label);
    final double diameter = widget.radius * 2;
    final int idx = _accentIndexForLabel(widget.label);
    
    // Получаем акцентный цвет по индексу
    final Color baseColor = widget.textColor ?? AccentColorsHelper.getAccentColorByIndex(context, idx);
    final Color bgColor = widget.backgroundColor ?? baseColor.withOpacity(0.25);

    return SizedBox(
      width: diameter,
      height: diameter,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipOval(
            child: Container(
              color: bgColor,
              decoration: widget.borderWidth > 0
                  ? BoxDecoration(
                      border: Border.all(
                        color: widget.borderColor ?? baseColor,
                        width: widget.borderWidth,
                      ),
                    )
                  : null,
            ),
          ),
          if (widget.avatarUrl != null && widget.avatarUrl!.isNotEmpty && !_hasTimedOut && !_imageError)
            ClipOval(
              child: CachedNetworkImage(
                imageUrl: widget.avatarUrl!,
                httpHeaders: _getAuthHeaders(),
                fit: BoxFit.cover,
                width: diameter,
                height: diameter,
                filterQuality: FilterQuality.medium,
                // Таймаут для загрузки изображения
                fadeInDuration: const Duration(milliseconds: 200),
                fadeOutDuration: const Duration(milliseconds: 100),
                placeholder: (context, url) => Center(
                  child: GlassLoading(size: widget.radius * 1.25, color: baseColor),
                ),
                errorWidget: (context, url, error) {
                  // Логируем ошибку для отладки
                  debugPrint('GlassAvatar: Failed to load image $url - $error');
                  _onImageError();
                  return Center(
                    child: Text(
                      initials,
                      style: TextStyle(
                        color: widget.textColor ?? baseColor,
                        fontWeight: FontWeight.w700,
                        fontSize: (widget.radius * 0.85).clamp(10.0, 18.0),
                      ),
                    ),
                  );
                },
                // Колбэк успешной загрузки
                imageBuilder: (context, imageProvider) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _onImageLoaded();
                  });
                  return Image(
                    image: imageProvider,
                    fit: BoxFit.cover,
                    width: diameter,
                    height: diameter,
                  );
                },
                // Настройки кэширования
                memCacheWidth: diameter.toInt(),
                memCacheHeight: diameter.toInt(),
                maxWidthDiskCache: diameter.toInt(),
                maxHeightDiskCache: diameter.toInt(),
                // Настройки для предотвращения бесконечной загрузки
                cacheKey: 'avatar_${widget.avatarUrl!.hashCode}',
                useOldImageOnUrlChange: false,
              ),
            ),
          if (widget.avatarUrl == null || widget.avatarUrl!.isEmpty || _hasTimedOut || _imageError)
            Center(
              child: Text(
                initials,
                style: TextStyle(
                  color: widget.textColor ?? baseColor,
                  fontWeight: FontWeight.w700,
                  fontSize: (widget.radius * 0.85).clamp(10.0, 18.0),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
