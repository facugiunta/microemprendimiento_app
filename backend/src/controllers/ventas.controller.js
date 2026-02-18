import pool from '../config/database.js';
import { safeDel } from '../config/redis.js';
import { registrarAuditoria } from '../utils/auditLogger.js';

export async function listarVentas(req, res) {
  try {
    const usuarioId = req.usuarioId;
    const { pagina = 1, limite = 20, fecha_desde, fecha_hasta, mes, anio, producto_id } = req.query;
    const offset = (pagina - 1) * limite;

    let query = `
      SELECT v.id, v.producto_id, p.nombre as nombre_producto, v.cantidad, v.precio_unitario, v.total, v.nota, v.fecha, v.created_at
      FROM ventas v
      LEFT JOIN productos p ON v.producto_id = p.id
      WHERE v.usuario_id = $1
    `;
    const params = [usuarioId];

    let paramIndex = 2;

    if (fecha_desde) {
      query += ` AND v.fecha >= $${paramIndex}`;
      params.push(fecha_desde);
      paramIndex++;
    }

    if (fecha_hasta) {
      query += ` AND v.fecha <= $${paramIndex}`;
      params.push(fecha_hasta);
      paramIndex++;
    }

    if (mes && anio) {
      query += ` AND EXTRACT(MONTH FROM v.fecha) = $${paramIndex} AND EXTRACT(YEAR FROM v.fecha) = $${paramIndex + 1}`;
      params.push(mes, anio);
      paramIndex += 2;
    }

    if (producto_id) {
      query += ` AND v.producto_id = $${paramIndex}`;
      params.push(producto_id);
      paramIndex++;
    }

    query += ` ORDER BY v.fecha DESC LIMIT $${paramIndex} OFFSET $${paramIndex + 1}`;
    params.push(limite, offset);

    const resultado = await pool.query(query, params);

    // Contar total
    let countQuery = 'SELECT COUNT(*) as total FROM ventas WHERE usuario_id = $1';
    const countParams = [usuarioId];

    if (fecha_desde) {
      countQuery += ` AND fecha >= $${countParams.length + 1}`;
      countParams.push(fecha_desde);
    }

    if (fecha_hasta) {
      countQuery += ` AND fecha <= $${countParams.length + 1}`;
      countParams.push(fecha_hasta);
    }

    if (mes && anio) {
      countQuery += ` AND EXTRACT(MONTH FROM fecha) = $${countParams.length + 1} AND EXTRACT(YEAR FROM fecha) = $${countParams.length + 2}`;
      countParams.push(mes, anio);
    }

    if (producto_id) {
      countQuery += ` AND producto_id = $${countParams.length + 1}`;
      countParams.push(producto_id);
    }

    const totalResultado = await pool.query(countQuery, countParams);
    const totalRegistros = parseInt(totalResultado.rows[0].total);
    const totalPaginas = Math.ceil(totalRegistros / limite);

    res.json({
      success: true,
      data: resultado.rows,
      paginacion: {
        pagina_actual: parseInt(pagina),
        total_paginas: totalPaginas,
        total_registros: totalRegistros,
        limite: parseInt(limite),
      },
    });
  } catch (error) {
    console.error('❌ Error listando ventas:', error.message);
    res.status(500).json({
      success: false,
      error: 'Error al listar ventas',
      codigo: 'LIST_SALES_ERROR',
    });
  }
}

export async function obtenerVenta(req, res) {
  try {
    const usuarioId = req.usuarioId;
    const { id } = req.params;

    const resultado = await pool.query(
      `SELECT v.id, v.producto_id, p.nombre as nombre_producto, v.cantidad, v.precio_unitario, v.total, v.nota, v.fecha, v.created_at
       FROM ventas v
       LEFT JOIN productos p ON v.producto_id = p.id
       WHERE v.id = $1 AND v.usuario_id = $2`,
      [id, usuarioId]
    );

    if (resultado.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'Venta no encontrada',
        codigo: 'VENTA_NO_ENCONTRADA',
      });
    }

    res.json({
      success: true,
      data: resultado.rows[0],
    });
  } catch (error) {
    console.error('❌ Error obteniendo venta:', error.message);
    res.status(500).json({
      success: false,
      error: 'Error al obtener venta',
      codigo: 'GET_SALE_ERROR',
    });
  }
}

