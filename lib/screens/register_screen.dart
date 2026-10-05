import 'package:flutter/material.dart';

import '../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nombreController =
      TextEditingController();

  final TextEditingController correoController =
      TextEditingController();

  final TextEditingController telefonoController =
      TextEditingController();

  final TextEditingController claveController =
      TextEditingController();

  bool _registrando = false;
  bool _mostrarClave = false;

  @override
  void dispose() {
    nombreController.dispose();
    correoController.dispose();
    telefonoController.dispose();
    claveController.dispose();
    super.dispose();
  }

  Future<void> registrar() async {
    final nombre =
        nombreController.text.trim();

    final correo =
        correoController.text.trim();

    final telefono =
        telefonoController.text.trim();

    final clave =
        claveController.text.trim();

    // ============================================================
    // VALIDACIÓN LOCAL
    // ============================================================

    if (nombre.isEmpty ||
        correo.isEmpty ||
        clave.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Complete los campos obligatorios.'),
        ),
      );
      return;
    }

    if (!correo.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Ingrese un correo electrónico válido.'),
        ),
      );
      return;
    }

    if (clave.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text(
                'La contraseña debe tener al menos 6 caracteres.',
              ),
        ),
      );
      return;
    }

    setState(() {
      _registrando = true;
    });

    try {
      // ============================================================
      // REGISTRO EN EL BACKEND
      // ============================================================

      await ApiService.registrarUsuario(
        nombre: nombre,
        email: correo,
        telefono: telefono,
        password: clave,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Usuario registrado correctamente.'),
        ),
      );

      // Regresar a la pantalla de inicio de sesión.
      Navigator.pop(context);
    } on ValidationException catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No fue posible registrar el usuario: $error',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _registrando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear cuenta'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: nombreController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Nombre completo',
                prefixIcon:
                    Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: correoController,
              keyboardType:
                  TextInputType.emailAddress,
              textInputAction:
                  TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Correo electrónico',
                prefixIcon:
                    Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: telefonoController,
              keyboardType: TextInputType.phone,
              textInputAction:
                  TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Teléfono',
                prefixIcon:
                    Icon(Icons.phone_outlined),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: claveController,
              obscureText: !_mostrarClave,
              textInputAction:
                  TextInputAction.done,
              onSubmitted: (_) {
                if (!_registrando) {
                  registrar();
                }
              },
              decoration: InputDecoration(
                labelText: 'Contraseña',
                prefixIcon:
                    const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _mostrarClave
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _mostrarClave =
                          !_mostrarClave;
                    });
                  },
                ),
                border:
                    const OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed:
                    _registrando
                        ? null
                        : registrar,
                child: _registrando
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Crear cuenta',
                        style:
                            TextStyle(
                          fontSize: 17,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}