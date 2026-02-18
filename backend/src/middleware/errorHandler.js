export function errorHandler(err, req, res, next) {
  console.error('❌ Error:', err);

  // Error de validación de entrada
  if (err.name === 'ValidationError') {
    return res.status(400).json({
      success: false,
      error: err.message,
      codigo: 'VALIDATION_ERROR',
    });
  }

  // Error de no encontrado
  if (err.status === 404) {
    return res.status(404).json({
      success: false,
      error: err.message || 'Recurso no encontrado',
      codigo: 'NO_ENCONTRADO',
    });
  }

  // Error de no autorizado
  if (err.status === 401) {
    return res.status(401).json({
      success: false,
      error: err.message || 'No autorizado',
      codigo: 'NO_AUTORIZADO',
    });
  }

  // Error de base de datos
  if (err.code && err.code.startsWith('ECONNREFUSED')) {
    return res.status(503).json({
      success: false,
      error: 'Error de conexión a la base de datos',
      codigo: 'DB_CONNECTION_ERROR',
    });
  }

  // Error de duplicado (unique constraint)
  if (err.code === '23505') {
    return res.status(400).json({
      success: false,
      error: 'El registro ya existe (violación de restricción única)',
      codigo: 'DUPLICATE_ENTRY',
    });
  }

  // Error genérico
  return res.status(err.status || 500).json({
    success: false,
    error: err.message || 'Error interno del servidor',
    codigo: err.codigo || 'INTERNAL_SERVER_ERROR',
  });
}

export default errorHandler;
