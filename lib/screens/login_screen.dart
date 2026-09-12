import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/secure_storage_service.dart';
import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState
    extends State<LoginScreen> {
  final TextEditingController
      correoController =
      TextEditingController();

  final TextEditingController
      claveController =
      TextEditingController();

  bool ocultarClave = true;
  bool cargando = false;

  Future<void> iniciarSesion() async {
    final correo =
        correoController.text.trim();

    final clave =
        claveController.text.trim();

    if (correo.isEmpty ||
        clave.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Ingrese correo y contraseña',
          ),
        ),
      );

      return;
    }

    setState(() {
      cargando = true;
    });

    try {
      final response =
          await ApiService.login(
        email: correo,
        password: clave,
      );

      final accessToken =
          response['access_token']
              ?.toString();

      final refreshToken =
          response['refresh_token']
              ?.toString();

      if (accessToken == null ||
          refreshToken == null) {
        throw Exception(
          'El servidor no devolvió '
          'los tokens de sesión.',
        );
      }

      await SecureStorageService
          .saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );

      final user = response['user'];

      if (user is Map) {
        await SecureStorageService
            .saveUser(
          id:
              user['id']?.toString() ??
                  '',
          name:
              user['nombre']
                      ?.toString() ??
                  '',
          email:
              user['email']
                  ?.toString(),
        );
      }

      if (!mounted) {
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const HomeScreen(),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            e
                .toString()
                .replaceFirst(
                  'Exception: ',
                  '',
                ),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          cargando = false;
        });
      }
    }
  }

  @override
  void dispose() {
    correoController.dispose();
    claveController.dispose();
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF7F9FC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 35),

              const CircleAvatar(
                radius: 52,
                backgroundColor:
                    Color(0xFF1746A2),
                child: Icon(
                  Icons
                      .account_balance_wallet,
                  size: 55,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'FinanSmart',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight:
                      FontWeight.bold,
                  color:
                      Color(0xFF1746A2),
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Iniciar sesión',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),

              const SizedBox(height: 30),

              TextField(
                controller:
                    correoController,
                keyboardType:
                    TextInputType
                        .emailAddress,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Correo electrónico',
                  prefixIcon: Icon(
                    Icons.email_outlined,
                  ),
                  border:
                      OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 18),

              TextField(
                controller:
                    claveController,
                obscureText:
                    ocultarClave,
                decoration:
                    InputDecoration(
                  labelText:
                      'Contraseña',
                  prefixIcon:
                      const Icon(
                    Icons.lock_outline,
                  ),
                  border:
                      const OutlineInputBorder(),
                  suffixIcon:
                      IconButton(
                    icon: Icon(
                      ocultarClave
                          ? Icons
                              .visibility_off
                          : Icons
                              .visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        ocultarClave =
                            !ocultarClave;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: cargando
                      ? null
                      : iniciarSesion,
                  child: cargando
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child:
                              CircularProgressIndicator(
                            strokeWidth:
                                2,
                          ),
                        )
                      : const Text(
                          'Ingresar',
                          style:
                              TextStyle(
                            fontSize: 17,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 12),

              TextButton(
                onPressed: () {},
                child: const Text(
                  '¿Olvidaste tu contraseña?',
                ),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .center,
                children: [
                  const Text(
                    '¿No tienes cuenta?',
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const RegisterScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Registrarse',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}