import pool from '../config/database.js';
import { registrarAuditoria } from '../utils/auditLogger.js';

export async function generarReporteMensual(req, res) {
  try {
    const usuarioId = req.usuarioId;
    const ahora = new Date();
    const mes = req.query.mes || ahora.getMonth() + 1;
    const anio = req.query.anio || ahora.getFullYear();

    // Obtener total de ventas
    const ventasResultado = await pool.query(
      `SELECT COALESCE(SUM(total), 0) as total_ventas
       FROM ventas
       WHERE usuario_id = $1 AND EXTRACT(MONTH FROM fecha) = $2 AND EXTRACT(YEAR FROM fecha) = $3`,
      [usuarioId, mes, anio]
    );

    // Obtener total de compras
    const comprasResultado = await pool.query(
      `SELECT COALESCE(SUM(total), 0) as total_compras
       FROM compras
       WHERE usuario_id = $1 AND EXTRACT(MONTH FROM fecha) = $2 AND EXTRACT(YEAR FROM fecha) = $3`,
      [usuarioId, mes, anio]
    );

    // Obtener total de inversiones
    const inversionesResultado = await pool.query(
      `SELECT COALESCE(SUM(monto), 0) as total_inversiones
       FROM inversiones
       WHERE usuario_id = $1 AND EXTRACT(MONTH FROM fecha) = $2 AND EXTRACT(YEAR FROM fecha) = $3`,
      [usuarioId, mes, anio]
    );

    const totalVentas = parseFloat(ventasResultado.rows[0].total_ventas);
    const totalCompras = parseFloat(comprasResultado.rows[0].total_compras);
    const totalInversiones = parseFloat(inversionesResultado.rows[0].total_inversiones);
    const gananciaNeta = totalVentas - totalCompras - totalInversiones;

    res.json({
      success: true,
      data: {
        mes: parseInt(mes),
        anio: parseInt(anio),
        total_ventas: totalVentas,
        total_compras: totalCompras,
        total_inversiones: totalInversiones,
        ganancia_neta: gananciaNeta,
      },
    });
  } catch (error) {
    console.error('❌ Error generando reporte mensual:', error.message);
    res.status(500).json({
      success: false,
      error: 'Error al generar reporte mensual',
      codigo: 'MONTHLY_REPORT_ERROR',
    });
  }
}

export async function obtenerHistorialMensual(req, res) {
  try {
    const usuarioId = req.usuarioId;

    // Obtener todos los datos de ventas, compras e inversiones agrupados por mes
    const resultados = await pool.query(
      `SELECT
         EXTRACT(MONTH FROM fecha) as mes,
         EXTRACT(YEAR FROM fecha) as anio
       FROM (
         SELECT fecha FROM ventas WHERE usuario_id = $1
         UNION ALL
         SELECT fecha FROM compras WHERE usuario_id = $1
         UNION ALL
         SELECT fecha FROM inversiones WHERE usuario_id = $1
       ) AS todas_fechas
       ORDER BY anio DESC, mes DESC`,
      [usuarioId]
    );

    const mesesAnios = resultados.rows.map((r) => ({
      mes: parseInt(r.mes),
      anio: parseInt(r.anio),
    }));

    // Eliminar duplicados
    const mesesUnicos = [];
    const set = new Set();

    for (const item of mesesAnios) {
      const key = `${item.mes}-${item.anio}`;
      if (!set.has(key)) {
        set.add(key);
        mesesUnicos.push(item);
      }
    }

    // Para cada mes/año, obtener los datos
    const historial = [];

    for (const { mes, anio } of mesesUnicos) {
      const ventasResultado = await pool.query(
        `SELECT COALESCE(SUM(total), 0) as total_ventas FROM ventas WHERE usuario_id = $1 AND EXTRACT(MONTH FROM fecha) = $2 AND EXTRACT(YEAR FROM fecha) = $3`,
        [usuarioId, mes, anio]
      );

      const comprasResultado = await pool.query(
        `SELECT COALESCE(SUM(total), 0) as total_compras FROM compras WHERE usuario_id = $1 AND EXTRACT(MONTH FROM fecha) = $2 AND EXTRACT(YEAR FROM fecha) = $3`,
        [usuarioId, mes, anio]
      );

      const inversionesResultado = await pool.query(
        `SELECT COALESCE(SUM(monto), 0) as total_inversiones FROM inversiones WHERE usuario_id = $1 AND EXTRACT(MONTH FROM fecha) = $2 AND EXTRACT(YEAR FROM fecha) = $3`,
        [usuarioId, mes, anio]
      );

      const totalVentas = parseFloat(ventasResultado.rows[0].total_ventas);
      const totalCompras = parseFloat(comprasResultado.rows[0].total_compras);
      const totalInversiones = parseFloat(inversionesResultado.rows[0].total_inversiones);
      const ganancia = totalVentas - totalCompras - totalInversiones;

      historial.push({
        mes,
        anio,
        ventas: totalVentas,
        compras: totalCompras,
        inversiones: totalInversiones,
        ganancia,
      });
    }

    res.json({
      success: true,
      data: historial,
    });
  } catch (error) {
    console.error('❌ Error obteniendo historial mensual:', error.message);
    res.status(500).json({
      success: false,
      error: 'Error al obtener historial mensual',
      codigo: 'MONTHLY_HISTORY_ERROR',
    });
  }
}

