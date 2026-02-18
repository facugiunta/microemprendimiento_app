import pool from '../config/database.js';
import { registrarAuditoria } from '../utils/auditLogger.js';

export async function crearBackup(req, res) {
  try {
    const usuarioId = req.usuarioId;

    // Obtener datos del usuario
    const usuarioResultado = await pool.query('SELECT nombre, email FROM usuarios WHERE id = $1', [usuarioId]);

    const usuario = usuarioResultado.rows[0];

    // Obtener todos los datos del usuario
    const productosResultado = await pool.query('SELECT * FROM productos WHERE usuario_id = $1 ORDER BY id', [usuarioId]);

    const comprasResultado = await pool.query('SELECT * FROM compras WHERE usuario_id = $1 ORDER BY id', [usuarioId]);

    const ventasResultado = await pool.query('SELECT * FROM ventas WHERE usuario_id = $1 ORDER BY id', [usuarioId]);

    const inversionesResultado = await pool.query('SELECT * FROM inversiones WHERE usuario_id = $1 ORDER BY id', [usuarioId]);

    const reportesFeriaResultado = await pool.query('SELECT * FROM reportes_feria WHERE usuario_id = $1 ORDER BY id', [usuarioId]);

    const reportesFeriaItemsResultado = await pool.query(
      `SELECT rfi.* FROM reportes_feria_items rfi
       JOIN reportes_feria rf ON rfi.reporte_feria_id = rf.id
       WHERE rf.usuario_id = $1 ORDER BY rfi.id`,
      [usuarioId]
    );

    // Construir backup
    const backup = {
      version: '1.0',
      fecha_backup: new Date().toISOString(),
      usuario: {
        nombre: usuario.nombre,
        email: usuario.email,
      },
      datos: {
        productos: productosResultado.rows,
        compras: comprasResultado.rows,
        ventas: ventasResultado.rows,
        inversiones: inversionesResultado.rows,
        reportes_feria: reportesFeriaResultado.rows,
        reportes_feria_items: reportesFeriaItemsResultado.rows,
      },
    };

    // Registrar auditoría
    await registrarAuditoria({
      usuarioId,
      accion: 'BACKUP_CREAR',
      entidad: 'backup',
      datosNuevos: { fecha_backup: backup.fecha_backup },
      descripcion: 'Backup creado',
    });

    // Enviar como descarga
    res.setHeader('Content-Type', 'application/json');
    res.setHeader('Content-Disposition', `attachment; filename="backup_${usuarioId}_${Date.now()}.json"`);

    res.json(backup);
  } catch (error) {
    console.error('❌ Error creando backup:', error.message);
    res.status(500).json({
      success: false,
      error: 'Error al crear backup',
      codigo: 'BACKUP_CREATE_ERROR',
    });
  }
}

