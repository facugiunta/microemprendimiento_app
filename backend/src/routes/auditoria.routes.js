import express from 'express';
import { listarAuditoria, obtenerHistorialEntidad, obtenerResumen } from '../controllers/auditoria.controller.js';
import { verificarJWT } from '../middleware/auth.js';

const router = express.Router();

router.use(verificarJWT);

router.get('/', listarAuditoria);
router.get('/entidad/:entidad/:id', obtenerHistorialEntidad);
router.get('/resumen', obtenerResumen);

export default router;
