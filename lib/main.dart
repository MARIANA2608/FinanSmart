import 'package:flutter/material.dart';

import 'screens/financiamientos_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const FinanSmartApp());
}

// ============================================================
// DATOS TEMPORALES DE LA APLICACIÓN
// ============================================================

String usuarioNombre = 'Usuario FinanSmart';
String usuarioCorreo = 'usuario@finansmart.com';
String usuarioTelefono = '0999999999';
String usuarioClave = '123456';

final List<Map<String, dynamic>> solicitudes = [];

// ============================================================
// APLICACIÓN PRINCIPAL
// ============================================================

class FinanSmartApp extends StatelessWidget {
  const FinanSmartApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FinanSmart',
      theme: AppTheme.light,
      home: const InicioScreen(),
    );
  }
}

// ============================================================
// PANTALLA INICIAL
// ============================================================

class InicioScreen extends StatelessWidget {
  const InicioScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(
                height: 32,
              ),

              CircleAvatar(
                radius: 52,
                backgroundColor:
                    theme.colorScheme.primary,
                child: Icon(
                  Icons.account_balance_wallet,
                  size: 54,
                  color:
                      theme.colorScheme.onPrimary,
                ),
              ),

              const SizedBox(
                height: 24,
              ),

              Text(
                'FinanSmart',
                style: theme
                    .textTheme
                    .headlineLarge
                    ?.copyWith(
                  color:
                      theme.colorScheme.primary,
                ),
              ),

              const SizedBox(
                height: 8,
              ),

              Text(
                'Tu solución inteligente de financiamiento',
                textAlign: TextAlign.center,
                style:
                    theme.textTheme.bodyLarge,
              ),

