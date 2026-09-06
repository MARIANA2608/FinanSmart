import 'package:flutter/material.dart';

import 'financiamientos_screen.dart';
import 'nueva_solicitud_screen.dart';
import 'mis_solicitudes_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'FinanSmart',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          children: [
            _opcion(
              context: context,
              icono:
                  Icons.request_page_outlined,
              texto: 'Nueva solicitud',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const NuevaSolicitudScreen(),
                  ),
                );
              },
            ),

            _opcion(
              context: context,
              icono: Icons.list_alt,
              texto: 'Mis solicitudes',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const MisSolicitudesScreen(),
                  ),
                );
              },
            ),

            _opcion(
              context: context,
              icono:
                  Icons.calculate_outlined,
              texto: 'Simulador',
              onTap: () {},
            ),

            _opcion(
              context: context,
              icono:
                  Icons.account_balance_outlined,
              texto: 'Financiamientos',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const FinanciamientosScreen(),
                  ),
                );
              },
            ),

            _opcion(
              context: context,
              icono: Icons.person_outline,
              texto: 'Mi perfil',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _opcion({
    required BuildContext context,
    required IconData icono,
    required String texto,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              icono,
              size: 48,
              color:
                  theme.colorScheme.primary,
            ),

            const SizedBox(
              height: 12,
            ),

            Text(
              texto,
              textAlign:
                  TextAlign.center,
              style: theme
                  .textTheme
                  .titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}