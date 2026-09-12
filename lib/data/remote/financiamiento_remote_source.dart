import 'package:dio/dio.dart';

import '../../models/financiamiento_model.dart';
import '../../services/api_service.dart';

class FinanciamientoRemoteSource {
  const FinanciamientoRemoteSource();

  Future<List<FinanciamientoModel>> obtenerFinanciamientos({
    CancelToken? cancelToken,
  }) async {
    final response =
        await ApiService.obtenerFinanciamientos(
      cancelToken: cancelToken,
    );

    final rawData = response['data'];

    if (rawData is! List) {
      return <FinanciamientoModel>[];
    }

    final financiamientos =
        <FinanciamientoModel>[];

    for (final item in rawData) {
      if (item is Map) {
        financiamientos.add(
          FinanciamientoModel.fromJson(
            Map<String, dynamic>.from(
              item,
            ),
          ),
        );
      }
    }

    return financiamientos;
  }
}