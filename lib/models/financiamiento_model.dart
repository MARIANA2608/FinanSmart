import 'package:json_annotation/json_annotation.dart';

part 'financiamiento_model.g.dart';

@JsonSerializable()
class FinanciamientoModel {
  @JsonKey(name: 'id_tipo')
  final int id;

  @JsonKey(name: 'nombre')
  final String nombre;

  @JsonKey(name: 'descripcion')
  final String descripcion;

  @JsonKey(name: 'tasa_interes')
  final double tasaInteres;

  @JsonKey(name: 'plazo_minimo')
  final int plazoMinimo;

  @JsonKey(name: 'plazo_maximo')
  final int plazoMaximo;

  @JsonKey(name: 'estado')
  final String estado;

  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  const FinanciamientoModel({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.tasaInteres,
    required this.plazoMinimo,
    required this.plazoMaximo,
    required this.estado,
    this.updatedAt,
  });

  factory FinanciamientoModel.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$FinanciamientoModelFromJson(json);

  Map<String, dynamic> toJson() =>
      _$FinanciamientoModelToJson(this);
}