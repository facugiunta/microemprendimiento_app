import pool from '../config/database.js';
import { safeDel } from '../config/redis.js';
import { registrarAuditoria } from '../utils/auditLogger.js';

const CATEGORIAS_INVERSIONES = [
  'puesto_feria',
  'packaging',
  'stickers',
  'transporte',
  'marketing',
  'general',
  'otro',
];

export async function listarInversiones(req, res) {
  try {
    const usuarioId = req.usuarioId;
    const { pagina = 1, limite = 20, mes, anio, categoria } = req.query;
    const offset = (pagina - 1) * limite;

    let query = 'SELECT id, nombre, descripcion, monto, categoria, fecha, created_at FROM inversiones WHERE usuario_id = $1';
    const params = [usuarioId];

    let paramIndex = 2;

    if (mes && anio) {
      query += ` AND EXTRACT(MONTH FROM fecha) = $${paramIndex} AND EXTRACT(YEAR FROM fecha) = $${paramIndex + 1}`;
      params.push(mes, anio);
      paramIndex += 2;
    }

    if (categoria) {
      query += ` AND categoria = $${paramIndex}`;
      params.push(categoria);
      paramIndex++;
    }

    query += ` ORDER BY fecha DESC LIMIT $${paramIndex} OFFSET $${paramIndex + 1}`;
    params.push(limite, offset);

    const resultado = await pool.query(query, params);

    // Contar total
    let countQuery = 'SELECT COUNT(*) as total FROM inversiones WHERE usuario_id = $1';
    const countParams = [usuarioId];

    if (mes && anio) {
      countQuery += ` AND EXTRACT(MONTH FROM fecha) = $${countParams.length + 1} AND EXTRACT(YEAR FROM fecha) = $${countParams.length + 2}`;
      countParams.push(mes, anio);
    }

    if (categoria) {
      countQuery += ` AND categoria = $${countParams.length + 1}`;
      countParams.push(categoria);
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
    console.error('❌ Error listando inversiones:', error.message);
    res.status(500).json({
      success: false,
      error: 'Error al listar inversiones',
      codigo: 'LIST_INVESTMENTS_ERROR',
    });
  }
}

export async function obtenerInversion(req, res) {
  try {
    const usuarioId = req.usuarioId;
    const { id } = req.params;

    const resultado = await pool.query('SELECT id, nombre, descripcion, monto, categoria, fecha, created_at FROM inversiones WHERE id = $1 AND usuario_id = $2', [
      id,
      usuarioId,
    ]);

    if (resultado.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'Inversión no encontrada',
        codigo: 'INVERSION_NO_ENCONTRADA',
      });
    }

    res.json({
      success: true,
      data: resultado.rows[0],
    });
  } catch (error) {
    console.error('❌ Error obteniendo inversión:', error.message);
    res.status(500).json({
      success: false,
      error: 'Error al obtener inversión',
      codigo: 'GET_INVESTMENT_ERROR',
    });
  }
}

export async function crearInversion(req, res) {
  try {
    const usuarioId = req.usuarioId;
    const { nombre, descripcion, monto, categoria = 'general' } = req.body;

    const resultado = await pool.query(
      'INSERT INTO inversiones (usuario_id, nombre, descripcion, monto, categoria) VALUES ($1, $2, $3, $4, $5) RETURNING id, nombre, descripcion, monto, categoria, fecha, created_at',
      [usuarioId, nombre, descripcion, monto, categoria]
    );

    const inversion = resultado.rows[0];

    // Registrar auditoría
    await registrarAuditoria({
      usuarioId,
      accion: 'INVERSION',
      entidad: 'inversion',
      entidadId: inversion.id,
      datosNuevos: inversion,
      descripcion: `Inversión "${nombre}" creada`,
    });

    // Invalidar caché
    await safeDel(`inversiones_usuario_${usuarioId}`);

    res.status(201).json({
      success: true,
      data: inversion,
      mensaje: 'Inversión registrada exitosamente',
    });
  } catch (error) {
    console.error('❌ Error creando inversión:', error.message);
    res.status(500).json({
      success: false,
      error: 'Error al crear inversión',
      codigo: 'CREATE_INVESTMENT_ERROR',
    });
  }
}

