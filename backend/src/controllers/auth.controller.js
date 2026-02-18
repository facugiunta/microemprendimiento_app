import bcrypt from 'bcryptjs';
import pool from '../config/database.js';
import { generarJWT } from '../middleware/auth.js';
import { registrarAuditoria } from '../utils/auditLogger.js';

export async function registrarse(req, res) {
  try {
    const { nombre, email, password } = req.body;

    // Verificar si el email ya existe
    const usuarioExistente = await pool.query('SELECT id FROM usuarios WHERE email = $1', [email]);

    if (usuarioExistente.rows.length > 0) {
      return res.status(400).json({
        success: false,
        error: 'El email ya está registrado',
        codigo: 'EMAIL_DUPLICADO',
      });
    }

    // Hashear contraseña
    const passwordHash = await bcrypt.hash(password, 10);

    // Crear usuario
    const resultado = await pool.query(
      'INSERT INTO usuarios (nombre, email, password_hash) VALUES ($1, $2, $3) RETURNING id, nombre, email, created_at',
      [nombre, email, passwordHash]
    );

    const usuario = resultado.rows[0];

    // Registrar auditoría
    await registrarAuditoria({
      usuarioId: usuario.id,
      accion: 'LOGIN',
      entidad: 'usuario',
      entidadId: usuario.id,
      datosNuevos: { email },
      descripcion: 'Usuario registrado',
    });

    const token = generarJWT(usuario.id, usuario.email);

    res.status(201).json({
      success: true,
      data: {
        id: usuario.id,
        nombre: usuario.nombre,
        email: usuario.email,
        token,
      },
      mensaje: 'Usuario registrado exitosamente',
    });
  } catch (error) {
    console.error('❌ Error en registro:', error.message);
    res.status(500).json({
      success: false,
      error: 'Error al registrar usuario',
      codigo: 'REGISTRO_ERROR',
    });
  }
}

export async function login(req, res) {
  try {
    const { email, password } = req.body;

    // Buscar usuario
    const resultado = await pool.query('SELECT id, nombre, email, password_hash FROM usuarios WHERE email = $1', [email]);

    if (resultado.rows.length === 0) {
      return res.status(401).json({
        success: false,
        error: 'Email o contraseña inválidos',
        codigo: 'CREDENCIALES_INVALIDAS',
      });
    }

    const usuario = resultado.rows[0];

    // Verificar contraseña
    const passwordValida = await bcrypt.compare(password, usuario.password_hash);

    if (!passwordValida) {
      return res.status(401).json({
        success: false,
        error: 'Email o contraseña inválidos',
        codigo: 'CREDENCIALES_INVALIDAS',
      });
    }

    // Registrar auditoría
    await registrarAuditoria({
      usuarioId: usuario.id,
      accion: 'LOGIN',
      entidad: 'usuario',
      entidadId: usuario.id,
      ip: req.ip,
      descripcion: 'Usuario inició sesión',
    });

    const token = generarJWT(usuario.id, usuario.email);

    res.json({
      success: true,
      data: {
        id: usuario.id,
        nombre: usuario.nombre,
        email: usuario.email,
        token,
      },
      mensaje: 'Sesión iniciada exitosamente',
    });
  } catch (error) {
    console.error('❌ Error en login:', error.message);
    res.status(500).json({
      success: false,
      error: 'Error al iniciar sesión',
      codigo: 'LOGIN_ERROR',
    });
  }
}

export async function obtenerUsuario(req, res) {
  try {
    const usuarioId = req.usuarioId;

    const resultado = await pool.query('SELECT id, nombre, email, created_at FROM usuarios WHERE id = $1', [usuarioId]);

    if (resultado.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'Usuario no encontrado',
        codigo: 'USUARIO_NO_ENCONTRADO',
      });
    }

    const usuario = resultado.rows[0];

    res.json({
      success: true,
      data: usuario,
    });
  } catch (error) {
    console.error('❌ Error obteniendo usuario:', error.message);
    res.status(500).json({
      success: false,
      error: 'Error al obtener usuario',
      codigo: 'GET_USER_ERROR',
    });
  }
}

export default {
  registrarse,
  login,
  obtenerUsuario,
};
