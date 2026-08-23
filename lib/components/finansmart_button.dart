import 'package:flutter/material.dart';

/// Botón reutilizable de FinanSmart.
///
/// Su interfaz pública permite reutilizarlo en distintas pantallas
/// sin que el componente conozca navegación, backend o lógica de negocio.
class FinanSmartButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final bool outlined;
  final String? semanticLabel;

  const FinanSmartButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.outlined = false,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final Widget content = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (loading)
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: outlined
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onPrimary,
            ),
          )
        else if (icon != null)
          Icon(
            icon,
            size: 20,
          ),
        if (loading || icon != null)
          const SizedBox(width: 8),
        Text(
          loading ? 'Procesando...' : label,
        ),
      ],
    );

    final button = outlined
        ? OutlinedButton(
            onPressed: loading ? null : onPressed,
            child: content,
          )
        : FilledButton(
            onPressed: loading ? null : onPressed,
            child: content,
          );

    return Semantics(
      button: true,
      label: semanticLabel ?? label,
      enabled: onPressed != null && !loading,
      child: SizedBox(
        width: double.infinity,
        child: button,
      ),
    );
  }
}