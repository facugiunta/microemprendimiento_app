import express from 'express';
import { crearBackup, restaurarBackup, obtenerHistorialBackups } from '../controllers/backup.controller.js';
import { verificarJWT } from '../middleware/auth.js';

const router = express.Router();

router.use(verificarJWT);

router.post('/crear', crearBackup);
router.post('/restaurar', restaurarBackup);
router.get('/historial', obtenerHistorialBackups);

export default router;
