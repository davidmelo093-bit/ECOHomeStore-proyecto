/**
 * Wrapper de fetch que dispara onUnauthorized() si el servidor responde 401.
 * Devuelve null en ese caso; de lo contrario devuelve el Response normal.
 */
export async function apiFetch(url, options, onUnauthorized) {
    const res = await fetch(url, options);
    if (res.status === 401) { onUnauthorized?.(); return null; }
    return res;
}
