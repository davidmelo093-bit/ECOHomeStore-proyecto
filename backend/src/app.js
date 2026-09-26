
import express from 'express';
import http from 'http';
import cors from 'cors';
import { Server } from 'socket.io';
import path from 'path';
import { fileURLToPath } from 'url';
import jwt from 'jsonwebtoken';
import MessageModel from './models/message.model.js';
import authRouter from './controllers/auth.controller.js';
import productRouter from './routes/product.routes.js';
import userRouter from './routes/user.routes.js';

const app = express();

app.use(cors({
    origin: function (origin, callback) {
        // Permite si no hay origen (ej. Postman) o si incluye "localhost" o "127.0.0.1"
        if (!origin || origin.includes('localhost') || origin.includes('127.0.0.1')) {
            callback(null, true);
        } else {
            callback(new Error('No permitido por CORS'));
        }
    },
    methods: ['GET', 'POST', 'PUT', 'DELETE'],
    credentials: true
}));

app.use(express.json());

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
app.use(express.static(path.join(__dirname, '../public')));

const JWT_SECRET = process.env.JWT_SECRET || 'mi_clave_secreta_super_segura';

// 1. Inicialización del servidor HTTP wrapping Express
const server = http.createServer(app);



// 2. Inicialización de Socket.IO con configuración de CORS abierta para pruebas
const io = new Server(server, {
    cors: { origin: '*', methods: ['GET', 'POST'] }
});

const messages = [];

// MIDDLEWARE DE AUTENTICACIÓN EN WEBSOCKETS
io.use((socket, next) => {
    // Extrae el token enviado en la propiedad 'auth' del cliente
    const token = socket.handshake.auth?.token || socket.handshake.headers?.authorization?.split(' ')[1];

    if (!token) {
        console.log('[Socket.IO] Rechazado: Token no proporcionado');
        return next(new Error('Autenticación requerida: Token no proporcionado'));
    }

    // Verifica el token JWT con la clave
    jwt.verify(token, JWT_SECRET, (err, decoded) => {
        if (err) {
            console.log('[Socket.IO] Rechazado: Token inválido o expirado');
            return next(new Error('Token inválido o expirado'));
        }
        
        // Asocia los datos del usuario autenticado al socket único de esta conexión
        socket.user = decoded; // ej. { id, username, role }
        console.log(`[Socket.IO] Usuario autenticado conectado: ${socket.user.username} (ID: ${socket.user.id})`);
        next();
    });
});

// CANAL DE COMUNICACIÓN Y PERSISTENCIA AUTOMÁTICA
io.on('connection', async (socket) => {
    try {
        // Carga los últimos 10 mensajes desde PostgreSQL para este usuario que ingresa
        const history = await MessageModel.getLast10();
        socket.emit('messages-history', history);
    } catch (error) {
        console.error('Error al cargar historial de mensajes:', error);
    }

    // Recepción de evento 'new-message'
    socket.on('new-message', async (data) => {
        if (!data.text || data.text.trim() === '') return;

        try {
            // 1. Guardado automático en PostgreSQL antes de hacer broadcast
            const savedMessage = await MessageModel.create({
                user_id: socket.user.id,
                username: socket.user.username,
                text: data.text
            });

            console.log(`[BD Guardado] ${savedMessage.username}: ${savedMessage.text}`);

            // 2. Retransmisión masiva (Broadcast) a TODOS los clientes con io.emit
            io.emit('new-message', savedMessage);
        } catch (error) {
            console.error('Error al guardar mensaje en la base de datos:', error);
        }
    });

    socket.on('disconnect', () => {
        console.log(`[Socket.IO] Usuario desconectado: ${socket.user?.username}`);
    });
});

//Rutas API REST
//Ruta de autenticación (Login y Registro)
app.use('/auth', authRouter);
//Ruta de productos
app.use('/products', productRouter);
//Ruta de usuarios (stats del usuario autenticado)
app.use('/users', userRouter);

//Configuración servidor
const PORT = process.env.PORT || 3000;
server.listen(PORT, () => console.log(`Servidor activo en puerto ${PORT}`));