import express from 'express';
import {
  exportarProductos,
  exportarCompras,
  exportarVentas,
  exportarInversiones,
  exportarReporteMensual,
  exportarAuditoria,
} from '../controllers/exportar.controller.js';
import { verificarJWT } from '../middleware/auth.js';

const router = express.Router();

router.use(verificarJWT);

router.get('/productos', exportarProductos);
router.get('/compras', exportarCompras);
router.get('/ventas', exportarVentas);
router.get('/inversiones', exportarInversiones);
router.get('/reporte-mensual', exportarReporteMensual);
router.get('/auditoria', exportarAuditoria);

export default router;
