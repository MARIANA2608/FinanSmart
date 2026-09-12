// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'solicitud_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SolicitudModel _$SolicitudModelFromJson(Map<String, dynamic> json) =>
    SolicitudModel(
      id: (json['id'] as num?)?.toInt(),
      clientId: json['client_id'] as String,
      financiamientoId: (json['financiamiento_id'] as num).toInt(),
      monto: (json['monto'] as num).toDouble(),
      plazoMeses: (json['plazo_meses'] as num).toInt(),
      estado: json['estado'] as String?,
      actualizadoEn: json['actualizado_en'] as String?,
    );

Map<String, dynamic> _$SolicitudModelToJson(SolicitudModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'client_id': instance.clientId,
      'financiamiento_id': instance.financiamientoId,
      'monto': instance.monto,
      'plazo_meses': instance.plazoMeses,
      'estado': instance.estado,
      'actualizado_en': instance.actualizadoEn,
    };
