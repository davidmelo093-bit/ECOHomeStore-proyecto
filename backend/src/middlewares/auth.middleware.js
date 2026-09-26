import jwt from 'jsonwebtoken';

const JWT_SECRET = process.env.JWT_SECRET;

// 1. Definición del Middleware para verificar la firma de JWT
const authJWT = (req, res, next) => {
    const authHeader = req.headers['authorization'];

    if (!authHeader) {
        return res.status(401).json({ error: 'Token de acceso requerido en la cabecera' });
    }

    const parts = authHeader.split(' ');
    if (parts.length !== 2 || parts[0] !== 'Bearer') {
        return res.status(401).json({ error: 'Formato de token inválido (debe ser Bearer <token>)' });
    }

    const token = parts[1];

    jwt.verify(token, JWT_SECRET, (err, decoded) => {
        if (err) {
            return res.status(403).json({ error: 'Token inválido o expirado' });
        }
        req.user = decoded; 
        next();
    });
};

// 2. Definición del Middleware para autorización basada en roles específicos
const authorizeRole = (requiredRole) => {
    return (req, res, next) => {
        if (!req.user) {
            return res.status(401).json({ error: 'Usuario no autenticado' });
        }

        if (req.user.role !== requiredRole) {
            return res.status(403).json({ error: 'Acceso denegado: permisos insuficientes para esta operación' });
        }

        next();
    };
};

export { authJWT, authorizeRole };
