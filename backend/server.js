const express = require('express');
const cors = require('cors');
const crypto = require('crypto');

const app = express();
const PORT = 3000;

app.use(cors());
app.use(express.json());

/*
  Usuario de demostración para Semana 13.
  Las credenciales están únicamente en el backend
  para fines académicos y de prueba.
*/
const usuarioDemo = {
  id: 1,
  nombre: 'Mariana',
  email: 'mariana@finansmart.com',
  password: '123456'
};

/*
  El access token dura 90 segundos
  para poder demostrar en el video
  la renovación automática del token.
*/
const ACCESS_TOKEN_DURATION_MS =
  90 * 1000;

const REFRESH_TOKEN_DURATION_MS =
  24 * 60 * 60 * 1000;

const accessTokens = new Map();
const refreshTokens = new Map();

const financiamientos = [
  {
    id_tipo: 1,
    nombre: 'Microcrédito personal',
    descripcion:
      'Financiamiento para necesidades personales',
    tasa_interes: 12.5,
    plazo_minimo: 3,
    plazo_maximo: 24,
    estado: 'Activo',
    updated_at:
      new Date().toISOString()
  },
  {
    id_tipo: 2,
    nombre: 'Microcrédito emprendedor',
    descripcion:
      'Financiamiento para pequeños negocios',
    tasa_interes: 11.8,
    plazo_minimo: 6,
    plazo_maximo: 36,
    estado: 'Activo',
    updated_at:
      new Date().toISOString()
  }
];

const solicitudes = [];

/*
  Genera tokens aleatorios seguros.
*/
function generateToken() {
  return crypto
    .randomBytes(32)
    .toString('hex');
}

/*
  Crea access token.
*/
function createAccessToken(userId) {
  const token = generateToken();

  accessTokens.set(token, {
    userId,
    expiresAt:
      Date.now() +
      ACCESS_TOKEN_DURATION_MS
  });

  return token;
}

/*
  Crea refresh token.
*/
function createRefreshToken(userId) {
  const token = generateToken();

  refreshTokens.set(token, {
    userId,
    expiresAt:
      Date.now() +
      REFRESH_TOKEN_DURATION_MS
  });

  return token;
}

/*
  Middleware de autenticación.
*/
function authMiddleware(
  req,
  res,
  next
) {
  const authorization =
    req.headers.authorization;

  if (
    !authorization ||
    !authorization.startsWith(
      'Bearer '
    )
  ) {
    return res.status(401).json({
      ok: false,
      mensaje:
        'Token de acceso requerido.'
    });
  }

  const token =
    authorization.substring(7);

  const stored =
    accessTokens.get(token);

  if (!stored) {
    return res.status(401).json({
      ok: false,
      mensaje:
        'Token inválido.'
    });
  }

  if (
    Date.now() >
    stored.expiresAt
  ) {
    accessTokens.delete(token);

    return res.status(401).json({
      ok: false,
      mensaje:
        'Token expirado.'
    });
  }

  req.userId = stored.userId;

  next();
}

/*
  ============================================================
  HEALTH CHECK
  ============================================================
*/
app.get(
  '/api/health',
  (req, res) => {
    return res.status(200).json({
      ok: true,
      servicio:
        'FinanSmart API',
      estado: 'activo'
    });
  }
);

/*
  ============================================================
  LOGIN
  ============================================================
*/
app.post(
  '/api/auth/login',
  (req, res) => {
    const {
      email,
      password
    } = req.body;

    /*
      Errores asociados a campos.
      Esto permite demostrar HTTP 422.
    */
    const errors = {};

    if (!email) {
      errors.email =
        'El correo es obligatorio.';
    }

    if (!password) {
      errors.password =
        'La contraseña es obligatoria.';
    }

    if (
      Object.keys(errors).length >
      0
    ) {
      return res.status(422).json({
        ok: false,
        mensaje:
          'Existen campos inválidos.',
        errors
      });
    }

    if (
      email !== usuarioDemo.email ||
      password !==
        usuarioDemo.password
    ) {
      return res.status(401).json({
        ok: false,
        mensaje:
          'Correo o contraseña incorrectos.'
      });
    }

    const accessToken =
      createAccessToken(
        usuarioDemo.id
      );

    const refreshToken =
      createRefreshToken(
        usuarioDemo.id
      );

    return res.status(200).json({
      ok: true,
      mensaje:
        'Inicio de sesión correcto.',

      access_token:
        accessToken,

      refresh_token:
        refreshToken,

      /*
        Duración expresada
        en segundos.
      */
      expires_in: 90,

      user: {
        id:
          usuarioDemo.id,

        nombre:
          usuarioDemo.nombre,

        email:
          usuarioDemo.email
      }
    });
  }
);

