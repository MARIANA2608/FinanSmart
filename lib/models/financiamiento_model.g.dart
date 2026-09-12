// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'financiamiento_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FinanciamientoModel _$FinanciamientoModelFromJson(Map<String, dynamic> json) =>
    FinanciamientoModel(
      id: (json['id_tipo'] as num).toInt(),
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String,
      tasaInteres: (json['tasa_interes'] as num).toDouble(),
      plazoMinimo: (json['plazo_minimo'] as num).toInt(),
      plazoMaximo: (json['plazo_maximo'] as num).toInt(),
      estado: json['estado'] as String,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$FinanciamientoModelToJson(
  FinanciamientoModel instance,
) => <String, dynamic>{
  'id_tipo': instance.id,
  'nombre': instance.nombre,
  'descripcion': instance.descripcion,
  'tasa_interes': instance.tasaInteres,
  'plazo_minimo': instance.plazoMinimo,
  'plazo_maximo': instance.plazoMaximo,
  'estado': instance.estado,
  'updated_at': instance.updatedAt,
};
