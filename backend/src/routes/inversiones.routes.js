import express from 'express';
import {
  listarInversiones,
  obtenerInversion,
  crearInversion,
  actualizarInversion,
  eliminarInversion,
  obtenerInversionesMes,
  obtenerCategorias,
} from '../controllers/inversiones.controller.js';
import { verificarJWT } from '../middleware/auth.js';
import { validarInversion } from '../middleware/validate.js';

const router = express.Router();

router.use(verificarJWT);

router.get('/', listarInversiones);
router.post('/', validarInversion, crearInversion);
router.get('/historial/mes', obtenerInversionesMes);
router.get('/categorias', obtenerCategorias);
router.get('/:id', obtenerInversion);
router.put('/:id', actualizarInversion);
router.delete('/:id', eliminarInversion);

export default router;
