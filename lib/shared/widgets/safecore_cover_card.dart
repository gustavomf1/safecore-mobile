import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import 'safecore_auth_image.dart';
import 'motion_helpers.dart';

class SafeCoreCoverCard extends StatelessWidget {
  final String id;
  final String? codigo;
  final String titulo;
  final String? coverUrl;
  final bool hasImageCover;
  final bool hasAnyCover;
  final List<Widget> pills;
  final String? meta;
  final VoidCallback onTap;

  const SafeCoreCoverCard({
    super.key,
    required this.id,
    this.codigo,
    required this.titulo,
    required this.coverUrl,
    required this.hasImageCover,
    required this.hasAnyCover,
    required this.pills,
    this.meta,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return TapScale(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Hero(
          tag: 'cover-$id',
          child: ClipRRect(
            borderRadius: BorderRadius.circular(SafeCoreRadius.md),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildCover(c),
                  // scrim gradiente
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: [0.35, 1.0],
                        colors: [Colors.transparent, Color(0xCC000000)],
                      ),
                    ),
                  ),
                  // pills (canto superior esquerdo)
                  if (pills.isNotEmpty)
                    Positioned(
                      top: 10,
                      left: 10,
                      right: 10,
                      child: Wrap(spacing: 6, runSpacing: 4, children: pills),
                    ),
                  // título + meta (rodapé)
                  Positioned(
                    bottom: 10,
                    left: 12,
                    right: 12,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (codigo != null && codigo!.isNotEmpty) ...[
                          Text(
                            codigo!,
                            style: TextStyle(
                              color: c.accent,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'monospace',
                              letterSpacing: .3,
                            ),
                          ),
                          const SizedBox(height: 2),
                        ],
                        Text(
                          titulo,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: SafeCoreType.subtitle.copyWith(color: c.fg0, height: 1.3),
                        ),
                        if (meta != null && meta!.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            meta!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: SafeCoreType.body.copyWith(color: c.fg2),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCover(SafeCoreColors c) {
    // Caminho 1: imagem
    if (hasImageCover && coverUrl != null) {
      return SafeCoreAuthImage(url: coverUrl!, fit: BoxFit.cover);
    }
    // Caminho 2: evidência não-imagem (pdf, video, etc.)
    if (hasAnyCover) {
      return Container(
        color: c.bgElevated,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.insert_drive_file_outlined, color: c.fg2, size: 36),
            const SizedBox(height: 6),
            Text(
              'Documento anexado',
              style: SafeCoreType.body.copyWith(color: c.fg2),
            ),
          ],
        ),
      );
    }
    // Caminho 3: sem evidência
    return Container(
      color: c.bgElevated,
      child: Center(
        child: Icon(Icons.shield_outlined, color: c.fg3, size: 40),
      ),
    );
  }
}