export async function crearVenta(req, res) {
  const client = await pool.connect();

  try {
    await client.query('BEGIN');

    const usuarioId = req.usuarioId;
    const { producto_id, cantidad, precio_unitario, nota } = req.body;

    // Obtener producto
    const productoResultado = await client.query('SELECT id, nombre, stock, stock_minimo FROM productos WHERE id = $1 AND usuario_id = $2', [
      producto_id,
      usuarioId,
    ]);

    if (productoResultado.rows.length === 0) {
      await client.query('ROLLBACK');
      return res.status(404).json({
        success: false,
        error: 'Producto no encontrado',
        codigo: 'PRODUCTO_NO_ENCONTRADO',
      });
    }

    const producto = productoResultado.rows[0];

    // Validar stock
    if (cantidad > producto.stock) {
      await client.query('ROLLBACK');
      return res.status(400).json({
        success: false,
        error: `Stock insuficiente. Stock disponible: ${producto.stock}`,
        codigo: 'STOCK_INSUFICIENTE',
      });
    }

    const total = cantidad * precio_unitario;

    // Crear venta
    const ventaResultado = await client.query(
      `INSERT INTO ventas (usuario_id, producto_id, cantidad, precio_unitario, total, nota)
       VALUES ($1, $2, $3, $4, $5, $6)
       RETURNING id, producto_id, cantidad, precio_unitario, total, nota, fecha, created_at`,
      [usuarioId, producto_id, cantidad, precio_unitario, total, nota]
    );

    const venta = ventaResultado.rows[0];

    // Actualizar stock del producto
    const nuevoStock = producto.stock - cantidad;

    await client.query('UPDATE productos SET stock = $1, updated_at = NOW() WHERE id = $2', [nuevoStock, producto_id]);

    await client.query('COMMIT');

    // Registrar auditoría
    await registrarAuditoria({
      usuarioId,
      accion: 'VENTA',
      entidad: 'venta',
      entidadId: venta.id,
      datosNuevos: { ...venta, nombre_producto: producto.nombre },
      descripcion: `Venta de ${producto.nombre} (cantidad: ${cantidad})`,
    });

    // Invalidar caché
    await safeDel(`productos_usuario_${usuarioId}`);
    await safeDel(`ventas_usuario_${usuarioId}`);

    // Preparar respuesta
    const respuesta = {
      success: true,
      data: {
        ...venta,
        nombre_producto: producto.nombre,
      },
      mensaje: 'Venta registrada exitosamente',
    };

    // Advertencia de stock bajo
    if (nuevoStock <= producto.stock_minimo) {
      respuesta.advertencia_stock = true;
      respuesta.mensaje_advertencia = `⚠️ El producto '${producto.nombre}' se está quedando sin stock. Stock actual: ${nuevoStock}, Stock mínimo: ${producto.stock_minimo}`;
    }

    res.status(201).json(respuesta);
  } catch (error) {
    await client.query('ROLLBACK');
    console.error('❌ Error creando venta:', error.message);
    res.status(500).json({
      success: false,
      error: 'Error al registrar venta',
      codigo: 'CREATE_SALE_ERROR',
    });
  } finally {
    client.release();
  }
}

export async function obtenerVentasDia(req, res) {
  try {
    const usuarioId = req.usuarioId;
    const fecha = req.query.fecha || new Date().toISOString().split('T')[0];

    const resultado = await pool.query(
      `SELECT v.id, v.producto_id, p.nombre as nombre_producto, v.cantidad, v.precio_unitario, v.total, v.nota, v.fecha
       FROM ventas v
       LEFT JOIN productos p ON v.producto_id = p.id
       WHERE v.usuario_id = $1 AND DATE(v.fecha) = $2
       ORDER BY v.fecha DESC`,
      [usuarioId, fecha]
    );

    res.json({
      success: true,
      data: resultado.rows,
      mensaje: `${resultado.rows.length} ventas del día`,
    });
  } catch (error) {
    console.error('❌ Error obteniendo ventas del día:', error.message);
    res.status(500).json({
      success: false,
      error: 'Error al obtener ventas del día',
      codigo: 'DAILY_SALES_ERROR',
    });
  }
}

