import pool from '../config/db.js';

class ProductModel {

  //GET BY ID
  static async getById(id) {
    const query = `
      SELECT p.*, u.username AS created_by_username
      FROM products p
      LEFT JOIN users u ON u.id = p.created_by
      WHERE p.id = $1`;
    const { rows } = await pool.query(query, [id]);
    return rows.length > 0 ? rows[0] : null;
  }

  //GET
  static async getAll() {
    const query = `
      SELECT p.*, u.username AS created_by_username
      FROM products p
      LEFT JOIN users u ON u.id = p.created_by
      ORDER BY p.id ASC`;
    const { rows } = await pool.query(query);
    return rows;
  }

  //POST
  static async create(name, price, created_by) {
    const query = 'INSERT INTO products (name, price, created_by) VALUES ($1, $2, $3) RETURNING *';
    const { rows } = await pool.query(query, [name, price, created_by]);
    return rows[0];
  }

  //PUT
  static async updateAll(id, name, price) {
    const query = `
      UPDATE products 
      SET name = $1, price = $2, updated_at = CURRENT_TIMESTAMP 
      WHERE id = $3 
      RETURNING *`;
    const { rows } = await pool.query(query, [name, price, id]);
    return rows[0]; 
  }

  //PATCH
  static async updatePartial(id, fields) {
    const keys = Object.keys(fields);
    if (keys.length === 0) return null;

    const setClause = keys.map((key, index) => `"${key}" = $${index + 1}`).join(', ');
    const query = `
      UPDATE products 
      SET ${setClause}, updated_at = CURRENT_TIMESTAMP 
      WHERE id = $${keys.length + 1} 
      RETURNING *`;
    
    const values = [...Object.values(fields), id];
    const { rows } = await pool.query(query, values);
    return rows[0];
  }

  //DELETE
  static async delete(id) {
    const query = 'DELETE FROM products WHERE id = $1 RETURNING *';
    const { rows } = await pool.query(query, [id]);
    return rows[0];
  }
}

export default ProductModel;