export async function generarReporteAnual(req, res) {
  try {
    const usuarioId = req.usuarioId;
    const ahora = new Date();
    const anio = req.query.anio || ahora.getFullYear();

    // Obtener total de ventas
    const ventasResultado = await pool.query(
      `SELECT COALESCE(SUM(total), 0) as total_ventas
       FROM ventas
       WHERE usuario_id = $1 AND EXTRACT(YEAR FROM fecha) = $2`,
      [usuarioId, anio]
    );

    // Obtener total de compras
    const comprasResultado = await pool.query(
      `SELECT COALESCE(SUM(total), 0) as total_compras
       FROM compras
       WHERE usuario_id = $1 AND EXTRACT(YEAR FROM fecha) = $2`,
      [usuarioId, anio]
    );

    // Obtener total de inversiones
    const inversionesResultado = await pool.query(
      `SELECT COALESCE(SUM(monto), 0) as total_inversiones
       FROM inversiones
       WHERE usuario_id = $1 AND EXTRACT(YEAR FROM fecha) = $2`,
      [usuarioId, anio]
    );

    const totalVentas = parseFloat(ventasResultado.rows[0].total_ventas);
    const totalCompras = parseFloat(comprasResultado.rows[0].total_compras);
    const totalInversiones = parseFloat(inversionesResultado.rows[0].total_inversiones);
    const gananciaNeta = totalVentas - totalCompras - totalInversiones;

    res.json({
      success: true,
      data: {
        anio: parseInt(anio),
        total_ventas: totalVentas,
        total_compras: totalCompras,
        total_inversiones: totalInversiones,
        ganancia_neta: gananciaNeta,
      },
    });
  } catch (error) {
    console.error('❌ Error generando reporte anual:', error.message);
    res.status(500).json({
      success: false,
      error: 'Error al generar reporte anual',
      codigo: 'YEARLY_REPORT_ERROR',
    });
  }
}

export async function crearReporteFeria(req, res) {
  const client = await pool.connect();

  try {
    await client.query('BEGIN');

    const usuarioId = req.usuarioId;
    const { nombre_feria, fecha_feria, inversion_puesto = 0, gastos_varios = 0, productos_vendidos, nota } = req.body;

    // Obtener datos de productos
    let totalVentas = 0;
    let totalCostoProductos = 0;

    const items = [];

    for (const producto of productos_vendidos) {
      const productoResultado = await client.query(
        'SELECT id, nombre, precio_compra, precio_venta FROM productos WHERE id = $1 AND usuario_id = $2',
        [producto.producto_id, usuarioId]
      );

      if (productoResultado.rows.length === 0) {
        await client.query('ROLLBACK');
        return res.status(404).json({
          success: false,
          error: `Producto ${producto.producto_id} no encontrado`,
          codigo: 'PRODUCTO_NO_ENCONTRADO',
        });
      }

      const prod = productoResultado.rows[0];
      const cantidad = producto.cantidad;
      const precioCompra = parseFloat(prod.precio_compra);
      const precioVenta = parseFloat(prod.precio_venta);

      const subtotalVentas = precioVenta * cantidad;
      const subtotalCosto = precioCompra * cantidad;
      const subtotalGanancia = subtotalVentas - subtotalCosto;

      totalVentas += subtotalVentas;
      totalCostoProductos += subtotalCosto;

      items.push({
        producto_id: prod.id,
        nombre_producto: prod.nombre,
        cantidad,
        precio_compra: precioCompra,
        precio_venta: precioVenta,
        subtotal_ganancia: subtotalGanancia,
      });
    }

    const gananciaNeta = totalVentas - totalCostoProductos - inversion_puesto - gastos_varios;

    // Crear reporte
    const reporteResultado = await client.query(
      `INSERT INTO reportes_feria (usuario_id, nombre_feria, fecha_feria, inversion_puesto, gastos_varios, total_ventas, total_costo_productos, ganancia_neta, nota)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
       RETURNING id, nombre_feria, fecha_feria, inversion_puesto, gastos_varios, total_ventas, total_costo_productos, ganancia_neta, nota, created_at`,
      [usuarioId, nombre_feria, fecha_feria, inversion_puesto, gastos_varios, totalVentas, totalCostoProductos, gananciaNeta, nota]
    );

    const reporte = reporteResultado.rows[0];

    // Insertar items del reporte
    for (const item of items) {
      await client.query(
        `INSERT INTO reportes_feria_items (reporte_feria_id, producto_id, nombre_producto, cantidad, precio_compra, precio_venta, subtotal_ganancia)
         VALUES ($1, $2, $3, $4, $5, $6, $7)`,
        [reporte.id, item.producto_id, item.nombre_producto, item.cantidad, item.precio_compra, item.precio_venta, item.subtotal_ganancia]
      );
    }

    await client.query('COMMIT');

    // Registrar auditoría
    await registrarAuditoria({
      usuarioId,
      accion: 'CREAR',
      entidad: 'reporte_feria',
      entidadId: reporte.id,
      datosNuevos: reporte,
      descripcion: `Reporte de feria "${nombre_feria}" creado`,
    });

    res.status(201).json({
      success: true,
      data: {
        ...reporte,
        items,
      },
      mensaje: 'Reporte de feria creado exitosamente',
    });
  } catch (error) {
    await client.query('ROLLBACK');
    console.error('❌ Error creando reporte de feria:', error.message);
    res.status(500).json({
      success: false,
      error: 'Error al crear reporte de feria',
      codigo: 'FERIA_REPORT_ERROR',
    });
  } finally {
    client.release();
  }
}

