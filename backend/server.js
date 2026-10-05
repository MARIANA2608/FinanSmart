const express = require('express');
const cors = require('cors');
const crypto = require('crypto');

const app = express();

const PORT = process.env.PORT || 3000;

/*
  ============================================================
  CONFIGURACIÓN GENERAL
  ============================================================
*/

app.use(cors());
app.use(express.json());

/*
  ============================================================
  USUARIOS
  ============================================================
  
  Los usuarios se almacenan en memoria para la demostración.
  El usuario de prueba se mantiene disponible.
*/

const usuarios = [
  {
    id: 1,
    nombre: 'Mariana',
    email: 'mariana@finansmart.com',
    password: '123456',
    telefono: ''
  }
];

let siguienteUsuarioId = 2;

/*
  ============================================================
  TOKENS
  ============================================================
  
  Access token:
  90 segundos para permitir demostrar la renovación
  mediante refresh token.

  Refresh token:
  24 horas.
*/

const ACCESS_TOKEN_DURATION_MS = 90 * 1000;

const REFRESH_TOKEN_DURATION_MS =
  24 * 60 * 60 * 1000;

const accessTokens = new Map();

const refreshTokens = new Map();

/*
  ============================================================
  FINANCIAMIENTOS
  ============================================================
*/

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

/*
  ============================================================
  SOLICITUDES
  ============================================================
*/

const solicitudes = [];

/*
  ============================================================
  GENERACIÓN DE TOKENS
  ============================================================
*/

function generateToken() {
  return crypto
    .randomBytes(32)
    .toString('hex');
}

/*
  ============================================================
  CREAR ACCESS TOKEN
  ============================================================
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
  ============================================================
  CREAR REFRESH TOKEN
  ============================================================
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
  ============================================================
  MIDDLEWARE DE AUTENTICACIÓN
  ============================================================
*/

function authMiddleware(req, res, next) {

  const authorization =
    req.headers.authorization;

  if (
    !authorization ||
    !authorization.startsWith('Bearer ')
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

  req.userId =
    stored.userId;

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
      servicio: 'FinanSmart API',
      estado: 'activo'
    });

  }
);

/*
  ============================================================
  REGISTRO DE USUARIO
  ============================================================
*/

app.post(
  '/api/auth/register',
  (req, res) => {

    const {
      nombre,
      email,
      telefono,
      password
    } = req.body;

    const errors = {};

    /*
      Validación del nombre
    */

    if (
      !nombre ||
      !nombre.trim()
    ) {
      errors.nombre =
        'El nombre es obligatorio.';
    }

    /*
      Validación del correo
    */

    if (
      !email ||
      !email.trim()
    ) {
      errors.email =
        'El correo es obligatorio.';
    } else if (
      !email.includes('@')
    ) {
      errors.email =
        'Ingrese un correo electrónico válido.';
    }

    /*
      Validación de contraseña
    */

    if (
      !password ||
      !password.trim()
    ) {
      errors.password =
        'La contraseña es obligatoria.';
    } else if (
      password.trim().length < 6
    ) {
      errors.password =
        'La contraseña debe tener al menos 6 caracteres.';
    }

    /*
      Retornar errores
    */

    if (
      Object.keys(errors).length > 0
    ) {
      return res.status(422).json({
        ok: false,
        mensaje:
          'Existen campos inválidos.',
        errors
      });
    }

    /*
      Normalizar correo
    */

    const emailNormalizado =
      email.trim().toLowerCase();

    /*
      Verificar correo existente
    */

    const usuarioExistente =
      usuarios.find(
        (item) =>
          item.email.toLowerCase() ===
          emailNormalizado
      );

    if (usuarioExistente) {
      return res.status(409).json({
        ok: false,
        mensaje:
          'El correo electrónico ya está registrado.'
      });
    }

    /*
      Crear usuario
    */

    const nuevoUsuario = {
      id:
        siguienteUsuarioId++,

      nombre:
        nombre.trim(),

      email:
        emailNormalizado,

      password:
        password.trim(),

      telefono:
        telefono
          ? telefono.trim()
          : ''
    };

    usuarios.push(
      nuevoUsuario
    );

    /*
      Respuesta
    */

    return res.status(201).json({
      ok: true,
      mensaje:
        'Usuario registrado correctamente.',

      user: {
        id:
          nuevoUsuario.id,

        nombre:
          nuevoUsuario.nombre,

        email:
          nuevoUsuario.email,

        telefono:
          nuevoUsuario.telefono
      }
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

    const errors = {};

    /*
      Validación de campos
    */

    if (!email) {
      errors.email =
        'El correo es obligatorio.';
    }

    if (!password) {
      errors.password =
        'La contraseña es obligatoria.';
    }

    if (
      Object.keys(errors).length > 0
    ) {
      return res.status(422).json({
        ok: false,
        mensaje:
          'Existen campos inválidos.',
        errors
      });
    }

    /*
      Normalizar correo
    */

    const emailNormalizado =
      email.trim().toLowerCase();

    /*
      Buscar usuario
    */

    const usuario =
      usuarios.find(
        (item) =>
          item.email.toLowerCase() ===
            emailNormalizado &&
          item.password ===
            password
      );

    /*
      Credenciales incorrectas
    */

    if (!usuario) {
      return res.status(401).json({
        ok: false,
        mensaje:
          'Correo o contraseña incorrectos.'
      });
    }

    /*
      Crear tokens
    */

    const accessToken =
      createAccessToken(
        usuario.id
      );

    const refreshToken =
      createRefreshToken(
        usuario.id
      );

    /*
      Respuesta
    */

    return res.status(200).json({
      ok: true,

      mensaje:
        'Inicio de sesión correcto.',

      access_token:
        accessToken,

      refresh_token:
        refreshToken,

      expires_in: 90,

      user: {
        id:
          usuario.id,

        nombre:
          usuario.nombre,

        email:
          usuario.email,

        telefono:
          usuario.telefono
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

    /*
      Verificar expiración
    */

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

    /*
      Crear nuevo access token
    */

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

    const errors = {};

    /*
      Validar client_id
    */

    if (!client_id) {
      errors.client_id =
        'El identificador del cliente es obligatorio.';
    }

    /*
      Validar financiamiento
    */

    if (!financiamiento_id) {
      errors.financiamiento_id =
        'Seleccione un tipo de financiamiento.';
    }

    /*
      Validar monto
    */

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

    /*
      Validar plazo
    */

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
      Responder errores
    */

    if (
      Object.keys(errors).length > 0
    ) {
      return res.status(422).json({
        ok: false,
        mensaje:
          'Existen errores de validación.',
        errors
      });
    }

    /*
      Evitar solicitudes duplicadas
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

    /*
      Crear solicitud
    */

    const nuevaSolicitud = {

      id:
        solicitudes.length + 1,

      client_id:
        client_id,

      financiamiento_id:
        Number(financiamiento_id),

      monto:
        montoNumero,

      plazo_meses:
        plazoNumero,

      estado:
        'Recibida',

      actualizado_en:
        new Date().toISOString()
    };

    solicitudes.push(
      nuevaSolicitud
    );

    /*
      Respuesta
    */

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
  '0.0.0.0',
  () => {

    console.log(
      '==========================================='
    );

    console.log(
      'FinanSmart API iniciada correctamente'
    );

    console.log(
      `FinanSmart API ejecutándose en el puerto ${PORT}`
    );

    console.log(
      '==========================================='
    );

    console.log(
      'Modo de demostración activo.'
    );

    console.log(
      'Access token: 90 segundos'
    );

    console.log(
      '==========================================='
    );

  }
);