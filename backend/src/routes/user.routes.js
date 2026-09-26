import { Router } from 'express';
import { authJWT } from '../middlewares/auth.middleware.js';
import pool from '../config/db.js';

const router = Router();

// GET /users/me/stats — Devuelve datos del usuario autenticado + contador de productos creados
router.get('/me/stats', authJWT, async (req, res) => {
    try {
        const { rows } = await pool.query(
            'SELECT COUNT(*)::int AS product_count FROM products WHERE created_by = $1',
            [req.user.id]
        );
        res.json({
            id: req.user.id,
            username: req.user.username,
            role: req.user.role,
            product_count: rows[0].product_count
        });
    } catch (error) {
        console.error('[GET /users/me/stats] Error:', error.message);
        res.status(500).json({ error: 'Error al obtener estadísticas del usuario' });
    }
});

export default router;
