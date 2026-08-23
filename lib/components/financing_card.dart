import 'package:flutter/material.dart';

import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

/// Tarjeta reutilizable para mostrar un tipo de financiamiento.
///
/// Recibe todos los datos desde la pantalla que la utiliza.
/// No consulta la API y no conoce rutas de navegación.
class FinancingCard extends StatelessWidget {
  final String title;
  final String description;
  final double interestRate;
  final int minTerm;
  final int maxTerm;
  final String status;
  final VoidCallback? onTap;
  final Widget? trailing;

  const FinancingCard({
    super.key,
    required this.title,
    required this.description,
    required this.interestRate,
    required this.minTerm,
    required this.maxTerm,
    required this.status,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final bool active = status.toLowerCase() == 'activo';

    final Color statusBackground = active
        ? colorScheme.primaryContainer
        : colorScheme.errorContainer;

    final Color statusForeground = active
        ? colorScheme.onPrimaryContainer
        : colorScheme.onErrorContainer;

    return Semantics(
      container: true,
      label:
          '$title. '
          'Tasa de interés $interestRate por ciento. '
          'Plazo entre $minTerm y $maxTerm meses. '
          'Estado $status.',
      button: onTap != null,
      child: Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(
            AppRadius.lg,
          ),
          child: Padding(
            padding: const EdgeInsets.all(
              AppSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: theme.textTheme.titleLarge,
                      ),
                    ),

                    ?trailing,
                  ],
                ),

                const SizedBox(
                  height: AppSpacing.sm,
                ),

                Text(
                  description,
                  style: theme.textTheme.bodyMedium,
                ),

                const SizedBox(
                  height: AppSpacing.md,
                ),

                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    _InfoChip(
                      icon: Icons.percent,
                      label: '$interestRate% interés',
                    ),
                    _InfoChip(
                      icon: Icons.schedule,
                      label: '$minTerm–$maxTerm meses',
                    ),
                  ],
                ),

                const SizedBox(
                  height: AppSpacing.md,
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: statusBackground,
                    borderRadius: BorderRadius.circular(
                      AppRadius.pill,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        active
                            ? Icons.check_circle
                            : Icons.cancel,
                        size: 18,
                        color: statusForeground,
                      ),

                      const SizedBox(
                        width: AppSpacing.xs,
                      ),

                      Text(
                        status,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: statusForeground,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Elemento interno utilizado para mostrar
/// información complementaria como tasa y plazo.
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(
          AppRadius.pill,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: theme.colorScheme.primary,
          ),

          const SizedBox(
            width: AppSpacing.xs,
          ),

          Text(
            label,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}