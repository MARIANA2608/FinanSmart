import 'package:flutter/material.dart';

import '../database/app_database.dart';

class MisSolicitudesScreen extends StatefulWidget {
  const MisSolicitudesScreen({super.key});

  @override
  State<MisSolicitudesScreen> createState() =>
      _MisSolicitudesScreenState();
}

class _MisSolicitudesScreenState
    extends State<MisSolicitudesScreen> {
  final AppDatabase _database = AppDatabase();

  @override
  void dispose() {
    _database.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis solicitudes'),
      ),
      body: SafeArea(
        child: StreamBuilder<List<PendingOperation>>(
          stream: _database
              .select(_database.pendingOperations)
              .watch(),
          builder: (context, snapshot) {
            if (snapshot.connectionState ==
                    ConnectionState.waiting &&
                !snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'No fue posible cargar las solicitudes.',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            final solicitudes =
                snapshot.data ?? <PendingOperation>[];

            if (solicitudes.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.description_outlined,
                        size: 60,
                        color: Color(0xFF1746A2),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No tienes solicitudes registradas.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: solicitudes.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final solicitud = solicitudes[index];

                return _SolicitudCard(
                  solicitud: solicitud,
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _SolicitudCard extends StatelessWidget {
  final PendingOperation solicitud;

  const _SolicitudCard({
    required this.solicitud,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F0FF),
                borderRadius: BorderRadius.circular(21),
              ),
              child: const Icon(
                Icons.description,
                color: Color(0xFF1746A2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Microcrédito personal',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Operación: ${solicitud.operationType}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Intentos: ${solicitud.retryCount}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black26,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.access_time,
                    size: 16,
                    color: Color(0xFF1746A2),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    _estadoTexto(solicitud.syncStatus),
                    style: const TextStyle(
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _estadoTexto(String estado) {
    switch (estado.toLowerCase()) {
      case 'synced':
        return 'Enviada';
      case 'failed':
        return 'Error';
      case 'pending':
        return 'Pendiente';
      default:
        return estado;
    }
  }
}