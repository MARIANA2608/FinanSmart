import 'package:flutter/material.dart';

import 'database/app_database.dart';
import 'screens/financiamientos_screen.dart';
import 'screens/mis_solicitudes_screen.dart'
    as offline_solicitudes;
import 'screens/nueva_solicitud_screen.dart'
    as offline_nueva;
import 'services/api_client.dart';
import 'services/api_service.dart';
import 'services/secure_storage_service.dart';
import 'services/sync_service.dart';
import 'theme/app_theme.dart';

// ============================================================
// BASE DE DATOS ÚNICA DE LA APLICACIÓN
// ============================================================

final AppDatabase appDatabase = AppDatabase();

final SyncService syncService = SyncService(
  database: appDatabase,
);

// ============================================================
// DATOS DEL USUARIO
// ============================================================

String usuarioNombre = 'Usuario FinanSmart';
String usuarioCorreo = 'usuario@finansmart.com';
String usuarioTelefono = '0999999999';

// ============================================================
// INICIO DE LA APLICACIÓN
// ============================================================

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cliente HTTP centralizado de Semana 13.
  ApiClient.instance.initialize();

  // Recupera la sesión almacenada de forma segura.
  final tieneSesion =
      await SecureStorageService.hasSession();

  final nombreGuardado =
      await SecureStorageService.getUserName();

  final correoGuardado =
      await SecureStorageService.getUserEmail();

  if (nombreGuardado != null &&
      nombreGuardado.isNotEmpty) {
    usuarioNombre = nombreGuardado;
  }

  if (correoGuardado != null &&
      correoGuardado.isNotEmpty) {
    usuarioCorreo = correoGuardado;
  }

  runApp(
    FinanSmartApp(
      sesionActiva: tieneSesion,
    ),
  );

  // Inicia la sincronización de operaciones offline.
  await syncService.startMonitoring();
}

// ============================================================
// APLICACIÓN
// ============================================================

class FinanSmartApp extends StatelessWidget {
  final bool sesionActiva;

