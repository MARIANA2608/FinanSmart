const express = require('express');
const cors = require('cors');

const app = express();
const PORT = 3000;

app.use(cors());
app.use(express.json());

// Datos de ejemplo del catálogo de financiamientos.
const financiamientos = [
  {
    id_tipo: 1,
    nombre: 'Microcrédito personal',
    descripcion: 'Financiamiento para necesidades personales',
    tasa_interes: 12.5,
    plazo_minimo: 3,
    plazo_maximo: 24,
    estado: 'Activo'
  },
  {
    id_tipo: 2,
    nombre: 'Microcrédito emprendedor',
    descripcion: 'Financiamiento para pequeños negocios',
    tasa_interes: 11.8,
    plazo_minimo: 6,
    plazo_maximo: 36,
    estado: 'Activo'
  }
];

// Solicitudes recibidas durante la ejecución del servidor.
// Para este taller permite demostrar sincronización e idempotencia.
const solicitudes = [];

// Verificación del estado de la API.
app.get('/api/health', (req, res) => {
  res.status(200).json({
    ok: true,
    servicio: 'FinanSmart API',
    estado: 'activo'
  });
});

// Obtener tipos de financiamiento.
app.get('/api/financiamientos', (req, res) => {
  res.status(200).json({
    ok: true,
    mensaje: 'Tipos de financiamiento obtenidos correctamente',
    data: financiamientos
  });
});

// Crear una solicitud de financiamiento.
//
// client_id es generado por la aplicación móvil.
// Sirve como clave de idempotencia para impedir duplicados
// cuando una operación offline se vuelve a enviar.
app.post('/api/solicitudes', (req, res) => {
  const {
    client_id,
    financiamiento_id,
    monto,
    plazo_meses
  } = req.body;

  if (
    !client_id ||
    !financiamiento_id ||
    !monto ||
    !plazo_meses
  ) {
    return res.status(400).json({
      ok: false,
      mensaje: 'Faltan datos obligatorios.'
    });
  }

  // Si la operación ya fue procesada, no se crea un duplicado.
  const existente = solicitudes.find(
    (solicitud) => solicitud.client_id === client_id
  );

  if (existente) {
    return res.status(200).json({
      ok: true,
      duplicado: true,
      mensaje: 'La solicitud ya había sido procesada.',
      data: existente
    });
  }

  const nuevaSolicitud = {
    id: solicitudes.length + 1,
    client_id,
    financiamiento_id: Number(financiamiento_id),
    monto: Number(monto),
    plazo_meses: Number(plazo_meses),
    estado: 'Recibida',

    // La marca temporal la asigna el servidor.
    actualizado_en: new Date().toISOString()
  };

  solicitudes.push(nuevaSolicitud);

  return res.status(201).json({
    ok: true,
    mensaje: 'Solicitud registrada correctamente.',
    data: nuevaSolicitud
  });
});

// Permite comprobar las solicitudes sincronizadas.
app.get('/api/solicitudes', (req, res) => {
  res.status(200).json({
    ok: true,
    data: solicitudes
  });
});

app.listen(PORT, () => {
  console.log(
    `FinanSmart API ejecutándose en http://localhost:${PORT}`
  );
});