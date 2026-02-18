import pool from '../config/database.js';

export async function obtenerHistorialVentas(req, res) {
  try {
    const usuarioId = req.usuarioId;
    const { pagina = 1, limite = 20, fecha_desde, fecha_hasta, orden = 'desc' } = req.query;
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

    query += ` ORDER BY v.fecha ${orden} LIMIT $${paramIndex} OFFSET $${paramIndex + 1}`;
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
    console.error('❌ Error obteniendo historial de ventas:', error.message);
    res.status(500).json({
      success: false,
      error: 'Error al obtener historial de ventas',
      codigo: 'SALES_HISTORY_ERROR',
    });
  }
}

export async function obtenerHistorialCompras(req, res) {
  try {
    const usuarioId = req.usuarioId;
    const { pagina = 1, limite = 20, fecha_desde, fecha_hasta, orden = 'desc' } = req.query;
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

    query += ` ORDER BY c.fecha ${orden} LIMIT $${paramIndex} OFFSET $${paramIndex + 1}`;
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
    console.error('❌ Error obteniendo historial de compras:', error.message);
    res.status(500).json({
      success: false,
      error: 'Error al obtener historial de compras',
      codigo: 'PURCHASES_HISTORY_ERROR',
    });
  }
}

export async function obtenerHistorialInversiones(req, res) {
  try {
    const usuarioId = req.usuarioId;
    const { pagina = 1, limite = 20, fecha_desde, fecha_hasta, orden = 'desc' } = req.query;
    const offset = (pagina - 1) * limite;

    let query = `
      SELECT id, nombre, descripcion, monto, categoria, fecha, created_at
      FROM inversiones
      WHERE usuario_id = $1
    `;
    const params = [usuarioId];

    let paramIndex = 2;

    if (fecha_desde) {
      query += ` AND fecha >= $${paramIndex}`;
      params.push(fecha_desde);
      paramIndex++;
    }

    if (fecha_hasta) {
      query += ` AND fecha <= $${paramIndex}`;
      params.push(fecha_hasta);
      paramIndex++;
    }

    query += ` ORDER BY fecha ${orden} LIMIT $${paramIndex} OFFSET $${paramIndex + 1}`;
    params.push(limite, offset);

    const resultado = await pool.query(query, params);

    // Contar total
    let countQuery = 'SELECT COUNT(*) as total FROM inversiones WHERE usuario_id = $1';
    const countParams = [usuarioId];

    if (fecha_desde) {
      countQuery += ` AND fecha >= $${countParams.length + 1}`;
      countParams.push(fecha_desde);
    }

    if (fecha_hasta) {
      countQuery += ` AND fecha <= $${countParams.length + 1}`;
      countParams.push(fecha_hasta);
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
    console.error('❌ Error obteniendo historial de inversiones:', error.message);
    res.status(500).json({
      success: false,
      error: 'Error al obtener historial de inversiones',
      codigo: 'INVESTMENTS_HISTORY_ERROR',
    });
  }
}

export async function obtenerHistorialReportes(req, res) {
  try {
    const usuarioId = req.usuarioId;
    const { pagina = 1, limite = 20, orden = 'desc' } = req.query;
    const offset = (pagina - 1) * limite;

    const resultado = await pool.query(
      `SELECT id, nombre_feria, fecha_feria, inversion_puesto, gastos_varios, total_ventas, total_costo_productos, ganancia_neta, created_at
       FROM reportes_feria
       WHERE usuario_id = $1
       ORDER BY created_at ${orden}
       LIMIT $2 OFFSET $3`,
      [usuarioId, limite, offset]
    );

    const totalResultado = await pool.query('SELECT COUNT(*) as total FROM reportes_feria WHERE usuario_id = $1', [usuarioId]);
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
    console.error('❌ Error obteniendo historial de reportes:', error.message);
    res.status(500).json({
      success: false,
      error: 'Error al obtener historial de reportes',
      codigo: 'REPORTS_HISTORY_ERROR',
    });
  }
}

export async function obtenerTimelineCompleta(req, res) {
  try {
    const usuarioId = req.usuarioId;
    const { pagina = 1, limite = 20, fecha_desde, fecha_hasta, orden = 'desc' } = req.query;
    const offset = (pagina - 1) * limite;

    // Obtener todas las transacciones
    let query = `
      (SELECT 'venta' as tipo, v.id, v.fecha, v.total as monto, p.nombre as descripcion FROM ventas v LEFT JOIN productos p ON v.producto_id = p.id WHERE v.usuario_id = $1
      `;
    const params = [usuarioId];

    if (fecha_desde) {
      query += ` AND v.fecha >= $${params.length + 1}`;
      params.push(fecha_desde);
    }

    if (fecha_hasta) {
      query += ` AND v.fecha <= $${params.length + 1}`;
      params.push(fecha_hasta);
    }

    query += `)
      UNION ALL
      (SELECT 'compra' as tipo, c.id, c.fecha, c.total as monto, p.nombre as descripcion FROM compras c LEFT JOIN productos p ON c.producto_id = p.id WHERE c.usuario_id = $1
    `;

    if (fecha_desde) {
      query += ` AND c.fecha >= $${params.length + 1}`;
      params.push(fecha_desde);
    }

    if (fecha_hasta) {
      query += ` AND c.fecha <= $${params.length + 1}`;
      params.push(fecha_hasta);
    }

    query += `)
      UNION ALL
      (SELECT 'inversion' as tipo, i.id, i.fecha, i.monto, i.nombre as descripcion FROM inversiones i WHERE i.usuario_id = $1
    `;

    if (fecha_desde) {
      query += ` AND i.fecha >= $${params.length + 1}`;
      params.push(fecha_desde);
    }

    if (fecha_hasta) {
      query += ` AND i.fecha <= $${params.length + 1}`;
      params.push(fecha_hasta);
    }

    query += `)
      ORDER BY fecha ${orden}
      LIMIT $${params.length + 1} OFFSET $${params.length + 2}
    `;

    params.push(limite, offset);

    const resultado = await pool.query(query, params);

    // Contar total
    let countQuery = `
      SELECT COUNT(*) as total FROM (
        SELECT v.id FROM ventas v WHERE v.usuario_id = $1
    `;
    const countParams = [usuarioId];

    if (fecha_desde) {
      countQuery += ` AND v.fecha >= $${countParams.length + 1}`;
      countParams.push(fecha_desde);
    }

    if (fecha_hasta) {
      countQuery += ` AND v.fecha <= $${countParams.length + 1}`;
      countParams.push(fecha_hasta);
    }

    countQuery += `
        UNION ALL
        SELECT c.id FROM compras c WHERE c.usuario_id = $1
    `;

    if (fecha_desde) {
      countQuery += ` AND c.fecha >= $${countParams.length + 1}`;
      countParams.push(fecha_desde);
    }

    if (fecha_hasta) {
      countQuery += ` AND c.fecha <= $${countParams.length + 1}`;
      countParams.push(fecha_hasta);
    }

    countQuery += `
        UNION ALL
        SELECT i.id FROM inversiones i WHERE i.usuario_id = $1
    `;

    if (fecha_desde) {
      countQuery += ` AND i.fecha >= $${countParams.length + 1}`;
      countParams.push(fecha_desde);
    }

    if (fecha_hasta) {
      countQuery += ` AND i.fecha <= $${countParams.length + 1}`;
      countParams.push(fecha_hasta);
    }

    countQuery += `) as todas`;

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
    console.error('❌ Error obteniendo timeline completa:', error.message);
    res.status(500).json({
      success: false,
      error: 'Error al obtener timeline',
      codigo: 'TIMELINE_ERROR',
    });
  }
}

export default {
  obtenerHistorialVentas,
  obtenerHistorialCompras,
  obtenerHistorialInversiones,
  obtenerHistorialReportes,
  obtenerTimelineCompleta,
};
