
import { Router } from 'express';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import pool from '../config/db.js';

const router = Router();
const JWT_SECRET = process.env.JWT_SECRET;

// 1. POST /auth/signup - Registro seguro de usuarios
router.post('/signup', async (req, res) => {
    try {
        const { username, email, password, role } = req.body;

        if (!username || !email || !password) {
            return res.status(400).json({ error: 'Todos los campos son obligatorios' });
        }

        // Encriptar la contraseña (Hashing con algoritmo bcryptjs)
        const salt = await bcrypt.genSalt(10);
        const password_hash = await bcrypt.hash(password, salt);
        const userRole = role || 'cliente'; 

        const query = `
            INSERT INTO users (username, email, password_hash, role)
            VALUES ($1, $2, $3, $4)
            RETURNING id, username, email, role, created_at;
        `;
        const values = [username, email, password_hash, userRole];
        const { rows } = await pool.query(query, values);

        res.status(201).json({
            message: 'Usuario registrado con éxito',
            user: rows
        });
    } catch (error) {
        if (error.code === '23505') {
            return res.status(400).json({ error: 'El email o nombre de usuario ya está registrado' });
        }
        res.status(500).json({ error: 'Error interno en el servidor' });
    }
});

// 2. POST /auth/login - Autenticación y generación del JWT
router.post('/login', async (req, res) => {
    try {
        const { email, password } = req.body;

        if (!email || !password) {
            return res.status(400).json({ error: 'Email y contraseña obligatorios' });
        }

        // Buscar el usuario en la BD
        const query = 'SELECT * FROM users WHERE email = $1';
        const { rows } = await pool.query(query, [email]);

        if (rows.length === 0) {
            return res.status(401).json({ error: 'Credenciales inválidas' });
        }

        const user = rows[0];

        // Comparar el hash de la contraseña
        const isMatch = await bcrypt.compare(password, user.password_hash);
        if (!isMatch) {
            return res.status(401).json({ error: 'Credenciales inválidas' });
        }

        // Definir la información contenida en el token (Payload)
        const payload = {
            id: user.id,
            username: user.username,
            role: user.role
        };

        // Generar el Token JWT
        const token = jwt.sign(payload, JWT_SECRET, { expiresIn: process.env.JWT_EXPIRES_IN || '1h' });

        res.json({
            message: 'Inicio de sesión exitoso',
            token
        });
    } catch (error) {
        res.status(500).json({ error: 'Error interno en el servidor' });
    }
});

export default router;