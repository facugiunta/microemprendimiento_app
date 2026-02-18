import pool from '../config/database.js';
import { safeDel } from '../config/redis.js';
import { registrarAuditoria } from '../utils/auditLogger.js';

export async function listarCompras(req, res) {
  try {
    const usuarioId = req.usuarioId;
    const { pagina = 1, limite = 20, fecha_desde, fecha_hasta, mes, anio, producto_id } = req.query;
    const offset = (pagina - 1) * limite;

    let query = `
      SELECT c.id, c.producto_id, p.nombre as nombre_producto, c.cantidad, c.precio_unitario, c.total, c.proveedor, c.nota, c.fecha, c.created_at
      FROM compras c
      LEFT JOIN productos p ON c.producto_id = p.id
      WHERE c.usuario_id = $1
    `;
    const params = [usuarioId];

    let paramIndex = 2;

    if (fecha_desde) {
      query += ` AND c.fecha >= $${paramIndex}`;
      params.push(fecha_desde);
      paramIndex++;
    }

    if (fecha_hasta) {
      query += ` AND c.fecha <= $${paramIndex}`;
      params.push(fecha_hasta);
      paramIndex++;
    }

    if (mes && anio) {
      query += ` AND EXTRACT(MONTH FROM c.fecha) = $${paramIndex} AND EXTRACT(YEAR FROM c.fecha) = $${paramIndex + 1}`;
      params.push(mes, anio);
      paramIndex += 2;
    }

    if (producto_id) {
      query += ` AND c.producto_id = $${paramIndex}`;
      params.push(producto_id);
      paramIndex++;
    }

    query += ` ORDER BY c.fecha DESC LIMIT $${paramIndex} OFFSET $${paramIndex + 1}`;
    params.push(limite, offset);

    const resultado = await pool.query(query, params);

    // Contar total
    let countQuery = 'SELECT COUNT(*) as total FROM compras WHERE usuario_id = $1';
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
    console.error('❌ Error listando compras:', error.message);
    res.status(500).json({
      success: false,
      error: 'Error al listar compras',
      codigo: 'LIST_PURCHASES_ERROR',
    });
  }
}

export async function obtenerCompra(req, res) {
  try {
    const usuarioId = req.usuarioId;
    const { id } = req.params;

    const resultado = await pool.query(
      `SELECT c.id, c.producto_id, p.nombre as nombre_producto, c.cantidad, c.precio_unitario, c.total, c.proveedor, c.nota, c.fecha, c.created_at
       FROM compras c
       LEFT JOIN productos p ON c.producto_id = p.id
       WHERE c.id = $1 AND c.usuario_id = $2`,
      [id, usuarioId]
    );

    if (resultado.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'Compra no encontrada',
        codigo: 'COMPRA_NO_ENCONTRADA',
      });
    }

    res.json({
      success: true,
      data: resultado.rows[0],
    });
  } catch (error) {
    console.error('❌ Error obteniendo compra:', error.message);
    res.status(500).json({
      success: false,
      error: 'Error al obtener compra',
      codigo: 'GET_PURCHASE_ERROR',
    });
  }
}

