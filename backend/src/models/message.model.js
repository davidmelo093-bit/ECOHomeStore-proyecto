import pool from '../config/db.js';

class MessageModel {
    // 1. Guardar un nuevo mensaje en BD
    static async create({ user_id, username, text }) {
        const query = `
            INSERT INTO messages (user_id, username, text)
            VALUES ($1, $2, $3)
            RETURNING *;
        `;
        const values = [user_id, username, text];
        const { rows } = await pool.query(query, values);
        return rows[0];
    }

    // 2. Obtener los últimos 10 mensajes para el historial inicial
    static async getLast10() {
        const query = `
            SELECT 
            id, user_id, username, text, created_at 
            FROM messages 
            ORDER BY id DESC 
            LIMIT 10;
        `;
        const { rows } = await pool.query(query);
        return rows.reverse();
    }
}

export default MessageModel;


