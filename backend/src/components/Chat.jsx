import { useState, useEffect } from 'react';
import { io } from 'socket.io-client';

export default function Chat({ token, onLogout }) {
    const [socket, setSocket] = useState(null);
    const [messages, setMessages] = useState([]);
    const [text, setText] = useState('');

    useEffect(() => {
        // 1. Conexión WebSocket pasando el token JWT en 'auth' 
        const newSocket = io('http://localhost:3005', {
            auth: { token }
        });

        // 2. Escuchar el historial inicial de los últimos 10 mensajes desde PostgreSQL
        newSocket.on('messages-history', (history) => {
            setMessages(history);
        });

        // 3. Escuchar nuevos mensajes retransmitidos en tiempo real (Broadcast)
        newSocket.on('new-message', (message) => {
            setMessages((prevMessages) => [...prevMessages, message]);
        });

        setSocket(newSocket);

        // Desconexión limpia al desmontar el componente
        return () => newSocket.disconnect();
    }, [token]);

    const handleSendMessage = (e) => {
        e.preventDefault();
        if (text.trim() && socket) {
            // Emite el evento al backend sin necesidad de mandar usuario, el servidor lo reconoce por su token
            socket.emit('new-message', { text });
            setText('');
        }
    };

    return (
        <div style={{ maxWidth: '600px', margin: '30px auto', padding: '20px', border: '1px solid #ccc', borderRadius: '8px' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                <h3>Chat Interno Corporativo</h3>
                <button onClick={onLogout} style={{ backgroundColor: '#d32f2f', color: 'white', border: 'none', padding: '6px 12px', borderRadius: '4px', cursor: 'pointer' }}>
                    Cerrar Sesión
                </button>
            </div>

            {/* Listado de Mensajes */}
            <div style={{ height: '350px', overflowY: 'auto', border: '1px solid #e0e0e0', padding: '10px', marginBottom: '15px', borderRadius: '4px', background: '#fafafa' }}>
                {messages.length === 0 ? (
                    <p style={{ color: '#888', textAlign: 'center' }}>No hay mensajes aún.</p>
                ) : (
                    messages.map((msg) => (
                        <div key={msg.id} style={{ marginBottom: '10px', padding: '6px 10px', background: '#e8f5e9', borderRadius: '6px' }}>
                            <strong>{msg.username}: </strong>
                            <span>{msg.text}</span>
                            <span style={{ fontSize: '0.75em', color: '#666', marginLeft: '10px' }}>
                                {new Date(msg.created_at).toLocaleTimeString()}
                            </span>
                        </div>
                    ))
                )}
            </div>

            {/* Formulario de Envío */}
            <form onSubmit={handleSendMessage} style={{ display: 'flex', gap: '10px' }}>
                <input 
                    type="text" 
                    value={text} 
                    onChange={(e) => setText(e.target.value)} 
                    placeholder="Escribe un mensaje..." 
                    style={{ flex: 1, padding: '10px', border: '1px solid #ccc', borderRadius: '4px' }}
                />
                <button type="submit" style={{ padding: '10px 20px', backgroundColor: '#1976d2', color: 'white', border: 'none', borderRadius: '4px', cursor: 'pointer' }}>
                    Enviar
                </button>
            </form>
        </div>
    );
}