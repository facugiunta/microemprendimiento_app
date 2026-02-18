import express from 'express';
import {
  obtenerHistorialVentas,
  obtenerHistorialCompras,
  obtenerHistorialInversiones,
  obtenerHistorialReportes,
  obtenerTimelineCompleta,
} from '../controllers/historial.controller.js';
import { verificarJWT } from '../middleware/auth.js';

const router = express.Router();

router.use(verificarJWT);

router.get('/ventas', obtenerHistorialVentas);
router.get('/compras', obtenerHistorialCompras);
router.get('/inversiones', obtenerHistorialInversiones);
router.get('/reportes', obtenerHistorialReportes);
router.get('/todo', obtenerTimelineCompleta);

export default router;