              const SizedBox(
                height: 32,
              ),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const LoginScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Iniciar sesión',
                  ),
                ),
              ),

              const SizedBox(
                height: 16,
              ),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const RegistroScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Registrarse',
                  ),
                ),
              ),

              const SizedBox(
                height: 8,
              ),

              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        'La recuperación de contraseña '
                        'se implementará próximamente.',
                      ),
                    ),
                  );
                },
                child: const Text(
                  '¿Olvidaste tu contraseña?',
                ),
              ),

              const SizedBox(
                height: 32,
              ),

              const Divider(),

              const SizedBox(
                height: 24,
              ),

              Text(
                'Catálogo de financiamientos',
                style:
                    theme.textTheme.titleLarge,
              ),

              const SizedBox(
                height: 8,
              ),

              Text(
                'Consulta los productos disponibles '
                'directamente desde FinanSmart API.',
                textAlign: TextAlign.center,
                style:
                    theme.textTheme.bodyMedium,
              ),

              const SizedBox(
                height: 20,
              ),

              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const FinanciamientosScreen(),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.account_balance,
                  ),
                  label: const Text(
                    'Ver financiamientos',
                  ),
                ),
              ),

              const SizedBox(
                height: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// LOGIN
// ============================================================

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
  });

  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState
    extends State<LoginScreen> {
  final correoController =
      TextEditingController();

  final claveController =
      TextEditingController();

  bool ocultarClave = true;

  @override
  void dispose() {
    correoController.dispose();
    claveController.dispose();
    super.dispose();
  }

  void iniciarSesion() {
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
            'Ingrese correo y contraseña.',
          ),
        ),
      );

      return;
    }

    if (correo == usuarioCorreo &&
        clave == usuarioClave) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const MenuPrincipalScreen(),
        ),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Correo o contraseña incorrectos.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Iniciar sesión',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(
                Icons.lock_person_outlined,
                size: 72,
                color:
                    theme.colorScheme.primary,
              ),

              const SizedBox(
                height: 16,
              ),

              Text(
                'Bienvenido a FinanSmart',
                textAlign: TextAlign.center,
                style:
                    theme.textTheme.headlineMedium,
              ),

              const SizedBox(
                height: 24,
              ),

              TextField(
                controller:
                    correoController,
                keyboardType:
                    TextInputType.emailAddress,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Correo electrónico',
                  prefixIcon:
                      Icon(Icons.email_outlined),
                ),
              ),

              const SizedBox(
                height: 16,
              ),

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
                  suffixIcon:
                      IconButton(
                    tooltip:
                        ocultarClave
                            ? 'Mostrar contraseña'
                            : 'Ocultar contraseña',
                    onPressed: () {
                      setState(() {
                        ocultarClave =
                            !ocultarClave;
                      });
                    },
                    icon: Icon(
                      ocultarClave
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: 24,
              ),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed:
                      iniciarSesion,
                  child: const Text(
                    'Ingresar',
                  ),
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              Text(
                'Usuario de prueba',
                style:
                    theme.textTheme.titleMedium,
              ),

              const SizedBox(
                height: 8,
              ),

              Text(
                usuarioCorreo,
              ),

              Text(
                'Contraseña: $usuarioClave',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// REGISTRO
// ============================================================

class RegistroScreen
    extends StatefulWidget {
  const RegistroScreen({
    super.key,
  });

  @override
  State<RegistroScreen> createState() =>
      _RegistroScreenState();
}

class _RegistroScreenState
    extends State<RegistroScreen> {
  final nombreController =
      TextEditingController();

  final correoController =
      TextEditingController();

  final telefonoController =
      TextEditingController();

  final claveController =
      TextEditingController();

  @override
  void dispose() {
    nombreController.dispose();
    correoController.dispose();
    telefonoController.dispose();
    claveController.dispose();
    super.dispose();
  }

  void registrar() {
    final nombre =
        nombreController.text.trim();

    final correo =
        correoController.text.trim();

    final telefono =
        telefonoController.text.trim();

    final clave =
        claveController.text.trim();

    if (nombre.isEmpty ||
        correo.isEmpty ||
        clave.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Complete los campos obligatorios.',
          ),
        ),
      );

      return;
    }

    usuarioNombre = nombre;
    usuarioCorreo = correo;
    usuarioTelefono = telefono;
    usuarioClave = clave;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          'Usuario registrado correctamente.',
        ),
      ),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Crear cuenta',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.all(24),
          child: Column(
            children: [
              TextField(
                controller:
                    nombreController,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Nombre completo',
                  prefixIcon:
                      Icon(
                    Icons.person_outline,
                  ),
                ),
              ),

              const SizedBox(
                height: 16,
              ),

              TextField(
                controller:
                    correoController,
                keyboardType:
                    TextInputType.emailAddress,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Correo electrónico',
                  prefixIcon:
                      Icon(
                    Icons.email_outlined,
                  ),
                ),
              ),

              const SizedBox(
                height: 16,
              ),

              TextField(
                controller:
                    telefonoController,
                keyboardType:
                    TextInputType.phone,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Teléfono',
                  prefixIcon:
                      Icon(
                    Icons.phone_outlined,
                  ),
                ),
              ),

              const SizedBox(
                height: 16,
              ),

              TextField(
                controller:
                    claveController,
                obscureText: true,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Contraseña',
                  prefixIcon:
                      Icon(
                    Icons.lock_outline,
                  ),
                ),
              ),

              const SizedBox(
                height: 24,
              ),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: registrar,
                  child: const Text(
                    'Crear cuenta',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// MENÚ PRINCIPAL
// ============================================================

class MenuPrincipalScreen
    extends StatelessWidget {
  const MenuPrincipalScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'FinanSmart',
        ),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const InicioScreen(),
                ),
                (route) => false,
              );
            },
            icon: const Icon(
              Icons.logout,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'Hola, $usuarioNombre',
                style:
                    theme.textTheme.headlineMedium,
              ),

              const SizedBox(
                height: 4,
              ),

              Text(
                '¿Qué deseas hacer hoy?',
                style:
                    theme.textTheme.bodyLarge,
              ),

              const SizedBox(
                height: 20,
              ),

              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  children: [
                    _MenuCard(
                      icon:
                          Icons.add_card,
                      label:
                          'Nueva solicitud',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const NuevaSolicitudScreen(),
                          ),
                        );
                      },
                    ),

                    _MenuCard(
                      icon:
                          Icons.receipt_long,
                      label:
                          'Mis solicitudes',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const MisSolicitudesScreen(),
                          ),
                        );
                      },
                    ),

                    _MenuCard(
                      icon:
                          Icons.calculate_outlined,
                      label: 'Simulador',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const SimuladorScreen(),
                          ),
                        );
                      },
                    ),

                    _MenuCard(
                      icon:
                          Icons.account_balance,
                      label:
                          'Financiamientos',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const FinanciamientosScreen(),
                          ),
                        );
                      },
                    ),

                    _MenuCard(
                      icon:
                          Icons.person_outline,
                      label: 'Mi perfil',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const PerfilScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      button: true,
      label: label,
      child: Card(
        child: InkWell(
          onTap: onTap,
          borderRadius:
              BorderRadius.circular(16),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 44,
                color:
                    theme.colorScheme.primary,
              ),

              const SizedBox(
                height: 12,
              ),

              Padding(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 8,
                ),
                child: Text(
                  label,
                  textAlign:
                      TextAlign.center,
                  style:
                      theme.textTheme.titleMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// SIMULADOR
// ============================================================

class SimuladorScreen
    extends StatefulWidget {
  const SimuladorScreen({
    super.key,
  });

  @override
  State<SimuladorScreen>
      createState() =>
          _SimuladorScreenState();
}

class _SimuladorScreenState
    extends State<SimuladorScreen> {
  final montoController =
      TextEditingController();

  final plazoController =
      TextEditingController();

  final tasaController =
      TextEditingController(
    text: '12.5',
  );

  double? cuota;

  @override
  void dispose() {
    montoController.dispose();
    plazoController.dispose();
    tasaController.dispose();
    super.dispose();
  }

  void calcular() {
    final monto = double.tryParse(
      montoController.text,
    );

    final plazo = int.tryParse(
      plazoController.text,
    );

    final tasa = double.tryParse(
      tasaController.text,
    );

    if (monto == null ||
        plazo == null ||
        tasa == null ||
        plazo <= 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Ingrese valores válidos.',
          ),
        ),
      );

      return;
    }

    final interes =
        monto * (tasa / 100);

    final total =
        monto + interes;

    setState(() {
      cuota = total / plazo;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Simulador',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.all(24),
          child: Column(
            children: [
              TextField(
                controller:
                    montoController,
                keyboardType:
                    TextInputType.number,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Monto solicitado',
                  prefixText: '\$ ',
                ),
              ),

              const SizedBox(
                height: 16,
              ),

              TextField(
                controller:
                    plazoController,
                keyboardType:
                    TextInputType.number,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Plazo en meses',
                ),
              ),

              const SizedBox(
                height: 16,
              ),

              TextField(
                controller:
                    tasaController,
                keyboardType:
                    TextInputType.number,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Tasa de interés %',
                ),
              ),

              const SizedBox(
                height: 24,
              ),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: calcular,
                  child: const Text(
                    'Calcular',
                  ),
                ),
              ),

              if (cuota != null) ...[
                const SizedBox(
                  height: 24,
                ),

                Card(
                  child: Padding(
                    padding:
                        const EdgeInsets.all(
                      24,
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Cuota mensual estimada',
                          style: theme
                              .textTheme
                              .titleMedium,
                        ),

                        const SizedBox(
                          height: 8,
                        ),

                        Text(
                          '\$${cuota!.toStringAsFixed(2)}',
                          style: theme
                              .textTheme
                              .headlineLarge
                              ?.copyWith(
                            color:
                                theme
                                    .colorScheme
                                    .primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// NUEVA SOLICITUD
// ============================================================

class NuevaSolicitudScreen
    extends StatefulWidget {
  const NuevaSolicitudScreen({
    super.key,
  });

  @override
  State<NuevaSolicitudScreen>
      createState() =>
          _NuevaSolicitudScreenState();
}

class _NuevaSolicitudScreenState
    extends State<NuevaSolicitudScreen> {
  final montoController =
      TextEditingController();

  final plazoController =
      TextEditingController();

  String tipo =
      'Microcrédito personal';

  @override
  void dispose() {
    montoController.dispose();
    plazoController.dispose();
    super.dispose();
  }

  void enviarSolicitud() {
    final monto =
        montoController.text.trim();

    final plazo =
        plazoController.text.trim();

    if (monto.isEmpty ||
        plazo.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Complete monto y plazo.',
          ),
        ),
      );

      return;
    }

    solicitudes.add({
      'tipo': tipo,
      'monto': monto,
      'plazo': plazo,
      'estado': 'Pendiente',
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          'Solicitud registrada correctamente.',
        ),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Nueva solicitud',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.all(24),
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                initialValue: tipo,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Tipo de financiamiento',
                ),
                items: const [
                  DropdownMenuItem(
                    value:
                        'Microcrédito personal',
                    child: Text(
                      'Microcrédito personal',
                    ),
                  ),
                  DropdownMenuItem(
                    value:
                        'Microcrédito emprendedor',
                    child: Text(
                      'Microcrédito emprendedor',
                    ),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      tipo = value;
                    });
                  }
                },
              ),

              const SizedBox(
                height: 16,
              ),

              TextField(
                controller:
                    montoController,
                keyboardType:
                    TextInputType.number,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Monto solicitado',
                  prefixText: '\$ ',
                ),
              ),

              const SizedBox(
                height: 16,
              ),

              TextField(
                controller:
                    plazoController,
                keyboardType:
                    TextInputType.number,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Plazo en meses',
                ),
              ),

              const SizedBox(
                height: 24,
              ),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed:
                      enviarSolicitud,
                  child: const Text(
                    'Enviar solicitud',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// MIS SOLICITUDES
// ============================================================

class MisSolicitudesScreen
    extends StatefulWidget {
  const MisSolicitudesScreen({
    super.key,
  });

  @override
  State<MisSolicitudesScreen>
      createState() =>
          _MisSolicitudesScreenState();
}

class _MisSolicitudesScreenState
    extends State<MisSolicitudesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mis solicitudes',
        ),
      ),
      body: solicitudes.isEmpty
          ? const Center(
              child: Text(
                'Aún no tienes solicitudes.',
              ),
            )
          : ListView.separated(
              padding:
                  const EdgeInsets.all(16),
              itemCount:
                  solicitudes.length,
              separatorBuilder:
                  (context, index) {
                return const SizedBox(
                  height: 12,
                );
              },
              itemBuilder:
                  (context, index) {
                final solicitud =
                    solicitudes[index];

                return Card(
                  child: ListTile(
                    leading:
                        const CircleAvatar(
                      child: Icon(
                        Icons.description,
                      ),
                    ),
                    title: Text(
                      solicitud['tipo'],
                    ),
                    subtitle: Text(
                      'Monto: \$${solicitud['monto']}\n'
                      'Plazo: ${solicitud['plazo']} meses',
                    ),
                    trailing: Chip(
                      avatar:
                          const Icon(
                        Icons.schedule,
                        size: 18,
                      ),
                      label: Text(
                        solicitud['estado'],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// ============================================================
// PERFIL
// ============================================================

class PerfilScreen
    extends StatelessWidget {
  const PerfilScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mi perfil',
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding:
              const EdgeInsets.all(24),
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor:
                    theme.colorScheme.primary,
                child: Icon(
                  Icons.person,
                  size: 52,
                  color:
                      theme.colorScheme.onPrimary,
                ),
              ),
            ),

            const SizedBox(
              height: 24,
            ),

            ListTile(
              leading:
                  const Icon(
                Icons.person_outline,
              ),
              title:
                  const Text('Nombre'),
              subtitle:
                  Text(usuarioNombre),
            ),

            ListTile(
              leading:
                  const Icon(
                Icons.email_outlined,
              ),
              title:
                  const Text('Correo'),
              subtitle:
                  Text(usuarioCorreo),
            ),

            ListTile(
              leading:
                  const Icon(
                Icons.phone_outlined,
              ),
              title:
                  const Text('Teléfono'),
              subtitle: Text(
                usuarioTelefono.isEmpty
                    ? 'No registrado'
                    : usuarioTelefono,
              ),
            ),
          ],
        ),
      ),
    );
  }
}