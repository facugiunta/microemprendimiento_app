import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import { connectDatabase } from './config/database.js';
import { connectRedis } from './config/redis.js';
import runMigrations from './config/migrations.js';
import errorHandler from './middleware/errorHandler.js';

import authRoutes from './routes/auth.routes.js';
import productosRoutes from './routes/productos.routes.js';
import comprasRoutes from './routes/compras.routes.js';
import ventasRoutes from './routes/ventas.routes.js';
import inversionesRoutes from './routes/inversiones.routes.js';
import reportesRoutes from './routes/reportes.routes.js';
import auditoriaRoutes from './routes/auditoria.routes.js';
import historialRoutes from './routes/historial.routes.js';
import backupRoutes from './routes/backup.routes.js';
import exportarRoutes from './routes/exportar.routes.js';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors({
  origin: process.env.CORS_ORIGIN || '*',
}));

app.use(express.json());
app.use(express.urlencoded({ limit: '50mb', extended: true }));

// Health check
app.get('/health', (req, res) => {
  res.json({
    success: true,
    mensaje: 'El servidor está funcionando correctamente',
  });
});

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/productos', productosRoutes);
app.use('/api/compras', comprasRoutes);
app.use('/api/ventas', ventasRoutes);
app.use('/api/inversiones', inversionesRoutes);
app.use('/api/reportes', reportesRoutes);
app.use('/api/auditoria', auditoriaRoutes);
app.use('/api/historial', historialRoutes);
app.use('/api/backup', backupRoutes);
app.use('/api/exportar', exportarRoutes);

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    success: false,
    error: 'Ruta no encontrada',
    codigo: 'NOT_FOUND',
  });
});

// Error handler
app.use(errorHandler);

// Iniciar servidor
async function start() {
  try {
    console.log('\n╔═══════════════════════════════════════════════════════════╗');
    console.log('║    MICROEMPRENDIMIENTO - BACKEND (Node.js + Express)     ║');
    console.log('╚═══════════════════════════════════════════════════════════╝\n');

    // Conectar a PostgreSQL
    console.log('🔗 Conectando a PostgreSQL...');
    const dbConnected = await connectDatabase();

    if (!dbConnected) {
      throw new Error('No se pudo conectar a PostgreSQL');
    }

    // Ejecutar migraciones
    console.log('\n🔄 Ejecutando migraciones de base de datos...');
    await runMigrations();

    // Conectar a Redis
    console.log('\n🔗 Conectando a Redis...');
    const redisConnected = await connectRedis();

    if (!redisConnected) {
      console.warn('⚠️  Advertencia: No se pudo conectar a Redis. Continuando sin caché.');
    }

    // Iniciar servidor
    app.listen(PORT, '0.0.0.0', () => {
      console.log(`\n✅ Servidor ejecutándose en http://0.0.0.0:${PORT}`);
      console.log(`\n📚 Rutas disponibles:`);
      console.log(`   POST   /api/auth/register               - Registrar usuario`);
      console.log(`   POST   /api/auth/login                  - Iniciar sesión`);
      console.log(`   GET    /api/auth/me                     - Obtener usuario actual`);
      console.log(`   GET    /api/productos                   - Listar productos`);
      console.log(`   POST   /api/productos                   - Crear producto`);
      console.log(`   GET    /api/compras                     - Listar compras`);
      console.log(`   POST   /api/compras                     - Crear compra`);
      console.log(`   GET    /api/ventas                      - Listar ventas`);
      console.log(`   POST   /api/ventas                      - Crear venta`);
      console.log(`   GET    /api/inversiones                 - Listar inversiones`);
      console.log(`   POST   /api/inversiones                 - Crear inversión`);
      console.log(`   GET    /api/reportes/mensual            - Reporte mensual`);
      console.log(`   POST   /api/reportes/feria              - Crear reporte de feria`);
      console.log(`   GET    /api/auditoria                   - Listar auditoría`);
      console.log(`   GET    /api/historial/ventas            - Historial de ventas`);
      console.log(`   POST   /api/backup/crear                - Crear backup`);
      console.log(`   GET    /api/exportar/productos          - Exportar a Excel`);
      console.log(`\n💡 Prueba: curl http://0.0.0.0:${PORT}/health\n`);
    });
  } catch (error) {
    console.error('\n❌ Error al iniciar el servidor:', error.message);
    process.exit(1);
  }
}

start();

export default app;
