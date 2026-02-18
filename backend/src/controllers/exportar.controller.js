import pool from '../config/database.js';
import {
  exportarProductosExcel,
  exportarComprasExcel,
  exportarVentasExcel,
  exportarInversionesExcel,
  exportarReporteMensualExcel,
  exportarAuditoriaExcel,
} from '../utils/excelGenerator.js';
import { registrarAuditoria } from '../utils/auditLogger.js';

export async function exportarProductos(req, res) {
  try {
    const usuarioId = req.usuarioId;

    const resultado = await pool.query(
      'SELECT id, nombre, descripcion, stock, stock_minimo, precio_compra, precio_venta, activo FROM productos WHERE usuario_id = $1 AND activo = true ORDER BY nombre',
      [usuarioId]
    );

    const workbook = await exportarProductosExcel(resultado.rows);

    // Registrar auditoría
    await registrarAuditoria({
      usuarioId,
      accion: 'EXPORTAR',
      entidad: 'producto',
      descripcion: `${resultado.rows.length} productos exportados a Excel`,
    });

    res.setHeader('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
    res.setHeader('Content-Disposition', `attachment; filename="productos_${Date.now()}.xlsx"`);

    await workbook.xlsx.write(res);
    res.end();
  } catch (error) {
    console.error('❌ Error exportando productos:', error.message);
    res.status(500).json({
      success: false,
      error: 'Error al exportar productos',
      codigo: 'EXPORT_PRODUCTS_ERROR',
    });
  }
}

export async function exportarCompras(req, res) {
  try {
    const usuarioId = req.usuarioId;
    const { mes, anio } = req.query;

    let query = `
      SELECT c.id, c.producto_id, p.nombre as nombre_producto, c.cantidad, c.precio_unitario, c.total, c.proveedor, c.nota, c.fecha
      FROM compras c
      LEFT JOIN productos p ON c.producto_id = p.id
      WHERE c.usuario_id = $1
    `;
    const params = [usuarioId];

    if (mes && anio) {
      query += ` AND EXTRACT(MONTH FROM c.fecha) = $${params.length + 1} AND EXTRACT(YEAR FROM c.fecha) = $${params.length + 2}`;
      params.push(mes, anio);
    }

    query += ' ORDER BY c.fecha DESC';

    const resultado = await pool.query(query, params);

    const workbook = await exportarComprasExcel(resultado.rows);

    // Registrar auditoría
    await registrarAuditoria({
      usuarioId,
      accion: 'EXPORTAR',
      entidad: 'compra',
      descripcion: `${resultado.rows.length} compras exportadas a Excel`,
    });

    res.setHeader('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
    res.setHeader('Content-Disposition', `attachment; filename="compras_${Date.now()}.xlsx"`);

    await workbook.xlsx.write(res);
    res.end();
  } catch (error) {
    console.error('❌ Error exportando compras:', error.message);
    res.status(500).json({
      success: false,
      error: 'Error al exportar compras',
      codigo: 'EXPORT_PURCHASES_ERROR',
    });
  }
}

export async function exportarVentas(req, res) {
  try {
    const usuarioId = req.usuarioId;
    const { mes, anio } = req.query;

    let query = `
      SELECT v.id, v.producto_id, p.nombre as nombre_producto, v.cantidad, v.precio_unitario, v.total, v.nota, v.fecha
      FROM ventas v
      LEFT JOIN productos p ON v.producto_id = p.id
      WHERE v.usuario_id = $1
    `;
    const params = [usuarioId];

    if (mes && anio) {
      query += ` AND EXTRACT(MONTH FROM v.fecha) = $${params.length + 1} AND EXTRACT(YEAR FROM v.fecha) = $${params.length + 2}`;
      params.push(mes, anio);
    }

    query += ' ORDER BY v.fecha DESC';

    const resultado = await pool.query(query, params);

    const workbook = await exportarVentasExcel(resultado.rows);

    // Registrar auditoría
    await registrarAuditoria({
      usuarioId,
      accion: 'EXPORTAR',
      entidad: 'venta',
      descripcion: `${resultado.rows.length} ventas exportadas a Excel`,
    });

    res.setHeader('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
    res.setHeader('Content-Disposition', `attachment; filename="ventas_${Date.now()}.xlsx"`);

    await workbook.xlsx.write(res);
    res.end();
  } catch (error) {
    console.error('❌ Error exportando ventas:', error.message);
    res.status(500).json({
      success: false,
      error: 'Error al exportar ventas',
      codigo: 'EXPORT_SALES_ERROR',
    });
  }
}

export async function exportarInversiones(req, res) {
  try {
    const usuarioId = req.usuarioId;
    const { mes, anio, categoria } = req.query;

    let query = 'SELECT id, nombre, descripcion, monto, categoria, fecha FROM inversiones WHERE usuario_id = $1';
    const params = [usuarioId];

    if (mes && anio) {
      query += ` AND EXTRACT(MONTH FROM fecha) = $${params.length + 1} AND EXTRACT(YEAR FROM fecha) = $${params.length + 2}`;
      params.push(mes, anio);
    }

    if (categoria) {
      query += ` AND categoria = $${params.length + 1}`;
      params.push(categoria);
    }

    query += ' ORDER BY fecha DESC';

    const resultado = await pool.query(query, params);

    const workbook = await exportarInversionesExcel(resultado.rows);

    // Registrar auditoría
    await registrarAuditoria({
      usuarioId,
      accion: 'EXPORTAR',
      entidad: 'inversion',
      descripcion: `${resultado.rows.length} inversiones exportadas a Excel`,
    });

    res.setHeader('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
    res.setHeader('Content-Disposition', `attachment; filename="inversiones_${Date.now()}.xlsx"`);

    await workbook.xlsx.write(res);
    res.end();
  } catch (error) {
    console.error('❌ Error exportando inversiones:', error.message);
    res.status(500).json({
      success: false,
      error: 'Error al exportar inversiones',
      codigo: 'EXPORT_INVESTMENTS_ERROR',
    });
  }
}

export async function exportarReporteMensual(req, res) {
  try {
    const usuarioId = req.usuarioId;
    const ahora = new Date();
    const mes = req.query.mes || ahora.getMonth() + 1;
    const anio = req.query.anio || ahora.getFullYear();

    // Obtener datos del reporte
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
    const gananciaNeta = totalVentas - totalCompras - totalInversiones;

    const reporte = {
      total_ventas: totalVentas,
      total_compras: totalCompras,
      total_inversiones: totalInversiones,
      ganancia_neta: gananciaNeta,
    };

    const workbook = await exportarReporteMensualExcel(mes, anio, reporte);

    // Registrar auditoría
    await registrarAuditoria({
      usuarioId,
      accion: 'EXPORTAR',
      entidad: 'reporte',
      descripcion: `Reporte mensual ${mes}/${anio} exportado a Excel`,
    });

    res.setHeader('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
    res.setHeader('Content-Disposition', `attachment; filename="reporte_${mes}_${anio}_${Date.now()}.xlsx"`);

    await workbook.xlsx.write(res);
    res.end();
  } catch (error) {
    console.error('❌ Error exportando reporte mensual:', error.message);
    res.status(500).json({
      success: false,
      error: 'Error al exportar reporte',
      codigo: 'EXPORT_REPORT_ERROR',
    });
  }
}

export async function exportarAuditoria(req, res) {
  try {
    const usuarioId = req.usuarioId;

    const resultado = await pool.query(
      `SELECT id, accion, entidad, entidad_id, descripcion, fecha FROM auditoria WHERE usuario_id = $1 ORDER BY fecha DESC`,
      [usuarioId]
    );

    const workbook = await exportarAuditoriaExcel(resultado.rows);

    // Registrar auditoría
    await registrarAuditoria({
      usuarioId,
      accion: 'EXPORTAR',
      entidad: 'auditoria',
      descripcion: `${resultado.rows.length} registros de auditoría exportados a Excel`,
    });

    res.setHeader('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
    res.setHeader('Content-Disposition', `attachment; filename="auditoria_${Date.now()}.xlsx"`);

    await workbook.xlsx.write(res);
    res.end();
  } catch (error) {
    console.error('❌ Error exportando auditoría:', error.message);
    res.status(500).json({
      success: false,
      error: 'Error al exportar auditoría',
      codigo: 'EXPORT_AUDIT_ERROR',
    });
  }
}

export default {
  exportarProductos,
  exportarCompras,
  exportarVentas,
  exportarInversiones,
  exportarReporteMensual,
  exportarAuditoria,
};
