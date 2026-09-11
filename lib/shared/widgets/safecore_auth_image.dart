import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/provider/auth_provider.dart';
import '../theme/tokens.dart';

class SafeCoreAuthImage extends ConsumerWidget {
  final String url;
  final BoxFit fit;
  final Widget? errorWidget;

  const SafeCoreAuthImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final token = ref.watch(authProvider).valueOrNull?.token;

    return CachedNetworkImage(
      imageUrl: url,
      httpHeaders:
          token != null ? {'Authorization': 'Bearer $token'} : const {},
      fit: fit,
      fadeInDuration: const Duration(milliseconds: 200),
      placeholder: (_, __) => Container(
        color: SafeCoreColors.dark.bgElevated,
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: SafeCoreColors.dark.accent,
            ),
          ),
        ),
      ),
      errorWidget: (_, __, ___) =>
          errorWidget ??
          Container(
            color: SafeCoreColors.dark.bgElevated,
            child: Icon(
              Icons.broken_image_outlined,
              color: SafeCoreColors.dark.fg2,
              size: 32,
            ),
          ),
    );
  }
}
