import ProductModel from '../models/product.model.js';

// 1. GET /products/ - Obtener todos los productos
export const getAll = async (req, res) => {
    try {
        const products = await ProductModel.getAll();
        res.json(products);
    } catch (error) {
        res.status(500).json({ error: 'Error al obtener los productos' });
    }
};

// 2. GET /products/:id - Obtener un producto por ID
export const getById = async (req, res) => {
    try {
        const { id } = req.params;
        const product = await ProductModel.getById(id);

        if (!product) {
            return res.status(404).json({ error: 'Producto no encontrado' });
        }
        res.json(Array.isArray(product) ? product[0] : product);
    } catch (error) {
        res.status(500).json({ error: 'Error al obtener el producto' });
    }
};

// 3. POST /products/ - Crear un nuevo producto (Con autorización)
export const create = async (req, res) => {
    try {
        const { name, price } = req.body;

        if (!name || price === undefined) {
            return res.status(400).json({ error: 'El nombre y el precio son obligatorios' });
        }

        if (Number(price) < 0) {
            return res.status(400).json({ error: 'El precio no puede ser un valor negativo' });
        }

        if (Number(price) === 0) {
            return res.status(400).json({ error: 'El precio no puede ser cero' });
        }

        const created_by = req.user?.id; // Inyectado por authJWT middleware
        if (!created_by) {
            return res.status(401).json({ error: 'No se pudo identificar al usuario autenticado' });
        }

        const newProduct = await ProductModel.create(name, price, created_by);
        res.status(201).json(Array.isArray(newProduct) ? newProduct[0] : newProduct);

    } catch (error) {
        console.error('[POST /products] Error al crear producto:', error.message);
        res.status(500).json({
            error: 'Error al crear el producto',
            ...(process.env.NODE_ENV !== 'production' && { detail: error.message })
        });
    }
};


// 4. PUT /products/:id - Reemplazo total de un producto (Con autorización)
export const update = async (req, res) => {
    try {
        const { id } = req.params;
        const { name, price } = req.body;

        if (!name || price === undefined) {
            return res.status(400).json({ error: 'Los campos name y price son obligatorios' });
        }

        if (Number(price) < 0) {
            return res.status(400).json({ error: 'El precio no puede ser un valor negativo' });
        }

        if (Number(price) === 0) {
            return res.status(400).json({ error: 'El precio no puede ser cero' });
        }

        const updatedProduct = await ProductModel.updateAll(id, name, price);

        if (!updatedProduct || updatedProduct.length === 0) {
            return res.status(404).json({ error: 'Producto no encontrado' });
        }

        const productObject = Array.isArray(updatedProduct) ? updatedProduct[0] : updatedProduct;
        res.json(productObject);

    } catch (error) {
        res.status(500).json({ error: 'Error al actualizar el producto' });
    }
};

// 5. PATCH /products/:id - Actualización parcial de un producto (Con autorización)
export const updatePartial = async (req, res) => {
    try {
        const { id } = req.params;
        const fields = req.body;

        if (!fields || Object.keys(fields).length === 0) {
            return res.status(400).json({ error: 'Debe proporcionar al menos un campo para actualizar' });
        }

        if (Number(fields.price) < 0) {
            return res.status(400).json({ error: 'El precio no puede ser un valor negativo' });
        }

        if (Number(fields.price) === 0) {
            return res.status(400).json({ error: 'El precio no puede ser cero' });
        }

        const updatedProduct = await ProductModel.updatePartial(id, fields);

        if (!updatedProduct || updatedProduct.length === 0) {
            return res.status(404).json({ error: 'Producto no encontrado' });
        }

        const productObject = Array.isArray(updatedProduct) ? updatedProduct[0] : updatedProduct;
        res.json(productObject);

    } catch (error) {
        res.status(500).json({ error: 'Error al actualizar el producto' });
    }
};

// 6. DELETE /products/:id - Eliminar un producto (Con autorización)
export const deleteProduct = async (req, res) => {
    try {
        const { id } = req.params;
        const deletedProduct = await ProductModel.delete(id);

        if (!deletedProduct) {
            return res.status(404).json({ error: 'Producto no encontrado' });
        }

        res.json({
            message: 'Producto eliminado con éxito',
            product: deletedProduct
        });
    } catch (error) {
        res.status(500).json({ error: 'Error al eliminar el producto' });
    }
};

export { deleteProduct as delete };
