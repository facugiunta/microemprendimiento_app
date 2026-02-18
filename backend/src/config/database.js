import pg from 'pg';
import dotenv from 'dotenv';

dotenv.config();

const { Pool } = pg;

// Usar DATABASE_URL si está disponible (para Docker)
const connectionString = process.env.DATABASE_URL;

console.log('🔧 DATABASE_URL configurada:', connectionString ? 'Sí' : 'No');

const poolConfig = connectionString
  ? { 
      connectionString,
      max: 5,
      min: 0,
      idleTimeoutMillis: 10000,
      connectionTimeoutMillis: 5000,
    }
  : {
      host: process.env.DB_HOST || 'localhost',
      port: process.env.DB_PORT || 5432,
      user: process.env.DB_USER || 'postgres',
      password: process.env.DB_PASSWORD || 'postgres',
      database: process.env.DB_NAME || 'microemprendimiento_db',
      max: 5,
      min: 0,
      idleTimeoutMillis: 10000,
      connectionTimeoutMillis: 5000,
    };

const pool = new Pool(poolConfig);

pool.on('error', (err, client) => {
  console.error('❌ Error inesperado en el pool de PostgreSQL:', err.message);
});

pool.on('connect', () => {
  console.log('✅ Nueva conexión al pool de PostgreSQL');
});

export async function connectDatabase() {
  let client;
  try {
    client = await pool.connect();
    console.log('✅ Conectado a PostgreSQL');
    return true;
  } catch (error) {
    console.error('❌ Error conectando a PostgreSQL:', error.message);
    return false;
  } finally {
    if (client) {
      client.release();
    }
  }
}

export default pool;
