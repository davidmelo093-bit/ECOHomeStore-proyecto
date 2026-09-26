import { Router } from 'express';
import { authJWT, authorizeRole } from '../middlewares/auth.middleware.js';
import * as productController from '../controllers/product.controller.js';


const router = Router();

// Rutas públicas de lectura
router.get('/', productController.getAll);
router.get('/:id', productController.getById);

// Rutas de alteración: Requieren doble validación (Token + Rol Admin)
router.post('/', authJWT, authorizeRole('admin'), productController.create);
router.put('/:id', authJWT, authorizeRole('admin'), productController.update);
router.patch('/:id', authJWT, authorizeRole('admin'), productController.updatePartial);
router.delete('/:id', authJWT, authorizeRole('admin'), productController.delete);

export default router;
