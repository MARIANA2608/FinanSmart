const express = require('express');
const cors = require('cors');

const app = express();
const PORT = 3000;

app.use(cors());
app.use(express.json());

app.get('/api/health', (req, res) => {
  res.status(200).json({
    ok: true,
    servicio: 'FinanSmart API',
    estado: 'activo'
  });
});

app.get('/api/financiamientos', (req, res) => {
  res.status(200).json({
    ok: true,
    mensaje: 'Tipos de financiamiento obtenidos correctamente',
    data: [
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
    ]
  });
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`FinanSmart API ejecutándose en http://localhost:${PORT}`);
});