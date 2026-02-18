import jwt from 'jsonwebtoken';
import dotenv from 'dotenv';

dotenv.config();

export function verificarJWT(req, res, next) {
  try {
    const token = req.headers.authorization?.split(' ')[1];

    if (!token) {
      return res.status(401).json({
        success: false,
        error: 'Token no proporcionado',
        codigo: 'SIN_TOKEN',
      });
    }

    const secret = process.env.JWT_ACCESS_SECRET || process.env.JWT_SECRET || 'cambiar-en-produccion';
    const decoded = jwt.verify(token, secret);
    req.usuarioId = decoded.usuarioId;
    req.usuario = decoded;
    next();
  } catch (error) {
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({
        success: false,
        error: 'Token expirado',
        codigo: 'TOKEN_EXPIRADO',
      });
    }

    return res.status(401).json({
      success: false,
      error: 'Token inválido',
      codigo: 'TOKEN_INVALIDO',
    });
  }
}

export function generarJWT(usuarioId, email) {
  const secret = process.env.JWT_ACCESS_SECRET || process.env.JWT_SECRET || 'cambiar-en-produccion';
  return jwt.sign(
    { usuarioId, email },
    secret,
    { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
  );
}

export default verificarJWT;
