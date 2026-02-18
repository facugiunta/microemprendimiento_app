import pool from '../config/database.js';

export async function listarAuditoria(req, res) {
  try {
    const usuarioId = req.usuarioId;
    const { pagina = 1, limite = 20, entidad, accion, fecha_desde, fecha_hasta } = req.query;
    const offset = (pagina - 1) * limite;

    let query = 'SELECT id, usuario_id, accion, entidad, entidad_id, descripcion, fecha FROM auditoria WHERE usuario_id = $1';
    const params = [usuarioId];

    let paramIndex = 2;

    if (entidad) {
      query += ` AND entidad = $${paramIndex}`;
      params.push(entidad);
      paramIndex++;
    }

    if (accion) {
      query += ` AND accion = $${paramIndex}`;
      params.push(accion);
      paramIndex++;
    }

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

    query += ` ORDER BY fecha DESC LIMIT $${paramIndex} OFFSET $${paramIndex + 1}`;
    params.push(limite, offset);

    const resultado = await pool.query(query, params);

    // Contar total
    let countQuery = 'SELECT COUNT(*) as total FROM auditoria WHERE usuario_id = $1';
    const countParams = [usuarioId];

    if (entidad) {
      countQuery += ` AND entidad = $${countParams.length + 1}`;
      countParams.push(entidad);
    }

    if (accion) {
      countQuery += ` AND accion = $${countParams.length + 1}`;
      countParams.push(accion);
    }

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
    console.error('❌ Error listando auditoría:', error.message);
    res.status(500).json({
      success: false,
      error: 'Error al listar auditoría',
      codigo: 'LIST_AUDIT_ERROR',
    });
  }
}

export async function obtenerHistorialEntidad(req, res) {
  try {
    const usuarioId = req.usuarioId;
    const { entidad, id } = req.params;

    const resultado = await pool.query(
      `SELECT id, usuario_id, accion, entidad, entidad_id, datos_anteriores, datos_nuevos, descripcion, fecha
       FROM auditoria
       WHERE usuario_id = $1 AND entidad = $2 AND entidad_id = $3
       ORDER BY fecha DESC`,
      [usuarioId, entidad, id]
    );

    res.json({
      success: true,
      data: resultado.rows,
      mensaje: `${resultado.rows.length} cambios en ${entidad} ID ${id}`,
    });
  } catch (error) {
    console.error('❌ Error obteniendo historial de entidad:', error.message);
    res.status(500).json({
      success: false,
      error: 'Error al obtener historial',
      codigo: 'ENTITY_HISTORY_ERROR',
    });
  }
}

export async function obtenerResumen(req, res) {
  try {
    const usuarioId = req.usuarioId;
    const ahora = new Date();
    const mes = ahora.getMonth() + 1;
    const anio = ahora.getFullYear();

    const resultado = await pool.query(
      `SELECT
         accion,
         COUNT(*) as total
       FROM auditoria
       WHERE usuario_id = $1 AND EXTRACT(MONTH FROM fecha) = $2 AND EXTRACT(YEAR FROM fecha) = $3
       GROUP BY accion
       ORDER BY total DESC`,
      [usuarioId, mes, anio]
    );

    const resumen = resultado.rows.reduce((acc, row) => {
      acc[row.accion] = parseInt(row.total);
      return acc;
    }, {});

    res.json({
      success: true,
      data: resumen,
      mensaje: `Resumen de auditoría de ${mes}/${anio}`,
    });
  } catch (error) {
    console.error('❌ Error obteniendo resumen:', error.message);
    res.status(500).json({
      success: false,
      error: 'Error al obtener resumen',
      codigo: 'AUDIT_SUMMARY_ERROR',
    });
  }
}

export default {
  listarAuditoria,
  obtenerHistorialEntidad,
  obtenerResumen,
};
