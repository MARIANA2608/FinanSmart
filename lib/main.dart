import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const FinanSmartApp());
}

class FinanSmartApp extends StatelessWidget {
  const FinanSmartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FinanSmart',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1746A2),
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool cargando = false;

  String mensajeApi = 'Aún no se ha probado la conexión con el backend.';

  List<dynamic> financiamientos = [];

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000',
  );

  Future<void> probarConexion() async {
    setState(() {
      cargando = true;
      mensajeApi = 'Conectando con FinanSmart API...';
      financiamientos = [];
    });

    try {
      final url = Uri.parse('$baseUrl/api/financiamientos');

      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final datos = jsonDecode(response.body);

        setState(() {
          mensajeApi = 'Conexión exitosa con FinanSmart API';
          financiamientos = datos['data'] ?? [];
        });
      } else {
        setState(() {
          mensajeApi =
              'Error HTTP ${response.statusCode}: ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        mensajeApi = 'Error de conexión: $e';
      });
    } finally {
      setState(() {
        cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 25),

              const CircleAvatar(
                radius: 52,
                backgroundColor: Color(0xFF1746A2),
                child: Icon(
                  Icons.account_balance_wallet,
                  size: 55,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'FinanSmart',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1746A2),
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Tu solución inteligente de financiamiento',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 35),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: () {},
                  child: const Text(
                    'Iniciar sesión',
                    style: TextStyle(fontSize: 17),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () {},
                  child: const Text(
                    'Registrarse',
                    style: TextStyle(fontSize: 17),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              TextButton(
                onPressed: () {},
                child: const Text(
                  '¿Olvidaste tu contraseña?',
                ),
              ),

              const SizedBox(height: 30),

              const Divider(),

              const SizedBox(height: 20),

              const Text(
                'Prueba de conexión con el backend',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                'URL base: $baseUrl',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: cargando ? null : probarConexion,
                  icon: const Icon(Icons.cloud_done),
                  label: Text(
                    cargando
                        ? 'Conectando...'
                        : 'Probar conexión con API',
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      mensajeApi,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),

              if (financiamientos.isNotEmpty) ...[
                const SizedBox(height: 20),

                const Text(
                  'Financiamientos recibidos',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                ...financiamientos.map(
                  (item) => Card(
                    margin: const EdgeInsets.only(
                      bottom: 12,
                    ),
                    child: ListTile(
                      leading: const CircleAvatar(
                        child: Icon(
                          Icons.attach_money,
                        ),
                      ),
                      title: Text(
                        item['nombre'] ?? 'Sin nombre',
                      ),
                      subtitle: Text(
                        'Tasa: ${item['tasa_interes']}%\n'
                        'Plazo: ${item['plazo_minimo']} a '
                        '${item['plazo_maximo']} meses\n'
                        'Estado: ${item['estado']}',
                      ),
                      isThreeLine: true,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}