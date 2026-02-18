import express from 'express';
import {
  listarProductos,
  obtenerProducto,
  crearProducto,
  actualizarProducto,
  eliminarProducto,
  obtenerProductosBajoBajo,
} from '../controllers/productos.controller.js';
import { verificarJWT } from '../middleware/auth.js';
import { validarProducto } from '../middleware/validate.js';

const router = express.Router();

router.use(verificarJWT);

router.get('/', listarProductos);
router.post('/', validarProducto, crearProducto);
router.get('/stock-bajo', obtenerProductosBajoBajo);
router.get('/:id', obtenerProducto);
router.put('/:id', actualizarProducto);
router.delete('/:id', eliminarProducto);

export default router;
