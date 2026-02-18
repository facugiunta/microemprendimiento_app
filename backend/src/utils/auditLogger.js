import pool from '../config/database.js';

export async function registrarAuditoria({
  usuarioId,
  accion,
  entidad,
  entidadId,
  datosAnteriores,
  datosNuevos,
  ip,
  descripcion,
}) {
  try {
    await pool.query(
      `
      INSERT INTO auditoria (usuario_id, accion, entidad, entidad_id, datos_anteriores, datos_nuevos, ip, descripcion)
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
      `,
      [usuarioId, accion, entidad, entidadId || null, JSON.stringify(datosAnteriores) || null, JSON.stringify(datosNuevos) || null, ip || null, descripcion || null]
    );
  } catch (error) {
    console.error('❌ Error registrando auditoría:', error.message);
    // No lanzar error para no interrumpir la operación principal
  }
}

export default registrarAuditoria;
