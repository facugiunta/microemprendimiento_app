import express from 'express';
import { listarCompras, obtenerCompra, crearCompra, obtenerComprasDia, obtenerComprasMes, obtenerComprasRango } from '../controllers/compras.controller.js';
import { verificarJWT } from '../middleware/auth.js';
import { validarCompra } from '../middleware/validate.js';

const router = express.Router();

router.use(verificarJWT);

router.get('/', listarCompras);
router.post('/', validarCompra, crearCompra);
router.get('/historial/dia', obtenerComprasDia);
router.get('/historial/mes', obtenerComprasMes);
router.get('/historial/rango', obtenerComprasRango);
router.get('/:id', obtenerCompra);

export default router;
