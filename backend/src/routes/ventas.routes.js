import express from 'express';
import {
  listarVentas,
  obtenerVenta,
  crearVenta,
  obtenerVentasDia,
  obtenerVentasMes,
  obtenerVentasAnio,
  obtenerVentasRango,
} from '../controllers/ventas.controller.js';
import { verificarJWT } from '../middleware/auth.js';
import { validarVenta } from '../middleware/validate.js';

const router = express.Router();

router.use(verificarJWT);

router.get('/', listarVentas);
router.post('/', validarVenta, crearVenta);
router.get('/historial/dia', obtenerVentasDia);
router.get('/historial/mes', obtenerVentasMes);
router.get('/historial/anio', obtenerVentasAnio);
router.get('/historial/rango', obtenerVentasRango);
router.get('/:id', obtenerVenta);

export default router;
