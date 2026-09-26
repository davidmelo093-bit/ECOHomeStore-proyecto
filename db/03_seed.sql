-- ==============================================================================
-- 03_seed.sql: Inserción de usuarios iniciales de demostración
-- Contraseñas generadas con bcryptjs (10 rondas de salt):
-- admin@ecohome.com   -> admin123
-- cliente@ecohome.com -> cliente123
-- ==============================================================================

INSERT INTO users (username, email, password_hash, role)
VALUES 
    (
        'adminuser', 
        'admin@ecohome.com', 
        '$2b$10$./THOfyDyMIHPZnXhQau3u3FOj1japxJ80nq/wqK2sZtZOhcuASDu', 
        'admin'
    ),
    (
        'clienteuser', 
        'cliente@ecohome.com', 
        '$2b$10$werhYYh/ovBqlYDeRHPSoO7wEab71wsGYBXnhVtPMtq/XalmTxixq', 
        'cliente'
    )
ON CONFLICT (email) DO NOTHING;

-- Opcional: Inserción de productos de demostración iniciales
INSERT INTO products (name, price, created_by)
SELECT 'Lámpara LED Solar', 29.99, u.id FROM users u WHERE u.email = 'admin@ecohome.com'
UNION ALL
SELECT 'Termo de Acero Inoxidable', 18.50, u.id FROM users u WHERE u.email = 'admin@ecohome.com'
UNION ALL
SELECT 'Organizador de Escritorio Bambú', 24.00, u.id FROM users u WHERE u.email = 'admin@ecohome.com'
ON CONFLICT DO NOTHING;
