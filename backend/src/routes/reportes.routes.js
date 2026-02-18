import express from 'express';
import {
  generarReporteMensual,
  obtenerHistorialMensual,
  generarReporteAnual,
  crearReporteFeria,
  listarReportesFeria,
  obtenerReporteFeria,
  eliminarReporteFeria,
} from '../controllers/reportes.controller.js';
import { verificarJWT } from '../middleware/auth.js';
import { validarReporteFeria } from '../middleware/validate.js';

const router = express.Router();

router.use(verificarJWT);

router.get('/mensual', generarReporteMensual);
router.get('/mensual/historial', obtenerHistorialMensual);
router.get('/anual', generarReporteAnual);
router.post('/feria', validarReporteFeria, crearReporteFeria);
router.get('/feria', listarReportesFeria);
router.get('/feria/:id', obtenerReporteFeria);
router.delete('/feria/:id', eliminarReporteFeria);

export default router;