export async function obtenerVentasMes(req, res) {
  try {
    const usuarioId = req.usuarioId;
    const ahora = new Date();
    const mes = req.query.mes || ahora.getMonth() + 1;
    const anio = req.query.anio || ahora.getFullYear();

    const resultado = await pool.query(
      `SELECT v.id, v.producto_id, p.nombre as nombre_producto, v.cantidad, v.precio_unitario, v.total, v.nota, v.fecha
       FROM ventas v
       LEFT JOIN productos p ON v.producto_id = p.id
       WHERE v.usuario_id = $1 AND EXTRACT(MONTH FROM v.fecha) = $2 AND EXTRACT(YEAR FROM v.fecha) = $3
       ORDER BY v.fecha DESC`,
      [usuarioId, mes, anio]
    );

    res.json({
      success: true,
      data: resultado.rows,
      mensaje: `${resultado.rows.length} ventas de ${mes}/${anio}`,
    });
  } catch (error) {
    console.error('❌ Error obteniendo ventas del mes:', error.message);
    res.status(500).json({
      success: false,
      error: 'Error al obtener ventas del mes',
      codigo: 'MONTHLY_SALES_ERROR',
    });
  }
}

export async function obtenerVentasAnio(req, res) {
  try {
    const usuarioId = req.usuarioId;
    const ahora = new Date();
    const anio = req.query.anio || ahora.getFullYear();

    const resultado = await pool.query(
      `SELECT v.id, v.producto_id, p.nombre as nombre_producto, v.cantidad, v.precio_unitario, v.total, v.nota, v.fecha
       FROM ventas v
       LEFT JOIN productos p ON v.producto_id = p.id
       WHERE v.usuario_id = $1 AND EXTRACT(YEAR FROM v.fecha) = $2
       ORDER BY v.fecha DESC`,
      [usuarioId, anio]
    );

    res.json({
      success: true,
      data: resultado.rows,
      mensaje: `${resultado.rows.length} ventas de ${anio}`,
    });
  } catch (error) {
    console.error('❌ Error obteniendo ventas del año:', error.message);
    res.status(500).json({
      success: false,
      error: 'Error al obtener ventas del año',
      codigo: 'YEARLY_SALES_ERROR',
    });
  }
}

export async function obtenerVentasRango(req, res) {
  try {
    const usuarioId = req.usuarioId;
    const { fecha_desde, fecha_hasta } = req.query;

    if (!fecha_desde || !fecha_hasta) {
      return res.status(400).json({
        success: false,
        error: 'Parámetros fecha_desde y fecha_hasta requeridos',
        codigo: 'PARAMETROS_REQUERIDOS',
      });
    }

    const resultado = await pool.query(
      `SELECT v.id, v.producto_id, p.nombre as nombre_producto, v.cantidad, v.precio_unitario, v.total, v.nota, v.fecha
       FROM ventas v
       LEFT JOIN productos p ON v.producto_id = p.id
       WHERE v.usuario_id = $1 AND v.fecha BETWEEN $2 AND $3
       ORDER BY v.fecha DESC`,
      [usuarioId, fecha_desde, fecha_hasta]
    );

    res.json({
      success: true,
      data: resultado.rows,
      mensaje: `${resultado.rows.length} ventas entre ${fecha_desde} y ${fecha_hasta}`,
    });
  } catch (error) {
    console.error('❌ Error obteniendo ventas en rango:', error.message);
    res.status(500).json({
      success: false,
      error: 'Error al obtener ventas en rango',
      codigo: 'RANGE_SALES_ERROR',
    });
  }
}

export default {
  listarVentas,
  obtenerVenta,
  crearVenta,
  obtenerVentasDia,
  obtenerVentasMes,
  obtenerVentasAnio,
  obtenerVentasRango,
};
