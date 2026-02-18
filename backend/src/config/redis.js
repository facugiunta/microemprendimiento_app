import { createClient } from 'redis';
import dotenv from 'dotenv';

dotenv.config();

const redisClient = createClient({
  socket: {
    host: process.env.REDIS_HOST || 'localhost',
    port: parseInt(process.env.REDIS_PORT || '6379', 10),
    reconnectStrategy: (retries) => {
      if (retries > 10) {
        console.error('Redis max reconnect attempts reached');
        return new Error('Max redis retries reached');
      }
      return retries * 100;
    },
  },
});

redisClient.on('error', (err) => {
  console.error('Redis error:', err.message);
});

redisClient.on('connect', () => {
  console.log('Connected to Redis');
});

export async function connectRedis() {
  try {
    await redisClient.connect();
    return true;
  } catch (error) {
    console.error('Error connecting Redis:', error.message);
    return false;
  }
}

export async function safeDel(key) {
  if (!redisClient?.isOpen) return;
  try {
    await redisClient.del(key);
  } catch (error) {
    console.warn('Could not invalidate Redis cache:', error.message);
  }
}

export default redisClient;
