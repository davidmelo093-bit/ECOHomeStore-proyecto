import { useState, useEffect } from 'react';
import Login from './components/Login';
import Chat from './components/Chat';

export default function App() {
    const [token, setToken] = useState(null);

    useEffect(() => {
        // Al cargar la app, verificamos si existe un token persistido
        const savedToken = localStorage.getItem('token');
        if (savedToken) {
            setToken(savedToken);
        }
    }, []);

    const handleLogout = () => {
        localStorage.removeItem('token'); // Limpieza de token
        setToken(null);
    };

    return (
        <div>
            {!token ? (
                <Login onLoginSuccess={(newToken) => setToken(newToken)} />
            ) : (
                <Chat token={token} onLogout={handleLogout} />
            )}
        </div>
    );
}