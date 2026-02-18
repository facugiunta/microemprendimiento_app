export function validarRegistro(req, res, next) {
  const { nombre, email, password } = req.body;

  if (!nombre || !email || !password) {
    return res.status(400).json({
      success: false,
      error: 'Nombre, email y contraseña son requeridos',
      codigo: 'CAMPOS_REQUERIDOS',
    });
  }

  if (email.length < 5 || !email.includes('@')) {
    return res.status(400).json({
      success: false,
      error: 'Email inválido',
      codigo: 'EMAIL_INVALIDO',
    });
  }

  if (password.length < 6) {
    return res.status(400).json({
      success: false,
      error: 'La contraseña debe tener al menos 6 caracteres',
      codigo: 'PASSWORD_CORTA',
    });
  }

  next();
}

export function validarLogin(req, res, next) {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({
      success: false,
      error: 'Email y contraseña son requeridos',
      codigo: 'CAMPOS_REQUERIDOS',
    });
  }

  next();
}

export function validarProducto(req, res, next) {
  const { nombre, precio_compra, precio_venta } = req.body;

  if (!nombre) {
    return res.status(400).json({
      success: false,
      error: 'El nombre del producto es requerido',
      codigo: 'NOMBRE_REQUERIDO',
    });
  }

  if (precio_compra === undefined || precio_venta === undefined) {
    return res.status(400).json({
      success: false,
      error: 'Precios de compra y venta son requeridos',
      codigo: 'PRECIOS_REQUERIDOS',
    });
  }

  next();
}

export function validarCompra(req, res, next) {
  const { producto_id, cantidad, precio_unitario } = req.body;

  if (!producto_id || !cantidad || !precio_unitario) {
    return res.status(400).json({
      success: false,
      error: 'producto_id, cantidad y precio_unitario son requeridos',
      codigo: 'CAMPOS_REQUERIDOS',
    });
  }

  if (cantidad <= 0) {
    return res.status(400).json({
      success: false,
      error: 'La cantidad debe ser mayor a 0',
      codigo: 'CANTIDAD_INVALIDA',
    });
  }

  next();
}

export function validarVenta(req, res, next) {
  const { producto_id, cantidad, precio_unitario } = req.body;

  if (!producto_id || !cantidad || !precio_unitario) {
    return res.status(400).json({
      success: false,
      error: 'producto_id, cantidad y precio_unitario son requeridos',
      codigo: 'CAMPOS_REQUERIDOS',
    });
  }

  if (cantidad <= 0) {
    return res.status(400).json({
      success: false,
      error: 'La cantidad debe ser mayor a 0',
      codigo: 'CANTIDAD_INVALIDA',
    });
  }

  next();
}

export function validarInversion(req, res, next) {
  const { nombre, monto } = req.body;

  if (!nombre || !monto) {
    return res.status(400).json({
      success: false,
      error: 'Nombre y monto son requeridos',
      codigo: 'CAMPOS_REQUERIDOS',
    });
  }

  if (monto <= 0) {
    return res.status(400).json({
      success: false,
      error: 'El monto debe ser mayor a 0',
      codigo: 'MONTO_INVALIDO',
    });
  }

  next();
}

export function validarReporteFeria(req, res, next) {
  const { nombre_feria, fecha_feria, productos_vendidos } = req.body;

  if (!nombre_feria || !fecha_feria || !Array.isArray(productos_vendidos) || productos_vendidos.length === 0) {
    return res.status(400).json({
      success: false,
      error: 'nombre_feria, fecha_feria y productos_vendidos son requeridos',
      codigo: 'CAMPOS_REQUERIDOS',
    });
  }

  next();
}

export default {
  validarRegistro,
  validarLogin,
  validarProducto,
  validarCompra,
  validarVenta,
  validarInversion,
  validarReporteFeria,
};
