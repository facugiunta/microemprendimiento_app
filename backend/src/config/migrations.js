import pool from './database.js';

export async function runMigrations() {
  const client = await pool.connect();
  try {
    console.log('🔄 Ejecutando migraciones...');

    // Tabla: usuarios
    await client.query(`
      CREATE TABLE IF NOT EXISTS usuarios (
        id SERIAL PRIMARY KEY,
        nombre VARCHAR(100) NOT NULL,
        email VARCHAR(150) UNIQUE NOT NULL,
        password_hash VARCHAR(255) NOT NULL,
        created_at TIMESTAMP DEFAULT NOW(),
        updated_at TIMESTAMP DEFAULT NOW()
      );
    `);
    console.log('✅ Tabla usuarios creada/verificada');

    // Tabla: productos
    await client.query(`
      CREATE TABLE IF NOT EXISTS productos (
        id SERIAL PRIMARY KEY,
        usuario_id INT REFERENCES usuarios(id) ON DELETE CASCADE,
        nombre VARCHAR(200) NOT NULL,
        descripcion TEXT,
        stock INT NOT NULL DEFAULT 0,
        stock_minimo INT NOT NULL DEFAULT 0,
        precio_compra DECIMAL(12,2) NOT NULL DEFAULT 0,
        precio_venta DECIMAL(12,2) NOT NULL DEFAULT 0,
        activo BOOLEAN DEFAULT true,
        created_at TIMESTAMP DEFAULT NOW(),
        updated_at TIMESTAMP DEFAULT NOW()
      );
    `);
    console.log('✅ Tabla productos creada/verificada');

    // Tabla: compras
    await client.query(`
      CREATE TABLE IF NOT EXISTS compras (
        id SERIAL PRIMARY KEY,
        usuario_id INT REFERENCES usuarios(id) ON DELETE CASCADE,
        producto_id INT REFERENCES productos(id) ON DELETE SET NULL,
        cantidad INT NOT NULL,
        precio_unitario DECIMAL(12,2) NOT NULL,
        total DECIMAL(12,2) NOT NULL,
        proveedor VARCHAR(200),
        nota TEXT,
        fecha TIMESTAMP DEFAULT NOW(),
        created_at TIMESTAMP DEFAULT NOW()
      );
    `);
    console.log('✅ Tabla compras creada/verificada');

    // Tabla: ventas
    await client.query(`
      CREATE TABLE IF NOT EXISTS ventas (
        id SERIAL PRIMARY KEY,
        usuario_id INT REFERENCES usuarios(id) ON DELETE CASCADE,
        producto_id INT REFERENCES productos(id) ON DELETE SET NULL,
        cantidad INT NOT NULL,
        precio_unitario DECIMAL(12,2) NOT NULL,
        total DECIMAL(12,2) NOT NULL,
        nota TEXT,
        fecha TIMESTAMP DEFAULT NOW(),
        created_at TIMESTAMP DEFAULT NOW()
      );
    `);
    console.log('✅ Tabla ventas creada/verificada');

    // Tabla: inversiones
    await client.query(`
      CREATE TABLE IF NOT EXISTS inversiones (
        id SERIAL PRIMARY KEY,
        usuario_id INT REFERENCES usuarios(id) ON DELETE CASCADE,
        nombre VARCHAR(200) NOT NULL,
        descripcion TEXT,
        monto DECIMAL(12,2) NOT NULL,
        categoria VARCHAR(100) DEFAULT 'general',
        fecha TIMESTAMP DEFAULT NOW(),
        created_at TIMESTAMP DEFAULT NOW()
      );
    `);
    console.log('✅ Tabla inversiones creada/verificada');

    // Tabla: reportes_feria
    await client.query(`
      CREATE TABLE IF NOT EXISTS reportes_feria (
        id SERIAL PRIMARY KEY,
        usuario_id INT REFERENCES usuarios(id) ON DELETE CASCADE,
        nombre_feria VARCHAR(200) NOT NULL,
        fecha_feria DATE NOT NULL,
        inversion_puesto DECIMAL(12,2) DEFAULT 0,
        gastos_varios DECIMAL(12,2) DEFAULT 0,
        total_ventas DECIMAL(12,2) DEFAULT 0,
        total_costo_productos DECIMAL(12,2) DEFAULT 0,
        ganancia_neta DECIMAL(12,2) DEFAULT 0,
        nota TEXT,
        created_at TIMESTAMP DEFAULT NOW()
      );
    `);
    console.log('✅ Tabla reportes_feria creada/verificada');

    // Tabla: reportes_feria_items
    await client.query(`
      CREATE TABLE IF NOT EXISTS reportes_feria_items (
        id SERIAL PRIMARY KEY,
        reporte_feria_id INT REFERENCES reportes_feria(id) ON DELETE CASCADE,
        producto_id INT REFERENCES productos(id) ON DELETE SET NULL,
        nombre_producto VARCHAR(200),
        cantidad INT NOT NULL,
        precio_compra DECIMAL(12,2) NOT NULL,
        precio_venta DECIMAL(12,2) NOT NULL,
        subtotal_ganancia DECIMAL(12,2) NOT NULL
      );
    `);
    console.log('✅ Tabla reportes_feria_items creada/verificada');

    // Tabla: auditoria
    await client.query(`
      CREATE TABLE IF NOT EXISTS auditoria (
        id SERIAL PRIMARY KEY,
        usuario_id INT REFERENCES usuarios(id) ON DELETE CASCADE,
        accion VARCHAR(50) NOT NULL,
        entidad VARCHAR(50) NOT NULL,
        entidad_id INT,
        datos_anteriores JSONB,
        datos_nuevos JSONB,
        ip VARCHAR(45),
        descripcion TEXT,
        fecha TIMESTAMP DEFAULT NOW()
      );
    `);
    console.log('✅ Tabla auditoria creada/verificada');

    // Crear índices para mejor rendimiento
    await client.query(`
      CREATE INDEX IF NOT EXISTS idx_productos_usuario_id ON productos(usuario_id);
      CREATE INDEX IF NOT EXISTS idx_compras_usuario_id ON compras(usuario_id);
      CREATE INDEX IF NOT EXISTS idx_compras_fecha ON compras(fecha);
      CREATE INDEX IF NOT EXISTS idx_ventas_usuario_id ON ventas(usuario_id);
      CREATE INDEX IF NOT EXISTS idx_ventas_fecha ON ventas(fecha);
      CREATE INDEX IF NOT EXISTS idx_inversiones_usuario_id ON inversiones(usuario_id);
      CREATE INDEX IF NOT EXISTS idx_investiones_fecha ON inversiones(fecha);
      CREATE INDEX IF NOT EXISTS idx_auditoria_usuario_id ON auditoria(usuario_id);
      CREATE INDEX IF NOT EXISTS idx_auditoria_fecha ON auditoria(fecha);
    `);
    console.log('✅ Índices creados/verificados');

    console.log('✅ Todas las migraciones completadas exitosamente');
  } catch (error) {
    console.error('❌ Error durante migraciones:', error.message);
    throw error;
  } finally {
    client.release();
  }
}

export default runMigrations;
