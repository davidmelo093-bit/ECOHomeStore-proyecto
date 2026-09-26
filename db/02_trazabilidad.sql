-- ==============================================================================
-- 02_trazabilidad.sql: Alteración de tabla products para trazabilidad de autor
-- Vincula la clave foránea created_by con users(id)
-- ==============================================================================

ALTER TABLE products 
ADD COLUMN IF NOT EXISTS created_by INTEGER REFERENCES users(id) ON DELETE SET NULL;

COMMENT ON COLUMN products.created_by IS 'ID del usuario administrador creador del producto';
