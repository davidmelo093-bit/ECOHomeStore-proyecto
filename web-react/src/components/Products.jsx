import { useState, useEffect, useCallback } from 'react';
import { apiFetch } from '../utils/apiFetch';
import { API_URL } from '../config';

const API = API_URL;

export default function Products({ token, username, onLogout }) {
    const [products, setProducts] = useState([]);
    const [stats, setStats] = useState({ username, product_count: 0 });
    const [newName, setNewName] = useState('');
    const [newPrice, setNewPrice] = useState('');
    const [error, setError] = useState('');
    const [loading, setLoading] = useState(true);

    const authHeaders = { Authorization: `Bearer ${token}`, 'Content-Type': 'application/json' };

    const fetchProducts = useCallback(async () => {
        setLoading(true);
        try {
            const res = await fetch(`${API}/products`);
            if (!res.ok) throw new Error(`Error ${res.status} al cargar productos`);
            setProducts(await res.json());
        } catch (err) {
            setError(err.message);
        } finally {
            setLoading(false);
        }
    }, []);

    const fetchStats = useCallback(async () => {
        try {
            const res = await apiFetch(`${API}/users/me/stats`, { headers: authHeaders }, onLogout);
            if (res?.ok) setStats(await res.json());
        } catch {
            // Stats no críticos: falla silenciosa, el contador queda en 0
        }
    }, [token]); // eslint-disable-line react-hooks/exhaustive-deps

    useEffect(() => {
        fetchProducts();
        fetchStats();
    }, [fetchProducts, fetchStats]);

    const handleCreate = async (e) => {
        e.preventDefault();
        setError('');
        try {
            const res = await apiFetch(`${API}/products`, {
                method: 'POST',
                headers: authHeaders,
                body: JSON.stringify({ name: newName, price: Number(newPrice) }),
            }, onLogout);
            if (!res) return; // 401 → onLogout ya fue llamado
            const data = await res.json();
            if (!res.ok) { setError(data.error || 'Error al crear'); return; }
            setProducts(prev => [...prev, data]);
            setStats(prev => ({ ...prev, product_count: prev.product_count + 1 })); // reactividad local
            setNewName(''); setNewPrice('');
        } catch (err) {
            setError('No se pudo conectar con el servidor');
        }
    };

    const [editingId, setEditingId] = useState(null);
    const [editName, setEditName] = useState('');
    const [editPrice, setEditPrice] = useState('');

    const startEdit = (p) => {
        setEditingId(p.id);
        setEditName(p.name);
        setEditPrice(p.price);
    };

    const cancelEdit = () => {
        setEditingId(null);
        setEditName('');
        setEditPrice('');
    };

    const handleUpdate = async (id) => {
        setError('');
        try {
            const res = await apiFetch(`${API}/products/${id}`, {
                method: 'PUT',
                headers: authHeaders,
                body: JSON.stringify({ name: editName, price: Number(editPrice) }),
            }, onLogout);
            if (!res) return;
            const data = await res.json();
            if (!res.ok) { setError(data.error || 'Error al actualizar'); return; }
            setProducts(prev => prev.map(p => p.id === id ? { ...p, name: editName, price: Number(editPrice) } : p));
            cancelEdit();
        } catch (err) {
            setError('No se pudo conectar con el servidor');
        }
    };

    const handleDelete = async (id) => {
        if (!window.confirm('¿Seguro de eliminar este producto?')) return;
        setError('');
        try {
            const res = await apiFetch(`${API}/products/${id}`, {
                method: 'DELETE',
                headers: authHeaders,
            }, onLogout);
            if (!res) return;
            if (!res.ok) {
                const data = await res.json().catch(() => ({}));
                setError(data.error || 'Error al eliminar');
                return;
            }
            setProducts(prev => prev.filter(p => p.id !== id));
            setStats(prev => ({ ...prev, product_count: Math.max(0, prev.product_count - 1) }));
        } catch (err) {
            setError('No se pudo conectar con el servidor');
        }
    };

    return (
        <div style={{ maxWidth: '800px', margin: '30px auto', padding: '20px', fontFamily: 'sans-serif' }}>
            {/* Header con contador */}
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '16px' }}>
                <h2 style={{ margin: 0 }}>
                    Catálogo — <span style={{ color: '#1976d2' }}>{stats.username} ({stats.product_count})</span>
                </h2>
                <button onClick={onLogout} style={{ background: '#d32f2f', color: '#fff', border: 'none', padding: '6px 14px', borderRadius: '4px', cursor: 'pointer' }}>
                    Cerrar sesión
                </button>
            </div>

            {/* Formulario crear producto (solo admins verán éxito) */}
            <form onSubmit={handleCreate} style={{ display: 'flex', gap: '8px', marginBottom: '16px' }}>
                <input value={newName} onChange={e => setNewName(e.target.value)} placeholder="Nombre del producto" required
                    style={{ flex: 2, padding: '8px', border: '1px solid #ccc', borderRadius: '4px' }} />
                <input value={newPrice} onChange={e => setNewPrice(e.target.value)} placeholder="Precio" type="number" min="0.01" step="0.01" required
                    style={{ flex: 1, padding: '8px', border: '1px solid #ccc', borderRadius: '4px' }} />
                <button type="submit" style={{ padding: '8px 16px', background: '#2e7d32', color: '#fff', border: 'none', borderRadius: '4px', cursor: 'pointer' }}>
                    Agregar
                </button>
            </form>
            {error && <p style={{ color: 'red', margin: '0 0 12px' }}>{error}</p>}

            {/* Tabla de productos */}
            {loading ? <p>Cargando...</p> : (
                <table style={{ width: '100%', borderCollapse: 'collapse' }}>
                    <thead>
                        <tr style={{ background: '#f5f5f5' }}>
                            <th style={th}>#</th>
                            <th style={th}>Nombre</th>
                            <th style={th}>Precio</th>
                            <th style={th}>Creado por</th>
                            <th style={th}>Acciones</th>
                        </tr>
                    </thead>
                    <tbody>
                        {products.map((p, i) => (
                            <tr key={p.id} style={{ borderBottom: '1px solid #e0e0e0' }}>
                                <td style={td}>{i + 1}</td>
                                <td style={td}>
                                    {editingId === p.id ? (
                                        <input value={editName} onChange={e => setEditName(e.target.value)} style={{ padding: '4px', width: '90%' }} />
                                    ) : p.name}
                                </td>
                                <td style={td}>
                                    {editingId === p.id ? (
                                        <input type="number" step="0.01" value={editPrice} onChange={e => setEditPrice(e.target.value)} style={{ padding: '4px', width: '80px' }} />
                                    ) : `$${Number(p.price).toFixed(2)}`}
                                </td>
                                <td style={{ ...td, color: '#555', fontStyle: 'italic' }}>
                                    {p.created_by_username ?? '—'}
                                </td>
                                <td style={td}>
                                    {editingId === p.id ? (
                                        <div style={{ display: 'flex', gap: '4px' }}>
                                            <button onClick={() => handleUpdate(p.id)} style={btnSuccess}>Guardar</button>
                                            <button onClick={cancelEdit} style={btnSecondary}>Cancelar</button>
                                        </div>
                                    ) : (
                                        <div style={{ display: 'flex', gap: '4px' }}>
                                            <button onClick={() => startEdit(p)} style={btnPrimary}>Editar</button>
                                            <button onClick={() => handleDelete(p.id)} style={btnDanger}>Eliminar</button>
                                        </div>
                                    )}
                                </td>
                            </tr>
                        ))}
                    </tbody>
                </table>
            )}
        </div>
    );
}

const th = { padding: '10px 12px', textAlign: 'left', fontWeight: '600' };
const td = { padding: '10px 12px' };
const btnPrimary = { background: '#1976d2', color: '#fff', border: 'none', padding: '4px 8px', borderRadius: '4px', cursor: 'pointer', fontSize: '12px' };
const btnSuccess = { background: '#2e7d32', color: '#fff', border: 'none', padding: '4px 8px', borderRadius: '4px', cursor: 'pointer', fontSize: '12px' };
const btnDanger = { background: '#d32f2f', color: '#fff', border: 'none', padding: '4px 8px', borderRadius: '4px', cursor: 'pointer', fontSize: '12px' };
const btnSecondary = { background: '#757575', color: '#fff', border: 'none', padding: '4px 8px', borderRadius: '4px', cursor: 'pointer', fontSize: '12px' };