/*
  ============================================================
  REFRESH TOKEN
  ============================================================
*/
app.post(
  '/api/auth/refresh',
  (req, res) => {
    const refreshToken =
      req.body.refresh_token;

    if (!refreshToken) {
      return res.status(401).json({
        ok: false,
        mensaje:
          'Refresh token requerido.'
      });
    }

    const stored =
      refreshTokens.get(
        refreshToken
      );

    if (!stored) {
      return res.status(401).json({
        ok: false,
        mensaje:
          'Refresh token inválido.'
      });
    }

    if (
      Date.now() >
      stored.expiresAt
    ) {
      refreshTokens.delete(
        refreshToken
      );

      return res.status(401).json({
        ok: false,
        mensaje:
          'Refresh token expirado.'
      });
    }

    const newAccessToken =
      createAccessToken(
        stored.userId
      );

    return res.status(200).json({
      ok: true,

      access_token:
        newAccessToken,

      expires_in: 90
    });
  }
);

/*
  ============================================================
  CATÁLOGO DE FINANCIAMIENTOS
  ============================================================
*/
app.get(
  '/api/financiamientos',
  authMiddleware,
  (req, res) => {
    return res.status(200).json({
      ok: true,

      mensaje:
        'Tipos de financiamiento obtenidos correctamente',

      data:
        financiamientos
    });
  }
);

/*
  ============================================================
  CREAR SOLICITUD
  ============================================================
*/
app.post(
  '/api/solicitudes',
  authMiddleware,
  (req, res) => {
    const {
      client_id,
      financiamiento_id,
      monto,
      plazo_meses
    } = req.body;

    /*
      Errores de validación
      asociados a cada campo.
    */
    const errors = {};

    if (!client_id) {
      errors.client_id =
        'El identificador del cliente es obligatorio.';
    }

    if (!financiamiento_id) {
      errors.financiamiento_id =
        'Seleccione un tipo de financiamiento.';
    }

    const montoNumero =
      Number(monto);

    if (
      !monto ||
      Number.isNaN(montoNumero) ||
      montoNumero <= 0
    ) {
      errors.monto =
        'Ingrese un monto mayor a cero.';
    }

    const plazoNumero =
      Number(plazo_meses);

    if (
      !plazo_meses ||
      Number.isNaN(plazoNumero) ||
      plazoNumero <= 0
    ) {
      errors.plazo_meses =
        'Ingrese un plazo válido.';
    }

    /*
      HTTP 422 con errores
      asociados a los campos.
    */
    if (
      Object.keys(errors).length >
      0
    ) {
      return res.status(422).json({
        ok: false,

        mensaje:
          'Existen errores de validación.',

        errors
      });
    }

    /*
      Idempotencia mediante client_id.
      Evita crear solicitudes duplicadas.
    */
    const existente =
      solicitudes.find(
        (solicitud) =>
          solicitud.client_id ===
          client_id
      );

    if (existente) {
      return res.status(200).json({
        ok: true,

        duplicado: true,

        mensaje:
          'La solicitud ya había sido procesada.',

        data:
          existente
      });
    }

    const nuevaSolicitud = {
      id:
        solicitudes.length + 1,

      client_id,

      financiamiento_id:
        Number(
          financiamiento_id
        ),

      monto:
        montoNumero,

      plazo_meses:
        plazoNumero,

      estado:
        'Recibida',

      /*
        Marca temporal generada
        por el servidor.
      */
      actualizado_en:
        new Date().toISOString()
    };

    solicitudes.push(
      nuevaSolicitud
    );

    return res.status(201).json({
      ok: true,

      mensaje:
        'Solicitud registrada correctamente.',

      data:
        nuevaSolicitud
    });
  }
);

/*
  ============================================================
  LISTAR SOLICITUDES
  ============================================================
*/
app.get(
  '/api/solicitudes',
  authMiddleware,
  (req, res) => {
    return res.status(200).json({
      ok: true,
      data:
        solicitudes
    });
  }
);

/*
  ============================================================
  INICIAR SERVIDOR
  ============================================================
*/
app.listen(
  PORT,
  () => {
    console.log(
      '==========================================='
    );

    console.log(
      'FinanSmart API iniciada correctamente'
    );

    console.log(
      `Servidor: http://localhost:${PORT}`
    );

    console.log(
      '==========================================='
    );

    console.log(
      'Usuario Semana 13:'
    );

    console.log(
      'mariana@finansmart.com'
    );

    console.log(
      'Contraseña: 123456'
    );

    console.log(
      'Access token: 90 segundos'
    );

    console.log(
      '==========================================='
    );
  }
);