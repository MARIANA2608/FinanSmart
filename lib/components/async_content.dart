import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import 'finansmart_button.dart';

/// Componente reutilizable para representar estados asincrónicos.
///
/// Resuelve explícitamente:
/// - Cargando
/// - Vacío
/// - Error
/// - Éxito
///
/// No consulta servicios ni conoce endpoints.
/// Recibe desde afuera el estado y el contenido que debe mostrar.
class AsyncContent extends StatelessWidget {
  final bool loading;
  final String? errorMessage;
  final bool isEmpty;
  final Widget child;
  final VoidCallback? onRetry;

  final String emptyTitle;
  final String emptyMessage;

  const AsyncContent({
    super.key,
    required this.loading,
    required this.errorMessage,
    required this.isEmpty,
    required this.child,
    this.onRetry,
    this.emptyTitle = 'Sin resultados',
    this.emptyMessage =
        'No hay información disponible para mostrar.',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (loading) {
      return Semantics(
        label: 'Cargando información',
        liveRegion: true,
        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(
              AppSpacing.xl,
            ),
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (errorMessage != null) {
      return Semantics(
        container: true,
        label:
            'Error al cargar la información. $errorMessage',
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(
              AppSpacing.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: theme.colorScheme.error,
                ),

                const SizedBox(
                  height: AppSpacing.md,
                ),

                Text(
                  'No pudimos cargar la información',
                  textAlign: TextAlign.center,
                  style:
                      theme.textTheme.titleLarge,
                ),

                const SizedBox(
                  height: AppSpacing.sm,
                ),

                Text(
                  errorMessage!,
                  textAlign: TextAlign.center,
                  style:
                      theme.textTheme.bodyMedium,
                ),

                if (onRetry != null) ...[
                  const SizedBox(
                    height: AppSpacing.lg,
                  ),

                  FinanSmartButton(
                    label: 'Reintentar',
                    icon: Icons.refresh,
                    onPressed: onRetry,
                    semanticLabel:
                        'Reintentar carga de información',
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    if (isEmpty) {
      return Semantics(
        container: true,
        label:
            '$emptyTitle. $emptyMessage',
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(
              AppSpacing.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 48,
                  color: theme
                      .colorScheme
                      .onSurfaceVariant,
                ),

                const SizedBox(
                  height: AppSpacing.md,
                ),

                Text(
                  emptyTitle,
                  textAlign: TextAlign.center,
                  style:
                      theme.textTheme.titleLarge,
                ),

                const SizedBox(
                  height: AppSpacing.sm,
                ),

                Text(
                  emptyMessage,
                  textAlign: TextAlign.center,
                  style:
                      theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return child;
  }
}