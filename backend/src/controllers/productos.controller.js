import pool from '../config/database.js';
import { safeDel } from '../config/redis.js';
import { registrarAuditoria } from '../utils/auditLogger.js';

export async function listarProductos(req, res) {
  try {
    const usuarioId = req.usuarioId;
    const { pagina = 1, limite = 20 } = req.query;
    const offset = (pagina - 1) * limite;

    const resultado = await pool.query(
      `SELECT id, nombre, descripcion, stock, stock_minimo, precio_compra, precio_venta, activo, created_at, updated_at
       FROM productos
       WHERE usuario_id = $1 AND activo = true
       ORDER BY created_at DESC
       LIMIT $2 OFFSET $3`,
      [usuarioId, limite, offset]
    );

    const totalResultado = await pool.query('SELECT COUNT(*) as total FROM productos WHERE usuario_id = $1 AND activo = true', [usuarioId]);
    const totalRegistros = parseInt(totalResultado.rows[0].total);
    const totalPaginas = Math.ceil(totalRegistros / limite);

    // Invalidar caché
    await safeDel(`productos_usuario_${usuarioId}`);

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
    console.error('❌ Error listando productos:', error.message);
    res.status(500).json({
      success: false,
      error: 'Error al listar productos',
      codigo: 'LIST_PRODUCTS_ERROR',
    });
  }
}

export async function obtenerProducto(req, res) {
  try {
    const usuarioId = req.usuarioId;
    const { id } = req.params;

    const resultado = await pool.query(
      'SELECT id, nombre, descripcion, stock, stock_minimo, precio_compra, precio_venta, activo, created_at, updated_at FROM productos WHERE id = $1 AND usuario_id = $2',
      [id, usuarioId]
    );

    if (resultado.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'Producto no encontrado',
        codigo: 'PRODUCTO_NO_ENCONTRADO',
      });
    }

    res.json({
      success: true,
      data: resultado.rows[0],
    });
  } catch (error) {
    console.error('❌ Error obteniendo producto:', error.message);
    res.status(500).json({
      success: false,
      error: 'Error al obtener producto',
      codigo: 'GET_PRODUCT_ERROR',
    });
  }
}

export async function crearProducto(req, res) {
  try {
    const usuarioId = req.usuarioId;
    const { nombre, descripcion, stock = 0, stock_minimo = 0, precio_compra = 0, precio_venta = 0 } = req.body;

    console.log(`📝 Intentando crear producto: "${nombre}" para usuario: ${usuarioId}`);

    const resultado = await pool.query(
      `INSERT INTO productos (usuario_id, nombre, descripcion, stock, stock_minimo, precio_compra, precio_venta)
       VALUES ($1, $2, $3, $4, $5, $6, $7)
       RETURNING id, nombre, descripcion, stock, stock_minimo, precio_compra, precio_venta, activo, created_at`,
      [usuarioId, nombre, descripcion, stock, stock_minimo, precio_compra, precio_venta]
    );

    const producto = resultado.rows[0];
    console.log(`✅ Producto creado exitosamente: ID ${producto.id}`);

    // Registrar auditoría
    await registrarAuditoria({
      usuarioId,
      accion: 'CREAR',
      entidad: 'producto',
      entidadId: producto.id,
      datosNuevos: producto,
      descripcion: `Producto "${nombre}" creado`,
    });

    // Invalidar caché
    await safeDel(`productos_usuario_${usuarioId}`);

    res.status(201).json({
      success: true,
      data: producto,
      mensaje: 'Producto creado exitosamente',
    });
  } catch (error) {
    console.error('❌ Error creando producto:', error.message);
    console.error('   Stack:', error.stack);
    res.status(500).json({
      success: false,
      error: 'Error al crear producto',
      codigo: 'CREATE_PRODUCT_ERROR',
      detalle: error.message,
    });
  }
}