  const FinanSmartApp({
    super.key,
    required this.sesionActiva,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FinanSmart',
      theme: AppTheme.light,
      home: sesionActiva
          ? const MenuPrincipalScreen()
          : const InicioScreen(),
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
                            FinanciamientosScreen(
                          database:
                              appDatabase,
                        ),
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
  final TextEditingController correoController =
      TextEditingController();

  final TextEditingController claveController =
      TextEditingController();

  bool ocultarClave = true;
  bool iniciandoSesion = false;

  @override
  void dispose() {
    correoController.dispose();
    claveController.dispose();
    super.dispose();
  }

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
            'Ingrese correo y contraseña.',
          ),
        ),
      );

      return;
    }

    setState(() {
      iniciandoSesion = true;
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
          accessToken.isEmpty ||
          refreshToken == null ||
          refreshToken.isEmpty) {
        throw Exception(
          'El servidor no devolvió '
          'las credenciales de sesión.',
        );
      }

      await SecureStorageService.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );

      final user = response['user'];

      if (user is Map) {
        final id =
            user['id']?.toString() ?? '';

        final nombre =
            user['nombre']?.toString() ??
                'Usuario FinanSmart';

        final email =
            user['email']?.toString();

        await SecureStorageService.saveUser(
          id: id,
          name: nombre,
          email: email,
        );

        usuarioNombre = nombre;

        if (email != null &&
            email.isNotEmpty) {
          usuarioCorreo = email;
        }
      }

      if (!mounted) {
        return;
      }

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const MenuPrincipalScreen(),
        ),
        (route) => false,
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
          iniciandoSesion = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme =
        Theme.of(context);

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
                textAlign:
                    TextAlign.center,
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
                width:
                    double.infinity,
                child: FilledButton(
                  onPressed:
                      iniciandoSesion
                          ? null
                          : iniciarSesion,
                  child: Text(
                    iniciandoSesion
                        ? 'Iniciando...'
                        : 'Ingresar',
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                'Usuario de prueba Semana 13',
                style:
                    theme.textTheme.titleMedium,
              ),
              const SizedBox(
                height: 8,
              ),
              const Text(
                'mariana@finansmart.com',
              ),
              const Text(
                'Contraseña: 123456',
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

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({
    super.key,
  });

  @override
  State<RegistroScreen> createState() =>
      _RegistroScreenState();
}

class _RegistroScreenState
    extends State<RegistroScreen> {
  final TextEditingController nombreController =
      TextEditingController();

  final TextEditingController correoController =
      TextEditingController();

  final TextEditingController telefonoController =
      TextEditingController();

  final TextEditingController claveController =
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
                width:
                    double.infinity,
                child: FilledButton(
                  onPressed:
                      registrar,
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

class MenuPrincipalScreen extends StatefulWidget {
  const MenuPrincipalScreen({
    super.key,
  });

  @override
  State<MenuPrincipalScreen> createState() =>
      _MenuPrincipalScreenState();
}

class _MenuPrincipalScreenState
    extends State<MenuPrincipalScreen> {
  bool cerrandoSesion = false;

  Future<void> cerrarSesion() async {
    setState(() {
      cerrandoSesion = true;
    });

    try {
      await SecureStorageService.clearSession();

      await appDatabase.clearAllData();

      if (!mounted) {
        return;
      }

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const InicioScreen(),
        ),
        (route) => false,
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'No fue posible cerrar '
            'la sesión correctamente.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          cerrandoSesion = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme =
        Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'FinanSmart',
        ),
        actions: [
          IconButton(
            tooltip:
                'Cerrar sesión',
            onPressed:
                cerrandoSesion
                    ? null
                    : cerrarSesion,
            icon: cerrandoSesion
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child:
                        CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(
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
                    // ============================================
                    // NUEVA SOLICITUD
                    // ============================================

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
                                offline_nueva
                                    .NuevaSolicitudScreen(
                              database:
                                  appDatabase,
                            ),
                          ),
                        );
                      },
                    ),

                    // ============================================
                    // MIS SOLICITUDES
                    // ============================================

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
                                offline_solicitudes
                                    .MisSolicitudesScreen(
                              database:
                                  appDatabase,
                            ),
                          ),
                        );
                      },
                    ),

                    // ============================================
                    // SIMULADOR
                    // ============================================

                    _MenuCard(
                      icon:
                          Icons.calculate_outlined,
                      label:
                          'Simulador',
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

                    // ============================================
                    // FINANCIAMIENTOS
                    // ============================================

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
                                FinanciamientosScreen(
                              database:
                                  appDatabase,
                            ),
                          ),
                        );
                      },
                    ),

                    // ============================================
                    // MI PERFIL
                    // ============================================

                    _MenuCard(
                      icon:
                          Icons.person_outline,
                      label:
                          'Mi perfil',
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

// ============================================================
// TARJETA DEL MENÚ
// ============================================================

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
    final theme =
        Theme.of(context);

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

class SimuladorScreen extends StatefulWidget {
  const SimuladorScreen({
    super.key,
  });

  @override
  State<SimuladorScreen> createState() =>
      _SimuladorScreenState();
}

class _SimuladorScreenState
    extends State<SimuladorScreen> {
  final TextEditingController montoController =
      TextEditingController();

  final TextEditingController plazoController =
      TextEditingController();

  final TextEditingController tasaController =
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
    final monto =
        double.tryParse(
      montoController.text,
    );

    final plazo =
        int.tryParse(
      plazoController.text,
    );

    final tasa =
        double.tryParse(
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
      cuota =
          total / plazo;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme =
        Theme.of(context);

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
                  prefixText:
                      '\$ ',
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
                width:
                    double.infinity,
                child: FilledButton(
                  onPressed:
                      calcular,
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
                            color: theme
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
// PERFIL
// ============================================================

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme =
        Theme.of(context);

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
                  const Text(
                'Nombre',
              ),
              subtitle:
                  Text(
                usuarioNombre,
              ),
            ),
            ListTile(
              leading:
                  const Icon(
                Icons.email_outlined,
              ),
              title:
                  const Text(
                'Correo',
              ),
              subtitle:
                  Text(
                usuarioCorreo,
              ),
            ),
            ListTile(
              leading:
                  const Icon(
                Icons.phone_outlined,
              ),
              title:
                  const Text(
                'Teléfono',
              ),
              subtitle:
                  Text(
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