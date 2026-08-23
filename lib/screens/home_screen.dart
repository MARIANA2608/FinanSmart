import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FinanSmart'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          children: [
            _opcion(
              icono: Icons.request_page_outlined,
              texto: 'Nueva solicitud',
            ),
            _opcion(
              icono: Icons.list_alt,
              texto: 'Mis solicitudes',
            ),
            _opcion(
              icono: Icons.calculate_outlined,
              texto: 'Simulador',
            ),
            _opcion(
              icono: Icons.account_balance_outlined,
              texto: 'Financiamientos',
            ),
            _opcion(
              icono: Icons.person_outline,
              texto: 'Mi perfil',
            ),
          ],
        ),
      ),
    );
  }

  Widget _opcion({
    required IconData icono,
    required String texto,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icono,
              size: 48,
              color: const Color(0xFF1746A2),
            ),
            const SizedBox(height: 12),
            Text(
              texto,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}