export async function actualizarProducto(req, res) {
  try {
    const usuarioId = req.usuarioId;
    const { id } = req.params;
    const { nombre, descripcion, stock, stock_minimo, precio_compra, precio_venta } = req.body;

    // Obtener datos anteriores
    const resultadoAnterior = await pool.query('SELECT * FROM productos WHERE id = $1 AND usuario_id = $2', [id, usuarioId]);

    if (resultadoAnterior.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'Producto no encontrado',
        codigo: 'PRODUCTO_NO_ENCONTRADO',
      });
    }

    const datosAnteriores = resultadoAnterior.rows[0];

    // Actualizar
    const resultado = await pool.query(
      `UPDATE productos
       SET nombre = COALESCE($1, nombre),
           descripcion = COALESCE($2, descripcion),
           stock = COALESCE($3, stock),
           stock_minimo = COALESCE($4, stock_minimo),
           precio_compra = COALESCE($5, precio_compra),
           precio_venta = COALESCE($6, precio_venta),
           updated_at = NOW()
       WHERE id = $7 AND usuario_id = $8
       RETURNING id, nombre, descripcion, stock, stock_minimo, precio_compra, precio_venta, activo, created_at, updated_at`,
      [nombre, descripcion, stock, stock_minimo, precio_compra, precio_venta, id, usuarioId]
    );

    const productoActualizado = resultado.rows[0];

    // Registrar auditoría
    await registrarAuditoria({
      usuarioId,
      accion: 'ACTUALIZAR',
      entidad: 'producto',
      entidadId: id,
      datosAnteriores,
      datosNuevos: productoActualizado,
      descripcion: `Producto "${nombre}" actualizado`,
    });

    // Invalidar caché
    await safeDel(`productos_usuario_${usuarioId}`);

    res.json({
      success: true,
      data: productoActualizado,
      mensaje: 'Producto actualizado exitosamente',
    });
  } catch (error) {
    console.error('❌ Error actualizando producto:', error.message);
    res.status(500).json({
      success: false,
      error: 'Error al actualizar producto',
      codigo: 'UPDATE_PRODUCT_ERROR',
    });
  }
}

export async function eliminarProducto(req, res) {
  try {
    const usuarioId = req.usuarioId;
    const { id } = req.params;

    const resultado = await pool.query('SELECT * FROM productos WHERE id = $1 AND usuario_id = $2', [id, usuarioId]);

    if (resultado.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'Producto no encontrado',
        codigo: 'PRODUCTO_NO_ENCONTRADO',
      });
    }

    const producto = resultado.rows[0];

    // Soft delete: marcar como inactivo
    await pool.query('UPDATE productos SET activo = false, updated_at = NOW() WHERE id = $1', [id]);

    // Registrar auditoría
    await registrarAuditoria({
      usuarioId,
      accion: 'ELIMINAR',
      entidad: 'producto',
      entidadId: id,
      datosAnteriores: producto,
      descripcion: `Producto "${producto.nombre}" eliminado`,
    });

    // Invalidar caché
    await safeDel(`productos_usuario_${usuarioId}`);

    res.json({
      success: true,
      data: { id },
      mensaje: 'Producto eliminado exitosamente',
    });
  } catch (error) {
    console.error('❌ Error eliminando producto:', error.message);
    res.status(500).json({
      success: false,
      error: 'Error al eliminar producto',
      codigo: 'DELETE_PRODUCT_ERROR',
    });
  }
}

export async function obtenerProductosBajoBajo(req, res) {
  try {
    const usuarioId = req.usuarioId;

    const resultado = await pool.query(
      `SELECT id, nombre, descripcion, stock, stock_minimo, precio_compra, precio_venta
       FROM productos
       WHERE usuario_id = $1 AND activo = true AND stock <= stock_minimo
       ORDER BY stock ASC`,
      [usuarioId]
    );

    res.json({
      success: true,
      data: resultado.rows,
      mensaje: `${resultado.rows.length} productos con stock bajo`,
    });
  } catch (error) {
    console.error('❌ Error obteniendo productos con stock bajo:', error.message);
    res.status(500).json({
      success: false,
      error: 'Error al obtener productos con stock bajo',
      codigo: 'LOW_STOCK_ERROR',
    });
  }
}

export default {
  listarProductos,
  obtenerProducto,
  crearProducto,
  actualizarProducto,
  eliminarProducto,
  obtenerProductosBajoBajo,
};