export async function listarReportesFeria(req, res) {
  try {
    const usuarioId = req.usuarioId;
    const { pagina = 1, limite = 20 } = req.query;
    const offset = (pagina - 1) * limite;

    const resultado = await pool.query(
      `SELECT id, nombre_feria, fecha_feria, inversion_puesto, gastos_varios, total_ventas, total_costo_productos, ganancia_neta, nota, created_at
       FROM reportes_feria
       WHERE usuario_id = $1
       ORDER BY fecha_feria DESC
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
    console.error('❌ Error listando reportes de feria:', error.message);
    res.status(500).json({
      success: false,
      error: 'Error al listar reportes de feria',
      codigo: 'LIST_FERIA_REPORTS_ERROR',
    });
  }
}

export async function obtenerReporteFeria(req, res) {
  try {
    const usuarioId = req.usuarioId;
    const { id } = req.params;

    const reporteResultado = await pool.query(
      `SELECT id, nombre_feria, fecha_feria, inversion_puesto, gastos_varios, total_ventas, total_costo_productos, ganancia_neta, nota, created_at
       FROM reportes_feria
       WHERE id = $1 AND usuario_id = $2`,
      [id, usuarioId]
    );

    if (reporteResultado.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'Reporte de feria no encontrado',
        codigo: 'REPORTE_NO_ENCONTRADO',
      });
    }

    const reporte = reporteResultado.rows[0];

    // Obtener items
    const itemsResultado = await pool.query(
      `SELECT id, producto_id, nombre_producto, cantidad, precio_compra, precio_venta, subtotal_ganancia
       FROM reportes_feria_items
       WHERE reporte_feria_id = $1`,
      [id]
    );

    res.json({
      success: true,
      data: {
        ...reporte,
        items: itemsResultado.rows,
      },
    });
  } catch (error) {
    console.error('❌ Error obteniendo reporte de feria:', error.message);
    res.status(500).json({
      success: false,
      error: 'Error al obtener reporte de feria',
      codigo: 'GET_FERIA_REPORT_ERROR',
    });
  }
}

export async function eliminarReporteFeria(req, res) {
  try {
    const usuarioId = req.usuarioId;
    const { id } = req.params;

    const reporteResultado = await pool.query(
      'SELECT id, nombre_feria FROM reportes_feria WHERE id = $1 AND usuario_id = $2',
      [id, usuarioId]
    );

    if (reporteResultado.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'Reporte de feria no encontrado',
        codigo: 'REPORTE_NO_ENCONTRADO',
      });
    }

    const reporte = reporteResultado.rows[0];

    await pool.query('DELETE FROM reportes_feria WHERE id = $1 AND usuario_id = $2', [id, usuarioId]);

    await registrarAuditoria({
      usuarioId,
      accion: 'ELIMINAR',
      entidad: 'reporte_feria',
      entidadId: id,
      datosAnteriores: reporte,
      descripcion: `Reporte de feria "${reporte.nombre_feria}" eliminado`,
    });

    res.json({
      success: true,
      data: { id: parseInt(id) },
      mensaje: 'Reporte de feria eliminado exitosamente',
    });
  } catch (error) {
    console.error('âŒ Error eliminando reporte de feria:', error.message);
    res.status(500).json({
      success: false,
      error: 'Error al eliminar reporte de feria',
      codigo: 'DELETE_FERIA_REPORT_ERROR',
    });
  }
}

export default {
  generarReporteMensual,
  obtenerHistorialMensual,
  generarReporteAnual,
  crearReporteFeria,
  listarReportesFeria,
  obtenerReporteFeria,
  eliminarReporteFeria,
};
