import express from 'express';
import { registrarse, login, obtenerUsuario } from '../controllers/auth.controller.js';
import { validarRegistro, validarLogin } from '../middleware/validate.js';
import { verificarJWT } from '../middleware/auth.js';

const router = express.Router();

router.post('/register', validarRegistro, registrarse);
router.post('/login', validarLogin, login);
router.get('/me', verificarJWT, obtenerUsuario);

export default router;
