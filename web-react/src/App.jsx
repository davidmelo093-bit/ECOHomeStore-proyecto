import { useState, useEffect } from 'react';
import Login from './components/Login';
import Chat from './components/Chat';
import Products from './components/Products';

export default function App() {
    const [token, setToken] = useState(null);
    const [tab, setTab] = useState('products'); // 'products' | 'chat'
    const [username, setUsername] = useState('');

    useEffect(() => {
        // sesión no persistente: sessionStorage borrará al cerrar la pestaña
        const savedToken = sessionStorage.getItem('token');
        const savedUser = sessionStorage.getItem('username');
        if (savedToken) { setToken(savedToken); setUsername(savedUser ?? ''); }
    }, []);

    const handleLoginSuccess = (newToken, newUsername) => {
        sessionStorage.setItem('token', newToken);
        sessionStorage.setItem('username', newUsername ?? '');
        setToken(newToken);
        setUsername(newUsername ?? '');
    };

    const handleLogout = () => {
        sessionStorage.clear();
        setToken(null);
        setUsername('');
    };

    if (!token) {
        return <Login onLoginSuccess={handleLoginSuccess} />;
    }

    return (
        <div>
            {/* Barra de navegación de tabs */}
            <nav style={{ background: '#1976d2', padding: '0 20px', display: 'flex', gap: '4px' }}>
                {['products', 'chat'].map(t => (
                    <button key={t} onClick={() => setTab(t)} style={{
                        background: tab === t ? '#fff' : 'transparent',
                        color: tab === t ? '#1976d2' : '#fff',
                        border: 'none', padding: '12px 20px', cursor: 'pointer', fontWeight: '600',
                    }}>
                        {t === 'products' ? '🛍 Productos' : '💬 Chat'}
                    </button>
                ))}
            </nav>

            {tab === 'products'
                ? <Products token={token} username={username} onLogout={handleLogout} />
                : <Chat token={token} onLogout={handleLogout} />
            }
        </div>
    );
}