export async function crearCompra(req, res) {
  const client = await pool.connect();

  try {
    await client.query('BEGIN');

    const usuarioId = req.usuarioId;
    const { producto_id, cantidad, precio_unitario, proveedor, nota } = req.body;

    const total = cantidad * precio_unitario;

    // Obtener producto para actualizar stock y precio
    const productoResultado = await client.query('SELECT id, nombre, stock, precio_compra FROM productos WHERE id = $1 AND usuario_id = $2', [
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

    // Crear compra
    const compraResultado = await client.query(
      `INSERT INTO compras (usuario_id, producto_id, cantidad, precio_unitario, total, proveedor, nota)
       VALUES ($1, $2, $3, $4, $5, $6, $7)
       RETURNING id, producto_id, cantidad, precio_unitario, total, proveedor, nota, fecha, created_at`,
      [usuarioId, producto_id, cantidad, precio_unitario, total, proveedor, nota]
    );

    const compra = compraResultado.rows[0];

    // Actualizar stock y precio_compra del producto
    const nuevoStock = producto.stock + cantidad;

    await client.query(
      'UPDATE productos SET stock = $1, precio_compra = $2, updated_at = NOW() WHERE id = $3',
      [nuevoStock, precio_unitario, producto_id]
    );

    await client.query('COMMIT');

    // Registrar auditoría
    await registrarAuditoria({
      usuarioId,
      accion: 'COMPRA',
      entidad: 'compra',
      entidadId: compra.id,
      datosNuevos: { ...compra, nombre_producto: producto.nombre },
      descripcion: `Compra de ${producto.nombre} (cantidad: ${cantidad})`,
    });

    // Invalidar caché
    await safeDel(`productos_usuario_${usuarioId}`);
    await safeDel(`compras_usuario_${usuarioId}`);

    res.status(201).json({
      success: true,
      data: {
        ...compra,
        nombre_producto: producto.nombre,
      },
      mensaje: 'Compra registrada exitosamente',
    });
  } catch (error) {
    await client.query('ROLLBACK');
    console.error('❌ Error creando compra:', error.message);
    res.status(500).json({
      success: false,
      error: 'Error al registrar compra',
      codigo: 'CREATE_PURCHASE_ERROR',
    });
  } finally {
    client.release();
  }
}

export async function obtenerComprasDia(req, res) {
  try {
    const usuarioId = req.usuarioId;
    const hoy = new Date().toISOString().split('T')[0];

    const resultado = await pool.query(
      `SELECT c.id, c.producto_id, p.nombre as nombre_producto, c.cantidad, c.precio_unitario, c.total, c.proveedor, c.nota, c.fecha
       FROM compras c
       LEFT JOIN productos p ON c.producto_id = p.id
       WHERE c.usuario_id = $1 AND DATE(c.fecha) = $2
       ORDER BY c.fecha DESC`,
      [usuarioId, hoy]
    );

    res.json({
      success: true,
      data: resultado.rows,
      mensaje: `${resultado.rows.length} compras del día`,
    });
  } catch (error) {
    console.error('❌ Error obteniendo compras del día:', error.message);
    res.status(500).json({
      success: false,
      error: 'Error al obtener compras del día',
      codigo: 'DAILY_PURCHASES_ERROR',
    });
  }
}

export async function obtenerComprasMes(req, res) {
  try {
    const usuarioId = req.usuarioId;
    const ahora = new Date();
    const mes = req.query.mes || ahora.getMonth() + 1;
    const anio = req.query.anio || ahora.getFullYear();

    const resultado = await pool.query(
      `SELECT c.id, c.producto_id, p.nombre as nombre_producto, c.cantidad, c.precio_unitario, c.total, c.proveedor, c.nota, c.fecha
       FROM compras c
       LEFT JOIN productos p ON c.producto_id = p.id
       WHERE c.usuario_id = $1 AND EXTRACT(MONTH FROM c.fecha) = $2 AND EXTRACT(YEAR FROM c.fecha) = $3
       ORDER BY c.fecha DESC`,
      [usuarioId, mes, anio]
    );

    res.json({
      success: true,
      data: resultado.rows,
      mensaje: `${resultado.rows.length} compras de ${mes}/${anio}`,
    });
  } catch (error) {
    console.error('❌ Error obteniendo compras del mes:', error.message);
    res.status(500).json({
      success: false,
      error: 'Error al obtener compras del mes',
      codigo: 'MONTHLY_PURCHASES_ERROR',
    });
  }
}

export async function obtenerComprasRango(req, res) {
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
      `SELECT c.id, c.producto_id, p.nombre as nombre_producto, c.cantidad, c.precio_unitario, c.total, c.proveedor, c.nota, c.fecha
       FROM compras c
       LEFT JOIN productos p ON c.producto_id = p.id
       WHERE c.usuario_id = $1 AND c.fecha BETWEEN $2 AND $3
       ORDER BY c.fecha DESC`,
      [usuarioId, fecha_desde, fecha_hasta]
    );

    res.json({
      success: true,
      data: resultado.rows,
      mensaje: `${resultado.rows.length} compras entre ${fecha_desde} y ${fecha_hasta}`,
    });
  } catch (error) {
    console.error('❌ Error obteniendo compras en rango:', error.message);
    res.status(500).json({
      success: false,
      error: 'Error al obtener compras en rango',
      codigo: 'RANGE_PURCHASES_ERROR',
    });
  }
}

export default {
  listarCompras,
  obtenerCompra,
  crearCompra,
  obtenerComprasDia,
  obtenerComprasMes,
  obtenerComprasRango,
};
