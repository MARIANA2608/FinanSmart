import 'package:json_annotation/json_annotation.dart';

part 'solicitud_model.g.dart';

@JsonSerializable()
class SolicitudModel {
  final int? id;

  @JsonKey(name: 'client_id')
  final String clientId;

  @JsonKey(name: 'financiamiento_id')
  final int financiamientoId;

  final double monto;

  @JsonKey(name: 'plazo_meses')
  final int plazoMeses;

  final String? estado;

  @JsonKey(name: 'actualizado_en')
  final String? actualizadoEn;

  const SolicitudModel({
    this.id,
    required this.clientId,
    required this.financiamientoId,
    required this.monto,
    required this.plazoMeses,
    this.estado,
    this.actualizadoEn,
  });

  factory SolicitudModel.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$SolicitudModelFromJson(
        json,
      );

  Map<String, dynamic> toJson() =>
      _$SolicitudModelToJson(
        this,
      );
}