export async function restaurarBackup(req, res) {
  const client = await pool.connect();

  try {
    await client.query('BEGIN');

    const usuarioId = req.usuarioId;
    const backup = req.body;

    // Validar formato de backup
    if (!backup.version || !backup.datos) {
      return res.status(400).json({
        success: false,
        error: 'Formato de backup inválido',
        codigo: 'INVALID_BACKUP_FORMAT',
      });
    }

    // Eliminar datos actuales del usuario (EXCEPTO el registro del usuario)
    await client.query('DELETE FROM reportes_feria_items WHERE reporte_feria_id IN (SELECT id FROM reportes_feria WHERE usuario_id = $1)', [usuarioId]);

    await client.query('DELETE FROM reportes_feria WHERE usuario_id = $1', [usuarioId]);

    await client.query('DELETE FROM inversiones WHERE usuario_id = $1', [usuarioId]);

    await client.query('DELETE FROM ventas WHERE usuario_id = $1', [usuarioId]);

    await client.query('DELETE FROM compras WHERE usuario_id = $1', [usuarioId]);

    await client.query('DELETE FROM productos WHERE usuario_id = $1', [usuarioId]);

    // Restaurar productos
    for (const producto of backup.datos.productos || []) {
      await client.query(
        `INSERT INTO productos (usuario_id, nombre, descripcion, stock, stock_minimo, precio_compra, precio_venta, activo, created_at, updated_at)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)`,
        [
          usuarioId,
          producto.nombre,
          producto.descripcion,
          producto.stock,
          producto.stock_minimo,
          producto.precio_compra,
          producto.precio_venta,
          producto.activo,
          producto.created_at,
          producto.updated_at,
        ]
      );
    }

    // Obtener mapeo de IDs antiguos a nuevos para productos
    const productosNuevos = await client.query('SELECT id, nombre FROM productos WHERE usuario_id = $1 ORDER BY nombre', [usuarioId]);

    const mapeoProductos = {};
    for (const producto of backup.datos.productos || []) {
      const productoNuevo = productosNuevos.rows.find((p) => p.nombre === producto.nombre);
      if (productoNuevo) {
        mapeoProductos[producto.id] = productoNuevo.id;
      }
    }

    // Restaurar compras
    for (const compra of backup.datos.compras || []) {
      await client.query(
        `INSERT INTO compras (usuario_id, producto_id, cantidad, precio_unitario, total, proveedor, nota, fecha, created_at)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)`,
        [
          usuarioId,
          mapeoProductos[compra.producto_id] || compra.producto_id,
          compra.cantidad,
          compra.precio_unitario,
          compra.total,
          compra.proveedor,
          compra.nota,
          compra.fecha,
          compra.created_at,
        ]
      );
    }

    // Restaurar ventas
    for (const venta of backup.datos.ventas || []) {
      await client.query(
        `INSERT INTO ventas (usuario_id, producto_id, cantidad, precio_unitario, total, nota, fecha, created_at)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8)`,
        [
          usuarioId,
          mapeoProductos[venta.producto_id] || venta.producto_id,
          venta.cantidad,
          venta.precio_unitario,
          venta.total,
          venta.nota,
          venta.fecha,
          venta.created_at,
        ]
      );
    }

    // Restaurar inversiones
    for (const inversion of backup.datos.inversiones || []) {
      await client.query(
        `INSERT INTO inversiones (usuario_id, nombre, descripcion, monto, categoria, fecha, created_at)
         VALUES ($1, $2, $3, $4, $5, $6, $7)`,
        [
          usuarioId,
          inversion.nombre,
          inversion.descripcion,
          inversion.monto,
          inversion.categoria,
          inversion.fecha,
          inversion.created_at,
        ]
      );
    }

    // Restaurar reportes de feria
    const mapeoReportes = {};

    for (const reporte of backup.datos.reportes_feria || []) {
      const resultadoReporte = await client.query(
        `INSERT INTO reportes_feria (usuario_id, nombre_feria, fecha_feria, inversion_puesto, gastos_varios, total_ventas, total_costo_productos, ganancia_neta, nota, created_at)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
         RETURNING id`,
        [
          usuarioId,
          reporte.nombre_feria,
          reporte.fecha_feria,
          reporte.inversion_puesto,
          reporte.gastos_varios,
          reporte.total_ventas,
          reporte.total_costo_productos,
          reporte.ganancia_neta,
          reporte.nota,
          reporte.created_at,
        ]
      );

      mapeoReportes[reporte.id] = resultadoReporte.rows[0].id;
    }

    // Restaurar items de reportes de feria
    for (const item of backup.datos.reportes_feria_items || []) {
      await client.query(
        `INSERT INTO reportes_feria_items (reporte_feria_id, producto_id, nombre_producto, cantidad, precio_compra, precio_venta, subtotal_ganancia)
         VALUES ($1, $2, $3, $4, $5, $6, $7)`,
        [
          mapeoReportes[item.reporte_feria_id],
          mapeoProductos[item.producto_id] || item.producto_id,
          item.nombre_producto,
          item.cantidad,
          item.precio_compra,
          item.precio_venta,
          item.subtotal_ganancia,
        ]
      );
    }

    await client.query('COMMIT');

    // Registrar auditoría
    await registrarAuditoria({
      usuarioId,
      accion: 'BACKUP_RESTAURAR',
      entidad: 'backup',
      datosNuevos: { fecha_restauracion: new Date().toISOString() },
      descripcion: 'Backup restaurado',
    });

    res.json({
      success: true,
      data: {
        fecha_restauracion: new Date().toISOString(),
      },
      mensaje: 'Backup restaurado exitosamente',
    });
  } catch (error) {
    await client.query('ROLLBACK');
    console.error('❌ Error restaurando backup:', error.message);
    res.status(500).json({
      success: false,
      error: 'Error al restaurar backup',
      codigo: 'BACKUP_RESTORE_ERROR',
    });
  } finally {
    client.release();
  }
}

export async function obtenerHistorialBackups(req, res) {
  try {
    const usuarioId = req.usuarioId;

    // Obtener metadatos de backups desde auditoría
    const resultado = await pool.query(
      `SELECT id, descripcion, fecha FROM auditoria
       WHERE usuario_id = $1 AND accion IN ('BACKUP_CREAR', 'BACKUP_RESTAURAR')
       ORDER BY fecha DESC`,
      [usuarioId]
    );

    res.json({
      success: true,
      data: resultado.rows.map((row) => ({
        id: row.id,
        tipo: row.descripcion.includes('restaurado') ? 'restaurado' : 'creado',
        fecha: row.fecha,
      })),
    });
  } catch (error) {
    console.error('❌ Error obteniendo historial de backups:', error.message);
    res.status(500).json({
      success: false,
      error: 'Error al obtener historial de backups',
      codigo: 'BACKUP_HISTORY_ERROR',
    });
  }
}

export default {
  crearBackup,
  restaurarBackup,
  obtenerHistorialBackups,
};