export async function actualizarInversion(req, res) {
  try {
    const usuarioId = req.usuarioId;
    const { id } = req.params;
    const { nombre, descripcion, monto, categoria } = req.body;

    // Obtener datos anteriores
    const resultadoAnterior = await pool.query('SELECT * FROM inversiones WHERE id = $1 AND usuario_id = $2', [id, usuarioId]);

    if (resultadoAnterior.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'Inversión no encontrada',
        codigo: 'INVERSION_NO_ENCONTRADA',
      });
    }

    const datosAnteriores = resultadoAnterior.rows[0];

    const resultado = await pool.query(
      `UPDATE inversiones
       SET nombre = COALESCE($1, nombre),
           descripcion = COALESCE($2, descripcion),
           monto = COALESCE($3, monto),
           categoria = COALESCE($4, categoria)
       WHERE id = $5 AND usuario_id = $6
       RETURNING id, nombre, descripcion, monto, categoria, fecha, created_at`,
      [nombre, descripcion, monto, categoria, id, usuarioId]
    );

    const inversionActualizada = resultado.rows[0];

    // Registrar auditoría
    await registrarAuditoria({
      usuarioId,
      accion: 'ACTUALIZAR',
      entidad: 'inversion',
      entidadId: id,
      datosAnteriores,
      datosNuevos: inversionActualizada,
      descripcion: `Inversión "${nombre}" actualizada`,
    });

    // Invalidar caché
    await safeDel(`inversiones_usuario_${usuarioId}`);

    res.json({
      success: true,
      data: inversionActualizada,
      mensaje: 'Inversión actualizada exitosamente',
    });
  } catch (error) {
    console.error('❌ Error actualizando inversión:', error.message);
    res.status(500).json({
      success: false,
      error: 'Error al actualizar inversión',
      codigo: 'UPDATE_INVESTMENT_ERROR',
    });
  }
}

export async function eliminarInversion(req, res) {
  try {
    const usuarioId = req.usuarioId;
    const { id } = req.params;

    const resultado = await pool.query('SELECT * FROM inversiones WHERE id = $1 AND usuario_id = $2', [id, usuarioId]);

    if (resultado.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'Inversión no encontrada',
        codigo: 'INVERSION_NO_ENCONTRADA',
      });
    }

    const inversion = resultado.rows[0];

    await pool.query('DELETE FROM inversiones WHERE id = $1', [id]);

    // Registrar auditoría
    await registrarAuditoria({
      usuarioId,
      accion: 'ELIMINAR',
      entidad: 'inversion',
      entidadId: id,
      datosAnteriores: inversion,
      descripcion: `Inversión "${inversion.nombre}" eliminada`,
    });

    // Invalidar caché
    await safeDel(`inversiones_usuario_${usuarioId}`);

    res.json({
      success: true,
      data: { id },
      mensaje: 'Inversión eliminada exitosamente',
    });
  } catch (error) {
    console.error('❌ Error eliminando inversión:', error.message);
    res.status(500).json({
      success: false,
      error: 'Error al eliminar inversión',
      codigo: 'DELETE_INVESTMENT_ERROR',
    });
  }
}

export async function obtenerInversionesMes(req, res) {
  try {
    const usuarioId = req.usuarioId;
    const ahora = new Date();
    const mes = req.query.mes || ahora.getMonth() + 1;
    const anio = req.query.anio || ahora.getFullYear();

    const resultado = await pool.query(
      `SELECT id, nombre, descripcion, monto, categoria, fecha, created_at
       FROM inversiones
       WHERE usuario_id = $1 AND EXTRACT(MONTH FROM fecha) = $2 AND EXTRACT(YEAR FROM fecha) = $3
       ORDER BY fecha DESC`,
      [usuarioId, mes, anio]
    );

    res.json({
      success: true,
      data: resultado.rows,
      mensaje: `${resultado.rows.length} inversiones de ${mes}/${anio}`,
    });
  } catch (error) {
    console.error('❌ Error obteniendo inversiones del mes:', error.message);
    res.status(500).json({
      success: false,
      error: 'Error al obtener inversiones del mes',
      codigo: 'MONTHLY_INVESTMENTS_ERROR',
    });
  }
}

export async function obtenerCategorias(req, res) {
  try {
    res.json({
      success: true,
      data: CATEGORIAS_INVERSIONES,
    });
  } catch (error) {
    console.error('❌ Error obteniendo categorías:', error.message);
    res.status(500).json({
      success: false,
      error: 'Error al obtener categorías',
      codigo: 'GET_CATEGORIES_ERROR',
    });
  }
}

export default {
  listarInversiones,
  obtenerInversion,
  crearInversion,
  actualizarInversion,
  eliminarInversion,
  obtenerInversionesMes,
  obtenerCategorias,
};
